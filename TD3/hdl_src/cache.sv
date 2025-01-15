module cache #(
    localparam ByteOffsetBits = 4,
    localparam IndexBits = 6,
    localparam TagBits = 22,
    localparam NrWordsPerLine = 4,
    localparam NrLines = 64,
    localparam LineSize = 32 * NrWordsPerLine
) (
    input logic clk_i,
    input logic rstn_i,
    input logic [31:0] addr_i,
    // Read port
    input logic read_en_i,
    output logic read_valid_o,
    output logic [31:0] read_word_o,
    // Memory
    output logic [31:0] mem_addr_o,
    // Memory read port
    output logic mem_read_en_o,
    input logic mem_read_valid_i,
    input logic [LineSize-1:0] mem_read_data_i
);

    // Registres pour stocker les données du cache
    logic [NrLines-1:0] valid_lines;
    logic [NrLines-1:0][TagBits-1:0] tags;
    logic [NrLines-1:0][LineSize-1:0] data_lines;

    // Découpage de l'adresse
    logic [TagBits-1:0] tag;
    logic [IndexBits-1:0] index;
    logic [ByteOffsetBits-1:0] offset;

    assign tag = addr_i[31:32-TagBits];
    assign index = addr_i[32-TagBits-1:ByteOffsetBits];
    assign offset = addr_i[ByteOffsetBits-1:0];

    // Signal de hit
    logic is_hit;

    // Logique de détermination du hit
    always_comb begin
        // Par défaut, pas de hit
        is_hit = 1'b0;
        
        // Vérification du hit
        if (read_en_i) begin
            // Vérifier si la ligne est valide ET que le tag correspond
            if (valid_lines[index] && (tags[index] == tag)) begin
                is_hit = 1'b1;
            end
        end
    end

    // Logique de lecture du mot lors d'un hit
    always_comb begin
        // Valeurs par défaut
        read_valid_o = 1'b0;
        read_word_o = 32'b0;
        
        // Si c'est un hit et une lecture active
        if (is_hit && read_en_i) begin
            // Sélection du mot dans la ligne en fonction de l'offset
            case (offset[ByteOffsetBits-1:2])  // Division par 4 pour trouver l'index du mot
                2'b00: read_word_o = data_lines[index][31:0];
                2'b01: read_word_o = data_lines[index][63:32];
                2'b10: read_word_o = data_lines[index][95:64];
                2'b11: read_word_o = data_lines[index][127:96];
            endcase
            
            // Confirmer la validité de la lecture
            read_valid_o = 1'b1;
        end
    end

    // Logique de gestion des miss
    logic is_waiting_for_mem;
    logic [31:0] stored_addr;

    // Requête mémoire en cas de miss
    always_comb begin
        // Valeurs par défaut
        mem_read_en_o = 1'b0;
        mem_addr_o = 32'b0;

        // Si miss et pas déjà en attente de mémoire
        if (!is_hit && read_en_i && !is_waiting_for_mem) begin
            // Alignement de l'adresse sur la ligne de cache
            mem_addr_o = {tag, index, {ByteOffsetBits{1'b0}}};
            mem_read_en_o = 1'b1;
        end
    end

    // Gestion de la réponse mémoire
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            // Réinitialisation
            valid_lines <= '0;
            is_waiting_for_mem <= 1'b0;
            stored_addr <= 32'b0;
        end else begin
            // Logique de réception des données mémoire
            if (mem_read_valid_i) begin
                // Stocker les données
                data_lines[index] <= mem_read_data_i;
                
                // Marquer la ligne comme valide
                valid_lines[index] <= 1'b1;
                
                // Mettre à jour le tag
                tags[index] <= tag;
                
                // Réinitialiser l'état d'attente
                is_waiting_for_mem <= 1'b0;
            end else if (!is_hit && read_en_i) begin
                // Passer en attente de mémoire
                is_waiting_for_mem <= 1'b1;
                stored_addr <= addr_i;
            end
        end
    end

endmodule
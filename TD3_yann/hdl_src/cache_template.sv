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

    // Structure du cache
    typedef struct {
        logic valid;                // 1 bit pour valider la ligne
        logic [TagBits-1:0] tag;    // Le tag associé à l'adresse
        logic [LineSize-1:0] data;  // Données de la ligne
    } cache_line_t;

    cache_line_t cache_mem[NrLines]; // Mémoire du cache
    // Index et tag extraits de l'adresse
    logic [IndexBits-1:0] index;
    logic [TagBits-1:0] tag;
    assign index = addr_i[ByteOffsetBits + IndexBits - 1:ByteOffsetBits];
    assign tag = addr_i[31:32 - TagBits];

    // Ligne courante
    cache_line_t current_line;

    // Signaux internes
    logic hit;
    logic [31:0] word_offset;

    // Réinitialisation
    always_ff @(posedge clk_i or negedge rstn_i) begin

	
        if (!rstn_i) begin
            // Marquer toutes les lignes comme invalides
		hit = 0;
            for (int i = 0; i < NrLines; i++) begin
                cache_mem[i].valid <= 0;
		cache_mem[i].tag <= {TagBits{1'b0}};     
        	cache_mem[i].data <= {LineSize{1'b0}}; 
            end

        end else begin
            // Lecture de la mémoire
            if (read_en_i) begin
                current_line = cache_mem[index];
                hit = current_line.valid && (current_line.tag == tag);

                if (hit) begin
                    // Lecture réussie dans le cache
                    word_offset = addr_i[ByteOffsetBits-1:2];
                    read_word_o <= current_line.data[word_offset * 32 +: 32];
                    read_valid_o <= 1;
                end else begin
                    // Miss dans le cache, initier une lecture mémoire
                    mem_read_en_o <= 1;
		    read_valid_o <= 0;
		    
                    mem_addr_o <= {tag, index, {ByteOffsetBits{1'b0}}};
                end
            end

            // Réception des données mémoire
            if (mem_read_valid_i) begin
                // Mise à jour de la ligne de cache
                cache_mem[index].data <= mem_read_data_i;
                cache_mem[index].tag <= tag;
                cache_mem[index].valid <= 1;
		mem_read_en_o <= 1'b0;
            end
        end
    end
endmodule


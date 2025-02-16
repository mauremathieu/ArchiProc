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

    // Déclarations des structures du cache
    typedef struct {
        logic valid;
        logic [TagBits-1:0] tag;
        logic [LineSize-1:0] data;
    } cache_line_t;

    // Cache avec 2 voies par ligne
    cache_line_t cache [NrLines][2]; // 2 voies par ligne

    // LRU bits pour chaque ligne (0 pour voie 0, 1 pour voie 1)
    logic [NrLines-1:0] lru_bits;

    // Adresses décomposées
    logic [ByteOffsetBits-1:0] byte_offset;
    logic [IndexBits-1:0] cache_index;
    logic [TagBits-1:0] cache_tag;

    assign byte_offset = addr_i[ByteOffsetBits-1:0];
    assign cache_index = addr_i[ByteOffsetBits + IndexBits - 1:ByteOffsetBits];
    assign cache_tag = addr_i[31:ByteOffsetBits + IndexBits];

    // Détection de hit pour chaque voie
    logic hit_0, hit_1;
    logic [31:0] output_word_0, output_word_1;

    assign hit_0 = cache[cache_index][0].valid && (cache[cache_index][0].tag == cache_tag);
    assign hit_1 = cache[cache_index][1].valid && (cache[cache_index][1].tag == cache_tag);

    // Sortie du mot en cas de hit
    assign output_word_0 = cache[cache_index][0].data[byte_offset[ByteOffsetBits-1:2] * 32 +: 32];
    assign output_word_1 = cache[cache_index][1].data[byte_offset[ByteOffsetBits-1:2] * 32 +: 32];

    // Sélection du mot de sortie en cas de hit
    assign read_word_o = hit_0 ? output_word_0 : (hit_1 ? output_word_1 : 32'b0);
    assign read_valid_o = hit_0 || hit_1;

    // Gestion des lectures manquées
    logic [31:0] memory_address;
    logic memory_read_enable;

    assign memory_address = {cache_tag, cache_index, {ByteOffsetBits{1'b0}}};
    assign memory_read_enable = read_en_i && !(hit_0 || hit_1);

    assign mem_addr_o = memory_address;
    assign mem_read_en_o = memory_read_enable;

    // Mise à jour du cache dans un bloc combinatoire séparé
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            for (int i = 0; i < NrLines; i++) begin
                cache[i][0].valid <= 1'b0;
                cache[i][1].valid <= 1'b0;
            end
            lru_bits <= 0;
        end else if (mem_read_valid_i) begin
            // Mise à jour du cache
            if (lru_bits[cache_index] == 0) begin
                cache[cache_index][0].data <= mem_read_data_i;
                cache[cache_index][0].tag <= cache_tag;
                cache[cache_index][0].valid <= 1'b1;
            end else begin
                cache[cache_index][1].data <= mem_read_data_i;
                cache[cache_index][1].tag <= cache_tag;
                cache[cache_index][1].valid <= 1'b1;
            end

            // Mise à jour du LRU
            lru_bits[cache_index] <= ~lru_bits[cache_index];
        end
    end

endmodule
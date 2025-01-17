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

    cache_line_t cache [NrLines];

    // Adresses décomposées
    logic [ByteOffsetBits-1:0] byte_offset;
    logic [IndexBits-1:0] cache_index;
    logic [TagBits-1:0] cache_tag;

    assign byte_offset = addr_i[ByteOffsetBits-1:0];
    assign cache_index = addr_i[ByteOffsetBits + IndexBits - 1:ByteOffsetBits];
    assign cache_tag = addr_i[31:ByteOffsetBits + IndexBits];

    // Détection de hit
    logic hit_detected;
    logic [31:0] output_word;

    assign hit_detected = cache[cache_index].valid && (cache[cache_index].tag == cache_tag);
    assign output_word = cache[cache_index].data[byte_offset[ByteOffsetBits-1:2] * 32 +: 32];

    assign read_word_o = hit_detected ? output_word : 32'b0;
    assign read_valid_o = hit_detected;

    // Gestion des lectures manquées
    logic [31:0] memory_address;
    logic memory_read_enable;

    assign memory_address = {cache_tag, cache_index, {ByteOffsetBits{1'b0}}};
    assign memory_read_enable = read_en_i && !hit_detected;

    assign mem_addr_o = memory_address;
    assign mem_read_en_o = memory_read_enable;

    // Mise à jour du cache dans un bloc combinatoire séparé
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            // Réinitialisation avec des boucles combinées
            for (int i = 0; i < NrLines; i++) begin
                cache[i].valid <= 1'b0;
            end
        end else if (mem_read_valid_i) begin
            // Mise à jour directe du cache
            cache[cache_index].data <= mem_read_data_i;
            cache[cache_index].tag <= cache_tag;
            cache[cache_index].valid <= 1'b1;
        end
    end

endmodule
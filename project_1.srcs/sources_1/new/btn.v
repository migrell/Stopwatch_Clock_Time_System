module btn_debounce(
    input clk,
    input reset,
    input i_btn,
    output o_btn
);
    //state
    reg [7:0] q_reg;
    reg edge_detect;
    wire btn_debounce;
    
    //1khz clk 
    reg [16:0] counter;  // 더 넓은 카운터 비트 범위
    reg r_1khz;
    
    // 클럭 분주기 (더 안정적으로)
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            counter <= 0;
            r_1khz <= 0;
        end else begin
            if(counter >= 100_000 - 1) begin // 1kHz
                counter <= 0;
                r_1khz <= 1'b1;
            end else begin
                counter <= counter + 1;
                r_1khz <= 1'b0;
            end
        end
    end
    
    // 시프트 레지스터 로직
    always @(posedge r_1khz or posedge reset) begin
        if(reset) begin
            q_reg <= 0;
        end else begin
            q_reg <= {i_btn, q_reg[7:1]};  // 올바른 시프트 연산
        end  
    end
    
    // 8개 비트 모두 1인지 확인
    assign btn_debounce = &q_reg;
    
    // 엣지 감지기
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            edge_detect <= 1'b0;
        end else begin
            edge_detect <= btn_debounce;
        end
    end
    
    // 상승 엣지 출력
    assign o_btn = btn_debounce & (~edge_detect);
endmodule
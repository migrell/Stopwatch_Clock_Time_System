`timescale 1ns / 1ps

module clock(
    input clk,
    input reset,
    input btn_sec,
    input btn_min,
    input btn_hour,
    input enable,
    output o_1hz,
    output reg [6:0] o_msec,
    output reg [5:0] o_sec, o_min,
    output reg [4:0] o_hour
);
    // 1Hz 신호 생성 (1초마다 펄스)
    reg [26:0] clk_counter;
    
    // 100Hz 신호 생성 (msec 용)
    reg [19:0] msec_counter;
    wire msec_pulse;
    
    // 1Hz 클럭 생성
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_counter <= 0;
        end else begin
            if (clk_counter >= 100_000_000 - 1) begin  // 100MHz 클럭에서 1초
                clk_counter <= 0;
            end else begin
                clk_counter <= clk_counter + 1;
            end
        end
    end
    
    assign o_1hz = (clk_counter == 100_000_000 - 1);
    
    // 100Hz 클럭 생성 (msec 계산용)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            msec_counter <= 0;
        end else begin
            if (msec_counter >= 1_000_000 - 1) begin  // 100MHz 클럭에서 10ms
                msec_counter <= 0;
            end else begin
                msec_counter <= msec_counter + 1;
            end
        end
    end
    
    assign msec_pulse = (msec_counter == 1_000_000 - 1);
    
    // 시계 카운팅 로직
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            o_msec <= 0;
            o_sec <= 0;
            o_min <= 0;
            o_hour <= 0;
        end
        
        else if (enable) begin
            // msec 카운팅 (100Hz로 작동)
            if (msec_pulse) begin
                if (o_msec >= 99) begin
                    o_msec <= 0;
                end else begin
                    o_msec <= o_msec + 1;
                end
            end
            
            // 시 버튼이 눌렸을 때
            if (btn_hour) begin
                if (o_hour >= 23) begin
                    o_hour <= 0;
                end else begin
                    o_hour <= o_hour + 1;
                end
            end
            
            // 분 버튼이 눌렸을 때
            else if (btn_min) begin
                if (o_min >= 59) begin
                    o_min <= 0;
                end else begin
                    o_min <= o_min + 1;
                end
            end
            
            // 초 버튼이 눌렸을 때
            else if (btn_sec) begin
                if (o_sec >= 59) begin
                    o_sec <= 0;
                end else begin
                    o_sec <= o_sec + 1;
                end
            end
            
            // 자동 카운팅 (버튼이 눌리지 않았을 때)
            else if (o_1hz) begin
                // 초 증가
                o_msec <= 0; // 새로운 초가It  시작될 때 밀리초 초기화
                
                if (o_sec >= 59) begin
                    o_sec <= 0;
                    // 분 증가
                    if (o_min >= 59) begin
                        o_min <= 0;
                        // 시간 증가
                        if (o_hour >= 23) begin
                            o_hour <= 0;
                        end else begin
                            o_hour <= o_hour + 1;
                        end
                    end else begin
                        o_min <= o_min + 1;
                    end
                end else begin
                    o_sec <= o_sec + 1;
                end
            end
        end
    end
endmodule
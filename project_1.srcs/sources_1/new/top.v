`timescale 1ns / 1ps

module top_stopwatch(
    input clk,
    input reset,
    input btn_run,        // 좌측 버튼 - 스톱워치 실행/정지/시 설정
    input btn_clear,      // 우측 버튼 - 스톱워치 초기화
    input btn_sec,        // 아래쪽 버튼 - 초 설정 (시계 모드)
    input btn_min,        // 위쪽 버튼 - 분 설정 (시계 모드)
    input [1:0] sw,       // 스위치 배열
    output [3:0] fnd_comm,
    output [7:0] fnd_font,
    output [3:0] led
);
    // 디바운싱된 버튼 신호들
    wire w_btn_run, w_btn_clear, w_btn_min, w_btn_sec;
    // 모드별 버튼 분기
    wire w_btn_hour;
    
    // FSM 신호들
    wire [1:0] current_state;
    wire is_clock_mode, sw2, sw3;
    
    // 스톱워치 제어 신호
    wire w_run, w_clear;
    
    // 시간 데이터 신호들 (스톱워치와 시계)
    wire [6:0] s_msec, c_msec, disp_msec;
    wire [5:0] s_sec, s_min, c_sec, c_min, disp_sec, disp_min;
    wire [4:0] s_hour, c_hour, disp_hour;
    
    // 모드에 따른 버튼 기능 분기
    assign w_btn_hour = w_btn_run & sw[1];  // 시계 모드에서 시간 설정 기능
    
    // LED 출력 할당
    assign led[0] = current_state[0];  // 현재 상태 하위 비트
    assign led[1] = current_state[1];  // 현재 상태 상위 비트
    assign led[2] = w_run;             // 스톱워치 실행 중일 때 켜짐
    assign led[3] = is_clock_mode;     // 시계 모드일 때 켜짐
    
    // 버튼 디바운싱 모듈들
    btn_debounce U_Btn_DB_RUN(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_run),
        .o_btn(w_btn_run)
    );

    btn_debounce U_Btn_DB_CLEAR(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_clear),
        .o_btn(w_btn_clear)
    );

    btn_debounce U_Btn_DB_SEC(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_sec),
        .o_btn(w_btn_sec)
    );

    btn_debounce U_Btn_DB_MIN(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_min),
        .o_btn(w_btn_min)
    );
    
    // FSM 컨트롤러
    fsm_controller U_FSM(
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .btn_run(w_btn_run),
        .sw_mode_in(sw[1]),
        .current_state(current_state),
        .is_clock_mode(is_clock_mode),
        .sw2(sw2),
        .sw3(sw3)
    );
    
    // 스톱워치 제어 유닛
    stopwatch_cu U_STOPWATCH_CU(
        .clk(clk),
        .reset(reset),
        .i_btn_run(w_btn_run & ~sw[1]),  // 스톱워치 모드에서만 동작
        .i_btn_clear(w_btn_clear & ~sw[1]),
        .o_run(w_run),
        .o_clear(w_clear)
    );
    
    // 스톱워치 데이터 패스
    stopwatch_dp U_STOPWATCH_DP(
        .clk(clk),
        .reset(reset),
        .run(w_run),
        .clear(w_clear),
        .msec(s_msec),
        .sec(s_sec),
        .min(s_min),
        .hour(s_hour)
        );
    // top_stopwatch 모듈 내부에서:
clock U_CLOCK(
    .clk(clk),
    .reset(reset),
    .btn_sec(w_btn_sec & sw[1]),  // 시계 모드에서만 동작
    .btn_min(w_btn_min & sw[1]),  // 시계 모드에서만 동작
    .btn_hour(w_btn_hour),        // 시계 모드에서만 동작
    .enable(sw[1]),              // 시계 모드에서만 동작
    .o_1hz(),
    .o_msec(c_msec),
    .o_sec(c_sec),
    .o_min(c_min),
    .o_hour(c_hour)
);
        
    // 디스플레이 멀티플렉서
    display_mux U_DISPLAY_MUX(
        .sw_mode(sw[1]),
        .current_state(current_state),
        .sw_msec(s_msec),
        .sw_sec(s_sec),
        .sw_min(s_min),
        .sw_hour(s_hour),
        .clk_msec(c_msec),
        .clk_sec(c_sec),
        .clk_min(c_min),
        .clk_hour(c_hour),
        .o_msec(disp_msec),
        .o_sec(disp_sec),
        .o_min(disp_min),
        .o_hour(disp_hour)
    );
    
    // FND 컨트롤러
    fnd_controller U_FND_CTRL(
        .clk(clk),
        .reset(reset),
        .sw_mode(sw[0]),
        .sw(sw),
        .current_state(current_state),
        .msec(disp_msec),
        .sec(disp_sec),
        .min(disp_min),
        .hour(disp_hour),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm)
    );
    
endmodule
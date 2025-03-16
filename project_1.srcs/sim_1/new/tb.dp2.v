`timescale 1ns/1ps

module tb_stopwatch_dp();
    // 테스트벤치 신호 선언
    reg clk;
    reg reset;
    reg run;
    reg clear;
    
    wire [6:0] msec;
    wire [6:0] sec;
    wire [6:0] min;
    wire [4:0] hour;
    
    // clk_div_100 모듈을 직접 정의 (시뮬레이션을 빠르게 하기 위함)
    // 원래 모듈을 수정하지 않고 여기서 새로 정의
    reg tick_100;
    
    // 테스트할 모듈 인스턴스화
    stopwatch_dp uut (
        .clk(clk),
        .reset(reset),
        .run(run),
        .clear(clear),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );
    
    // 보다 빠른 클럭 생성 (1ns 주기)
    initial begin
        clk = 0;
        forever #0.5 clk = ~clk; // 1ns 주기 (1GHz)
    end
    
    // 빠른 시뮬레이션을 위한 tick_100 생성 (원래 모듈의 분주비를 오버라이드)
    // 실제 구현에서는 이 부분이 필요 없음
    initial begin
        // clk_div_100 모듈 내부 신호에 직접 접근하여 오버라이드
        force uut.u_clk_div_100.o_clk = tick_100;
        
        tick_100 = 0;
        // 매우 짧은 주기로 tick 신호 생성 (실제보다 빠르게)
        forever #5 tick_100 = ~tick_100;
    end
    
    // 변화 모니터링
    initial begin
        $monitor("Time=%0t | run=%b | clear=%b | hour=%d | min=%d | sec=%d | msec=%d", 
                 $time, run, clear, hour, min, sec, msec);
    end
    
    // 테스트 시나리오
    initial begin
        // 초기화
        reset = 1;
        run = 0;
        clear = 0;
        
        // 리셋 해제
        #20 reset = 0;
        
        // 테스트 케이스 1: 타이머 실행 (run=1)
        #20 run = 1;
        
        // 충분한 시간 동안 실행 (msec, sec, min, hour 값이 증가하는지 확인)
        #10000;
        
        // 테스트 케이스 2: clear 신호로 초기화 (clear=1)
        clear = 1;
        #20;
        clear = 0;
        #50;
        
        // 테스트 케이스 3: 초기화 후 다시 실행
        run = 1;
        #5000;
        
        // 테스트 케이스 4: 타이머 정지 (run=0)
        run = 0;
        #200;
        
        // 시뮬레이션 종료
        #100 $finish;
    end
    
    // 파형 생성
    initial begin
        $dumpfile("tb_stopwatch_dp.vcd");
        $dumpvars(0, tb_stopwatch_dp);
    end
    
endmodule
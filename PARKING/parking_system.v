module parking_system
  ( 
  input clk,reset_n,
 input sensor_entrance, sensor_exit, 
 input [1:0] password,
 output wire GREEN_LED,RED_LED
    );
 parameter IDLE = 3'b000, WAIT_PASSWORD = 3'b001, WRONG_PASS = 3'b010, RIGHT_PASS = 3'b011,STOP = 3'b100;
 reg[2:0] current_state, next_state;
 reg[31:0] counter_wait;
 reg red_tmp,green_tmp;

      always @(posedge clk or negedge reset_n)
       begin
           if(~reset_n) 
            current_state = IDLE;
           else
            current_state = next_state;
       end
 
      always @(posedge clk or negedge reset_n) 
      begin
         if(~reset_n) 
           counter_wait <= 0;
         else if(current_state==WAIT_PASSWORD)
           counter_wait <= counter_wait + 1;
         else 
            counter_wait <= 0;
       end
 
 always @(*)
         begin
         case(current_state)
               IDLE: begin
                      if(sensor_entrance == 1)
                       next_state = WAIT_PASSWORD;
                     else
                       next_state = IDLE;
                     end
     WAIT_PASSWORD: begin
                    if(counter_wait <= 3)
                      next_state = WAIT_PASSWORD;
                    else 
                     begin
                      if((password==2'b01))
                       next_state = RIGHT_PASS;
                      else
                       next_state = WRONG_PASS;
                    end
                    end
      WRONG_PASS: begin
                   if((password==2'b01))
                      next_state = RIGHT_PASS;
                  else
                      next_state = WRONG_PASS;
                  end
      RIGHT_PASS: begin
                   if(sensor_entrance==1 && sensor_exit == 1)
                     next_state = STOP;
                   else if(sensor_exit == 1)
                     next_state = IDLE;
                  else
                     next_state = RIGHT_PASS;
                 end
            STOP: begin
                     if((password==2'b01))
                         next_state = RIGHT_PASS;
                     else
                         next_state = STOP;
                  end
        default: next_state = IDLE;
    endcase
 end
  
  always @(posedge clk) 
    begin 
      case(current_state)
 IDLE         : begin green_tmp = 1'b0; red_tmp = 1'b0;  end
 WAIT_PASSWORD: begin green_tmp = 1'b0; red_tmp = 1'b1;  end
 WRONG_PASS   : begin green_tmp = 1'b0; red_tmp = ~red_tmp;end
 RIGHT_PASS   : begin green_tmp = ~green_tmp; red_tmp = 1'b0; end
 STOP         : begin green_tmp = 1'b0; red_tmp = ~red_tmp; end
       endcase
    end
 assign RED_LED = red_tmp  ;
 assign GREEN_LED = green_tmp;

endmodule

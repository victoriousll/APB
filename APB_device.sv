
module APB_device
#(parameter op1_ADDR = 4'h0, // адрес регистра, где хранится 1 операнд
parameter op2_ADDR = 4'h4,              // адрес регистра, где хранится 2 операнд
parameter res_ADDR = 4'h8,           // адрес регистра результата
parameter control_ADDDR = 4'hC)             // адрес контрольного регистра

(
    input wire PWRITE,            // сигнал, выбирающий режим записи или чтения (1 - запись, 0 - чтение)
    input wire PCLK,              // сигнал синхронизации
    input wire PSEL,              // сигнал выбора периферии 
    input wire [31:0] PADDR,      // Адрес регистра
    input wire [31:0] PWDATA,     // Данные для записи в регистр
    output reg [31:0] PRDATA = 0, // Данные, прочитанные из регистра
    input wire PENABLE,           // сигнал разрешения
    output reg PREADY = 0         // сигнал готовности (флаг того, что всё сделано успешно)
);


//Регистры для записи значений
reg [31:0] operand1 = 0; // регистр операнда 1
reg [31:0] operand2 = 0; // регистр операнда 2
reg [31:0] resultReg = 0; // регистр результата
reg [1:0] controlReg = 0; // контрольный регистр  (значение 0 - сложение по И
                          //                                1 - сложение по ИЛИ
                          //                                2 - по модулю 2 )

// циклы записи и чтения интерфейса APB

always @(posedge PCLK) 
begin
    
    if (PSEL && !PWRITE && PENABLE) // ЧТЕНИЕ 
     begin
        case(PADDR)
         4'h0: PRDATA <= operand1;
         4'h4: PRDATA <= operand2;
         4'h8: PRDATA <= resultReg;
         4'hC: PRDATA <= controlReg;
        endcase
        PREADY <= 1'd1;            // поднимаем флаг заверешения операции
     end

    
    else if (PSEL && PWRITE && PENABLE) // ЗАПИСЬ
     begin
        if(PADDR != 4'h8) //запись в регистр результата НЕ производится
        begin
            case(PADDR)
              4'h0: operand1 <= PWDATA; // запись по адресу регистра номера человека в группе
              4'h4: operand2 <= PWDATA;            // запись по адресу регистра даты
              4'hC: controlReg <= PWDATA;            // запись по адресу регистра имени
            endcase
            PREADY <= 1'd1;   // поднимаем флаг заверешения операции
        end
     end

   
   if (PREADY) // сбрасываем PREADY после выполнения записи или чтения
    begin
      $display();
      $display("Operation: %b", PWRITE);
      $display("Address: %h", PADDR);

      if(PWRITE)
      begin
        $display("Data for recording: %h", PWDATA);
      end

      else if(!PWRITE)
      begin
        $display("Read data: %h", PRDATA);
      end

      PREADY <= !PREADY;
    end
end



//функция выполнения операций сложения по И, ИЛИ, по модулю 2
always @(controlReg) 
begin 
  if (controlReg == 1 || controlReg == 2 || controlReg == 3)//контрольный регистр может принимать только значения 1, 2, 3
  begin
    if(controlReg == 1) // 0 - сложение по И
    begin
      resultReg <= operand1 & operand2; // AND
    end

    else if(controlReg == 2) // 1 - сложение по ИЛИ
    begin
      resultReg <= operand1 | operand2; // OR
    end

    else if(controlReg == 3) // по модулю 2
    begin
      resultReg <= operand1 ^ operand2; // XOR
    end
  end
end


endmodule

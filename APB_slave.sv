module APB_slave
#(parameter number_in_group_ADDR = 4'h0, // адрес регистра, где хранится номер студента в группе
parameter data_ADDR = 4'h4,              // адрес регистра, где хранится дата дд.мм.гг
parameter surname_ADDR = 4'h8,           // адрес регистра, где хранится первые 4 буквы фамилии
parameter name_ADDDR = 4'hC)             // адрес регистра, где хранится первые 4 буквы имени

(
    input wire PWRITE,            // сигнал, выбирающий режим записи или чтения (1 - запись, 0 - чтение)
    input wire PCLK,              // сигнал синхронизации
    input wire PSEL,              // сигнал выбора переферии 
    input wire [31:0] PADDR,      // Адрес регистра
    input wire [31:0] PWDATA,     // Данные для записи в регистр
    output reg [31:0] PRDATA = 0, // Данные, прочитанные из регистра
    input wire PENABLE,           // сигнал разрешения
    output reg PREADY = 0         // сигнал готовности (флаг того, что всё сделано успешно)
);



//Регистры для записи значений
reg [31:0] number_in_group = 0;
reg [31:0] data = 0;
reg [31:0] surname = 0;
reg [31:0] name = 0;

// циклы записи и чтения интерфейса APB

always @(posedge PSEL or posedge PCLK) 
begin
    
    if (PSEL && !PWRITE && PENABLE) // Чтение из регистров 
     begin
        case(PADDR)
         4'h0: PRDATA <= number_in_group;
         4'h4: PRDATA <= data;
         4'h8: PRDATA <= surname;
         4'hC: PRDATA <= name;
        endcase
        PREADY <= 1'd1;            // поднимаем флаг заверешения операции
     end

    
    else if (PSEL && PWRITE && PENABLE) // Запись в регистры
     begin
        case(PADDR)
         4'h0: number_in_group <= PWDATA; // запись по адресу регистра номера человека в группе
         4'h4: data <= PWDATA;            // запись по адресу регистра даты
         4'h8: surname <= PWDATA;         // запись по адресу регистра фамилии
         4'hC: name <= PWDATA;            // запись по адресу регистра имени
        endcase
        PREADY <= 1'd1;   // поднимаем флаг заверешения операции
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


endmodule
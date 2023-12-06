`include "APB_master.sv"
`include "APB_slave.sv"
module APB_master_tb;



reg PCLK = 0;                   // сигнал синхронизации
reg PWRITE_MASTER = 0;          // сигнал, выбирающий режим записи или чтения (1 - запись, 0 - чтение)
wire PSEL;                      // сигнал выбора переферии 
reg [31:0] PADDR_MASTER = 0;    // Адрес регистра
reg [31:0] PWDATA_MASTER = 0;   // Данные для записи в регистр
wire [31:0] PRDATA_MASTER;       // Данные, прочитанные из слейва
wire PENABLE;                    // сигнал разрешения, формирующийся в мастер APB
reg PRESET = 0;                   // сигнал сброса
wire PREADY;                      // сигнал готовности (флаг того, что всё сделано успешно)
wire [31:0] PADDR;                // адрес, который мы будем передавать в слейв
wire [31:0] PWDATA;               // данные, которые будут передаваться в слейв,
wire [31:0] PRDATA ;              // данные, прочтённые с слейва
wire PWRITE;                      // сигнал записи или чтения на вход слейва

APB_master APB_master_1 (
    .PCLK(PCLK),
    .PWRITE_MASTER(PWRITE_MASTER),
    .PSEL(PSEL),
    .PADDR_MASTER(PADDR_MASTER),
    .PWDATA_MASTER(PWDATA_MASTER),
    .PRDATA_MASTER(PRDATA_MASTER),
    .PENABLE(PENABLE),
    .PRESET(PRESET),
    .PREADY(PREADY),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PWRITE(PWRITE)
);

APB_slave APB_slave_1 (
    .PWRITE(PWRITE),
    .PSEL(PSEL),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PENABLE(PENABLE),
    .PREADY(PREADY),
    .PCLK(PCLK)
);



always #200 PCLK = ~PCLK; // генерация входного сигнала Pclk

initial begin
//ЗАПИСЬ
PCLK = 0;
PWRITE_MASTER = 1;         // выбираем запись
PWDATA_MASTER = 32'h17;         // в данные для записи записываем 17
PADDR_MASTER = 0;           // выбираем адрес регистра number_in_group
@(posedge PCLK);
@(posedge PCLK);

PWRITE_MASTER = 1;         // выбираем запись
PWDATA_MASTER = 32'h15112023; // в данные для записи записываем 15.11.2023
PADDR_MASTER = 4;           // выбираем адрес регистра date
@(posedge PCLK);
@(posedge PCLK);

PWRITE_MASTER = 1;         // выбираем запись
PWDATA_MASTER = 32'h4C594150; // в данные для записи записываем первые 4 буквы фамилии в аски коде(1 буква - 8 бит)
PADDR_MASTER = 8;           // выбираем адрес регистра surname
@(posedge PCLK);
@(posedge PCLK);

PWRITE_MASTER = 1;            // выбираем запись
PWDATA_MASTER = 32'h56494B41;  // в данные для записи записываем первые 4 буквы имени в аски коде
PADDR_MASTER = 4'hC;           // выбираем адрес регистра name
@(posedge PCLK);
@(posedge PCLK);


//ЧТЕНИЕ
PWRITE_MASTER = 0;            // выбираем чтение
PADDR_MASTER = 0;           // выбираем адрес регистра номера в группе
@(posedge PCLK);
@(posedge PCLK);


PWRITE_MASTER = 0;            // выбираем чтение
PADDR_MASTER = 4;          // выбираем адрес регистра date
@(posedge PCLK);
@(posedge PCLK);

PWRITE_MASTER = 0;            // выбираем чтение
PADDR_MASTER = 8;            // выбираем адрес регистра surname
@(posedge PCLK);
@(posedge PCLK);

PWRITE_MASTER = 0;            // выбираем чтение
PADDR_MASTER = 4'hC;           // выбираем адрес регистра name
@(posedge PCLK);
@(posedge PCLK);




 #500 $finish; // Заканчиваем симуляцию
end







initial begin
$dumpfile("APB_master.vcd"); // создание файла для сохранения результатов симуляции
$dumpvars(0, APB_master_tb); // установка переменных для сохранения в файле
$dumpvars;
end


endmodule
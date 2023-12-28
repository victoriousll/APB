`include "APB_master.sv"
`include "APB_device.sv"
module APB_device_tb;

reg PCLK = 0;                   // сигнал синхронизации
reg PWRITE_MASTER = 0;          // сигнал, выбирающий режим записи или чтения (1 - запись, 0 - чтение)
wire PSEL;                      // сигнал выбора периферии 
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

APB_device APB_device_1 (
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
@(posedge PCLK);

//Запись 1 операнда
PWRITE_MASTER = 1;         // выбираем запись
PADDR_MASTER = 0;          // выбираем адрес 1 операнда
PWDATA_MASTER = 32'h3;    // в 1 операнд записываем 3
@(posedge PCLK);
@(posedge PCLK);

//Запись 2 операнда
PWRITE_MASTER = 1;         // выбираем запись
PADDR_MASTER = 4;          // выбираем адрес 2 операнда
PWDATA_MASTER = 32'h7;    // в 2 операнд записываем 7
@(posedge PCLK);
@(posedge PCLK);

//Запись операции сложения по И
PWRITE_MASTER = 1;         // выбираем запись
PADDR_MASTER = 4'hC;          // выбираем адрес контрольного регистра
PWDATA_MASTER = 1;    // в контрольный регистр записываем номер операции сложения по ИЛИ
@(posedge PCLK);
@(posedge PCLK);  

//Чтение результата
PWRITE_MASTER = 0;         // выбираем чтение
PADDR_MASTER = 4'h8;       // выбираем адрес регистра результата
@(posedge PCLK);
@(posedge PCLK);    

//Запись 1 операнда
PWRITE_MASTER = 1;         // выбираем запись
PADDR_MASTER = 0;          // выбираем адрес 1 операнда
PWDATA_MASTER = 32'hA;    // в 1 операнд записываем 10 
@(posedge PCLK);
@(posedge PCLK);

//Запись 2 операнда
PWRITE_MASTER = 1;         // выбираем запись
PADDR_MASTER = 4;          // выбираем адрес 2 операнда
PWDATA_MASTER = 32'h4;    // в 2 операнд записываем 4 
@(posedge PCLK);
@(posedge PCLK);

//Запись операции сложения по ИЛИ
PWRITE_MASTER = 1;         // выбираем запись
PADDR_MASTER = 4'hC;          // выбираем адрес контрольного регистра
PWDATA_MASTER = 2;    // в контрольный регистр записываем номер операции сложения по ИЛИ
@(posedge PCLK);
@(posedge PCLK);  

//Чтение результата
PWRITE_MASTER = 0;         // выбираем чтение
PADDR_MASTER = 4'h8;       // выбираем адрес регистра результата
@(posedge PCLK);
@(posedge PCLK); 


//Запись 1 операнда
PWRITE_MASTER = 1;         // выбираем запись
PADDR_MASTER = 0;          // выбираем адрес 1 операнда
PWDATA_MASTER = 32'h9;    // в 1 операнд записываем 9 
@(posedge PCLK);
@(posedge PCLK);

//Запись 2 операнда
PWRITE_MASTER = 1;         // выбираем запись
PADDR_MASTER = 4;          // выбираем адрес 2 операнда
PWDATA_MASTER = 32'h3;    // в 2 операнд записываем 3 
@(posedge PCLK);
@(posedge PCLK);

//Запись операции сложения по модулю 2
PWRITE_MASTER = 1;         // выбираем запись
PADDR_MASTER = 4'hC;          // выбираем адрес контрольного регистра
PWDATA_MASTER = 3;    // в контрольный регистр записываем номер операции сложения по модулю 2
@(posedge PCLK);
@(posedge PCLK);  


//Чтение результата
PWRITE_MASTER = 0;         // выбираем чтение
PADDR_MASTER = 4'h8;       // выбираем адрес регистра результата
@(posedge PCLK);
@(posedge PCLK); 








 #500 $finish; // Заканчиваем симуляцию
end







initial begin
$dumpfile("APB_device.vcd"); // создание файла для сохранения результатов симуляции
$dumpvars(0, APB_device_tb); // установка переменных для сохранения в файле
$dumpvars;
end


endmodule
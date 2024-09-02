#include <iostream>
#include <memory>

#include "Vmarian_tb_verilator.h"
#include "verilated.h"

vluint64_t main_time = 0;
double sc_time_stamp() { return main_time; }

int main(int argc, char** argv) {

  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  
  const std::unique_ptr<Vmarian_tb_verilator> top{new Vmarian_tb_verilator};

  while ( !Verilated::gotFinish() ) { 
    if(main_time != -1) {
      top->eval();    
    }
    main_time = top->nextTimeSlot();
  }

  top->final();

  return 0;
}

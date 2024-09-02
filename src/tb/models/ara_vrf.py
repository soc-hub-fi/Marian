# script to help understand how VRF requests are managed in Ara

import math

# encoding of SEW
EW8    = 0
EW16   = 1
EW32   = 2
EW64   = 3
EW128  = 4
EW256  = 5
EW512  = 6
EW1024 = 7

# static configuration
vlen     = 512
vlenb    = vlen / 8
NrLanes  =   4
NrBanks  =   8
BankMask = 2**int(math.ceil(math.log2(NrBanks)))-1

# instruction
class Instruction:
  
  def __init__(self, name, v1_id, sew, vl, vstart):

    # insn config
    self.name    = name
    self.vs      = v1_id
    self.sew_int = sew  
    self.eew_int = sew # ToDo: this will be needed for expanding insn
    self.vl      = vl
    self.vstart  = vstart
    self.vscale  = 0

    self.op_id   = [self.vs] 

    # lane-context config (lane sequencer)
    self.lane_vl     = []
    self.lane_vstart = []

    # operand requester config.
    self.req_addr = []
    self.req_bank = []
    self.req_len  = []
    # payload addr
    self.payl_addr = []

    # get sew encoding
    if self.sew_int == 0:
      self.sew_str = "EW8"
    elif self.sew_int == 1: 
      self.sew_str = "EW16"
    elif self.sew_int == 2: 
      self.sew_str = "EW32"
    elif self.sew_int == 3: 
      self.sew_str = "EW64"
    elif self.sew_int == 4: 
      self.sew_str = "EW128"
    elif self.sew_int == 5: 
      self.sew_str = "EW256"
    elif self.sew_int == 6: 
      self.sew_str = "EW512"
    elif self.sew_int == 7: 
      self.sew_str = "EW1024"
    else:
      raise ValueError("Provided SEW is unspecified")

    # create request and payload data
    self.__get_lane_data()
    self.__get_op_reqs()

    self.report_insn()
    self.print_vec_info()
    self.print_lane_info()

  # populate data which is sent to operand_requester of each lane
  def __get_lane_data(self):
    for curr_lane in range(0, NrLanes):
      # calc vl
      tmp_vl = int(self.vl/NrLanes)
      if (curr_lane < self.vl % NrLanes):
        tmp_vl += 1
      self.lane_vl.append(tmp_vl)
      # calc vstart
      tmp_vstart = int(self.vstart/NrLanes)
      if (curr_lane < self.vstart % NrLanes):
        tmp_vstart -= 1
      self.lane_vstart.append(tmp_vstart)

  # helper function used to help calculate the VRF request address
  def __vaddr(self, vid, nr_lanes):
    vaddr = vid * int(vlenb / nr_lanes / 8)
    return vaddr


  # calculate the requester_d addr field using source reg ID
  def __get_req_addr(self, lane, operand):
    tmp_addr = self.__vaddr(operand, NrLanes)
    shift = EW64 - self.sew_int
    req_addr = tmp_addr + (self.lane_vstart[lane] >> shift)

    return req_addr


  # calculate the memory bank ID using the requester addr
  def __get_req_bank(self, req_addr):
    req_bank = req_addr & BankMask
    return req_bank


  # calculate len field of requester_d
  def __get_req_len(self, lane):

    if self.vscale != 0:
      req_len = (self.lane_vl[lane] >> self.sew_int) >> self.eew_int
    else:
      req_len = self.lane_vl[lane]

    return req_len

  # get payload addr (this is address used for selected SRAM bank)
  def __get_payload_addr(self, req_addr):
    payl_addr = req_addr >> int(math.ceil(math.log2(NrBanks)))
    return payl_addr


  # When creating requests, the FSM iterates until all elements have been requested
  # The following function is used to determine if another request is required
  def __decr_req_len(self, req_len, req_vew):
    # vew == req.eew
    if req_len < (1 << (EW64 - req_vew)):
      return 0
    else:
      return req_len - ((1 << (EW64 - req_vew)))

  
  def __get_op_reqs(self):

    for lane in range(0, NrLanes):

      req_complete = False

      lane_req_addr = []     
      lane_req_bank = []     
      lane_req_len  = []    
      lane_payl_adr = []           
              
      req_addr = self.__get_req_addr(lane, self.vs)
      req_bank = self.__get_req_bank(req_addr)    
      req_len  = self.__get_req_len(lane)    
      payl_adr = self.__get_payload_addr(req_addr)

      lane_req_addr.append(req_addr)
      lane_req_bank.append(req_bank)
      lane_req_len.append(req_len)
      lane_payl_adr.append(payl_adr)

      while(req_complete == False):

        req_len = self.__decr_req_len(req_len, self.eew_int)

        if req_len != 0:
          req_addr += 1
          req_bank = self.__get_req_bank(req_addr)
          payl_adr = self.__get_payload_addr(req_addr)

          lane_req_addr.append(req_addr)
          lane_req_bank.append(req_bank)
          lane_req_len.append(req_len)
          lane_payl_adr.append(payl_adr)

        else:
          req_complete = True

      self.req_addr.append(lane_req_addr)
      self.req_bank.append(lane_req_bank)
      self.req_len.append(lane_req_len)
      self.payl_addr.append(lane_payl_adr)

  
  def write_back_test(self, elem_count):
    tmp = self.__vaddr(self.vs, NrLanes)
    shift = (EW64 - self.sew_int)
    tmp_addr = tmp + ((self.vstart + (elem_count >> 2)) >> shift)
    payl_addr = tmp_addr >> int(math.ceil(math.log2(NrBanks))) 
    bank_addr = tmp_addr & BankMask
    print(f"payl : {payl_addr}")
    print(f"bnk  : {bank_addr}")
    return tmp_addr


  def report_insn(self):
    print(f"\nInsn {self.name}\n--------------------")
    print(f"vs     : {self.vs}")
    print(f"SEW    : {self.sew_str}")
    print(f"vl     : {self.vl}")
    print(f"vstart : {self.vstart}\n")


  # Print VP config
  def print_vec_info(self):
    print("Vector Configuration\n--------------------")
    print(f"NrLanes : {NrLanes:2d}")
    print(f"vstart  : {self.vstart:2d}")
    print(f"vl      : {self.vl:2d}\n")

  # Print configuration values for each lane
  def print_lane_info(self):
    print("lane        |", end='')
    for lane in range(0, NrLanes):
      print(f"|  {lane:2d}   |", end='')
    print("\n==================================================")
  
    print("lane_vl     |", end='')
    for lane in range(0, NrLanes):
      print(f"|  {self.lane_vl[lane]:2d}   |", end='')
  
    print("\nlane_vstart |", end='')
    for lane in range(0, NrLanes):
      print(f"|  {self.lane_vstart[lane]:2d}   |", end='')

    print("\n==================================================")

    print("\nREQ_ADDR:")
    for lane in range(0, NrLanes):
      print(f"lane {lane}: {self.req_addr[lane]}")
    print()
    print("REQ_BANK (SRAM BANK):")
    for lane in range(0, NrLanes):
      print(f"lane {lane}: {self.req_bank[lane]}")
    print()
    print("REQ_LEN:")
    for lane in range(0, NrLanes):
      print(f"lane {lane}: {self.req_len[lane]}")
    print()
    print("PAYL_ADDR (SRAM ADDR):")
    for lane in range(0, NrLanes):
      print(f"lane {lane}: {self.payl_addr[lane]}")
    print()


# equivalent of idx_width function that is used in RTL
def idx_width(num_idx):
  if num_idx > 1:
    return int(math.ceil(math.log2(num_idx)))
  else:
    return 1


################################################################################

if __name__ == "__main__":
  insn = Instruction("ADD", v1_id=14, sew=EW32, vl=16, vstart=0)
  insn.write_back_test(0)



# Model of write back operation used for the crypto unit of Marian

from enum import Enum, IntEnum
import random

# CONSTANTS
# Number of lanes
NrLanes = 4
# Number of elements in a single crypto operation element group
CryptoEGS = 4
# max element bit width
ELEN = 64
# number of bytes in each operand request
OperandBytes = int((NrLanes * ELEN) / 8)

# Ops
AraOp = Enum('AraOp', [
    'VAESK1',    'VAESK2',
    'VAESDF_VV', 'VAESDM_VV', 'VAESEF_VV', 'VAESEM_VV',
    'VAESDF_VS', 'VAESDM_VS', 'VAESEF_VS', 'VAESEM_VS', 'VAESZ_VS',
    'VGMUL',     'VGHSH',
    'VSHA'
])

# vSew
class SEW(IntEnum):
    EW8 = 0
    EW16 = 1
    EW32 = 2
    EW64 = 3
    EW128 = 4
    EW256 = 5
    EW512 = 6
    EW1024 = 7

# LMUL
class LMUL(IntEnum):
    LMUL_1 = 0
    LMUL_2 = 1
    LMUL_4 = 2
    LMUL_8 = 3
    LMUL_RSVD = 4
    LMUL_1_8 = 5
    LMUL_1_4 = 6
    LMUL_1_2 = 7


# VTYPE CFG
class VType:
    def __init__(self, vill, vma, vta, vsew=SEW.EW8, vlmul=LMUL.LMUL_1):
        self.vill = vill
        self.vma = vma
        self.vta = vta
        self.vsew = vsew
        self.vlmul = vlmul


# PE REQUEST
class PeRequest:
    def __init__(self, req_id, op, vs1, vd, vs2, scalar_op, vl, vstart, vtype):
        self.id = req_id
        self.op = op
        self.vs1 = vs1
        self.vd = vd
        self.vs2 = vs2
        self.scalar_op = scalar_op
        self.vl = vl
        self.vstart = vstart
        self.eg_len = int(vl/CryptoEGS)
        self.vtype = vtype
        self.check_params()

    def print_request(self):
        print("\nPeRequest:")
        print(f"\tid        = {self.id}")
        print(f"\top        = {self.op}")
        print(f"\tvs1       = {self.vs1}")
        print(f"\tvd        = {self.vd}")
        print(f"\tvs2       = {self.vs2}")
        print(f"\tscalar_op = {self.scalar_op}")
        print(f"\tvl        = {self.vl}")
        print(f"\tvstart    = {self.vstart}")
        print(f"\teg_len    = {self.eg_len}")
        print("VType:")
        print(f"\tvill  = {self.vtype.vill}")
        print(f"\tvma   = {self.vtype.vma}")
        print(f"\tvta   = {self.vtype.vta}")
        print(f"\tvsew  = {2**(3+self.vtype.vsew)}")
        print(f"\tvlmul = {self.vtype.vlmul}\n")

    def check_params(self):
        if self.vl == 0:
            print(f"[ERROR] : vl cannot be 0!")
            exit(1)
        if (self.op == AraOp.VAESK1 or
                self.op == AraOp.VAESK2 or
                self.op == AraOp.VAESDF_VV or
                self.op == AraOp.VAESDM_VV or
                self.op == AraOp.VAESEF_VV or
                self.op == AraOp.VAESEM_VV or
                self.op == AraOp.VAESDF_VS or
                self.op == AraOp.VAESDM_VS or
                self.op == AraOp.VAESEF_VS or
                self.op == AraOp.VAESEM_VS or
                self.op == AraOp.VAESZ_VS or
                self.op == AraOp.VGMUL or
                self.op == AraOp.VGHSH):
            if self.vl % 4 != 0:
                print(f"[ERROR] : vl for {self.op} must be a multiple of 4!")
                exit(1)
            if self.vstart % 4 != 0:
                print(f"[ERROR] : vstart for {self.op} must be a multiple of 4 when SEW is 32b!")
                exit(1)
        else:
            if self.vtype.vsew == SEW.EW32:
                if self.vl % 4 != 0:
                    print(f"[ERROR] : vl for {self.op} must be a multiple of 4 when SEW is 32b!")
                    exit(1)
                if self.vstart % 4 != 0:
                    print(f"[ERROR] : vstart for {self.op} must be a multiple of 4 when SEW is 32b!")
                    exit(1)
            elif self.vtype.vsew == SEW.EW64:
                if self.vl % 8 != 0:
                    print(f"[ERROR] : vl for {self.op} must be a multiple of 8 when SEW is 64b!")
                    exit(1)
                if self.vstart % 8 != 0:
                    print(f"[ERROR] : vstart for {self.op} must be a multiple of 8 when SEW is 64b!")
                    exit(1)
            else:
                print(f"[ERROR] : illegal VSEW configuration of PeReq!")
                exit(1)


# Result buffer (in bytes)
class CryptoResult:
    def __init__(self, pe_request):
        self.pe_req = pe_request
        self.result_w_bytes = 0
        self.result = []
        self.result_hex = []
        self.gen_random_results()
        self.print_results()

    def gen_random_results(self):
        random.seed()
        # if SEW=32b, result will be 32*4=128b
        # if SEW=64b, result will be 64*4=256b
        self.result_w_bytes = (1 << int(self.pe_req.vtype.vsew)) * CryptoEGS
        for byte_idx in range(0, self.result_w_bytes):
            rand_byte = random.randbytes(1)
            self.result.append(int.from_bytes(rand_byte, byteorder='little'))
        self.result_hex = ['0x%.02X' % elem for elem in self.result]

    def print_results(self):
        word_size = 2**self.pe_req.vtype.vsew
        word_count = 4
        print("\nCryptoResult:")
        for word in range(0, word_count):
            tmp_list = []
            for element in range(0, word_size):
                tmp_list.append(self.result_hex[(word*word_size)+element])
            print(f"\tword_{word}: {tmp_list}")


# helper function to generate indices of shuffled bytes
def shuffle_index(byte_idx, nr_lanes, ew):
    if nr_lanes == 1:
        idx = [0] * 8
        if ew == 64:
            idx[7] = 7
            idx[6] = 6
            idx[5] = 5
            idx[4] = 4
            idx[3] = 3
            idx[2] = 2
            idx[1] = 1
            idx[0] = 0
            return idx[byte_idx]
        elif ew == 32:
            idx[7] = 7
            idx[6] = 6
            idx[5] = 5
            idx[4] = 4
            idx[3] = 3
            idx[2] = 2
            idx[1] = 1
            idx[0] = 0
            return idx[byte_idx]
        elif ew == 16:
            idx[7] = 7
            idx[6] = 6
            idx[5] = 3
            idx[4] = 2
            idx[3] = 5
            idx[2] = 4
            idx[1] = 1
            idx[0] = 0
            return idx[byte_idx]
        else:
            idx[7] = 7
            idx[6] = 3
            idx[5] = 5
            idx[4] = 1
            idx[3] = 6
            idx[2] = 2
            idx[1] = 4
            idx[0] = 0
            return idx[byte_idx]

    elif nr_lanes == 2:
        idx = [0] * 16
        if ew == 64:
            idx[15] = 15
            idx[14] = 14
            idx[13] = 13
            idx[12] = 12
            idx[11] = 11
            idx[10] = 10
            idx[9] = 9
            idx[8] = 8
            idx[7] = 7
            idx[6] = 6
            idx[5] = 5
            idx[4] = 4
            idx[3] = 3
            idx[2] = 2
            idx[1] = 1
            idx[0] = 0
            return idx[byte_idx]
        elif ew == 32:
            idx[15] = 15
            idx[14] = 14
            idx[13] = 13
            idx[12] = 12
            idx[11] = 7
            idx[10] = 6
            idx[9] = 5
            idx[8] = 4
            idx[7] = 11
            idx[6] = 10
            idx[5] = 9
            idx[4] = 8
            idx[3] = 3
            idx[2] = 2
            idx[1] = 1
            idx[0] = 0
            return idx[byte_idx]
        elif ew == 16:
            idx[15] = 15
            idx[14] = 14
            idx[13] = 7
            idx[12] = 6
            idx[11] = 11
            idx[10] = 10
            idx[9] = 3
            idx[8] = 2
            idx[7] = 13
            idx[6] = 12
            idx[5] = 5
            idx[4] = 4
            idx[3] = 9
            idx[2] = 8
            idx[1] = 1
            idx[0] = 0
            return idx[byte_idx]
        else:
            idx[15] = 15
            idx[14] = 7
            idx[13] = 11
            idx[12] = 3
            idx[11] = 13
            idx[10] = 5
            idx[9] = 9
            idx[8] = 1
            idx[7] = 14
            idx[6] = 6
            idx[5] = 10
            idx[4] = 2
            idx[3] = 12
            idx[2] = 4
            idx[1] = 8
            idx[0] = 0
            return idx[byte_idx]

    elif nr_lanes == 4:
        idx = [0] * 32
        if ew == 64:
            idx[31] = 31
            idx[30] = 30
            idx[29] = 29
            idx[28] = 28
            idx[27] = 27
            idx[26] = 26
            idx[25] = 25
            idx[24] = 24
            idx[23] = 23
            idx[22] = 22
            idx[21] = 21
            idx[20] = 20
            idx[19] = 19
            idx[18] = 18
            idx[17] = 17
            idx[16] = 16
            idx[15] = 15
            idx[14] = 14
            idx[13] = 13
            idx[12] = 12
            idx[11] = 11
            idx[10] = 10
            idx[9] = 9
            idx[8] = 8
            idx[7] = 7
            idx[6] = 6
            idx[5] = 5
            idx[4] = 4
            idx[3] = 3
            idx[2] = 2
            idx[1] = 1
            idx[0] = 0
            return idx[byte_idx]
        elif ew == 32:
            idx[31] = 31
            idx[30] = 30
            idx[29] = 29
            idx[28] = 28
            idx[27] = 23
            idx[26] = 22
            idx[25] = 21
            idx[24] = 20
            idx[23] = 15
            idx[22] = 14
            idx[21] = 13
            idx[20] = 12
            idx[19] = 7
            idx[18] = 6
            idx[17] = 5
            idx[16] = 4
            idx[15] = 27
            idx[14] = 26
            idx[13] = 25
            idx[12] = 24
            idx[11] = 19
            idx[10] = 18
            idx[9] = 17
            idx[8] = 16
            idx[7] = 11
            idx[6] = 10
            idx[5] = 9
            idx[4] = 8
            idx[3] = 3
            idx[2] = 2
            idx[1] = 1
            idx[0] = 0
            return idx[byte_idx]
        elif ew == 16:
            idx[31] = 31
            idx[30] = 30
            idx[29] = 23
            idx[28] = 22
            idx[27] = 15
            idx[26] = 14
            idx[25] = 7
            idx[24] = 6
            idx[23] = 27
            idx[22] = 26
            idx[21] = 19
            idx[20] = 18
            idx[19] = 11
            idx[18] = 10
            idx[17] = 3
            idx[16] = 2
            idx[15] = 29
            idx[14] = 28
            idx[13] = 21
            idx[12] = 20
            idx[11] = 13
            idx[10] = 12
            idx[9] = 5
            idx[8] = 4
            idx[7] = 25
            idx[6] = 24
            idx[5] = 17
            idx[4] = 16
            idx[3] = 9
            idx[2] = 8
            idx[1] = 1
            idx[0] = 0
            return idx[byte_idx]
        else:
            idx[31] = 31
            idx[30] = 23
            idx[29] = 15
            idx[28] = 7
            idx[27] = 27
            idx[26] = 19
            idx[25] = 11
            idx[24] = 3
            idx[23] = 29
            idx[22] = 21
            idx[21] = 13
            idx[20] = 5
            idx[19] = 25
            idx[18] = 17
            idx[17] = 9
            idx[16] = 1
            idx[15] = 30
            idx[14] = 22
            idx[13] = 14
            idx[12] = 6
            idx[11] = 26
            idx[10] = 18
            idx[9] = 10
            idx[8] = 2
            idx[7] = 28
            idx[6] = 20
            idx[5] = 12
            idx[4] = 4
            idx[3] = 24
            idx[2] = 16
            idx[1] = 8
            idx[0] = 0
            return idx[byte_idx]

    elif nr_lanes == 8:
        idx = [0] * 64
        if ew == 64:
            idx[63] = 63
            idx[62] = 62
            idx[61] = 61
            idx[60] = 60
            idx[59] = 59
            idx[58] = 58
            idx[57] = 57
            idx[56] = 56
            idx[55] = 55
            idx[54] = 54
            idx[53] = 53
            idx[52] = 52
            idx[51] = 51
            idx[50] = 50
            idx[49] = 49
            idx[48] = 48
            idx[47] = 47
            idx[46] = 46
            idx[45] = 45
            idx[44] = 44
            idx[43] = 43
            idx[42] = 42
            idx[41] = 41
            idx[40] = 40
            idx[39] = 39
            idx[38] = 38
            idx[37] = 37
            idx[36] = 36
            idx[35] = 35
            idx[34] = 34
            idx[33] = 33
            idx[32] = 32
            idx[31] = 31
            idx[30] = 30
            idx[29] = 29
            idx[28] = 28
            idx[27] = 27
            idx[26] = 26
            idx[25] = 25
            idx[24] = 24
            idx[23] = 23
            idx[22] = 22
            idx[21] = 21
            idx[20] = 20
            idx[19] = 19
            idx[18] = 18
            idx[17] = 17
            idx[16] = 16
            idx[15] = 15
            idx[14] = 14
            idx[13] = 13
            idx[12] = 12
            idx[11] = 11
            idx[10] = 10
            idx[9] = 9
            idx[8] = 8
            idx[7] = 7
            idx[6] = 6
            idx[5] = 5
            idx[4] = 4
            idx[3] = 3
            idx[2] = 2
            idx[1] = 1
            idx[0] = 0
            return idx[byte_idx]
        elif ew == 32:
            idx[63] = 63
            idx[62] = 62
            idx[61] = 61
            idx[60] = 60
            idx[59] = 55
            idx[58] = 54
            idx[57] = 53
            idx[56] = 52
            idx[55] = 47
            idx[54] = 46
            idx[53] = 45
            idx[52] = 44
            idx[51] = 39
            idx[50] = 38
            idx[49] = 37
            idx[48] = 36
            idx[47] = 31
            idx[46] = 30
            idx[45] = 29
            idx[44] = 28
            idx[43] = 23
            idx[42] = 22
            idx[41] = 21
            idx[40] = 20
            idx[39] = 15
            idx[38] = 14
            idx[37] = 13
            idx[36] = 12
            idx[35] = 7
            idx[34] = 6
            idx[33] = 5
            idx[32] = 4
            idx[31] = 59
            idx[30] = 58
            idx[29] = 57
            idx[28] = 56
            idx[27] = 51
            idx[26] = 50
            idx[25] = 49
            idx[24] = 48
            idx[23] = 43
            idx[22] = 42
            idx[21] = 41
            idx[20] = 40
            idx[19] = 35
            idx[18] = 34
            idx[17] = 33
            idx[16] = 32
            idx[15] = 27
            idx[14] = 26
            idx[13] = 25
            idx[12] = 24
            idx[11] = 19
            idx[10] = 18
            idx[9] = 17
            idx[8] = 16
            idx[7] = 11
            idx[6] = 10
            idx[5] = 9
            idx[4] = 8
            idx[3] = 3
            idx[2] = 2
            idx[1] = 1
            idx[0] = 0
            return idx[byte_idx]
        elif ew == 16:
            idx[63] = 63
            idx[62] = 62
            idx[61] = 55
            idx[60] = 54
            idx[59] = 47
            idx[58] = 46
            idx[57] = 39
            idx[56] = 38
            idx[55] = 31
            idx[54] = 30
            idx[53] = 23
            idx[52] = 22
            idx[51] = 15
            idx[50] = 14
            idx[49] = 7
            idx[48] = 6
            idx[47] = 59
            idx[46] = 58
            idx[45] = 51
            idx[44] = 50
            idx[43] = 43
            idx[42] = 42
            idx[41] = 35
            idx[40] = 34
            idx[39] = 27
            idx[38] = 26
            idx[37] = 19
            idx[36] = 18
            idx[35] = 11
            idx[34] = 10
            idx[33] = 3
            idx[32] = 2
            idx[31] = 61
            idx[30] = 60
            idx[29] = 53
            idx[28] = 52
            idx[27] = 45
            idx[26] = 44
            idx[25] = 37
            idx[24] = 36
            idx[23] = 29
            idx[22] = 28
            idx[21] = 21
            idx[20] = 20
            idx[19] = 13
            idx[18] = 12
            idx[17] = 5
            idx[16] = 4
            idx[15] = 57
            idx[14] = 56
            idx[13] = 49
            idx[12] = 48
            idx[11] = 41
            idx[10] = 40
            idx[9] = 33
            idx[8] = 32
            idx[7] = 25
            idx[6] = 24
            idx[5] = 17
            idx[4] = 16
            idx[3] = 9
            idx[2] = 8
            idx[1] = 1
            idx[0] = 0
            return idx[byte_idx]
        else:
            idx[63] = 63
            idx[62] = 55
            idx[61] = 47
            idx[60] = 39
            idx[59] = 31
            idx[58] = 23
            idx[57] = 15
            idx[56] = 7
            idx[55] = 59
            idx[54] = 51
            idx[53] = 43
            idx[52] = 35
            idx[51] = 27
            idx[50] = 19
            idx[49] = 11
            idx[48] = 3
            idx[47] = 61
            idx[46] = 53
            idx[45] = 45
            idx[44] = 37
            idx[43] = 29
            idx[42] = 21
            idx[41] = 13
            idx[40] = 5
            idx[39] = 57
            idx[38] = 49
            idx[37] = 41
            idx[36] = 33
            idx[35] = 25
            idx[34] = 17
            idx[33] = 9
            idx[32] = 1
            idx[31] = 62
            idx[30] = 54
            idx[29] = 46
            idx[28] = 38
            idx[27] = 30
            idx[26] = 22
            idx[25] = 14
            idx[24] = 6
            idx[23] = 58
            idx[22] = 50
            idx[21] = 42
            idx[20] = 34
            idx[19] = 26
            idx[18] = 18
            idx[17] = 10
            idx[16] = 2
            idx[15] = 60
            idx[14] = 52
            idx[13] = 44
            idx[12] = 36
            idx[11] = 28
            idx[10] = 20
            idx[9] = 12
            idx[8] = 4
            idx[7] = 56
            idx[6] = 48
            idx[5] = 40
            idx[4] = 32
            idx[3] = 24
            idx[2] = 16
            idx[1] = 8
            idx[0] = 0
            return idx[byte_idx]

    else:  # nr_lanes == 16:
        idx = [0] * 128
        if ew == 64:
            idx[127] = 127
            idx[126] = 126
            idx[125] = 125
            idx[124] = 124
            idx[123] = 123
            idx[122] = 122
            idx[121] = 121
            idx[120] = 120
            idx[119] = 119
            idx[118] = 118
            idx[117] = 117
            idx[116] = 116
            idx[115] = 115
            idx[114] = 114
            idx[113] = 113
            idx[112] = 112
            idx[111] = 111
            idx[110] = 110
            idx[109] = 109
            idx[108] = 108
            idx[107] = 107
            idx[106] = 106
            idx[105] = 105
            idx[104] = 104
            idx[103] = 103
            idx[102] = 102
            idx[101] = 101
            idx[100] = 100
            idx[99] = 99
            idx[98] = 98
            idx[97] = 97
            idx[96] = 96
            idx[95] = 95
            idx[94] = 94
            idx[93] = 93
            idx[92] = 92
            idx[91] = 91
            idx[90] = 90
            idx[89] = 89
            idx[88] = 88
            idx[87] = 87
            idx[86] = 86
            idx[85] = 85
            idx[84] = 84
            idx[83] = 83
            idx[82] = 82
            idx[81] = 81
            idx[80] = 80
            idx[79] = 79
            idx[78] = 78
            idx[77] = 77
            idx[76] = 76
            idx[75] = 75
            idx[74] = 74
            idx[73] = 73
            idx[72] = 72
            idx[71] = 71
            idx[70] = 70
            idx[69] = 69
            idx[68] = 68
            idx[67] = 67
            idx[66] = 66
            idx[65] = 65
            idx[64] = 64
            idx[63] = 63
            idx[62] = 62
            idx[61] = 61
            idx[60] = 60
            idx[59] = 59
            idx[58] = 58
            idx[57] = 57
            idx[56] = 56
            idx[55] = 55
            idx[54] = 54
            idx[53] = 53
            idx[52] = 52
            idx[51] = 51
            idx[50] = 50
            idx[49] = 49
            idx[48] = 48
            idx[47] = 47
            idx[46] = 46
            idx[45] = 45
            idx[44] = 44
            idx[43] = 43
            idx[42] = 42
            idx[41] = 41
            idx[40] = 40
            idx[39] = 39
            idx[38] = 38
            idx[37] = 37
            idx[36] = 36
            idx[35] = 35
            idx[34] = 34
            idx[33] = 33
            idx[32] = 32
            idx[31] = 31
            idx[30] = 30
            idx[29] = 29
            idx[28] = 28
            idx[27] = 27
            idx[26] = 26
            idx[25] = 25
            idx[24] = 24
            idx[23] = 23
            idx[22] = 22
            idx[21] = 21
            idx[20] = 20
            idx[19] = 19
            idx[18] = 18
            idx[17] = 17
            idx[16] = 16
            idx[15] = 15
            idx[14] = 14
            idx[13] = 13
            idx[12] = 12
            idx[11] = 11
            idx[10] = 10
            idx[9] = 9
            idx[8] = 8
            idx[7] = 7
            idx[6] = 6
            idx[5] = 5
            idx[4] = 4
            idx[3] = 3
            idx[2] = 2
            idx[1] = 1
            idx[0] = 0
            return idx[byte_idx]
        elif ew == 32:
            idx[127] = 127
            idx[126] = 126
            idx[125] = 125
            idx[124] = 124
            idx[123] = 119
            idx[122] = 118
            idx[121] = 117
            idx[120] = 116
            idx[119] = 111
            idx[118] = 110
            idx[117] = 109
            idx[116] = 108
            idx[115] = 103
            idx[114] = 102
            idx[113] = 101
            idx[112] = 100
            idx[111] = 95
            idx[110] = 94
            idx[109] = 93
            idx[108] = 92
            idx[107] = 87
            idx[106] = 86
            idx[105] = 85
            idx[104] = 84
            idx[103] = 79
            idx[102] = 78
            idx[101] = 77
            idx[100] = 76
            idx[99] = 71
            idx[98] = 70
            idx[97] = 69
            idx[96] = 68
            idx[95] = 63
            idx[94] = 62
            idx[93] = 61
            idx[92] = 60
            idx[91] = 55
            idx[90] = 54
            idx[89] = 53
            idx[88] = 52
            idx[87] = 47
            idx[86] = 46
            idx[85] = 45
            idx[84] = 44
            idx[83] = 39
            idx[82] = 38
            idx[81] = 37
            idx[80] = 36
            idx[79] = 31
            idx[78] = 30
            idx[77] = 29
            idx[76] = 28
            idx[75] = 23
            idx[74] = 22
            idx[73] = 21
            idx[72] = 20
            idx[71] = 15
            idx[70] = 14
            idx[69] = 13
            idx[68] = 12
            idx[67] = 7
            idx[66] = 6
            idx[65] = 5
            idx[64] = 4
            idx[63] = 123
            idx[62] = 122
            idx[61] = 121
            idx[60] = 120
            idx[59] = 115
            idx[58] = 114
            idx[57] = 113
            idx[56] = 112
            idx[55] = 107
            idx[54] = 106
            idx[53] = 105
            idx[52] = 104
            idx[51] = 99
            idx[50] = 98
            idx[49] = 97
            idx[48] = 96
            idx[47] = 91
            idx[46] = 90
            idx[45] = 89
            idx[44] = 88
            idx[43] = 83
            idx[42] = 82
            idx[41] = 81
            idx[40] = 80
            idx[39] = 75
            idx[38] = 74
            idx[37] = 73
            idx[36] = 72
            idx[35] = 67
            idx[34] = 66
            idx[33] = 65
            idx[32] = 64
            idx[31] = 59
            idx[30] = 58
            idx[29] = 57
            idx[28] = 56
            idx[27] = 51
            idx[26] = 50
            idx[25] = 49
            idx[24] = 48
            idx[23] = 43
            idx[22] = 42
            idx[21] = 41
            idx[20] = 40
            idx[19] = 35
            idx[18] = 34
            idx[17] = 33
            idx[16] = 32
            idx[15] = 27
            idx[14] = 26
            idx[13] = 25
            idx[12] = 24
            idx[11] = 19
            idx[10] = 18
            idx[9] = 17
            idx[8] = 16
            idx[7] = 11
            idx[6] = 10
            idx[5] = 9
            idx[4] = 8
            idx[3] = 3
            idx[2] = 2
            idx[1] = 1
            idx[0] = 0
            return idx[byte_idx]
        elif ew == 16:
            idx[127] = 127
            idx[126] = 126
            idx[125] = 119
            idx[124] = 118
            idx[123] = 111
            idx[122] = 110
            idx[121] = 103
            idx[120] = 102
            idx[119] = 95
            idx[118] = 94
            idx[117] = 87
            idx[116] = 86
            idx[115] = 79
            idx[114] = 78
            idx[113] = 71
            idx[112] = 70
            idx[111] = 63
            idx[110] = 62
            idx[109] = 55
            idx[108] = 54
            idx[107] = 47
            idx[106] = 46
            idx[105] = 39
            idx[104] = 38
            idx[103] = 31
            idx[102] = 30
            idx[101] = 23
            idx[100] = 22
            idx[99] = 15
            idx[98] = 14
            idx[97] = 7
            idx[96] = 6
            idx[95] = 123
            idx[94] = 122
            idx[93] = 115
            idx[92] = 114
            idx[91] = 107
            idx[90] = 106
            idx[89] = 99
            idx[88] = 98
            idx[87] = 91
            idx[86] = 90
            idx[85] = 83
            idx[84] = 82
            idx[83] = 75
            idx[82] = 74
            idx[81] = 67
            idx[80] = 66
            idx[79] = 59
            idx[78] = 58
            idx[77] = 51
            idx[76] = 50
            idx[75] = 43
            idx[74] = 42
            idx[73] = 35
            idx[72] = 34
            idx[71] = 27
            idx[70] = 26
            idx[69] = 19
            idx[68] = 18
            idx[67] = 11
            idx[66] = 10
            idx[65] = 3
            idx[64] = 2
            idx[63] = 125
            idx[62] = 124
            idx[61] = 117
            idx[60] = 116
            idx[59] = 109
            idx[58] = 108
            idx[57] = 101
            idx[56] = 100
            idx[55] = 93
            idx[54] = 92
            idx[53] = 85
            idx[52] = 84
            idx[51] = 77
            idx[50] = 76
            idx[49] = 69
            idx[48] = 68
            idx[47] = 61
            idx[46] = 60
            idx[45] = 53
            idx[44] = 52
            idx[43] = 45
            idx[42] = 44
            idx[41] = 37
            idx[40] = 36
            idx[39] = 29
            idx[38] = 28
            idx[37] = 21
            idx[36] = 20
            idx[35] = 13
            idx[34] = 12
            idx[33] = 5
            idx[32] = 4
            idx[31] = 121
            idx[30] = 120
            idx[29] = 113
            idx[28] = 112
            idx[27] = 105
            idx[26] = 104
            idx[25] = 97
            idx[24] = 96
            idx[23] = 89
            idx[22] = 88
            idx[21] = 81
            idx[20] = 80
            idx[19] = 73
            idx[18] = 72
            idx[17] = 65
            idx[16] = 64
            idx[15] = 57
            idx[14] = 56
            idx[13] = 49
            idx[12] = 48
            idx[11] = 41
            idx[10] = 40
            idx[9] = 33
            idx[8] = 32
            idx[7] = 25
            idx[6] = 24
            idx[5] = 17
            idx[4] = 16
            idx[3] = 9
            idx[2] = 8
            idx[1] = 1
            idx[0] = 0
            return idx[byte_idx]
        else:
            idx[127] = 127
            idx[126] = 119
            idx[125] = 111
            idx[124] = 103
            idx[123] = 95
            idx[122] = 87
            idx[121] = 79
            idx[120] = 71
            idx[119] = 63
            idx[118] = 55
            idx[117] = 47
            idx[116] = 39
            idx[115] = 31
            idx[114] = 23
            idx[113] = 15
            idx[112] = 7
            idx[111] = 123
            idx[110] = 115
            idx[109] = 107
            idx[108] = 99
            idx[107] = 91
            idx[106] = 83
            idx[105] = 75
            idx[104] = 67
            idx[103] = 59
            idx[102] = 51
            idx[101] = 43
            idx[100] = 35
            idx[99] = 27
            idx[98] = 19
            idx[97] = 11
            idx[96] = 3
            idx[95] = 125
            idx[94] = 117
            idx[93] = 109
            idx[92] = 101
            idx[91] = 93
            idx[90] = 85
            idx[89] = 77
            idx[88] = 69
            idx[87] = 61
            idx[86] = 53
            idx[85] = 45
            idx[84] = 37
            idx[83] = 29
            idx[82] = 21
            idx[81] = 13
            idx[80] = 5
            idx[79] = 121
            idx[78] = 113
            idx[77] = 105
            idx[76] = 97
            idx[75] = 89
            idx[74] = 81
            idx[73] = 73
            idx[72] = 65
            idx[71] = 57
            idx[70] = 49
            idx[69] = 41
            idx[68] = 33
            idx[67] = 25
            idx[66] = 17
            idx[65] = 9
            idx[64] = 1
            idx[63] = 126
            idx[62] = 118
            idx[61] = 110
            idx[60] = 102
            idx[59] = 94
            idx[58] = 86
            idx[57] = 78
            idx[56] = 70
            idx[55] = 62
            idx[54] = 54
            idx[53] = 46
            idx[52] = 38
            idx[51] = 30
            idx[50] = 22
            idx[49] = 14
            idx[48] = 6
            idx[47] = 122
            idx[46] = 114
            idx[45] = 106
            idx[44] = 98
            idx[43] = 90
            idx[42] = 82
            idx[41] = 74
            idx[40] = 66
            idx[39] = 58
            idx[38] = 50
            idx[37] = 42
            idx[36] = 34
            idx[35] = 26
            idx[34] = 18
            idx[33] = 10
            idx[32] = 2
            idx[31] = 124
            idx[30] = 116
            idx[29] = 108
            idx[28] = 100
            idx[27] = 92
            idx[26] = 84
            idx[25] = 76
            idx[24] = 68
            idx[23] = 60
            idx[22] = 52
            idx[21] = 44
            idx[20] = 36
            idx[19] = 28
            idx[18] = 20
            idx[17] = 12
            idx[16] = 4
            idx[15] = 120
            idx[14] = 112
            idx[13] = 104
            idx[12] = 96
            idx[11] = 88
            idx[10] = 80
            idx[9] = 72
            idx[8] = 64
            idx[7] = 56
            idx[6] = 48
            idx[5] = 40
            idx[4] = 32
            idx[3] = 24
            idx[2] = 16
            idx[1] = 8
            idx[0] = 0
            return idx[byte_idx]


# helper function to get the position of the current result byte, using the vstart and result bytes sent
def get_byte_pos(vstart_byte, result_bytes_written, current_result_byte_idx):
    return (vstart_byte + result_bytes_written + current_result_byte_idx) % OperandBytes


class WriteBack:
    def __init__(self):
        self.vtype = VType(vill=0, vma=0, vta=0, vsew=SEW.EW32, vlmul=LMUL.LMUL_1)
        self.pe_req = PeRequest(req_id=0, op=AraOp.VAESK1, vs1=1, vd=2, vs2=3,
                                scalar_op=0, vl=16, vstart=4, vtype=self.vtype)
        self.write_back_data_unshuffled = (NrLanes*int(ELEN/8))*[0]
        self.write_back_data = [[0 for i in range(int(ELEN/8))] for j in range(NrLanes)]
        self.pe_req.print_request()

    def set_vtype(self, new_vtype):
        self.vtype = new_vtype
        self.pe_req.vtype = new_vtype

    def set_pe_req(self, new_pe_req):
        self.pe_req = new_pe_req

    def shuffle_bytes(self):
        self.write_back_data = [[0 for i in range(int(ELEN/8))] for j in range(NrLanes)]
        for write_byte_idx in range(0, OperandBytes):
            shuffled_byte_idx = shuffle_index(write_byte_idx, NrLanes, 2**(3+self.pe_req.vtype.vsew))
            byte_lane = shuffled_byte_idx >> 3
            byte_offset = shuffled_byte_idx & 0x7
            self.write_back_data[byte_lane][byte_offset] = self.write_back_data_unshuffled[write_byte_idx]

    def print_write_buff(self):
        print(f"\nShuffled Write-Back buffer:")
        for lane in range(0, NrLanes):
            tmp_frmt_arr = ['0x%.02X' % elem for elem in self.write_back_data[lane]]
            print(f"\tLane {lane} : {tmp_frmt_arr}")

    def run_write_back(self):

        sew = self.pe_req.vtype.vsew
        vstart = self.pe_req.vstart
        vl = self.pe_req.vl
        result = CryptoResult(self.pe_req)
        # how many elements are contained within a single write buffer
        elems_per_write = int(OperandBytes / (2**sew))

        # number of bytes in each result
        result_bytes = CryptoEGS * 2**sew
        # number of results bytes in complete request
        result_bytes_total = result_bytes * int(vl/CryptoEGS)
        vstart_byte = (vstart % elems_per_write) * (2**sew)
        print(f"\nsingle result in pe request    = {result_bytes} Bytes / {result_bytes*8} bits")
        print(f"all results in pe request      = {result_bytes_total} Bytes / {result_bytes_total * 8} bits")
        print(f"bytes per write back operation = {OperandBytes} Bytes / {OperandBytes*8} bits")
        print(f"vstart byte position           = Byte {vstart_byte}/{OperandBytes}")

        # calculate how many write back buffers will need to be transmitted to write all results to the VRF
        write_back_required_count = int((result_bytes_total-1)/OperandBytes) + 1
        print(f"\n{write_back_required_count} write back operations required to send all results to VRF")

        # number of total bytes written
        result_bytes_written = 0
        # index counter of current result bytes
        current_result_byte_idx = 0
        # iterate through until all results have been written
        while result_bytes_written < result_bytes_total:

            write_index_lo = get_byte_pos(vstart_byte, result_bytes_written, current_result_byte_idx)
            write_index_hi = 0
            result_bytes_remaining = result_bytes - current_result_byte_idx
            # if all remaining bytes from current result will fit into the current write buffer
            if (write_index_lo + result_bytes_remaining) <= OperandBytes:
                # hi of range is low plus remaining bytes
                write_index_hi = write_index_lo + result_bytes_remaining

            # we are limited by the amount of space remaining in write-buffer. So let's fill the
            # remaining space and then we will use the next write buffer to send the remaining bytes
            # of the result.
            else:
                write_index_hi = OperandBytes

            for write_back_byte_idx in range(0, OperandBytes):
                if (write_back_byte_idx >= write_index_lo) and (write_back_byte_idx < write_index_hi):
                    self.write_back_data_unshuffled[write_back_byte_idx] = result.result[write_back_byte_idx-write_index_lo + current_result_byte_idx]

                else:
                    # don't update value (register output in HW)
                    self.write_back_data_unshuffled[write_back_byte_idx] = self.write_back_data_unshuffled[write_back_byte_idx]

            # write the shuffled bytes
            self.shuffle_bytes()

            # update the number of writes completed
            result_bytes_written += (write_index_hi - write_index_lo)

            if (write_index_hi == OperandBytes) or (result_bytes_written == result_bytes_total):
                print("\nWrite back buffer to be written to VRF....")
                self.print_write_buff()
                # clear write buffer
                self.write_back_data_unshuffled = (NrLanes * int(ELEN / 8)) * [0]

            # increment the current result byte index by the range of bytes sent
            current_result_byte_idx += write_index_hi - write_index_lo
            # if the current result byte index points to the end of the result, time to reset!
            if current_result_byte_idx == result_bytes:
                result = CryptoResult(self.pe_req) # generate fresh results (handshaking in HW)
                current_result_byte_idx = 0



if __name__ == "__main__":
    print(f"NrLanes = {NrLanes}")
    write_back_model = WriteBack()
    write_back_model.run_write_back()

# ------------------------------------------------------------------------------
# dump2hex.py
#
# Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
# Date     : 07-jan-2024
#
# Description: Script to convert a dump file into a hex file that can be read
#              using the Verilog readmemh tasks.
#
#              Note that the .dump input file must be generated using the
#              following command `objdump -fhs <elf_name>.elf > <dump_name>.dump
#
#              The script is called with the following options:
#              python3 dump2hex.py <input> <mem_width> <depth> <output>
#
#              The options are defined as follows:
#              input - Absolute path to input .dump file
#              mem_width - The width of each row in the output hex file in bits
#              depth - Total number of rows in output hex file. Note that any
#              rows beyond the memory region allocated by the .elf will be set
#              to zero.
#              output - Absolute path to output .hex file
# ------------------------------------------------------------------------------
import sys
import re
from datetime import datetime
from math import ceil

# script execution time to be used globally
time = datetime.now().strftime('%d-%b-%Y %H:%M:%S')


# Contains dump file data and methods to extract data from input file
class DumpFile:
    def __init__(self, fn):
        self.dump_file_path = fn
        self.dump_file = []
        self.section_info_arr = []
        self.dump_relative_addr_range = (-1, -1)
        self.byte_arr = []
        self.section_bytes = {}

        self._create_section_information()
        self._initialise_byte_arr()
        self._populate_byte_arr()

    # Parse the header information within dump file to extract section reference information
    def _create_section_information(self):
        self._create_dump_data()
        line_idx = 8  # starting line of section information when dump performed using -fhs
        # iterate through section header information and isolate/extract fields
        while self.dump_file[line_idx].find("Contents") == -1:
            text = self.dump_file[line_idx] + self.dump_file[line_idx + 1]
            section_info = SectionInfo(text)  # constructor parses section info string and populates fields

            if section_info.is_allocated:
                search_string = f"Contents of section {section_info.name}:"
                content_definition_line_idx = self._find_line_in_dump(search_string)

                if content_definition_line_idx:
                    section_info.content_definition_line_idx = content_definition_line_idx + 1

            self.section_info_arr.append(section_info)
            line_idx += 2

        self._calculate_relative_ranges()
        self._populate_section_bytes()

    # Pull data from .dump file into memory
    def _create_dump_data(self):
        with open(self.dump_file_path, 'rt') as f:
            for line in f:
                self.dump_file.append(line)

    # locate first line in dump containing a specific substring
    def _find_line_in_dump(self, sub_str):
        for line_idx, line in enumerate(self.dump_file):
            if line.find(sub_str) != -1:
                return line_idx

    # calculate relative address ranges for each section and dump
    def _calculate_relative_ranges(self):

        addr_arr = []
        for section in self.section_info_arr:
            if section.is_allocated:
                addr_arr.append(section.section_addr_range[0])
                addr_arr.append(section.section_addr_range[1])

        if len(addr_arr) == 0:
            sys.exit("[ERROR] - Failed to calculate relative address ranges as no abs address ranges could be found.")

        base_addr = min(addr_arr)
        end_addr = max(addr_arr)

        self.dump_relative_addr_range = (0, end_addr-base_addr)

        for section in self.section_info_arr:
            if section.is_allocated:
                section.section_relative_addr_range = (section.section_addr_range[0] - base_addr,
                                                       section.section_addr_range[1] - base_addr)

    # dependent on address range being calculated first in _calculate_relative_ranges
    def _initialise_byte_arr(self):
        self.byte_arr = ['00'] * (self.dump_relative_addr_range[1] + 1)

    # For each section in .elf, call method to extract contents and load them into section byte array
    def _populate_section_bytes(self):
        for section in self.section_info_arr:
            if section.content_definition_line_idx != -1:
                self._scrape_bytes_from_section(section)

    # Extract data from specific section into section byte array
    def _scrape_bytes_from_section(self, section):
        bytes_per_line = 16
        line_idx = section.content_definition_line_idx
        curr_line_addr = section.section_relative_addr_range[0]

        section_bytes = []  # words split into little-endian bytes

        while curr_line_addr < section.section_relative_addr_range[1]:

            line_bytes = []

            line = self.dump_file[line_idx]
            line = line.lstrip()
            line = line.split(' ')

            byte_string = ""
            # convert big-endian split words into single string
            for word_idx in range(1, 5):
                for byte_idx in range(0, 7, 2):
                    if line[word_idx] == '':  # don't add empty bytes
                        break
                    byte_string += line[word_idx][byte_idx:byte_idx+2]

            for nibble_idx in range(0, len(byte_string), 2):
                line_bytes.append(byte_string[nibble_idx] + byte_string[nibble_idx+1])

            section_bytes.append(line_bytes)
            curr_line_addr += bytes_per_line
            line_idx += 1

        self.section_bytes[section] = section_bytes

    # Take each section byte array and copy it into the corresponding bytes of the "global" byte array
    def _populate_byte_arr(self):
        for section in self.section_bytes:
            addr = section.section_relative_addr_range[0]  # start address of section

            for word in self.section_bytes[section]:
                for byte in word:
                    self.byte_arr[addr] = byte
                    addr += 1


# Contains section specific data from input file
class SectionInfo:

    def __init__(self, section_header_string):

        # extract section fields from section header in dump
        text = section_header_string  # assign to renamed + mutable variable for readability
        idx = re.search(r"\d+", text)
        self.idx = idx.group()
        text = text[idx.end():]
        name = re.search(r"\.\w+\.*\w+", text)
        self.name = name.group()
        text = text[name.end():]
        size = re.search(r"\w+", text)
        self.size = "0x" + size.group()
        text = text[size.end():]
        vma = re.search(r"\w+", text)
        self.vma = "0x" + vma.group()
        text = text[vma.end():]
        lma = re.search(r"\w+", text)
        self.lma = "0x" + lma.group()
        text = text[lma.end():]
        file_off = re.search(r"\w+", text)
        self.file_off = "0x" + file_off.group()
        text = text[file_off.end():]
        align = re.search(r"2\*\*\d+", text)
        self.align = align.group()
        text = text[re.search(r"\n", text).end():]
        # extract section configuration flags
        config_flags = re.search(r"\w+.*", text)
        self.config_flags = config_flags.group()

        # mark if section is allocated memory space
        self.is_allocated = False
        if self.config_flags.find('ALLOC') != -1:
            self.is_allocated = True

        # create int representations of relevant fields
        self.idx_int = int(self.idx)
        self.size_int = int(self.size, 16)
        self.vma_int = int(self.vma, 16)
        self.lma_int = int(self.lma, 16)
        self.file_off_int = int(self.file_off, 16)
        self.align_int = int(self.align[3:])

        # determine inclusive byte address range of section (only if allocated)
        if self.is_allocated:
            self.section_addr_range = (self.lma_int, self.lma_int + self.size_int - 1)
        else:
            self.section_addr_range = (-1, -1)

        self.content_definition_line_idx = -1   # initialised and calculated/overriden externally
        self.section_relative_addr_range = (-1, -1)

    def print(self):
        print(f'Idx: {self.idx}, '
              f'Name: {self.name}, '
              f'Size: {self.size}, '
              f'VMA: {self.vma}, '
              f'LMA: {self.lma}, '
              f'File off: {self.file_off}, '
              f'Align: {self.align}, '
              f'CFG_FLAGS: {self.config_flags}'
              )

    # prints all members
    def debug_print(self):
        print(f'Idx: {self.idx}, '
              f'Name: {self.name}, '
              f'Size: {self.size}, '
              f'VMA: {self.vma}, '
              f'LMA: {self.lma}, '
              f'File off: {self.file_off}, '
              f'Align: {self.align}, '
              f'CFG_FLAGS: {self.config_flags}, '
              f'ALLOC?: {self.is_allocated}, '
              f'idx_int: {self.idx_int}, '
              f'size_int: {self.size_int}, '
              f'vma_int: {self.vma_int}, '
              f'lma_int: {self.lma_int}, '
              f'file_off_int: {self.file_off_int}, '
              f'align_int: {self.align_int}, '
              f'addr_range: {self.section_addr_range}, '
              f'relative_addr_range: {self.section_relative_addr_range}, '
              f'content_line_idx: {self.content_definition_line_idx}'
              )


# Contains methods to extract data using dump file object and write to output file
class HexFile:
    def __init__(self, dump_file, output_word_width_bits, output_num_words, output_file, trim_hex):
        self.dump_file = dump_file
        self.word_width_bits = output_word_width_bits
        self.word_width_bytes = ceil(self.word_width_bits/8)
        self.num_words = output_num_words
        self.output_path = output_file
        self.string_arr = []
        self.word_count = 0
        self.trim_hex = trim_hex
        # Determine required size of output file and verify that depth provided is adequate
        required_mem_depth = ceil(len(self.dump_file.byte_arr)/self.word_width_bytes)
        if required_mem_depth > self.num_words:
            sys.exit(f"[ERROR] Specified output memory depth of {self.num_words} is too small. " 
                     f"Must be at least {required_mem_depth}!")
        else:
            self.hex_byte_arr = [['00'] * self.word_width_bytes] * self.num_words

        self._populate_hex_byte_arr()
        self._generate_hex_string_arr()
        self._write_output_hex()

    # Extract data from dump file object for generating hex files
    def _populate_hex_byte_arr(self):
        word_byte_idx = self.word_width_bytes - 1
        word_idx = 0
        line = ['00']*self.word_width_bytes

        for byte in self.dump_file.byte_arr:
            line[word_byte_idx] = byte
            if word_byte_idx == 0:
                word_byte_idx = self.word_width_bytes - 1
                self.hex_byte_arr[word_idx] = line
                word_idx += 1
                line = ['00']*self.word_width_bytes
            else:
                word_byte_idx -= 1
        # save any remaining bytes
        self.hex_byte_arr[word_idx] = line
        # number of words in resulting hex
        self.word_count = word_idx+1
        # Trim hex if selected
        if self.trim_hex == 1:
            self.hex_byte_arr = self.hex_byte_arr[:self.word_count]

    # Combine bytes into word-sized strings for writing
    def _generate_hex_string_arr(self):
        for word in self.hex_byte_arr:
            tmp_str = ""
            for byte in word:
                tmp_str += byte            
            self.string_arr.append(tmp_str)

    # Write hex data to output file
    def _write_output_hex(self):
        with open(self.output_path, 'wt') as output_file:
            output_file.write(f"{'//'* 50}\n")
            output_file.write(f"// Script used for generation: {__file__}\n")
            output_file.write(f"// Date/time: {time}\n")
            output_file.write(f"// Parameters used:\n")
            output_file.write(f"// \t\tInput File Path     = {self.dump_file.dump_file_path}\n")
            output_file.write(f"// \t\tOutput File Path    = {self.output_path}\n")
            output_file.write(f"// \t\tMemory Width bits   = {self.word_width_bits}\n")
            output_file.write(f"// \t\tTarget Memory Depth = {self.num_words}\n")
            output_file.write(f"// \t\tHex File Depth      = {self.word_count}\n")
            output_file.write(f"{'//' * 50}\n")
            output_file.write("@0\n")            
            for word in self.string_arr:
                output_file.write(word + '\n')


def main():
    input_file = sys.argv[1]
    output_width_bits = int(sys.argv[2])
    mem_size_words = int(sys.argv[3])
    output_file = sys.argv[4]
    trim = int(sys.argv[5])

    print(f"\n[{time}] Running {__file__} with parameters:")
    print(f"Input File Path   = {input_file}")
    print(f"Output File Path  = {output_file}")
    print(f"Memory Width bits = {output_width_bits}")
    print(f"Memory Depth      = {mem_size_words}")
    print(f"Trim Hexfile      = {trim}\n")

    dump_file = DumpFile(input_file)
    HexFile(dump_file, output_width_bits, mem_size_words, output_file, trim)


if __name__ == "__main__":
    main()

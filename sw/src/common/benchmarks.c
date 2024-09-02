

/*! @addtogroup test_utils
@{
*/

#include <stdint.h>
#include <stddef.h>

#include "lfsr.h"

#include "crypto/share/benchmarks.h"

size_t test_rdrandom(unsigned char * dest, size_t len) {

  for(size_t i =0; i < len; i ++) {
    dest[i] = poll_rnd8();
  }
    
  return len;
}

uint64_t average_count(uint64_t* count_arr) {
  
  uint64_t tmp_average = 0;

  for(unsigned i = 0; i < TEST_COUNT; i++) {
    tmp_average += count_arr[i];
  }

  return (tmp_average/TEST_COUNT);
}



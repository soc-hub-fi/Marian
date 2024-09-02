// Copyright 2022 Rivos Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#ifndef ZVKSH_H_
#define ZVKSH_H_

#include <stdint.h>

extern void
zvksh_sm3_encode_lmul1(
    void* dest,
    const void* src,
    uint64_t length
);

extern void
zvksh_sm3_encode_lmul2(
    void* dest,
    const void* src,
    uint64_t length
);

extern void
zvksh_sm3_encode_lmul4(
    void* dest,
    const void* src,
    uint64_t length
);

#endif  // ZVKNS_H_
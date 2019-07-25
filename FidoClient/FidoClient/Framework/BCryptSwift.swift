//
//  BCryptSwift.swift
//  BCryptSwift
//
//  Created by Felipe Florencio Garcia on 3/14/17.
//  Copyright © 2017 Felipe Florencio Garcia. All rights reserved.
//
//  Originally created by Joe Kramer https://github.com/meanjoe45/JKBCrypt
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ----------------------------------------------------------------------
//
// This Swift port is based on the Objective-C port by Jay Fuerstenberg.
// https://github.com/jayfuerstenberg/JFCommon
//
// ----------------------------------------------------------------------
//
// The Objective-C port is based on the original Java implementation by Damien Miller
// found here: http://www.mindrot.org/projects/jBCrypt/
// In accordance with the Damien Miller's request, his original copyright covering
// his Java implementation is included here:
//
// Copyright (c) 2006 Damien Miller <djm@mindrot.org>
//
// Permission to use, copy, modify, and distribute this software for any
// purpose with or without fee is hereby granted, provided that the above
// copyright notice and this permission notice appear in all copies.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
// WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
// ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
// ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
// OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//
// Only the methods that are being used have been kept, and the files have
// been merged into one

import Foundation

// Table for Base64 encoding
let base64_code : [Character] = [
    ".", "/", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K",
    "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X",
    "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
    "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x",
    "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
]

// BCrypt parameters
let BCRYPT_SALT_LEN: Int = 16

public class BCryptSwift: NSObject {
 
    
    /**
     Generates a salt with a defaulted set of 10 rounds.
     
     :returns: String    The generated salt.
     */
    public class func generateSalt() -> String {
        return generateSaltWithNumberOfRounds(10)
    }



    /**
     Generates a salt with the provided number of rounds.
     
     :param: numberOfRounds  The number of rounds to apply.
     
     The work factor increases exponentially as the `numberOfRounds` increases.
     
     :returns: String    The generated salt
     */
    public class func generateSaltWithNumberOfRounds(_ rounds: UInt) -> String {
        let randomData : [Int8] = generateRandomSignedDataOfLength(BCRYPT_SALT_LEN)
        
        var salt : String
        salt =  "$2a$" + ((rounds < 10) ? "0" : "") + "\(rounds)" + "$"
        salt += encodeData(randomData, ofLength: UInt(randomData.count))
        
        return salt
    }
    
    /**
     Returns an [Int8] populated with bytes whose values range from -128 to 127.
     
     :param: length  The length of the resulting NSData (must be at least 1)
     
     :returns: [Int8]   [Int8] containing random signed bytes.
     */
    public class func generateRandomSignedDataOfLength(_ length: Int) -> [Int8] {
        guard length >= 1 else {
            return []
        }
        
        var sequence = generateNumberSequenceBetween(-128, 127, ofLength: length, withUniqueValues: false)
        var randomData : [Int8] = [Int8](repeating: 0, count: length)
        
        for i in 0 ..< length {
            randomData[i] = Int8(sequence[i])
        }
        
        return randomData
    }
    
    /**
     Generates an optionally unique sequence of random numbers between low and high and places them into the sequence.
     
     :param: length      The length of the sequence (must be at least 1)
     :param: low         The low number (must be lower or equal to high).
     :param: high        The high number (must be equal or higher than low).
     :param: onlyUnique  TRUE if only unique values are to be generated, FALSE otherwise.
     
     The condition is checked that if `onlyUnique` is TRUE the `length` cannot exceed the range of `low` to `high`.
     
     :returns: [Int32]
     */
    public class func generateNumberSequenceBetween(_ first: Int32, _ second: Int32, ofLength length: Int, withUniqueValues unique: Bool) -> [Int32] {
        if length < 1 {
            return [Int32]()
        }
        
        var sequence : [Int32] = [Int32](repeating: 0, count: length)
        if unique {
            if (first <= second && (length > (second - first) + 1)) ||
                (first > second  && (length > (first - second) + 1)) {
                return [Int32]()
            }
            
            var loop : Int = 0
            while loop < length {
                let number = generateNumberBetween(first, second)
                
                // If the number is unique, add it to the sequence
                if !isNumber(number, inSequence: sequence, ofLength: loop) {
                    sequence[loop] = number
                    loop += 1
                }
            }
        }
        else {
            // Repetitive values are allowed
            for i in 0 ..< length {
                sequence[i] = generateNumberBetween(first, second)
            }
        }
        
        return sequence
    }
    
    /**
     Generates a random number between low and high and places it into the receiver.
     
     :param: first   The first
     :param: second  The second
     
     :returns: Int32  Random 32-bit number
     */
    public class func generateNumberBetween(_ first: Int32, _ second: Int32) -> Int32 {
        var low : Int32
        var high : Int32
        
        if first <= second {
            low  = first
            high = second
        }
        else {
            low  = second
            high = first
        }
        
        let modular = UInt32((high - low) + 1)
        let random = arc4random()
        
        return Int32(random % modular) + low
    }
    
    /**
     Returns true if the provided number appears within the sequence.
     
     :param: number      The number to search for in the sequence.
     :param: sequence    The sequence to search in (must not be nil and must be of at least `length` elements)
     :param: length      The length of the sequence to test (must be at least 1)
     
     :returns: Bool      TRUE if `number` is found in sequence, FALSE if not found.
     */
    public class func isNumber(_ number: Int32, inSequence sequence: [Int32], ofLength length: Int) -> Bool {
        if length < 1 || length > sequence.count {
            return false
        }
        
        for i in 0 ..< length where sequence[i] == number {
            return true
        }
        
        // The number was not found, return false
        return false
    }
    
    /**
     Encodes an NSData composed of signed chararacters and returns slightly modified
     Base64 encoded string.
     
     :param: data    The data to be encoded. Passing nil will result in nil being returned.
     :param: length  The length. Must be greater than 0 and no longer than the length of data.
     
     :returns: String  A Base64 encoded string.
     */
    class fileprivate func encodeData(_ data: [Int8], ofLength length: UInt) -> String {
        
        if data.count == 0 || length == 0 {
            // Invalid data so return nil.
            return String()
        }
        
        var len : Int = Int(length)
        if len > data.count {
            len = data.count
        }
        
        var offset : Int = 0
        var c1 : UInt8
        var c2 : UInt8
        var result : String = String()
        
        var dataArray : [UInt8] = data.map {
            UInt8(bitPattern: Int8($0))
        }
        
        while offset < len {
            c1 = dataArray[offset] & 0xff
            offset += 1
            result.append(base64_code[Int((c1 >> 2) & 0x3f)])
            c1 = (c1 & 0x03) << 4
            if offset >= len {
                result.append(base64_code[Int(c1 & 0x3f)])
                break
            }
            
            c2 = dataArray[offset] & 0xff
            offset += 1
            c1 |= (c2 >> 4) & 0x0f
            result.append(base64_code[Int(c1 & 0x3f)])
            c1 = (c2 & 0x0f) << 2
            if offset >= len {
                result.append(base64_code[Int(c1 & 0x3f)])
                break
            }
            
            c2 = dataArray[offset] & 0xff
            offset += 1
            c1 |= (c2 >> 6) & 0x03
            result.append(base64_code[Int(c1 & 0x3f)])
            result.append(base64_code[Int(c2 & 0x3f)])
        }
        
        return result
    }
}


Pod::Spec.new do |spec|
  spec.name         = "FidoClientIOS"
  spec.version      = "0.1.0"
  spec.summary      = "This is the NHS digital Fido Client"
  spec.homepage     = "https://git.nhschoices.net/nhsonline/nhsonline-fido-client-ios"
  spec.license      = { :type => 'MIT', :text => <<-LICENSE
        MIT License

        Copyright (c) 2019 NHS Digital

        Permission is hereby granted, free of charge, to any person obtaining a copy
        of this software and associated documentation files (the "Software"), to deal
        in the Software without restriction, including without limitation the rights
        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        copies of the Software, and to permit persons to whom the Software is
        furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all
        copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.

  LICENSE
  }
  spec.author        = "NHS Digital"
  spec.platform      = :ios, "9.0"
  spec.source        = { :git => "https://git.nhschoices.net/nhsonline/nhsonline-fido-client-ios.git", :tag => "#{spec.version}" }
  spec.source_files  = "FIDOClient/**/*.{h,swift}"
  spec.exclude_files = ["FIDOClient/Exclude", "FIDOClient/FIDOClientTests/"]
  spec.swift_version = "5.0"
end


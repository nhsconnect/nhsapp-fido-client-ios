struct DisplayPNGCharacteristicsDescriptor: Codable {
    var width: Double = 0
    var height: Double = 0
    var bitDepth: String? = nil
    var colorType: String? = nil
    var compression: String? = nil
    var filter: String? = nil
    var interlace: String? = nil
    var plte: [RGBPalletteEntry]? = nil
    
    init(bitDepth: String?, colorType: String?, compression: String?, filter: String?, interlace: String?, plte: [RGBPalletteEntry]?){
        self.bitDepth = bitDepth
        self.colorType = colorType
        self.compression = compression
        self.filter = filter
        self.interlace = interlace
        self.plte = plte
    }
}



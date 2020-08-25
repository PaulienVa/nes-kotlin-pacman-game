; Kotlin pacman Game
;
; Author Paulien van Alst
;

  .inesprg 1    ; Defines the number of 16kb PRG banks
  .ineschr 1    ; Defines the number of 8kb CHR banks
  .inesmap 0    ; Defines the NES mapper
  .inesmir 1    ; Defines VRAM mirroring of banks

  .rsset $0000
pointerBackgroundLowByte  .rs 1
pointerBackgroundHighByte .rs 1

pacTile1Y = $0300
pacTile1X = $0303

scoreTile1Value = $030E   ; sprite is the 2nd bite
;
; gridY1 = #$3D  ; 8e rij
; gridY2 = #$42  ; 10e rij

  .bank 0
  .org $C000

RESET:
  JSR LoadBackground
  JSR LoadPalettes
  JSR LoadAttributes
  JSR LoadSprites
  JSR LoadScores

  LDA #%10000000   ; Enable NMI, sprites and background on table 0
  STA $2000
  LDA #%00011110   ; Enable sprites, enable backgrounds
  STA $2001
  LDA #$00         ; No background scrolling
  STA $2006
  STA $2006
  STA $2005
  STA $2005

InfiniteLoop:
  JMP InfiniteLoop

LoadBackground:
  LDA $2002
  LDA #$20
  STA $2006
  LDA #$00
  STA $2006

  LDA #LOW(background)
  STA pointerBackgroundLowByte
  LDA #HIGH(background)
  STA pointerBackgroundHighByte

  LDX #$00
  LDY #$00
.Loop:
  LDA [pointerBackgroundLowByte], y
  STA $2007

  INY
  CPY #$00
  BNE .Loop

  INC pointerBackgroundHighByte
  INX
  CPX #$04
  BNE .Loop
  RTS

LoadPalettes:
  LDA $2002
  LDA #$3F
  STA $2006
  LDA #$00
  STA $2006

  LDX #$00
.Loop:
  LDA palettes, x
  STA $2007
  INX
  CPX #$20
  BNE .Loop
  RTS

LoadAttributes:
  LDA $2002
  LDA #$23
  STA $2006
  LDA #$C0
  STA $2006
  LDX #$00
.Loop:
  LDA attributes, x
  STA $2007
  INX
  CPX #$40
  BNE .Loop
  RTS

LoadSprites:
  LDX #$00
.Loop:
  LDA sprites, x
  STA $0300, x
  INX
  CPX #$0D
  BNE .Loop
  RTS

LoadScores:
  LDX #$00
.Loop:
  LDA scores, x
  STA $030E, x
  INX
  CPX #$A2
  BNE .Loop
  RTS

ReadPlayerOneControls:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016

  LDA $4016       ; Player 1 - A
  LDA $4016       ; Player 1 - B
  LDA $4016       ; Player 1 - Select
  LDA $4016       ; Player 1 - Start

ReadUp:
  LDA $4016       ; Player 1 - Up
  AND #%00000001
  BEQ EndReadUp

  LDA pacTile1Y
  CMP #$3D
  BCC EndReadUp
  SEC
  SBC #$01
  STA pacTile1Y
EndReadUp:

ReadDown:
  LDA $4016       ; Player 1 - Down
  AND #%00000001
  BEQ EndReadDown

  LDA pacTile1Y
  CMP #$42
  BCS EndReadDown
  CLC
  ADC #$01
  STA pacTile1Y
EndReadDown:

ReadLeft:
  LDA $4016       ; Player 1 - Left
  AND #%00000001
  BEQ EndReadLeft

  LDA pacTile1X
  SEC
  SBC #$01
  STA pacTile1X
EndReadLeft:

ReadRight:
  LDA $4016       ; Player 1 - Right
  AND #%00000001
  BEQ EndReadRight

  LDA pacTile1X
  CLC
  ADC #$01
  STA pacTile1X

  ; BEQ AddOnes
EndReadRight:

  RTS

NMI:
  LDA #$00
  STA $2003
  LDA #$03
  STA $4014

  JSR ReadPlayerOneControls

  RTI

  .bank 1
  .org $E000

background:
  .include "graphics/background.asm"

palettes:
  .include "graphics/palettes.asm"

attributes:
  .include "graphics/attributes.asm"

sprites:
   .include "graphics/sprites.asm"

scores:
   .include "graphics/scores.asm"

  .org $FFFA
  .dw NMI
  .dw RESET
  .dw 0

  .bank 2
  .org $0000
  .incbin "graphics.chr"

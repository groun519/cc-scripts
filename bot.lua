local speaker = peripheral.wrap("left")

if not speaker then
 error("스피커 없음")
end

local decoder = require("cc.audio.dfpwm").make_decoder()

local file = fs.open("jang.dfpwm", "rb")

if not file then
 error("music 못 찾음")
end

while true do
 local chunk = file.read(16384)

 if chunk == nil then
  break
 end

 local buffer = decoder(chunk)

 while not speaker.playAudio(buffer) do
  os.pullEvent("speaker_audio_empty")
 end
end

file.close()

print("끝")
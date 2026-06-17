local speaker=peripheral.find("speaker")

local decoder=require("cc.audio.dfpwm").make_decoder()

local file=fs.open("music.dfpwm","rb")

while true do
 local chunk=file.read(16*1024)

 if not chunk then
  break
 end

 local buffer=decoder(chunk)

 while not speaker.playAudio(buffer) do
  os.pullEvent("speaker_audio_empty")
 end
end

file.close()
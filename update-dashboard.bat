@echo off
cd /d "C:\Users\Aditya Saxena\Desktop\gocomet-dashboard"
set TODAY=%date:~10,4%-%date:~4,2%-%date:~7,2%
echo Running Claude Code for %TODAY%...
claude --continue "Today is %TODAY%. Read only /transcripts/harshita/%TODAY%.txt, /transcripts/zara/%TODAY%.txt and /transcripts/maya/%TODAY%.txt. Add this date to dashboard.html following the same structure as previous dates. Do not touch existing dates."
git add dashboard.html
git commit -m "Dashboard update %TODAY%"
git push
echo Done! Dashboard live in 30 seconds.
pause
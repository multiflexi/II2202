#! /bin/bash

video=("old_town_cross_2160p50" "crowd_run_2160p50" "sintel")

function press_enter
{
	echo ""
	echo -n "Press Enter to continue"
	read
	clear
}

function evaluate_x264
{
	preset=(ultrafast superfast veryfast faster fast medium slow slower veryslow placebo)
	bitrate=(500 1000 1500 2000 2500 3000 3500 4000 4500 5000 6000 7000 8000 9000 10000 11000 12000 13000 14000 15000)

#	if [ -d Output/x264 ]; then
#		echo "x264 folder already exists, check for results"
#		return
#	elif [ ! -d Output/x264 ]; then
#		mkdir Output/x264
#	fi

#	if [ ! -d Output/x264/encoded ]; then
#		mkdir Output/x264/encoded
#	fi

#	if [ ! -d Output/x264/transcoded ]; then
#		mkdir Output/x264/transcoded
#	fi

#	if [ ! -d Output/x264/results ]; then
#		mkdir Output/x264/results
#	fi

#	if [ ! -d Output/x264/results/powergadget ]; then
#		mkdir Output/x264/results/powergadget
#	fi

#	if [ ! -d Output/x264/results/nvidiasmi ]; then
#		mkdir Output/x264/results/nvidiasmi
#	fi

#	if [ ! -d Output/x264/results/vqmt ]; then
#		mkdir Output/x264/results/vqmt
#	fi

#	if [ ! -d Output/x264/results/vmaf ]; then
#		mkdir Output/x264/results/vmaf
#	fi

	height=
	width=
	for v in "${video[@]}"; do
		for p in "${preset[@]}"; do
			for b in "${bitrate[@]}"; do
				echo -e "\e[92mStarting power consumption logging\e[0m"
				echo "modprobe msr"
				echo "modprobe cpuid"
				echo "Tools/power_gadget & > Output/x264/results/powergadget/$v$p$b.csv"
				echo "nvidia-smi -i 0 -l 1 --query-gpu=timestamp,pstate,temperature.gpu,utilization.gpu,memory.used,clocks.current.video,clocks.current.graphics,clocks.current.sm,fan.speed,power.draw --format=csv -f Output/x264/results/nvidiasmi/$v$p$b.csv"
				echo -e "\e[92mStarting Encoding\e[0m"
				echo "ffmpeg -benchmark -y -i Input/$v.yuv -c:v libx264 -preset $p -b:v $b -an Output/x264/encoded/$v$p$b"
				echo -e "\e[32mDone encoding\e[0m"
				echo -e "\e[32mStarting Transcoding\e[0m"
				echo "ffmpeg -i Output/x264/encoded/$v$p$b.mkv -c:v rawvideo -pix_fmt yuv420p Output/x264/transcoded/$v$p$b.yuv"
				echo -e "\e[32mDone transcoding\e[0m"
				echo -e "\e[32mStarting evaluation with VQMT and VMAF\e[0m" 
				if [ $v=${video[0]} ] || [ $v=${video[1]} ]; then
					height=2160
					width=3840
				else 
					height=1744
					width=4096
				fi
				echo $v
				echo "Tools/vqmt Input/$v.y4m Output/x264/transcoded/$v$p$b height width 500 1 Output/x264/results/vqmt/$v$p$p PSNRHVSM MSSSIM"
				echo "Tools/run_vmaf yuv420p width height Input/$v.y4m Output/x264/transcoded/$v$p$b --out-fmt text > Output/x264/results/vmaf/$v$p$b"
				echo -e "\e[32mDone evaluating with VQMT and VMAF\e[0m"
				echo "rm Output/x264/encoded/$v$p$b"
				echo "rm Output/x264/transcoded/$v$p$b"
			done	
		done	
	done	
	
}

function evaluate_test
{
	bitrate=(500k 1000k 1500k 2000k 2500k 3000k 3500k 4000k 4500k 5000k 6000k 7000k 8000k 9000k 10000k 11000k 12000k 13000k 14000k 15000k)

	if [ -d Output/test ]; then
		echo "test folder already exists, check for results"
		return
	elif [ ! -d Output/test ]; then
		mkdir Output/test
	fi

	if [ ! -d Output/test/encoded ]; then
		mkdir Output/test/encoded
	fi

	if [ ! -d Output/test/transcoded ]; then
		mkdir Output/test/transcoded
	fi

	if [ ! -d Output/test/results ]; then
		mkdir Output/test/results
	fi

	if [ ! -d Output/test/results/powergadget ]; then
		mkdir Output/test/results/powergadget
	fi

	if [ ! -d Output/test/results/ffmpeg ]; then
		mkdir Output/test/results/ffmpeg
	fi

	if [ ! -d Output/test/results/nvidiasmi ]; then
		mkdir Output/test/results/nvidiasmi
	fi

	if [ ! -d Output/test/results/vqmt ]; then
		mkdir Output/test/results/vqmt
	fi

	if [ ! -d Output/test/results/vmaf ]; then
		mkdir Output/test/results/vmaf
	fi

	height=
	width=
	for v in "${video[@]}"; do
		
			for b in "${bitrate[@]}"; do
				echo -e "\e[92mStarting power consumption logging\e[0m"
				modprobe msr
				modprobe cpuid
				Tools/power_gadget/power_gadget -e 1000 > Output/test/results/powergadget/$v$b.csv &
				nvidia-smi -i 0 -l 1 --query-gpu=timestamp,pstate,temperature.gpu,utilization.gpu,memory.used,clocks.current.video,clocks.current.graphics,clocks.current.sm,fan.speed,power.draw --format=csv -f Output/test/results/nvidiasmi/$v$b.csv &
				echo -e "\e[92mStarting Encoding\e[0m"
				FFREPORT=file=Output/test/results/ffmpeg/$v$b.log:level=32 Tools/ffmpeg/ffmpeg -benchmark -y -i Input/y4m/$v.y4m -c:v libtheora -b:v $b -an Output/test/encoded/$v$b.mkv
				echo -e "\e[93mDone with encoding\e[0m"
				pkill -f power_gadget
				pkill -f nvidia-smi
				echo -e "\e[93mDone with power consumption logging\e[0m"
				echo -e "\e[92mStarting Transcoding\e[0m"
				FFREPORT=file=Output/test/results/ffmpeg/T$v$b.log:level=32 Tools/ffmpeg/ffmpeg -i Output/test/encoded/$v$b.mkv -c:v rawvideo -pix_fmt yuv420p Output/test/transcoded/$v$b.yuv
				echo -e "\e[93mDone with transcoding\e[0m"
				echo -e "\e[92mStarting evaluation with VQMT and VMAF\e[0m"
				if [ "$v" == "${video[0]}" ] || [ "$v" == "${video[1]}" ]; then
					height=2160
					width=3840
				elif [ "$v" == "${video[2]}" ]; then 
					height=1744
					width=4096
				fi
				Tools/vqmt/vqmt Input/yuv/$v.yuv Output/test/transcoded/$v$b.yuv $height $width 500 1 Output/test/results/vqmt/$v$b PSNRHVSM MSSSIM &
				Tools/vmaf/run_vmaf yuv420p $width $height Input/yuv/$v.yuv Output/test/transcoded/$v$b.yuv --out-fmt text > Output/test/results/vmaf/$v$b &
				wait ${!}
				echo -e "\e[93mDone with evaluating with VQMT and VMAF\e[0m"
				rm Output/test/encoded/$v$b.mkv
				rm Output/test/transcoded/$v$b.yuv
			done
	chmod -R 777 Output/test	
			
	done	
	
}


selection=

until [ "$selection" = "0" ]; do
	echo ""
	echo "SELECT AN ENCODER"
	echo "1 - x264"
	echo "2 - x265"
	echo "3 - NVENC h264"
	echo "4 - NVENC h265"
	echo "5 - QSV h264" 
	echo ""
	echo "6 - Test"
	echo "0 - Exit"
	echo "" 
	echo -n "Enter selection"
	read selection
	case $selection in
		1 ) evaluate_x264; press_enter ;;
		2 ) echo "evaluate_x265"; press_enter;;
		3 ) echo "evaluate_NVENCh264"; press_enter;;
		4 ) echo "evaluate_NVENCh265"; press_enter;;
		5 ) echo "evaluate_QSVh264"; press_enter;;
		6 ) evaluate_test; press_enter;;
		0 ) exit;;
		* ) echo "Selection not valid"; press_enter;
	esac
done







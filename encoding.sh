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
    bitrate=(500k 1000k 1500k 2000k 2500k 3000k 3500k 4000k 4500k 5000k 6000k 7000k 8000k 9000k 10000k 11000k 12000k 13000k 14000k 15000k)
    preset=(ultrafast superfast veryfast faster fast medium slow slower veryslow placebo)

    if [ -d Output/x264 ]; then
        echo "test folder already exists, check for results"
        return
    elif [ ! -d Output/x264 ]; then
        mkdir Output/x264
    fi

    if [ ! -d Output/x264/encoded ]; then
        mkdir Output/x264/encoded
    fi

    if [ ! -d Output/x264/transcoded ]; then
        mkdir Output/x264/transcoded
    fi

    if [ ! -d Output/x264/results ]; then
        mkdir Output/x264/results
    fi

    if [ ! -d Output/x264/results/powergadget ]; then
        mkdir Output/x264/results/powergadget
    fi

    if [ ! -d Output/x264/results/ffmpeg ]; then
        mkdir Output/x264/results/ffmpeg
    fi

    if [ ! -d Output/x264/results/vqmt ]; then
        mkdir Output/x264/results/vqmt
    fi

    if [ ! -d Output/x264/results/vmaf ]; then
        mkdir Output/x264/results/vmaf
    fi

    chmod -R 777 Output/x264

    height=
    width=

    for v in "${video[@]}"; do
        for p in "${preset[@]}"; do
            for b in "${bitrate[@]}"; do
                echo -e "\e[92mStarting power consumption logging\e[0m"
                modprobe msr
                modprobe cpuid
                Tools/power_gadget/power_gadget -e 1000 > Output/x264/results/powergadget/$v$p$b.csv &
                echo -e $(date -u) "\e[92mStarting Encoding\e[0m"
                FFREPORT=file=Output/x264/results/ffmpeg/$v$p$b.log:level=32 Tools/ffmpeg/ffmpeg -benchmark -y -i Input/y4m/$v.y4m -c:v libx264 -preset $p -b:v $b -an Output/x264/encoded/$v$p$b.mkv
                echo -e $(date -u) "\e[93mDone with encoding\e[0m"
                pkill -f power_gadget
                echo -e $(date -u) "\e[93mDone with power consumption logging\e[0m"
                echo -e $(date -u) "\e[92mStarting Transcoding\e[0m"
                FFREPORT=file=Output/x264/results/ffmpeg/T$v$p$b.log:level=32 Tools/ffmpeg/ffmpeg -i Output/x264/encoded/$v$p$b.mkv -c:v rawvideo -pix_fmt yuv420p Output/x264/transcoded/$v$p$b.yuv
                echo -e $(date -u) "\e[93mDone with transcoding\e[0m"
                echo -e $(date -u) "\e[92mStarting evaluation with VQMT and VMAF\e[0m"
                if [ "$v" == "${video[0]}" ] || [ "$v" == "${video[1]}" ]; then
                    height=2160
                    width=3840
                elif [ "$v" == "${video[2]}" ]; then
                    height=1744
                    width=4096
                fi
                Tools/vqmt/vqmt Input/yuv/$v.yuv Output/x264/transcoded/$v$p$b.yuv $height $width 500 1 Output/x264/results/vqmt/$v$p$b PSNRHVSM MSSSIM &
                Tools/vmaf/run_vmaf yuv420p $width $height Input/yuv/$v.yuv Output/x264/transcoded/$v$p$b.yuv --out-fmt text > Output/x264/results/vmaf/$v$p$b &
                wait ${!}
                echo -e $(date -u) "\e[93mDone with evaluating with VQMT and VMAF\e[0m"
                rm Output/x264/encoded/$v$p$b.mkv
                rm Output/x264/transcoded/$v$p$b.yuv
            done
        done
    done

}

function evaluate_x265
{
    bitrate=(500k 1000k 1500k 2000k 2500k 3000k 3500k 4000k 4500k 5000k 6000k 7000k 8000k 9000k 10000k 11000k 12000k 13000k 14000k 15000k)
    preset=(ultrafast superfast veryfast faster fast medium slow slower veryslow placebo)

    if [ -d Output/x265 ]; then
        echo "test folder already exists, check for results"
        return
    elif [ ! -d Output/x265 ]; then
        mkdir Output/x265
    fi

    if [ ! -d Output/x265/encoded ]; then
        mkdir Output/x265/encoded
    fi

    if [ ! -d Output/x265/transcoded ]; then
        mkdir Output/x265/transcoded
    fi

    if [ ! -d Output/x265/results ]; then
        mkdir Output/x265/results
    fi

    if [ ! -d Output/x265/results/powergadget ]; then
        mkdir Output/x265/results/powergadget
    fi

    if [ ! -d Output/x265/results/ffmpeg ]; then
        mkdir Output/x265/results/ffmpeg
    fi

    if [ ! -d Output/x265/results/nvidiasmi ]; then
        mkdir Output/x265/results/nvidiasmi
    fi

    if [ ! -d Output/x265/results/vqmt ]; then
        mkdir Output/x265/results/vqmt
    fi

    if [ ! -d Output/x265/results/vmaf ]; then
        mkdir Output/x265/results/vmaf
    fi

    chmod -R 777 Output/x265

    height=
    width=

    for v in "${video[@]}"; do
        for p in "${preset[@]}"; do
            for b in "${bitrate[@]}"; do
                echo -e "\e[92mStarting power consumption logging\e[0m"
                modprobe msr
                modprobe cpuid
                Tools/power_gadget/power_gadget -e 1000 > Output/x265/results/powergadget/$v$p$b.csv &
                nvidia-smi -i 0 -l 1 --query-gpu=timestamp,pstate,temperature.gpu,utilization.gpu,memory.used,clocks.current.video,clocks.current.graphics,clocks.current.sm,fan.speed,power.draw --format=csv -f Output/x265/results/nvidiasmi/$v$p$b.csv &
                echo -e "\e[92mStarting Encoding\e[0m"
                FFREPORT=file=Output/x265/results/ffmpeg/$v$p$b.log:level=32 Tools/ffmpeg/ffmpeg -benchmark -y -i Input/y4m/$v.y4m -c:v libx265 -preset $p -b:v $b -an Output/x265/encoded/$v$p$b.mkv
                echo -e "\e[93mDone with encoding\e[0m"
                pkill -f power_gadget
                pkill -f nvidia-smi
                echo -e "\e[93mDone with power consumption logging\e[0m"
                echo -e "\e[92mStarting Transcoding\e[0m"
                FFREPORT=file=Output/x265/results/ffmpeg/T$v$p$b.log:level=32 Tools/ffmpeg/ffmpeg -i Output/x265/encoded/$v$p$b.mkv -c:v rawvideo -pix_fmt yuv420p Output/x265/transcoded/$v$p$b.yuv
                echo -e "\e[93mDone with transcoding\e[0m"
                echo -e "\e[92mStarting evaluation with VQMT and VMAF\e[0m"
                if [ "$v" == "${video[0]}" ] || [ "$v" == "${video[1]}" ]; then
                    height=2160
                    width=3840
                elif [ "$v" == "${video[2]}" ]; then
                    height=1744
                    width=4096
                fi
                Tools/vqmt/vqmt Input/yuv/$v.yuv Output/x265/transcoded/$v$p$b.yuv $height $width 500 1 Output/x265/results/vqmt/$v$p$b PSNRHVSM MSSSIM &
                Tools/vmaf/run_vmaf yuv420p $width $height Input/yuv/$v.yuv Output/x265/transcoded/$v$p$b.yuv --out-fmt text > Output/x265/results/vmaf/$v$p$b &
                wait ${!}
                echo -e "\e[93mDone with evaluating with VQMT and VMAF\e[0m"
                rm Output/x265/encoded/$v$p$b.mkv
                rm Output/x265/transcoded/$v$p$b.yuv
            done
        done
    done
}

function evaluate_NVENCh264
{
    bitrate=(500k 1000k 1500k 2000k 2500k 3000k 3500k 4000k 4500k 5000k 6000k 7000k 8000k 9000k 10000k 11000k 12000k 13000k 14000k 15000k)
    preset=(medium fast hp hq bd ll llhq llhp)

    if [ -d Output/NVENCh264 ]; then
        echo "test folder already exists, check for results"
        return
    elif [ ! -d Output/NVENCh264 ]; then
        mkdir Output/NVENCh264
    fi

    if [ ! -d Output/NVENCh264/encoded ]; then
        mkdir Output/NVENCh264/encoded
    fi

    if [ ! -d Output/NVENCh264/transcoded ]; then
        mkdir Output/NVENCh264/transcoded
    fi

    if [ ! -d Output/NVENCh264/results ]; then
        mkdir Output/NVENCh264/results
    fi

    if [ ! -d Output/NVENCh264/results/powergadget ]; then
        mkdir Output/NVENCh264/results/powergadget
    fi

    if [ ! -d Output/NVENCh264/results/ffmpeg ]; then
        mkdir Output/NVENCh264/results/ffmpeg
    fi

    if [ ! -d Output/NVENCh264/results/nvidiasmi ]; then
        mkdir Output/NVENCh264/results/nvidiasmi
    fi

    if [ ! -d Output/NVENCh264/results/vqmt ]; then
        mkdir Output/NVENCh264/results/vqmt
    fi

    if [ ! -d Output/NVENCh264/results/vmaf ]; then
        mkdir Output/NVENCh264/results/vmaf
    fi

    chmod -R 777 Output/NVENCh264

    height=
    width=

    for p in "${preset[@]}"; do
        for b in "${bitrate[@]}"; do
            for v in "${video[@]}"; do
                echo -e $(date -u) "\e[92mStarting power consumption logging\e[0m"
                modprobe msr
                modprobe cpuid
                Tools/power_gadget/power_gadget -e 1000 > Output/NVENCh264/results/powergadget/$v$p$b.csv &
                nvidia-smi -i 0 -l 1 --query-gpu=timestamp,pstate,temperature.gpu,utilization.gpu,memory.used,clocks.current.video,clocks.current.graphics,clocks.current.sm,fan.speed,power.draw --format=csv -f Output/NVENCh264/results/nvidiasmi/$v$p$b.csv &
                echo -e $(date -u) "\e[92mStarting Encoding\e[0m"
                FFREPORT=file=Output/NVENCh264/results/ffmpeg/$v$p$b.log:level=32 Tools/ffmpeg/ffmpeg -benchmark -y -i Input/y4m/$v.y4m -c:v h264_nvenc -preset $p -b:v $b -an Output/NVENCh264/encoded/$v$p$b.mkv
                echo -e $(date -u) "\e[93mDone with encoding\e[0m"
                pkill -f power_gadget
                pkill -f nvidia-smi
                echo -e $(date -u) "\e[93mDone with power consumption logging\e[0m"
                echo -e $(date -u) "\e[92mStarting Transcoding\e[0m"
                FFREPORT=file=Output/NVENCh264/results/ffmpeg/T$v$p$b.log:level=32 Tools/ffmpeg/ffmpeg -i Output/NVENCh264/encoded/$v$p$b.mkv -c:v rawvideo -pix_fmt yuv420p Output/NVENCh264/transcoded/$v$p$b.yuv
                echo -e $(date -u) "\e[93mDone with transcoding\e[0m"
	    done
	    for v in "${video[@]}"; do
                echo -e $(date -u) "\e[92mStarting evaluation with VQMT and VMAF\e[0m"
                if [ "$v" == "${video[0]}" ] || [ "$v" == "${video[1]}" ]; then
                    height=2160
                    width=3840
                elif [ "$v" == "${video[2]}" ]; then
                    height=1744
                    width=4096
                fi
                Tools/vqmt/vqmt Input/yuv/$v.yuv Output/NVENCh264/transcoded/$v$p$b.yuv $height $width 500 1 Output/NVENCh264/results/vqmt/$v$p$b PSNRHVSM MSSSIM &
                Tools/vmaf/run_vmaf yuv420p $width $height Input/yuv/$v.yuv Output/NVENCh264/transcoded/$v$p$b.yuv --out-fmt text > Output/NVENCh264/results/vmaf/$v$p$b &
            done
	    wait 
	    echo -e $(date -u) "\e[93mDone with evaluating with VQMT and VMAF\e[0m"
	    for v in "${video[@]}"; do
                rm Output/NVENCh264/encoded/$v$p$b.mkv
                rm Output/NVENCh264/transcoded/$v$p$b.yuv
 	    done
        done
    done
}

function evaluate_NVENCh265
{
    bitrate=(500k 1000k 1500k 2000k 2500k 3000k 3500k 4000k 4500k 5000k 6000k 7000k 8000k 9000k 10000k 11000k 12000k 13000k 14000k 15000k)
    preset=(medium fast hp hq bd ll llhq llhp)

    if [ -d Output/NVENCh265 ]; then
        echo "test folder already exists, check for results"
        return
    elif [ ! -d Output/NVENCh265 ]; then
        mkdir Output/NVENCh265
    fi

    if [ ! -d Output/NVENCh265/encoded ]; then
        mkdir Output/NVENCh265/encoded
    fi

    if [ ! -d Output/NVENCh265/transcoded ]; then
        mkdir Output/NVENCh265/transcoded
    fi

    if [ ! -d Output/NVENCh265/results ]; then
        mkdir Output/NVENCh265/results
    fi

    if [ ! -d Output/NVENCh265/results/powergadget ]; then
        mkdir Output/NVENCh265/results/powergadget
    fi

    if [ ! -d Output/NVENCh265/results/ffmpeg ]; then
        mkdir Output/NVENCh265/results/ffmpeg
    fi

    if [ ! -d Output/NVENCh265/results/nvidiasmi ]; then
        mkdir Output/NVENCh265/results/nvidiasmi
    fi

    if [ ! -d Output/NVENCh265/results/vqmt ]; then
        mkdir Output/NVENCh265/results/vqmt
    fi

    if [ ! -d Output/NVENCh265/results/vmaf ]; then
        mkdir Output/NVENCh265/results/vmaf
    fi

    chmod -R 777 Output/NVENCh265

    height=
    width=

    for v in "${video[@]}"; do
        for p in "${preset[@]}"; do
            for b in "${bitrate[@]}"; do
                echo -e "\e[92mStarting power consumption logging\e[0m"
                modprobe msr
                modprobe cpuid
                Tools/power_gadget/power_gadget -e 1000 > Output/NVENCh265/results/powergadget/$v$p$b.csv &
                nvidia-smi -i 0 -l 1 --query-gpu=timestamp,pstate,temperature.gpu,utilization.gpu,memory.used,clocks.current.video,clocks.current.graphics,clocks.current.sm,fan.speed,power.draw --format=csv -f Output/NVENCh265/results/nvidiasmi/$v$p$b.csv &
                echo -e "\e[92mStarting Encoding\e[0m"
                FFREPORT=file=Output/NVENCh265/results/ffmpeg/$v$p$b.log:level=32 Tools/ffmpeg/ffmpeg -benchmark -y -i Input/y4m/$v.y4m -c:v nvenc_hevc -preset $p -b:v $b -an Output/NVENCh265/encoded/$v$p$b.mkv
                echo -e "\e[93mDone with encoding\e[0m"
                pkill -f power_gadget
                pkill -f nvidia-smi
                echo -e "\e[93mDone with power consumption logging\e[0m"
                echo -e "\e[92mStarting Transcoding\e[0m"
                FFREPORT=file=Output/NVENCh265/results/ffmpeg/T$v$p$b.log:level=32 Tools/ffmpeg/ffmpeg -i Output/NVENCh265/encoded/$v$p$b.mkv -c:v rawvideo -pix_fmt yuv420p Output/NVENCh265/transcoded/$v$p$b.yuv
                echo -e "\e[93mDone with transcoding\e[0m"
                echo -e "\e[92mStarting evaluation with VQMT and VMAF\e[0m"
                if [ "$v" == "${video[0]}" ] || [ "$v" == "${video[1]}" ]; then
                    height=2160
                    width=3840
                elif [ "$v" == "${video[2]}" ]; then
                    height=1744
                    width=4096
                fi
                Tools/vqmt/vqmt Input/yuv/$v.yuv Output/NVENCh265/transcoded/$v$p$b.yuv $height $width 500 1 Output/NVENCh265/results/vqmt/$v$p$b PSNRHVSM MSSSIM &
                Tools/vmaf/run_vmaf yuv420p $width $height Input/yuv/$v.yuv Output/NVENCh265/transcoded/$v$p$b.yuv --out-fmt text > Output/NVENCh265/results/vmaf/$v$p$b &
                wait ${!}
                echo -e "\e[93mDone with evaluating with VQMT and VMAF\e[0m"
                rm Output/NVENCh265/encoded/$v$p$b.mkv
                rm Output/NVENCh265/transcoded/$v$p$b.yuv
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
	echo -n "Enter selection: "
	read selection
	case $selection in
		1 ) evaluate_x264; press_enter ;;
		2 ) evaluate_x265; press_enter;;
		3 ) evaluate_NVENCh264; press_enter;;
		4 ) evaluate_NVENCh265; press_enter;;
		5 ) echo "evaluate_QSVh264"; press_enter;;
		6 ) evaluate_test; press_enter;;
		0 ) exit;;
		* ) echo "Selection not valid"; press_enter;
	esac
done







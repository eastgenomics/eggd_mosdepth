#!/bin/bash
# eggd_mosdepth 1.0.0

main() {
    
    gunzip mosdepth_container.tar.gz

    # dir for downloaded files
    mkdir input
    mkdir -p out/mosdepth_output

    # downloads all input files to /in with individual sub dirs, move all to /input
    dx-download-all-inputs
    find ~/in -type f -name "*" -print0 | xargs -0 -I {} mv {} ~/input

    # check if set, if not set to empty string
    if [[ -z $optional_arguments ]]; then
      optional_arguments=""
    fi

    # if flag set add in to optional arguments
    if [ "$qual_flags" = true ]; then
      optional_arguments+=" --flag 1796 --mapq 20";
    fi


    if [[ $bed ]]; then
      # if bed file is being used
      # specify path of bed in container, then add the full bed path after --by to optional args
      bed_path="/data/input/$bed_prefix.bed"
      bed_arg="--by $bed_path"
      optional_arguments="${optional_arguments} ${bed_arg}"
    fi

    echo $optional_arguments
    
    # add dnanexus user to docker group & start docker daemon
    sudo usermod -a -G docker dnanexus
    newgrp docker
    sudo systemctl start docker

    # load local container & get id
    sudo docker load --input mosdepth_container.tar
    mosdepth_id=$(docker images --format="{{.Repository}} {{.ID}}" | grep "^quay.io" | cut -d' ' -f2) 

    if [[ $optional_arguments =~ "--quantize" ]]; then
        # if --quantize option given
        if [[ $quantize_labels ]]; then
          # optional labels passed
          echo "using specified labels"
          echo $quantize_labels

          # build string of labels from array in format for mosdepth
          IFS=", " read -r -a array <<< $quantize_labels
          labels=""
          for i in "${!array[@]}"; do 
            labels+=MOSDEPTH_Q$i="${array[$i]}" && labels+=" ";
          done

          # set bam path variable to pass
          bam_file="/data/input/$bam_prefix.bam"

          # pass env variables to container, loop to export labels to container env varibales
          # then run mosdepth
          sudo docker run -v `pwd`:/data \
          --env labels="$labels" --env optional_arguments="$optional_arguments" \
          --env bam_prefix="$bam_prefix" --env bam_file="$bam_file" \
          -w "/data/out/mosdepth_output" \
          $mosdepth_id /bin/bash -c \
          'for label in $labels; do export $label; done; mosdepth $optional_arguments $bam_prefix $bam_file'  
        else

        # no labels given, use default
        sudo docker run -v `pwd`:/data -w "/data/out/mosdepth_output" $mosdepth_id /bin/bash -c \
        "export MOSDEPTH_Q0=NO_COVERAGE; 
         export MOSDEPTH_Q1=LOW_COVERAGE;
         export MOSDEPTH_Q2=CALLABLE;
         export MOSDEPTH_Q3=HIGH_COVERAGE;
         mosdepth $optional_arguments $bam_prefix '/data/input/$bam_prefix.bam'"
        fi
    else
    # not using quantize option, run mosdepth normally with container
    sudo docker run -v `pwd`:/data -w "/data/out/mosdepth_output" $mosdepth_id mosdepth $optional_arguments $bam_prefix "/data/input/$bam_prefix.bam"
    fi

    echo "app finished, uploading files"
    
    # upload output files
    dx-upload-all-outputs

    echo "uploaded"
}

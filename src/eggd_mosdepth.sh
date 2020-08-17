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

    if [[ $bed ]]; then
      # if bed file is being used

      # DNAnexus doesn't seem to handle passing files through optional string well
      # get full path of bed, then add the full bed path after --by to optional args
      bed_path=$(realpath ~/input/*.bed)
      bed_arg="--by $bed_path"
      optional_arguments="${optional_arguments} ${bed_arg}"
    fi

    if [[ $optional_arguments =~ "--quantize" ]]; then
        # if --quantize option given
        if [[ $quantize_labels ]]; then
          # optional labels passed
          echo "Using user defined labels"
          IFS=',' read -r -a array <<< "$quantize_labels"
          for i in "${!array[@]}"
          # loop over label array, pass label no. and label
          do
              export MOSDEPTH_Q$i="${array[$i]}"
          done
    
        else
        # no labels given, use default
        echo "Using default 4 labels:"
        echo "MOSDEPTH_Q0=NO_COVERAGE"
        echo "MOSDEPTH_Q1=LOW_COVERAGE"
        echo "MOSDEPTH_Q2=CALLABLE"
        echo "MOSDEPTH_Q3=HIGH_COVERAGE"
        
        export MOSDEPTH_Q0=NO_COVERAGE
        export MOSDEPTH_Q1=LOW_COVERAGE
        export MOSDEPTH_Q2=CALLABLE
        export MOSDEPTH_Q3=HIGH_COVERAGE
        fi
    fi

    # check if set, if not set to empty string
    if [[ -z $optional_arguments ]]; then
      optional_arguments=""
    fi
    
    echo "Using following optional arguments:"
    echo $optional_arguments
    echo $quantize_labels

    # add dnanexus user to docker group
    sudo usermod -a -G docker dnanexus
    newgrp docker

    sudo systemctl start docker

    # load local container & get id
    sudo docker load --input mosdepth_container.tar
    mosdepth_id=$(docker images --format="{{.Repository}} {{.ID}}" | grep "^quay.io" | cut -d' ' -f2) 

    # command to run mosdepth
    cmd="mosdepth $optional_arguments $bam_prefix ../../input/*bam"
    echo $cmd

    # run container with ID and mosdepth cmd
    sudo docker run -v "/home/dnanexus/input:/input" -v "/home/dnanexus/out/:/out" -w "/out/mosdepth_output" $mosdepth_id /bin/bash -c $cmd

    echo "output:"   
    ls out/mosdepth_output

    echo "app finished, uploading files"
    # upload output files
    dx-upload-all-outputs
    cp this that
    echo "uploaded"
}

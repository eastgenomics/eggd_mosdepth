#!/bin/bash
# eggd_mosdepth 1.0.0

main() {
    
    # temp dir for downloaded files
    mkdir ~/input/

    # downloads all input files to /in with individual sub dirs, move all to /input
    dx-download-all-inputs
    find ~/in -type f -name "*" -print0 | xargs -0 -I {} mv {} ~/input

    filename="${bam_name%%.*}"

    if [[ $optional_arguments =~ "--by" ]]; then
      # if bed file is being used

      # DNAnexus doesn't seem to handle passing files through optional string well
      # get full path of bed, then add the full bed path after --by to pass bed
      bed_path=$(realpath ~/input/*.bed)

      bed_arg="--by $bed_path"

      optional_arguments="${optional_arguments/--by/$bed_arg}"
    fi

    if [[ $optional_arguments =~ "--quantize" ]]; then
        # if --quantize option given
        echo "setting labels"
        if [[ $quantize_labels ]]; then
          # optional labels passed
          echo "custom labels"
          IFS=',' read -r -a array <<< "$quantize_labels"
          for i in "${array[@]}"
          # loop over label array, pass label no. and label
          do
              export MOSDEPTH_Q$i="${array[$i]}"
          done
    
        else
        # no labels given, use default
        echo "standard labels"
        export MOSDEPTH_Q0=NO_COVERAGE
        export MOSDEPTH_Q1=LOW_COVERAGE
        export MOSDEPTH_Q2=CALLABLE
        export MOSDEPTH_Q3=HIGH_COVERAGE

        fi
    fi
    
    echo "Using following optional arguments:"
    echo $optional_arguments
    echo $quantize_labels

    # get conda and build it, required to install mosdepth
    wget -q https://repo.anaconda.com/miniconda/Miniconda2-latest-Linux-x86_64.sh 

    bash ~/Miniconda2-latest-Linux-x86_64.sh -b -p $HOME/miniconda

    source ~/miniconda/bin/activate

    conda init

    source ~/.bashrc

    # add required channels for mosdepth
    conda config --add channels bioconda
    conda config --add channels conda-forge

    conda install mosdepth

    # run in output directory
    mkdir ~/output && cd ~/output
    

    echo "running mosdepth using:"
    echo $filename
    echo "mosdepth $optional_arguments $filename ~/input/*.bam"

    # run mosdepth
    mosdepth $optional_arguments $filename ~/input/*.bam


    
    
    echo "app finished, uploading files"

    # uploads files and passes dx file-id to dx-jobutil-add-output
    # to add to the mosdepth_output array:file
    for file in ./*; 
      do id=$(dx upload $file --brief) && dx-jobutil-add-output --array mosdepth_output "$id"; 
    done

    echo "uploaded"
}

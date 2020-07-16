#!/bin/bash
# eggd_mosdepth 1.0.0

main() {
    
    # temp dir for downloaded files
    mkdir ~/input/

    # downloads all input files to /in with individual sub dirs, move all to /input
    dx-download-all-inputs
    find ~/in -type f -name "*" -print0 | xargs -0 -I {} mv {} ~/input

    # unzip miniconda installer, has to be zipped as it has syntax errors that
    # prevent dx build from working
    gunzip Miniconda2-latest-Linux-x86_64.sh.gz

    if [[ $bed ]]; then
      # if bed file is being used

      # DNAnexus doesn't seem to handle passing files through optional string well
      # get full path of bed, then add the full bed path after --by to pass bed
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
    
    echo "Using following optional arguments:"
    echo $optional_arguments
    echo $quantize_labels

    # build miniconda, required to install mosdepth
    bash ~/Miniconda2-latest-Linux-x86_64.sh -b -p $HOME/miniconda

    source ~/miniconda/bin/activate

    conda init

    source ~/.bashrc

    # add required channels for mosdepth
    conda config --add channels bioconda
    conda config --add channels conda-forge

    conda install mosdepth

    # run in output directory
    mkdir -p ~/out/mosdepth_output && cd ~/out/mosdepth_output
    
    echo "running mosdepth"
    echo "mosdepth $optional_arguments $bam_prefix ~/input/*.bam"

    # run mosdepth
    mosdepth $optional_arguments $bam_prefix ~/input/*.bam

    echo "app finished, uploading files"

    # upload output files
    dx-upload-all-outputs

    echo "uploaded"
}

#!/usr/bin/env cwl-runner
cwlVersion: "cwl:draft-3"
class: Workflow
description: "ATAC-seq 02 trimming - reads: SE"
requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
inputs:
  - id: "#input_read1_fastq_files"
    type:
      type: array
      items: File
    description: "Input fastq files"
  - id: "#input_adapters_files"
    type:
      type: array
      items: File
    description: "Input adapters files"
  - id: "#nthreads"
    type: int
    default: 1
    description: "Number of threads"
  - id: "#quality_score"
    type: string
    default: "-phred33"
  - id: "#trimmomatic_jar_path"
    type: string
    default: "/usr/share/java/trimmomatic.jar"
    description: "Trimmomatic Java jar file"
  - id: "#trimmomatic_java_opts"
    type:
      - 'null'
      - string
    description: "JVM arguments should be a quoted, space separated list"
outputs:
  - id: "#output_data_fastq_trimmed_files"
    source: "#trimmomatic.output_read1_trimmed_file"
    description: "Trimmed fastq files"
    type:
      type: array
      items: File
  - id: "#trimmed_fastq_read_count"
    source: "#count_fastq_reads.output_read_count"
    description: "Trimmed read counts of fastq files"
    type:
      type: array
      items: File
steps:
  - id: "#trimmomatic"
    run: {$import: "../trimmomatic/trimmomatic.cwl"}
    scatter:
      - "#trimmomatic.input_read1_fastq_file"
      - "#trimmomatic.input_adapters_file"
    scatterMethod: dotproduct
    inputs:
      - id: "#trimmomatic.input_read1_fastq_file"
        source: "#input_read1_fastq_files"
      - id: "#trimmomatic.input_adapters_file"
        source: "#input_adapters_files"
      - id: "#trimmomatic.nthreads"
        source: "#nthreads"
      - id: "#trimmomatic.java_opts"
        source: "#trimmomatic_java_opts"
      - id: "#trimmomatic.trimmomatic_jar_path"
        source: "#trimmomatic_jar_path"
      - id: "#trimmomatic.end_mode"
        valueFrom: "SE"
      - id: "#trimmomatic.illuminaclip"
        valueFrom: "2:30:15"
      - id: "#trimmomatic.leading"
        valueFrom: $(3)
      - id: "#trimmomatic.trailing"
        valueFrom: $(3)
      - id: "#trimmomatic.slidingwindow"
        valueFrom: "4:20"
      - id: "#trimmomatic.minlen"
        valueFrom: $(15)
      - id: "#trimmomatic.phred"
        valueFrom: "33"
    outputs:
      - id: "#trimmomatic.output_read1_trimmed_file"
  - id: "#extract_basename"
    run: {$import: "../utils/extract-basename.cwl" }
    scatter: "#extract_basename.input_file"
    inputs:
      - id: "#extract_basename.input_file"
        source: "#trimmomatic.output_read1_trimmed_file"
    outputs:
      - id: "#extract_basename.output_basename"
  - id: "#count_fastq_reads"
    run: {$import: "../utils/count-fastq-reads.cwl" }
    scatter:
      - "#count_fastq_reads.input_fastq_file"
      - "#count_fastq_reads.input_basename"
    scatterMethod: dotproduct
    inputs:
      - id: "#count_fastq_reads.input_fastq_file"
        source: "#trimmomatic.output_read1_trimmed_file"
      - id: "#count_fastq_reads.input_basename"
        source: "#extract_basename.output_basename"
    outputs:
      - id: "#count_fastq_reads.output_read_count"
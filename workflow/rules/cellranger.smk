import glob
import os
from pathlib import Path

def get_sample_option(wc):
    option_str=""
    prefix=units["sample"][wc.sample] 
    option_str += f"--sample={prefix}"
    return option_str

def get_fq_path(wc):
    filepath = units["fq1"][wc.sample][0]
    dirname, basename = os.path.split(filepath)
    return dirname

rule cellranger_count:
    input:
        fq=get_fq_path
    output:
        raw="{OUTDIR}/cellranger_count/{sample}/raw_feature_bc_matrix.h5",
        filtered="{OUTDIR}/cellranger_count/{sample}/filtered_feature_bc_matrix.h5",
        bam="{OUTDIR}/cellranger_count/{sample}/possorted_genome_bam.bam"
    params:
        reference=config['cellranger']['reference']
    envmodules:
        config['envmodules']['cellranger']
    threads: get_resource("cellranger", "threads")
    resources:
        mem_mb=get_resource("cellranger", "mem_mb"),
        walltime=get_resource("cellranger", "walltime")
    log:
        err="{OUTDIR}/logs/cellranger_count/{sample}.err",
        out="{OUTDIR}/logs/cellranger_count/{sample}.out",
        time="{OUTDIR}/logs/time/cellranger_count/{sample}"
    shell:
        """
        {DATETIME} > {log.time} &&
        cellranger-atac count --id={wildcards.sample} \
        --reference={params.reference} \
        --fastqs={input.fq} \
        2> {log.err} > {log.out} &&
        mv {wildcards.sample} "{OUTDIR}/cellranger_count/" &&
        {DATETIME} >> {log.time}
        """

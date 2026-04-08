configfile: "config.yaml"
SPECIES = ["panthera_tigris", "panthera_leo", "pan_paniscus"]

rule: all
    input:
        expand("results/plots/{species}.png", species=SPECIES)

rule: download
    output:
        "data/animal_population_data.csv"
    conda:
        "envs/curl.yaml"
    shell:
        "curl https://animals.org/statistics/population_data.csv > {output} 2> {log}"

rule: analyze
    input:
        "data/animal_population_data.csv"
    output:
        "results/analysis/{species}_counts.csv"
    log:
        "logs/analysis/{species}_counts.log"
    conda:
        "envs/analysis.yaml"
    params:
        threshold = config["threshold"]
    threads: 
        4
    resources:
        mem_mb = 8000
    script:
        "scripts/species-analysis.py"
    
rule: plot
    input:
        "results/analysis/{species}_counts.csv"
    output:
        "results/plots/{species}.png"
    benchmark:
        "benchmarks/plot_{species}.tsv"    
    container: 
        "docker://hub-account/r-plotting:2.1"
    script:
        "scripts/plot-species-counts.r"
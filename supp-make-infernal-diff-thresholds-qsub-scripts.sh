for t in 30 35 40 45; do 
    rm -rf arc-t$t-infernal-out
    rm -rf bac-t$t-infernal-out
    perl step3-make-infernal-qsub-scripts.pl -t $t arc.r25.genome.list arc-t$t-infernal-out > arc.t$t.infernal.sh
    perl step3-make-infernal-qsub-scripts.pl -t $t bac.r50.genome.list bac-t$t-infernal-out > bac.t$t.infernal.sh
done

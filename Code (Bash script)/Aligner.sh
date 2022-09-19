export SUDO_ASKPASS="/path/to/myaskpass.sh"
set -e
choice=$(zenity --entry --text="1. Pairwise Alignment

2. Multiple Sequence Alignment

3. Conserved Regions

4. Phylogenetic Tree

5. Kmers Count

6. Graphical View

Please enter your choice" --width=400 --title "Aligner")

if [ $choice -lt 1 ] || [ $choice -gt 6 ]; then
zenity --warning --text="Invalid choice" --no-wrap
else

if [ $choice = 1 ]; then
sudo -A apt-get install ncbi-blast+ 
database_file=$(zenity --file-selection --title="Select a fasta file to determine the database by indexing" --file-filter="*.fa *.fasta")

query_file=$(zenity --file-selection --title="Select a query to run blast" --file-filter="*.fa *.fasta")

type=$(zenity --list --radiolist --title "Type" --text "Choose the type of the database and query files" --column "select" --column "Type" TRUE "DNA" FALSE "protein")



if [ $type = "protein" ]; then
makeblastdb -in $database_file -dbtype prot
notify-send "Done" "Indexing is completed"

output=$(zenity --entry --title "Output File" --text "Enter a name to the output file")

notify-send "Pairwise Alignment" "Please wait until it is completed"
blastp -query $query_file -db $database_file -out $output.txt
zenity --info --text="Paiwise alignment is generated" --title="Done" --no-wrap


elif [ $type = "DNA" ]; then
makeblastdb -in $database_file -dbtype nucl
notify-send "Done" "Indexing is completed"

output=$(zenity --entry --title "Output File" --text "Enter a name to the output file")

notify-send "Pairwise Alignment" "Please wait until it is completed"
blastn -query $query_file -db $database_file -out $output.txt
zenity --info --text="Paiwise alignment is generated" --title="Done" --no-wrap
fi

fi

#########################################################################
if [ $choice = 2 ]; then

directory=$(zenity --file-selection --title="Choose the directory which have the fasta files" --directory)

zenity --info --text="Now a fasta file will be generated that conatins all the fasta files in this directory" --no-wrap


MSA_file=$(zenity --entry --title "MSA File" --text "Please enter a name to that file")

for file in $directory/*.fa
do
cat $file >> $MSA_file.fa
done
notify-send "Multiple Sequence Alignment" "$MSA_file is created"

method=$(zenity --list --radiolist --title "Method" --text "Choose your preferred method" --column "select" --column "method" TRUE "Muscle" FALSE "Kalign")



if [ $method = "Muscle" ]; then

sudo -A apt-get install muscle
muscle -in $MSA_file.fa -out $MSA_file.afa
notify-send "Multiple Sequence Alignment" "$MSA_file.afa is created"

output=$(zenity --list --radiolist --title "Method" --text "Choose the output format" --column "select" --column "format" TRUE "clastalw" FALSE "html")


if [ $output = clastalw ]; then
muscle -in $MSA_file.fa -out $MSA_file.clw -clw
notify-send "Multiple Sequence Alignment" "$MSA_file.clw is created"
elif [ $output = html ]; then
muscle -in $MSA_file.fa -out $MSA_file.html -html
notify-send "Multiple Sequence Alignment" "$MSA_file.html is created"
fi


elif [ $method = "Kalign" ]; then
sudo -A apt-get install kalign
kalign -i $MSA_file.fa -o $MSA_file.afa
notify-send "Multiple Sequence Alignment" "$MSA_file.afa is created"
output2=$(zenity --list --radiolist --title "Method" --text "Choose the output format" --column "select" --column "format" TRUE "clastal" FALSE "MSF")



if [ $output2 = clastal ]; then
kalign -i $MSA_file.fa -f clu -o $MSA_file.clu
notify-send "Multiple Sequence Alignment" "$MSA_file.clu is created"
elif [ $output2 = MSF ]; then
kalign -i $MSA_file.fa -f msf -o $MSA_file.msf
notify-send "Multiple Sequence Alignment" "$MSA_file.msf is created"
fi

fi
zenity --info --text="MSA is generated" --title="Done" --no-wrap
fi
#########################################################################
if [ $choice = 3 ]; then

format=$(zenity --list --radiolist --title "Format" --text "Choose the format you would like to show its conserved regions 
(only clw format can know its function by pfam)" --height=230 --column "select" --column "format" TRUE "clw" FALSE "html" FALSE "clu" FALSE "msf")

if [ $format = clw ]; then
cfile=$(zenity --file-selection --title "Conserved Region" --text "Please enter a file to see its conseved regions" --file-filter="*.clw")
zenity --text-info --filename=$cfile --width=700 --height=700 --title=$cfile | zenity --info --text="In clw file, the regions that sequence specialied with stars * identify identical aminoacids
and with : identify amino acids have similar properties and functions and
also with . identify amino acids that may be probable to have same functions
and properties of clastalw format." --title="Conserved Regions" --no-wrap

if zenity --question --title "Pfam" --text "Do you want to know its function from pfam?" --no-wrap
then
if zenity --question --title "Pfam" --text "Do you want to download pfam? (if it is previously downloaded press no)" --no-wrap
then
notify-send "Pfam" "please wait..."
wget ftp://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam31.0/Pfam-A.hmm.gz
gunzip Pfam-A.hmm.gz
sudo -A apt install hmmer
hmmpress Pfam-A.hmm
notify-send "Pfam" "pfam is downloaded successfully"
fi
output=$(zenity --entry --title "Output File" --text "Enter a name to the output file")
notify-send "Pfam" "please wait..."
hmmsearch --tblout $output.txt -E 1e-5 --cpu 2 Pfam-A.hmm $cfile
zenity --text-info --filename=$output.txt --width=700 --height=700 --title=$output
fi




elif [ $format = html ]; then
cfile=$(zenity --file-selection --title "Conserved Region" --text "Please enter a file to see its conseved regions" --file-filter="*.html")
zenity --text-info --filename=$cfile --width=700 --height=700 --title=$cfile --html  | zenity --info --text="
In html file, the regions of blue color are conserved
The grey color are the semi conserved regions
The white color are the not conserved as they are not identical" --title="Conserved Regions" --no-wrap

elif [ $format = clu ]; then
cfile=$(zenity --file-selection --title "Conserved Region" --text "Please enter a file to see its conseved regions" --file-filter="*.clu")
zenity --text-info --filename=$cfile --width=700 --height=700 --title=$cfile

elif [ $format = msf ]; then
cfile=$(zenity --file-selection --title "Conserved Region" --text "Please enter a file to see its conseved regions" --file-filter="*.msf")
zenity --text-info --filename=$cfile --width=700 --height=700 --title=$cfile
fi




fi

################################################################
if [ $choice = 4 ]; then
combinedfile=$(zenity --file-selection --title="Select the MSA file" --file-filter="*.fa *.fasta")

tree=$(zenity --entry --title "Output File" --text "Enter a name to the output tree file")

muscle -in $combinedfile -out $tree.clw -clw -tree1 $tree.phy

method=$(zenity --list --radiolist --title "Tree" --text "Choose your preferred choice" --column "select" --column "format" TRUE "Newick" FALSE "Visualize")



if [ $method = Newick ]; then

zenity --text-info --filename=$tree.phy --width=700 --height=700 --title=$tree.phy

elif [ $method = Visualize ]; then
sudo -A apt-get install njplot
njplot $tree.phy

fi


fi
###################################################################
if [ $choice = 5 ]; then

file=$(zenity --file-selection --title="Please select a file")

kmer=$(zenity --entry --title "Kmer count" --text "Please enter the kmer you want to count")

z=$( grep -c "$kmer" $file )

zenity --info --text="$z" --title="Count of $kmer" --width=100 --height=100


fi
###################################################################
if [ $choice = 6 ]; then

gr=$(zenity --list --radiolist --title "Tree" --text "Choose your preferred choice" --column "select" --column "graph" TRUE "Terminal" FALSE "barplot")


if [ $gr = Terminal ]; then
graph=$(zenity --entry --title "Output File" --text "Enter a name to the output file")
touch $graph.txt
x=()
printf "@" >> $graph.txt
nokmers=$(zenity --scale --title "Number of kmers" --text "Enter number of kmers you want to count" --min-value=1 --max-value=50 --step=1 --value=1)


for (( i=1; i<=$nokmers; i++))
do
kmer=$(zenity --entry --title "kmer $i" --text "Enter the $nokmers kmer(s)")
x+=( $kmer )
printf "$kmer " >> $graph.txt
done
echo " " | tr " " "\n" >> $graph.txt
number=$(zenity --scale --title "Number of files" --text "Enter the number of files you want to involve" --min-value=1 --max-value=50 --step=1 --value=1)



for (( j=1; j<=$number; j++))
do
file=$(zenity --file-selection --title="Choose the $number file(S)")
#echo " " | tr " " "\n" >> $graph.txt
t=$( basename "$file" )
echo "$t" | tr "\n" " " >> $graph.txt
for (( t=0; t<${#x[@]}-1; t++))
do
grep -c "${x[t]}" $file | tr "\n" " " >> $graph.txt
done
grep -c "${x[-1]}" $file >> $graph.txt


done




sudo -A pip3 install termgraph 
x=$(termgraph $graph.txt --width 30 --different-scale --title "counts of kmers" --delim space)
zenity --info --text="$x" --width=600 --height=100 --title="Graph"



elif [ $gr = barplot ]; then

graph2=$(zenity --entry --title "Output File" --text "Enter a name to the output file")

touch $graph2.txt
x2=()
printf "@ " >> $graph2.txt
nokmers2=$(zenity --scale --title "Number of kmers" --text "Enter number of kmers you want to count" --min-value=1 --max-value=50 --step=1 --value=1)


for (( i=1; i<=$nokmers2; i++))
do
kmer2=$(zenity --entry --title "kmer $i" --text "Enter the $nokmers kmer(s)")
x2+=( $kmer2 )
printf "$kmer2 " >> $graph2.txt
done
echo " " | tr " " "\n" >> $graph2.txt
number2=$(zenity --scale --title "Number of files" --text "Enter the number of files you want to involve" --min-value=1 --max-value=50 --step=1 --value=1)


for (( i=1; i<=$number2; i++))
do

file=$(zenity --file-selection --title="Choose the $number file(S)")




#echo " " | tr " " "\n" >> $graph.txt
t=$( basename "$file" )
echo "$t" | tr "\n" " " >> $graph2.txt
for (( t2=0; t2<${#x2[@]}-1; t2++))
do
grep -c "${x2[t2]}" $file | tr "\n" " " >> $graph2.txt
done
grep -c "${x2[-1]}" $file >> $graph2.txt

done


touch $graph2.plot

echo "
set terminal png
set datafile separator whitespace
set style data histogram
set style histogram clustered gap 6
set style fill solid 1 noborder
set xtics scale 0
set yrange [1:]
plot for [i=2:${#x2[@]}+1] '$graph2.txt' using i:xtic(1) title columnheader
" >> $graph2.plot


sudo -A apt-get install gnuplot
gnuplot $graph2.plot > $graph2.png
yad --image $graph2.png --title $graph2.png
fi
fi

fi







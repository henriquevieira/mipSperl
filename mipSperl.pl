#!/usr/bin/perl

##############################################################################
# MIPS Simulator
# 
# Authors:	Henrique Cursino Vieira, The Smurf <enrikevieira@gmail.com>
#		Walkiria Karla Resende, <walkiriaresende@gmail.com>
# Version:	0.5
##############################################################################

print ("File:");
$fileIn = <STDIN>;

if( (open(FILE, $fileIn)) == false){
	 print "Error: INVALID FILE\n"; 

}

open(OUTPUT1, ">registers.txt");
open(OUTPUT2, ">memoria.txt");

# ---- Variables and vetors simulator ----
@memoria_instructions;
@register=();
@memoria; # possui 10240 bytes

$PC = '';
$clocks=0;

# ---- Variaveis auxilares ----
$linha;
$tamanho_codigo;
$index;
$index_label;
%lista_labels; # hash
$erro = 'FALSE'; # caso exista um erro na codificacao MIPS para a execucao do simulador
$tipo_erro;
%lista_mensagem_erro; # hash

# ---- lista de mensagens de erro ----

$lista_mensagem_erro{101} = 'Erro de sintaxe.';
$lista_mensagem_erro{201} = 'Erro! Register inexistente.';

# ---- armazena todo o codigo em um array ----

while($linha = <FILE>){

	# limpa a linha
	$linha =~ s/^\s+//g;
	$linha =~ s/\s+#.+//g;
	$linha =~ s/^#.+//g;
	$linha =~ s/\s+$//g;
	$linha =~ s/\$zero/0/g; # torna a palavra $zero em 0

	# se a linha for diferente de vazio, adiciona no array @memoria_instrucoes
	if($linha ne ''){
		push(@memoria_instrucoes, $linha);
	}
}

close(FILE);

$tamanho_codigo = @memoria_instrucoes;

# ---- armazenar os labels ----

for($index_label = 0; $index_label < $tamanho_codigo; $index_label++){

	$memoria_instrucoes[$index_label] =~ s/\t{1,}$//;

	if($memoria_instrucoes[$index_label] =~ /:$/ && $memoria_instrucoes[$index_label] !~ /main:/){
	
		$memoria_instrucoes[$index_label] =~ s/://g;
		$lista_labels{$memoria_instrucoes[$index_label]} = $index_label;	
	}

}

# ---- FUNCOES ----

sub add {

	$comando = $_[0];

	$PC = $comando;
	$clocks++;
	@add = split(/\s/,$comando);

	if ($add[1] !~ /\$[0-9],/ || $add[2] !~ /\$[0-9],/){

		$tipo_erro = 101;
		$erro = 'TRUE';
	}
	
	$add[1] =~ s/\$//g;
	$add[1] =~ s/,//g;
	$add[2] =~ s/\$//g;
	$add[2] =~ s/,//g;
	$add[3] =~ s/\$//g;
	
 	if( $add[1] ne '' && $add[2] ne '' && $add[3] ne ''){
	
		$register[$add[1]] = $register[$add[2]] + $register[$add[3]];		
	} else {
	
		$tipo_erro= 101;
		$erro = 'TRUE';
	}
	
}

sub subt {

	$comando = $_[0];

	$PC = $comando;
	$clocks++;
	@sub = split(/\s/,$comando);

	if ($sub[1] !~ /\$[0-9],/ || $sub[2] !~ /\$[0-9],/){

		$tipo_erro = 101;
		$erro = 'TRUE';
	}
	
	$sub[1] =~ s/\$//g;
	$sub[1] =~ s/,//g;
	$sub[2] =~ s/\$//g;
	$sub[2] =~ s/,//g;
	$sub[3] =~ s/\$//g;
	
	if($sub[1] ne '' && $sub[2] ne '' && $sub[3] ne ''){
	
		$register[$sub[1]] = $register[$sub[2]] - $register[$sub[3]];
	} else {
	
		$tipo_erro= 101;
		$erro = 'TRUE';
	}

}

sub addi {

	$comando = $_[0];

	$PC = $comando;
	$clocks++;
	@addi = split(/\s/,$comando);

	if ($addi[1] !~ /\$[0-9],/ || $addi[2] !~ /\$[0-9],/){

		$tipo_erro = 101;
		$erro = 'TRUE';
	}
	
	$addi[1] =~ s/\$//g;
	$addi[1] =~ s/,//g;
	$addi[2] =~ s/\$//g;
	$addi[2] =~ s/,//g;
	
	if($addi[1] ne '' && $addi[2] ne '' && $addi[3] ne ''){
	
		$register[$addi[1]] = $register[$addi[2]] + $addi[3];
	} else {
	
		$tipo_erro = 101;
		$erro = 'TRUE';
	}

}

sub lw {

	$comando = $_[0];

	$PC = $comando;
	$clocks++;
	@lw = split(/\s/,$comando);

	if ($lw[1] !~ /\$[0-9]?[0-9],/ || $lw[2] !~ /\d+\(\$\d?\d\)/){

		$tipo_erro = 101;
		$erro = 'TRUE';
	}
	
	$lw[1] =~ s/\$//g;
	$lw[1] =~ s/,//g;
	$lw[2] =~ s/\)$//g;

	@lw_aux = split(/\(/,$lw[2]); # segunda parte do comando lw
	$lw_aux[1] =~ s/\$//g;

	if($lw[1] ne '' && $lw_aux[0] ne '' && $lw_aux[1] ne ''){
	
		$register[$lw[1]] = $memoria[$register[$lw_aux[1]] + $lw_aux[0]];
	} else {
	
		$tipo_erro= 101;
		$erro = 'TRUE';
	}

}

sub sw {

	$comando = $_[0];

	$PC = $comando;
	$clocks++;
	@sw = split(/\s/,$comando);

	if ($sw[1] !~ /\$[0-9]?[0-9],/ || $sw[2] !~ /\d+\(\$\d?\d\)/){
 
		$tipo_erro = 101;
		$erro = 'TRUE';
	}

	$sw[1] =~ s/\$//g;
	$sw[1] =~ s/,//g;
	$sw[2] =~ s/\)$//g;

	@sw_aux = split(/\(/,$sw[2]); # segunda parte do comando sw
	$sw_aux[1] =~ s/\$//g;
	
	
	if($sw[1] ne '' && $sw_aux[0] ne '' && $sw_aux[1] ne ''){
	
		$memoria_pos = $register[$sw_aux[1]] + $sw_aux[0];
		$mem = verifica_memoria($memoria_pos);
	
		$memoria[$mem] = $register[$sw[1]];	
	} else {
	
		$tipo_erro= 101;
		$erro = 'TRUE';
	}
 

}

sub andd {

	$comando = $_[0];

	$PC = $comando;
	$clocks++;
	@and = split(/\s/,$comando);

	if ($and[1] !~ /\$[0-9]?[0-9],/ || $and[2] !~ /\$[0-9]?[0-9],/ || $and[3] !~ /\$[0-9]?[0-9]/){

		$tipo_erro = 101;
		$erro='TRUE';
	}

	$and[1] =~ s/\$//g;
	$and[1] =~ s/,//g;
	$and[2] =~ s/\$//g;
	$and[2] =~ s/,//g;
	$and[3] =~ s/\$//g;


	if($and[1] ne '' && $and[2] ne '' && $and[3] ne ''){

		$a = int($register[$and[2]]); # Converte para integer
		$b = int($register[$and[3]]); # Converte para integer
		
		$register[$and[1]] = $a & $b;

	} else {
	
		print "Erro de Sintaxe - $comando\n";
		$erro = 'TRUE';
	}

	
}


sub orr{
	$comando = $_[0];

	$PC = $comando;
	$clocks++;
	@or = split(/\s/,$comando);

	if ($or[1] !~ /\$[0-9]?[0-9],/ || $or[2] !~ /\$[0-9]?[0-9],/ || $or[3] !~ /\$[0-9]?[0-9]/){

		$tipo_erro = 101;
		$erro='TRUE';
	}
	
	$or[1] =~ s/\$//g;
	$or[1] =~ s/,//g;
	$or[2] =~ s/\$//g;
	$or[2] =~ s/,//g;
	$or[3] =~ s/\$//g;


	if($or[1] ne '' && $or[2] ne '' && $or[3] ne ''){
		
		$a = int($register[$or[2]]);
		$b = int($register[$or[3]]);
	
		$register[$or[1]] = $a | $b;
		
	}
	 else {
	
		print "Erro de Sintaxe - $comando\n";
		$erro = 'TRUE';
	}
}


sub beq {

	$comando = $_[0];

	$PC = $comando;
	$clocks++;
	@beq = split(/\s/,$memoria_instrucoes[$index]);
	$beq[1] =~ s/\$//g;
	$beq[1] =~ s/,//g;
	$beq[2] =~ s/\$//g;
	$beq[2] =~ s/,//g;

	if($beq[1] ne '' && $beq[2] ne '' && $beq[3] ne ''){
	
		if( $register[$beq[1]] == $register[$beq[2]] ) {
	
			$index = mudar_indice($beq[3]);
			return 'TRUE';
		} else {
	
			return 'FALSE';
		}
	
	} else {
	
		$tipo_erro= 101;
		$erro = 'TRUE';
	}
	
}

sub bne {

	$comando = $_[0];

	$PC = $comando;
	$clocks++;
	@bne = split(/\s/,$memoria_instrucoes[$index]);
	$bne[1] =~ s/\$//g;
	$bne[1] =~ s/,//g;
	$bne[2] =~ s/\$//g;
	$bne[2] =~ s/,//g;
	
	if($bne[1] ne '' && $bne[2] ne '' && $bne[3] ne ''){
	
		if( $register[$bne[1]] != $bne[2] ) {
	
			$index = mudar_indice($bne[3]);
			return 'TRUE';
		} else {
	
			return 'FALSE';
		}
		
	} else {
	
		$tipo_erro= 101;
		$erro = 'TRUE';
	}
	
}

sub slt {

	$comando = $_[0];

	$PC = $comando;
	$clocks++;
	@slt = split(/\s/,$comando);
	$slt[1] =~ s/\$//g;
	$slt[1] =~ s/,//g;
	$slt[2] =~ s/\$//g;
	$slt[2] =~ s/,//g;
	$slt[3] =~ s/\$//g;
	$slt[3] =~ s/,//g;
	
	if($slt[1] ne '' && $slt[2] ne '' && $slt[3] ne ''){
	
		if( $register[$slt[2]] < $register[$slt[3]] ){
			$register[$slt[1]] = 1;
		}

		else {
			$register[$slt[1]] = 0;
		}
		
	} else {
	
		$tipo_erro= 101;
		$erro = 'TRUE';
	}

}

sub blt {

	$comando = $_[0];

	$PC = $comando;
	$clocks++;
	@blt = split(/\s/,$memoria_instrucoes[$index]);
	$blt[1] =~ s/\$//g;
	$blt[1] =~ s/,//g;
	$blt[2] =~ s/\$//g;
	$blt[2] =~ s/,//g;

	if($blt[1] ne '' && $blt[2] ne '' && $blt[3] ne ''){
	
		if( $register[$blt[1]] < $register[$blt[2]] ) {
	
			$index = mudar_indice($blt[3]);
			return 'TRUE';
		} else {
	
			return 'FALSE';
		}
		
	} else {
	
		$tipo_erro= 101;
		$erro = 'TRUE';
	}

}

sub bgt {

	$comando = $_[0];

	$PC = $comando;
	$clocks++;
	@bgt = split(/\s/,$memoria_instrucoes[$index]);
	$bgt[1] =~ s/\$//g;
	$bgt[1] =~ s/,//g;
	$bgt[2] =~ s/\$//g;
	$bgt[2] =~ s/,//g;

	if($bgt[1] ne '' && $bgt[2] ne '' && $bgt[3] ne ''){
	
		if( $register[$bgt[1]] > $register[$bgt[2]] ) {
	
			$index = mudar_indice($bgt[3]);
			return 'TRUE';
		} else {
	
			return 'FALSE';
		}
	
	} else {
	
		$tipo_erro= 101;
		$erro = 'TRUE';
	}

}

sub ble {

	$comando = $_[0];

	$PC = $comando;
	$clocks++;
	@ble = split(/\s/,$memoria_instrucoes[$index]);
	$ble[1] =~ s/\$//g;
	$ble[1] =~ s/,//g;
	$ble[2] =~ s/\$//g;
	$ble[2] =~ s/,//g;

	if($ble[1] ne '' && $ble[2] ne '' && $ble[3] ne ''){

		if( $register[$ble[1]] <= $register[$ble[2]] ) {
	
			$index = mudar_indice($ble[3]);
			return 'TRUE';
		} else {
	
			return 'FALSE';
		}
	
	} else {
	
		$tipo_erro= 101;
		$erro = 'TRUE';
	}

}

sub bge {

	$comando = $_[0];

	$PC = $comando;
	$clocks++;
	@bge = split(/\s/,$memoria_instrucoes[$index]);
	$bge[1] =~ s/\$//g;
	$bge[1] =~ s/,//g;
	$bge[2] =~ s/\$//g;
	$bge[2] =~ s/,//g;

	if($bge[1] ne '' && $bge[2] ne '' && $bge[3] ne ''){
	
		if( $register[$bge[1]] >= $register[$bge[2]] ) {

			$index = mudar_indice($bge[3]);
			return 'TRUE';
		} else {
	
			return 'FALSE';
		}
	
	} else {
	
		$tipo_erro= 101;
		$erro = 'TRUE';
	}

}

sub li {

	$comando = $_[0];
	
	$PC = $comando; 
	$clocks++;
	@li = split(/\s/,$comando);
	
	if ($li[1] !~ /\$[0-9]?[0-9],/){
 
		$tipo_erro = 101;
		$erro = 'TRUE';
	}
	
	$li[1] =~ s/\$//g;
	$li[1] =~ s/,//g;
	
	if($li[1] ne '' && $li[2] ne ''){
	
		$register[$li[1]] = $li[2];
	} else {
	
		$tipo_erro= 101;
		$erro = 'TRUE';
	}

}

sub la {

	$comando = $_[0];

	$PC = $comando;
	$clocks++;
	@la = split(/\s/,$comando);
	$la[1] =~ s/\$//g;
	$la[1] =~ s/,//g;
	
	if($la[1] ne '' && $la[2] ne ''){
	
		$register[$la[1]] = 0; # pegar da declaração do vetor
	} else {

		$tipo_erro= 101;
		$erro= 'TRUE';
	}

}

sub j {

	$comando = $_[0];

	$PC = $comando;
	$clocks++;
	@j = split(/\s/,$comando);

	if($j[1] ne ''){
	
		# Recebe o LABEL e aplica a função mudar_indice
		$novo_index = mudar_indice($j[1]);

		# muda o indice atual para o indice indicado
		$index = $novo_index;
	} else {
	
		$tipo_erro= 101;
		$erro= 'TRUE';
	}

}

sub mudar_indice {

	$label = $_[0];
	$indice = 0;

	# busca o LABEL armazenado na @lista_labels e retorna o indice dele
	
	foreach $busca_label (keys(%lista_labels)){
	
		if($label =~ /^$busca_label$/){
		
			$indice = $lista_labels{$busca_label};
		}	
	}
	
	return $indice;
}


sub verifica_register { # verifica se o programa contém um register maior do que 32

		$register_indice = @register;

		if ($register_indice > 32){
			$tipo_erro= 201;
			$erro= 'TRUE'; 
		}
}

sub  verifica_memoria{

	$posicao = $_[0];
	
	while ($memoria[$posicao] != ''){
	
		print "oiew\n";
		$posicao = $posicao + 4;
	
	}
	
	return $posicao;
}

# ---- Executa as instrucoes ----

for($index = 0; $index < $tamanho_codigo; $index++){

# 	Mostra o codigo sendo lido no terminal
# 	print "$memoria_instrucoes[$index]\n";

#	Mostra o valor dos registeres em cada instante
# 	$c = 0;
# 	foreach $saida (@register){
# 
# 	print "register $c -- $saida \n";
# 	$c++;
# 
# 	}

	verifica_register();
	
	if($erro eq 'TRUE'){

		print "Erro $tipo_erro - $memoria_instrucoes[$index-1]\n";
		print "$lista_mensagem_erro{$tipo_erro}\n";
		last; # termina a execucao com erro detectado
	
	}

	if($memoria_instrucoes[$index] =~ '^add\s'){

		add($memoria_instrucoes[$index]);
	}

	if($memoria_instrucoes[$index] =~ '^sub\s'){

		subt($memoria_instrucoes[$index]);
	}

	if($memoria_instrucoes[$index] =~ '^addi\s'){

		addi($memoria_instrucoes[$index]);
	}

	if($memoria_instrucoes[$index] =~ '^lw\s'){

		lw($memoria_instrucoes[$index]);
	}
	
	if($memoria_instrucoes[$index] =~ '^sw\s'){

		sw($memoria_instrucoes[$index]);
	}
	
	if($memoria_instrucoes[$index] =~ '^and\s'){

		andd($memoria_instrucoes[$index]);
	}
	
	if($memoria_instrucoes[$index] =~ '^or\s'){

		orr($memoria_instrucoes[$index]);
	}
	
	if($memoria_instrucoes[$index] =~ '^beq\s'){

		beq($memoria_instrucoes[$index]);
	}
	
	if($memoria_instrucoes[$index] =~ '^bne\s'){

		bne($memoria_instrucoes[$index]);
	}

	if($memoria_instrucoes[$index] =~ '^slt\s'){
	
		slt($memoria_instrucoes[$index]);
	}
	
	if($memoria_instrucoes[$index] =~ '^blt\s'){
	
		blt($memoria_instrucoes[$index]);
	}
	
	if($memoria_instrucoes[$index] =~ '^bgt\s'){

		bgt($memoria_instrucoes[$index]);
	}
	
	if($memoria_instrucoes[$index] =~ '^ble\s'){

		ble($memoria_instrucoes[$index]);
	}
	
	if($memoria_instrucoes[$index] =~ '^bge\s'){

		bge($memoria_instrucoes[$index]);
	}
	
	if($memoria_instrucoes[$index] =~ '^li\s'){

 		li($memoria_instrucoes[$index]);
	}	
	
	if($memoria_instrucoes[$index] =~ '^la\s'){

 		la($memoria_instrucoes[$index]);
	}

	if($memoria_instrucoes[$index] =~ '^j\s'){

		j($memoria_instrucoes[$index]);
	}
	
}

# ---- SAIDAS ----

# Lista os LABELs 
foreach $chave (keys(%lista_labels)){

	print "labels -- $chave\n";

}

# Lista os registeres ao termino do codigo
$c = 0;

if($tipo_erro != 201){

	foreach $saida (@register){

		print "register $c -- $saida \n";
		$c++;
	}
}

# Mostra o CLOCK no fim
print "clocks -- $clocks\n";

# ---- register ----

$aux = 0;
foreach $saida (@register){

	print OUTPUT1 "register $aux = $saida\n";
	$aux++;
}

while ($aux < 32){
	print OUTPUT1 "register $aux = 0\n";
	$aux++;
}

# ---- Memoria ----

$aux = 0;
$tamanho_memoria = @memoria;
for($i = 0; $i < $tamanho_memoria; $i= $i+4){

 	print OUTPUT2 "Memoria $aux = $memoria[$i]\n";

	$aux = $aux + 4;

}

for($i = $aux; $i < 10240; $i = $i+4){
	print OUTPUT2 "Memoria $aux = 0\n";
	$aux = $aux + 4;

}



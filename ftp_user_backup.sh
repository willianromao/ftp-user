#!/bin/bash
# SCRIPT PARA GERENCIAR USUARIOS FTP
# CRIADO POR WILLIAN ROMÃO
# BIBLIOGRAFIA: ADM DE REDES COM SCRIPTS, DANIEL G. COSTA

trap 'clear ; echo Script Finalizado ; sleep 1 ; clear ; exit 0 ;' 2

inicio()
{
	clear
	echo "Gerenciador de usuarios FTP"
	echo
	echo "Opcoes:"
	echo

	echo "1. Adicionar um novo usuario"
	echo "2. Remover um usuario"
	echo "3. Gerenciar as pastas dos usuarios"
	echo "4. Alterar senha dos usuarios"
	echo "5. Listar usuarios ativos"
	echo "6. Lixeira"
	echo "7. Sair"
	echo

	echo -n "Digite a opcao desejada: "
	read opcao

		case $opcao in
		1) adicionar ;;
		2) remover ;;
		3) gerenciar ;;
		4) senha ;;
		5) listar ;;
		6) lixeira ;;
		7) sair ;;
		*) echo ; echo "Opcao invalida" ; sleep 1 ; inicio ;;

	esac
}

adicionar()
{
	clear
	echo "Usuarios ativos:"
	sort /etc/vsftpd.chroot_list | uniq
	echo
	echo
	echo "Adicionar um novo usuario"
	echo
	echo "Digite o nome de usuario ou enter para sair:"
	read -a useradd

	if [ -z "${useradd[0]}" ] 
	then
		sleep 1
		inicio
	
	else
		userteste=`getent passwd ${useradd[0]} | cut -d ":" -f 1,6`
		
		if [ -n "$userteste" ]
		then
			echo
			echo "$userteste"
			echo
			echo "O usuario ja existe."
			read
			adicionar
		else

			for usergroup in `sort /etc/vsftpd.chroot_list_groups | cut -d ":" -f 1 | uniq`
			do
				if [ -e /tmp/ftp/$usergroup/${useradd[0]} ]
				then			
				echo
				echo "O usuarios ${useradd[0]} nao existe, mas existe suas pastas no ftp."
				echo
				echo "Deseja reativa-lo? (s/n)"
				read -a questao
					if [ -z ${questao[0]} ]
					then
						adicionar
			
					elif [ ${questao[0]} == "s" ]
					then
						addreativego
					else
						adicionar
					fi
				fi
			done

			if [ -e /tmp/ftp/${useradd[0]} ]
			then
				echo
				echo "O usuarios ${useradd[0]} nao esta ativo, mas existe suas pastas no ftp."
				echo
				echo "Deseja reativa-lo? (s/n)"
				read -a questao
					if [ -z ${questao[0]} ]
					then
						adicionar
			
					elif [ ${questao[0]} == "s" ]
					then
						addreativego
					else
						adicionar
					fi
			else
				if [ "${#useradd[@]}" -ge 2 ]
					then
					echo
					echo "Escolha apenas um nome. Exemplo: ${useradd[0]}. "
					read
					adicionar

				else
				
					addgo
				fi
			fi

		fi
	fi
}

addgo()
{
	echo
	echo "Deseja proceguir com o usuario ${useradd[0]}? (s/n)"
	read -a questao
	if [ -z ${questao[0]} ]
	then
		adicionar
	fi
	if [ ${questao[0]} == "s" ]
	
	then
		clear
		echo "ABRINDO PASTAS... "
		sleep 2
		chmod 777 /tmp/ftp
		mkdir /tmp/ftp/${useradd[0]}
		mkdir /tmp/ftp/${useradd[0]}/downloads
		mkdir /tmp/ftp/${useradd[0]}/uploads
		chmod -R o+w /tmp/ftp/${useradd[0]}/downloads
		echo
		echo "Copie os arquivos para a pasta downloads do usuario ftp ${useradd[0]} e continue"
		read
		clear
		echo "FECHANDO PASTAS..."
		sleep 2
		chmod 771 /tmp/ftp
		chmod 500 /tmp/ftp/${useradd[0]}
		chmod -R 500 /tmp/ftp/${useradd[0]}/downloads
		chmod -R 700 /tmp/ftp/${useradd[0]}/uploads
		
		### CRIAR USUARIO ###
		clear
		echo "CRIANDO O USUARIO FTP..."
		sleep 2
		useradd ${useradd[0]} -d /tmp/ftp/${useradd[0]} -s /bin/false
		echo
		echo "Defina a senha do usuario ftp ${useradd[0]} abaixo"
		sleep 2
		passwd ${useradd[0]}
		echo
		chown -R ${useradd[0]} /tmp/ftp/${useradd[0]}
		echo ${useradd[0]} >> /etc/vsftpd.chroot_list
		sleep 2
		clear
		echo "Usuario ${useradd[0]} adicionado com sucesso!"
		echo
		echo
		echo "Digite enter para sair"
		read

		inicio

	else
		adicionar

	fi

}

addreativego()
{
	echo
	echo "Deseja realmente reativar o usuario ${useradd[0]}? (s/n)"
	read -a questao
	if [ -z ${questao[0]} ]
	then
		adicionar
	elif [ ${questao[0]} == "s" ]
	then
		if [ -e /tmp/ftp/${useradd[0]} ]
		then
			### RECRIAR USUARIO SIMPLES ###
			clear
			echo "REATIVANDO O USUARIO FTP..."
			sleep 2
			useradd ${useradd[0]} -d /tmp/ftp/${useradd[0]} -s /bin/false
			echo
			echo "Defina a senha do usuario ftp ${useradd[0]} abaixo"
			sleep 2
			passwd ${useradd[0]}
			echo
			chown -R ${useradd[0]} /tmp/ftp/${useradd[0]}
			echo ${useradd[0]} >> /etc/vsftpd.chroot_list
			sleep 2
			clear
			echo "Usuario ${useradd[0]} reativado com sucesso!"

			### MODIFICAR PASTAS ###
			echo
			echo "Deseja gerenciar as pastas do usuario ${useradd[0]}? (s/n)"
			read -a questao
				if [ -z ${questao[0]} ]
				then
					inicio
				elif [ ${questao[0]} == "s" ]
				then
					clear
					echo "REABRINDO PASTAS... "
					sleep 2
					chmod 777 /tmp/ftp
					chmod 777 /tmp/ftp/${useradd[0]}
					chmod -R 777 /tmp/ftp/${useradd[0]}/downloads
					chmod -R 777 /tmp/ftp/${useradd[0]}/uploads
					echo "Copie os novos arquivos para a pasta downloads do usuario ftp ${useradd[0]} e continue"
					read
					clear
					echo "FECHANDO PASTAS..."
					sleep 2
					chown -R ${useradd[0]} /tmp/ftp/${useradd[0]}
					chmod -R 700 /tmp/ftp/${useradd[0]}/uploads
					chmod -R 500 /tmp/ftp/${useradd[0]}/downloads
					chmod 500 /tmp/ftp/${useradd[0]}
					chmod 771 /tmp/ftp
					clear
					echo "Pastas do usuario ${useradd[0]} atualizadas com sucesso!"
					echo
					echo
					echo "Digite enter para sair"
					read
			
					inicio
				else
					inicio
				fi
		else
			for usergroup in `sort /etc/vsftpd.chroot_list_groups | cut -d ":" -f 1 | uniq`
			do
				if [ -e /tmp/ftp/$usergroup/${useradd[0]} ]
				then	
					### RECRIAR USUARIO DE GRUPO ###
					clear
					echo "REATIVANDO O USUARIO FTP..."
					sleep 2
					useradd ${useradd[0]} -d /tmp/ftp/$usergroup/${useradd[0]} -g $usergroup -s /bin/false
					echo
					echo "Defina a senha do usuario ftp ${useradd[0]} abaixo"
					sleep 2
					passwd ${useradd[0]}
					echo
					chown ${useradd[0]}.$usergroup /tmp/ftp/$usergroup/${useradd[0]}
					chown -R ${useradd[0]}.$usergroup /tmp/ftp/$usergroup/${useradd[0]}/${useradd[0]}
					chown -R $usergroup.$usergroup /tmp/ftp/$usergroup/${useradd[0]}/Planos
					echo ${useradd[0]} >> /etc/vsftpd.chroot_list
					echo "$usergroup:${useradd[0]}" >> /etc/vsftpd.chroot_list_groups
					sleep 2
					clear
					echo "Usuario ${useradd[0]} reativado com sucesso!"

					### MODIFICAR PASTAS ###
					echo
					echo "Deseja gerenciar as pastas do usuario ${useradd[0]}? (s/n)"
					read -a questao
						if [ -z ${questao[0]} ]
						then
							inicio
						elif [ ${questao[0]} == "s" ]
						then
							clear
							echo "REABRINDO PASTAS... "
							sleep 2
							chmod 755 /tmp/ftp
							chmod 755 /tmp/ftp/$usergroup
							chmod 755 /tmp/ftp/$usergroup/${useradd[0]}
							chmod -R 777 /tmp/ftp/$usergroup/${useradd[0]}/${useradd[0]}
							chmod -R 777 /tmp/ftp/$usergroup/${useradd[0]}/Planos
							echo "Copie os novos arquivos para a pasta downloads do usuario ftp ${useradd[0]} e continue"
							read
							clear
							echo "FECHANDO PASTAS..."
							sleep 2
							chown ${useradd[0]}.$usergroup /tmp/ftp/$usergroup/${useradd[0]}
							chown -R ${useradd[0]}.$usergroup /tmp/ftp/$usergroup/${useradd[0]}
							chown -R $usergroup.$usergroup /tmp/ftp/$usergroup/Planos
							chmod -R 750 /tmp/ftp/$usergroup/${useradd[0]}/Planos
							chmod -R 750 /tmp/ftp/$usergroup/${useradd[0]}/${useradd[0]}
							chmod 550 /tmp/ftp/$usergroup/${useradd[0]}
							chmod 550 /tmp/ftp/$usergroup
							chmod 771 /tmp/ftp
							clear
							echo "Pastas do usuario ${useradd[0]} atualizadas com sucesso!"
							echo
							echo
							echo "Digite enter para sair"
							read
							inicio
						else
							inicio
						fi
				fi					
			done
		fi		
	else
		adicionar

	fi

}

remover()
{
		clear
		echo "Remover um usuario"
		echo
		echo "Escolha uma usuario ou a opcao sair:"
		echo

	select userdel in `sort /etc/vsftpd.chroot_list | uniq` Sair
	do

	if [ $userdel == "Sair" ]
	then
		sleep 1
		inicio
	elif [ -z $userdel ]
	then
		echo
		echo "Opcao invalida."
		sleep 1
		remover
	fi
		userpath=`getent passwd $userdel | cut -d ":" -f 6`
		usergroup=`sort /etc/vsftpd.chroot_list_groups | grep -w $userdel | cut -d ":" -f 1 | uniq`

	if [ -n "$usergroup" ]
	then
		if [ "$userdel" == "$usergroup" ]
		then
			if [ -s $userpath ]
			then
				echo
				echo "O usuario $userdel é administrador de grupo."
				echo
				echo "Para remover este usuario é necessário remover o grupo primeiro."
				echo
				echo "Digite enter para voltar"
				read
				remover
			else
				echo
				echo "O usuario $userdel é adminitrador de grupo, porem vazio."
			fi
		else
			echo
			echo "Usuario membro do grupo $usergroup."
		fi
	fi
	if [ -e $userpath ]
	then
		deluser

	else
		delgo
	fi
	done

}

delgo()
{

		echo
		echo "O usuario $userdel nao tem pastas no ftp."
		echo
		echo "Deseja remover este usuario? (s/n)"
		read -a questao
	if [ -z ${questao[0]} ]
	then
		remover
	fi
	if [ ${questao[0]} == "s" ]
	then
		clear
		userdel $userdel
		sed -i "/$userdel/d" /etc/vsftpd.chroot_list
		sed -i "/$userdel/d" /etc/vsftpd.chroot_list_groups
		clear
		echo "Usuario $userdel removido com sucesso!"
		echo
		echo
		echo "Digite enter para sair"
		read

		inicio
	else
		remover
	fi

}

deluser()
{
		echo
		echo "Deseja realmente remover o usuario ftp $userdel? (s/n)"
		read -a questao
	if [ -z ${questao[0]} ]
	then
		remover
	fi
	
	if [ ${questao[0]} == "s" ]
	then
		### REMOVENDO O USUARIO ###

		clear
		userdel $userdel
			if [ "$userdel" == "$usergroup" ]
			then
				groupdel $userdel
			fi
		sed -i "/$userdel/d" /etc/vsftpd.chroot_list
		sed -i "/$userdel/d" /etc/vsftpd.chroot_list_groups
		clear
			if [ "$userdel" == "$usergroup" ]
			then
				echo "Usuario administrador de grupo $userdel removido com sucesso!"
			else
				echo "Usuario $userdel removido com sucesso!"
				echo
			fi

		### REMOVENDO PASTAS ###

		echo "Deseja mover as pastas do usuario ftp $userdel para o lixo? (s/n)"
		read -a questao
		if [ -z ${questao[0]} ]
		then
			remover
		
		elif [ ${questao[0]} == "s" ]
		then
			clear
			echo "MOVENDO PASTAS PARA O LIXO DO FTP..."
			mv $userpath /tmp/ftp_lixo || echo "Erro ao mover as pastas para o lixo."
			sleep 2
			clear
			echo "Usuario $userdel removido com sucesso!"
			echo
			echo
			echo "Digite enter para sair"
			read

			inicio
		else
			inicio

		fi
	else
		remover

	fi
	
}

gerenciar()
{
		clear
		echo "Gerenciar as pastas dos usuarios"
		echo
		echo "Escolha um usuario ou a opcao sair:"
	
	select usermod in `sort /etc/vsftpd.chroot_list | uniq` Sair
	do

	if [ $usermod == "Sair" ]
	then
		sleep 1
		inicio
	elif [ -z $usermod ]
	then
		echo
		echo "Opcao invalida."
		sleep 1
		remover
	fi

		userpath=`getent passwd $usermod | cut -d ":" -f 6`
		usergroup=`sort /etc/vsftpd.chroot_list_groups | grep -w $usermod | cut -d ":" -f 1 | uniq`
			
	if [ -e "$userpath" ]
	then
		modgo
	else
		delgo
	fi
done
}

modgo()
{

	if [ -n "$usergroup" ]
	then
		if [ "$usermod" == "$usergroup" ]
		then
			echo
			echo "O usuario $usermod é administrador de grupo."
			echo "Favor, gerencia-lo manualmente."
			echo
			echo "Digite enter para voltar"
			read
			gerenciar
		else
			echo
			echo "O usuario $usermod é membro do grupo $usergroup."
		fi
	fi
		echo
		echo "Deseja proceguir com o usuario $usermod? (s/n)"
		read -a questao
	if [ -z ${questao[0]} ]
	then
		gerenciar
	elif [ ${questao[0]} != "s" ]
	then
		gerenciar
	else
		if [ -z "$usergroup" ]
		then
			clear
			echo "REABRINDO PASTAS..."
			sleep 2
			chmod 777 /tmp/ftp
			chmod 777 $userpath
			chmod -R 777 $userpath/downloads
			chmod -R 777 $userpath/uploads
			echo "Copie os novos arquivos para a pasta downloads do usuario ftp $usermod e continue"
			read
		
			clear
			echo "FECHANDO PASTAS..."
			sleep 2
			chmod -R 700 $userpath/uploads
			chmod -R 500 $userpath/downloads
			chmod 500 $userpath
			chmod 771 /tmp/ftp
		
			clear
			echo "Pastas do usuario $usermod atualizadas com sucesso!"
			echo
			echo
			echo "Digite enter para sair"
			read
			inicio
		else
			clear
			echo "REABRINDO PASTAS..."
			sleep 2
			chmod 777 /tmp/ftp
			chmod o+rx /tmp/ftp/$usergroup
			chmod o+rx $userpath
			chmod -R o+rwx $userpath/Planos
			echo "Copie os novos arquivos para a pasta do usuario ftp $usermod e continue"
			read
		
			clear
			echo "FECHANDO PASTAS..."
			sleep 2
			chmod -R 750 $userpath/Planos
			chown -R $usergroup.$usergroup $userpath/Planos
			chmod o-rx $userpath
			chmod o-rx /tmp/ftp/$usergroup
			chmod 771 /tmp/ftp

			clear
			echo "Pastas do usuario $usermod atualizadas com sucesso!"
			echo
			echo
			echo "Digite enter para sair"
			read
			inicio
		fi
	fi

}

senha()
{
		clear
		echo "Alterar senha dos usuarios"
		echo
		echo "Escolha um usuario ou a opcao sair:"

	select userkey in `sort /etc/vsftpd.chroot_list | uniq` Sair
	do

	if [ $userkey == "Sair" ]
	then
		sleep 1
		inicio
	elif [ -z $userkey ]
	then
		echo
		echo "Opcao invalida."
		sleep 1
		senha
	fi
	
		userpath=`getent passwd $userkey | cut -d ":" -f 6`

	if [ -e "$userpath" ]
	then
		keygo
	else
		echo
		echo "O usuario nao esta ativo."
		echo
		echo "Verifique sua situacao no servidor ftp manualmente."
		echo
		echo
		echo "Digite enter para sair"
		read
		senha
	fi
done

}

keygo()
{

		echo
		echo "Deseja proceguir com o usuario $userkey? (s/n)"
		read -a questao
	if [ -z ${questao[0]} ]
	then
		senha
	fi
	if [ ${questao[0]} == "s" ]
	
	then
		clear
		echo "Defina a senha do usuario ftp $userkey abaixo"
		passwd $userkey
		echo
		echo
		echo "Digite enter para sair"
		read

		inicio

	else
		senha

	fi

}

listar()
{
		clear
		usercount=`sort /etc/vsftpd.chroot_list | uniq | wc -l`
		echo "$usercount usuarios ativos:"
		echo
		sort /etc/vsftpd.chroot_list | uniq
		echo
		echo
		echo "Detalhe das pastas:"
		echo
		df -h /dev/sda3
		echo

	for userlist in `sort /etc/vsftpd.chroot_list | uniq`
	do
		userpath=`getent passwd $userlist | cut -d ":" -f 6`
		cd $userpath
		cd ..
		echo $PWD &>> /tmp/userlist.txt
	done

	for userlist in `sort /tmp/userlist.txt | uniq`
	do
		ls -gh --color=always $userlist | awk 'NF > 3'
	done
		rm /tmp/userlist.txt
		echo
		echo
		echo "Digite enter para sair"
		read

	inicio
}

lixeira()
{
		clear
		echo "Lixeira"
		echo
		echo "Escolha o usuario que deseja restaurar da lixeira ou a opcao sair:"
		echo
		echo "OBS: Se o usuario for membro de grupo, restaure-o manualmente."
		echo
	select userlixo in `ls -C /tmp/ftp_lixo` Sair
	do

	if [ $userlixo == "Sair" ]
	then
		sleep 1
		inicio
	elif [ -z $userlixo ]
	then
		echo
		echo "Opcao invalida."
		sleep 1
		lixeira
	fi

		userpath=`getent passwd $userlixo | cut -d ":" -f 6`
	if [ -z $userpath ]
	then
		lixgo
	else
		if [ -e $userpath ]
		then
			echo
			echo "O usuario esta ativo."
			sleep 1
			lixeira
		else
			lixdirgo
		fi
	
	fi
done
}

lixgo()
{
		echo
		echo "Deseja realmente restaurar o usuario ftp $userlixo? (s/n)"
		read -a questao
	if [ -z ${questao[0]} ]
	then
		lixeira
	elif [ ${questao[0]} != "s" ]
	then
		lixeira
	else
		clear
		echo "RESTAURANDO PASTAS... "
		sleep 2
		mkdir /tmp/ftp/$userlixo

		
		cp -a /tmp/ftp_lixo/$userlixo/* /tmp/ftp/$userlixo || echo "Erro na copia do lixo."
		rm -R /tmp/ftp_lixo/$userlixo || echo "Erro na remocao no lixo."
		sleep 2
		chmod 500 /tmp/ftp/$userlixo
		chmod -R 500 /tmp/ftp/$userlixo/downloads
		chmod -R 700 /tmp/ftp/$userlixo/uploads
		clear
		echo "RECRIANDO O USUARIO FTP..."
		sleep 2
		useradd $userlixo -d /tmp/ftp/$userlixo -s /bin/false
		echo
		echo "Defina a nova senha do usuario ftp $userlixo abaixo"
		sleep 2
		passwd $userlixo
		echo
		chown -R $userlixo /tmp/ftp/$userlixo
		echo $userlixo >> /etc/vsftpd.chroot_list
		sleep 2
		clear
		echo "Usuario ftp $userlixo restaurado com sucesso!"
		echo
		echo
		echo "Digite enter para sair"
		read
		lixeira
	fi


}

lixdirgo()
{
	echo
	echo "O usuario esta ativo."
	echo
	echo "Deseja mover as pastas do usuario $userlixo do lixo para o ftp? (s/n)"
	read -a questao
	if [ -z ${questao[0]} ]
	then
		lixeira
	elif [ ${questao[0]} == "s" ]
	then
		clear
		echo "RESTAURANDO PASTAS... "
		sleep 2
		mkdir /tmp/ftp/$userlixo
		cp -a /tmp/ftp_lixo/$userlixo/* /tmp/ftp/$userlixo || echo "Erro na copia do lixo."
		rm -R /tmp/ftp_lixo/$userlixo || echo "Erro na remocao do lixo."
		sleep 2
		chmod 500 /tmp/ftp/$userlixo
		chmod -R 500 /tmp/ftp/$userlixo/downloads
		chmod -R 700 /tmp/ftp/$userlixo/uploads
		chown -R $userlixo /tmp/ftp/$userlixo
		echo $userlixo >> /etc/vsftpd.chroot_list
		clear
		echo "Usuario $userlixo restaurado com sucesso!"
		echo
		echo
		echo "Digite enter para sair"
		read
		inicio
	else
		lixiera
	fi
	
}

sair()
{
	clear
	echo "Script Finalizado"
	sleep 1
	clear
	exit 0
}
# inicia o script
inicio

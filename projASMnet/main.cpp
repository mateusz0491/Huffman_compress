#include <stdio.h>
#include <iostream>
#include <fstream>

using namespace std;
extern "C" {
	//deklaracja zewnetrznej funkcji dolinkowanej z asemblera
	char* utworz_tablice(char* text, long* output_data, char* table_char, long* table_code, char* table_code_il);
}

int main()
{
	ifstream plik;
	plik.open("input.txt");
	if (plik)
	{
		plik.seekg(0, std::ios::end);
		int length = plik.tellg();
		plik.seekg(0, std::ios::beg);
		//table_char:DWORD, table_code:DWORD, table_code_il:DWORD
		char* tab = new char[length];
		long* tab_output = new long[length];
		char* table_char = new char;// [256];
		long* table_code = new long;// [256];
		char* table_code_il = new char;// [256];
		char c;
		long d = 0;
		int i = 0;
		char ch = 0x00;
		memset(tab, 0, length);
		memset(tab_output, 0, length);
		while (!plik.eof() && i < length)
		{
			plik.get(c);
			//tab[i] = c;
			memmove(&tab[i], &c, sizeof(char));
			memmove(&tab_output[i], &d, sizeof(long));
			i++;
		}

		cout << length << "\n";
		cout << tab << "\n\n\n\n";
<<<<<<< HEAD
		char* tekst = utworz_tablice(tab, tab_output, table_char, table_code, table_code_il);
		oplik << tekst;
		cout << tekst << "\n";
		cout << table_char << "\n";
		cout << *table_char << "\n";
		cout << &table_char << "\n";
		oplik.close();
=======
		char* tekst = utworz_tablice(tab, tab_output);
		cout << tekst << "\n";
>>>>>>> parent of 1d91c76... Compress file
		plik.close();
	}
	return 0;
}
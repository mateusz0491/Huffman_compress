#include <stdio.h>
#include <iostream>
#include <fstream>

using namespace std;
extern "C" {
	//deklaracja zewnetrznej funkcji dolinkowanej z asemblera
	char* utworz_tablice(char* text, long* output_data);
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
		char* tab = new char[length];
		long* tab_output = new long[length];
		char c;
		long d = 0;
		int i = 0;
		memset(tab, 0, length);
		memset(tab_output, 0, length);
		while (!plik.eof() && i<length)
		{
			plik.get(c );
			//tab[i] = c;
			memmove(&tab[i], &c, sizeof(char));
			memmove(&tab_output[i], &d, sizeof(long));
			i++;
		}

		cout << length << "\n";
		cout << tab << "\n\n\n\n";
		char* tekst = utworz_tablice(tab, tab_output);
		cout << tekst << "\n";
		plik.close();
	}
	return 0;
}
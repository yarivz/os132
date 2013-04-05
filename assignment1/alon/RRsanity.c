// Test that fork fails gracefully.
// Tiny executable so that the limit can be filling the proc table.

#include "types.h"
#include "stat.h"
#include "user.h"

#define N  1000
/*
void
printf(int fd, char *s, ...)
{
  write(fd, s, strlen(s));
}
*/

void
foo()
{
  int i;
  int pid = getpid();
  for (i=0;i<1000;i++)
     printf(2, "child %d prints for the %d time\n",pid,i+1);
}

void
RRsanity(void)
{
  int wTime [10];
  int rTime [10];
  int pid [10];
  printf(1, "RRsanity test\n");

  int i=0;
  for(;i<10;i++)
  {  
    pid[i] = fork();
    if(pid[i] == 0)
    {
      foo();
      exit();      
    }
  }
  
  for(i=0;i<10;i++)
    pid[i] = wait2(&(wTime[i]),&(rTime[i]));
  
  for(i=0;i<10;i++)
    printf(1, "child %d: Waiting Time: %d Running Time: %d Turnaround Time: %d\n",pid[i],wTime[i],rTime[i],wTime[i]+rTime[i]);

}
int
main(void)
{
  RRsanity();
  exit();
}

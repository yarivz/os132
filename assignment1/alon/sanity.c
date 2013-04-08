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
foo(int cid)
{
  int i;
  switch(cid%3)
  {
    case 0:
      nice();
      break;
    case 1:
      nice();
      nice();
      break;
  }
  for (i=0;i<500;i++)
     printf(1, "child %d prints for the %d time\n",cid,i+1);
}

void
sanity(void)
{
  int wTime [30];
  int rTime [30];
  int tempwtime;
  int temprtime;
  int pid[30];
  int avg_all_wtime;
  int avg_all_rtime;
  int avg_high_wtime;
  int avg_high_rtime;
  int avg_medium_wtime;
  int avg_medium_rtime;
  int avg_low_wtime;
  int avg_low_rtime;
  int temp;
  int found = 0;
  
  printf(1, "sanity test\n");

  int i,cid;
  for(;cid<30;cid++)
  {  
    pid[cid] = fork();
    if(pid[cid] == 0)
    {
      foo(cid);
      exit();      
    }
  }
  
  for(i=0;i<30;i++,found=0)
  {
    temp = wait2(&tempwtime,&temprtime);
    for(cid=0;cid<30 && !found;cid++)
    {
      if(pid[cid] == temp)
      {
	 wTime[cid] = tempwtime;
	 rTime[cid] = temprtime;
	found = 1;
      }
    }
    avg_all_wtime += wTime[cid];
    avg_all_rtime += rTime[cid];
    
    switch(cid%3)
    {
      case 0:
	avg_medium_wtime += wTime[cid];
	avg_medium_rtime += rTime[cid];
	break;
      case 1:
	avg_low_wtime += wTime[cid];
	avg_low_rtime += rTime[cid];
	break;
      case 2:
	avg_high_wtime += wTime[cid];
	avg_high_rtime += rTime[cid];
	break;
    }
  }

  printf(1, "All: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_all_wtime/30, avg_all_rtime/30, (avg_all_wtime + avg_all_rtime)/30);
  printf(1, "High priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_high_wtime/10, avg_high_rtime/10, (avg_high_wtime + avg_high_rtime)/10);
  printf(1, "Medium priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_medium_wtime/10, avg_medium_rtime/10, (avg_medium_wtime + avg_medium_rtime)/10);
  printf(1, "Low priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_low_wtime/10, avg_low_rtime/10, (avg_low_wtime + avg_low_rtime)/10);

  for(i=0;i<30;i++)
    printf(1, "child %d: Waiting Time: %d Running Time: %d Turnaround Time: %d\n",i,wTime[i],rTime[i],wTime[i]+rTime[i]);

}
int
main(void)
{
  sanity();
  exit();
}
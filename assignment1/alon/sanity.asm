
_sanity:     file format elf32-i386


Disassembly of section .text:

00000000 <foo>:
}
*/

void
foo(int cid)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 24             	sub    $0x24,%esp
  int i;
  switch(cid%3)
   7:	8b 4d 08             	mov    0x8(%ebp),%ecx
   a:	ba 56 55 55 55       	mov    $0x55555556,%edx
   f:	89 c8                	mov    %ecx,%eax
  11:	f7 ea                	imul   %edx
  13:	89 c8                	mov    %ecx,%eax
  15:	c1 f8 1f             	sar    $0x1f,%eax
  18:	89 d3                	mov    %edx,%ebx
  1a:	29 c3                	sub    %eax,%ebx
  1c:	89 d8                	mov    %ebx,%eax
  1e:	89 c2                	mov    %eax,%edx
  20:	01 d2                	add    %edx,%edx
  22:	01 c2                	add    %eax,%edx
  24:	89 c8                	mov    %ecx,%eax
  26:	29 d0                	sub    %edx,%eax
  28:	85 c0                	test   %eax,%eax
  2a:	74 07                	je     33 <foo+0x33>
  2c:	83 f8 01             	cmp    $0x1,%eax
  2f:	74 09                	je     3a <foo+0x3a>
  31:	eb 12                	jmp    45 <foo+0x45>
  {
    case 0:		// Medium priority
      nice();
  33:	e8 38 08 00 00       	call   870 <nice>
      break;
  38:	eb 0b                	jmp    45 <foo+0x45>
    case 1:		// Low priority
      nice();
  3a:	e8 31 08 00 00       	call   870 <nice>
      nice();
  3f:	e8 2c 08 00 00       	call   870 <nice>
      break;
  44:	90                   	nop
  }
  for (i=0;i<500;i++)
  45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  4c:	eb 29                	jmp    77 <foo+0x77>
     printf(1, "child %d prints for the %d time\n",cid,i+1);
  4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  51:	83 c0 01             	add    $0x1,%eax
  54:	89 44 24 0c          	mov    %eax,0xc(%esp)
  58:	8b 45 08             	mov    0x8(%ebp),%eax
  5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  5f:	c7 44 24 04 a4 0d 00 	movl   $0xda4,0x4(%esp)
  66:	00 
  67:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  6e:	e8 6c 09 00 00       	call   9df <printf>
    case 1:		// Low priority
      nice();
      nice();
      break;
  }
  for (i=0;i<500;i++)
  73:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  77:	81 7d f4 f3 01 00 00 	cmpl   $0x1f3,-0xc(%ebp)
  7e:	7e ce                	jle    4e <foo+0x4e>
     printf(1, "child %d prints for the %d time\n",cid,i+1);
}
  80:	83 c4 24             	add    $0x24,%esp
  83:	5b                   	pop    %ebx
  84:	5d                   	pop    %ebp
  85:	c3                   	ret    

00000086 <sanity>:

void
sanity(void)
{
  86:	55                   	push   %ebp
  87:	89 e5                	mov    %esp,%ebp
  89:	56                   	push   %esi
  8a:	53                   	push   %ebx
  8b:	81 ec c0 01 00 00    	sub    $0x1c0,%esp
  int avg_medium_wtime;
  int avg_medium_rtime;
  int avg_low_wtime;
  int avg_low_rtime;
  int temp;
  int found = 0;
  91:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  
  printf(1, "sanity test\n");
  98:	c7 44 24 04 c5 0d 00 	movl   $0xdc5,0x4(%esp)
  9f:	00 
  a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a7:	e8 33 09 00 00       	call   9df <printf>

  int i,cid;
  for(;cid<30;cid++)
  ac:	eb 31                	jmp    df <sanity+0x59>
  {  
    pid[cid] = fork();
  ae:	e8 9d 07 00 00       	call   850 <fork>
  b3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  b6:	89 84 95 58 fe ff ff 	mov    %eax,-0x1a8(%ebp,%edx,4)
    if(pid[cid] == 0)
  bd:	8b 45 cc             	mov    -0x34(%ebp),%eax
  c0:	8b 84 85 58 fe ff ff 	mov    -0x1a8(%ebp,%eax,4),%eax
  c7:	85 c0                	test   %eax,%eax
  c9:	75 10                	jne    db <sanity+0x55>
    {
      foo(cid);
  cb:	8b 45 cc             	mov    -0x34(%ebp),%eax
  ce:	89 04 24             	mov    %eax,(%esp)
  d1:	e8 2a ff ff ff       	call   0 <foo>
      exit();      
  d6:	e8 7d 07 00 00       	call   858 <exit>
  int found = 0;
  
  printf(1, "sanity test\n");

  int i,cid;
  for(;cid<30;cid++)
  db:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
  df:	83 7d cc 1d          	cmpl   $0x1d,-0x34(%ebp)
  e3:	7e c9                	jle    ae <sanity+0x28>
      foo(cid);
      exit();      
    }
  }
  
  for(i=0;i<30;i++,found=0)
  e5:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  ec:	e9 11 01 00 00       	jmp    202 <sanity+0x17c>
  {
    temp = wait2(&tempwtime,&temprtime);
  f1:	8d 85 d0 fe ff ff    	lea    -0x130(%ebp),%eax
  f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  fb:	8d 85 d4 fe ff ff    	lea    -0x12c(%ebp),%eax
 101:	89 04 24             	mov    %eax,(%esp)
 104:	e8 5f 07 00 00       	call   868 <wait2>
 109:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for(cid=0;cid<30 && !found;cid++)
 10c:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
 113:	eb 3a                	jmp    14f <sanity+0xc9>
    {
      if(pid[cid] == temp)		// find the cid that matches the pid that returned from wait2
 115:	8b 45 cc             	mov    -0x34(%ebp),%eax
 118:	8b 84 85 58 fe ff ff 	mov    -0x1a8(%ebp,%eax,4),%eax
 11f:	3b 45 c8             	cmp    -0x38(%ebp),%eax
 122:	75 27                	jne    14b <sanity+0xc5>
      {
	 wTime[cid] = tempwtime;
 124:	8b 95 d4 fe ff ff    	mov    -0x12c(%ebp),%edx
 12a:	8b 45 cc             	mov    -0x34(%ebp),%eax
 12d:	89 94 85 50 ff ff ff 	mov    %edx,-0xb0(%ebp,%eax,4)
	 rTime[cid] = temprtime;
 134:	8b 95 d0 fe ff ff    	mov    -0x130(%ebp),%edx
 13a:	8b 45 cc             	mov    -0x34(%ebp),%eax
 13d:	89 94 85 d8 fe ff ff 	mov    %edx,-0x128(%ebp,%eax,4)
	found = 1;
 144:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  }
  
  for(i=0;i<30;i++,found=0)
  {
    temp = wait2(&tempwtime,&temprtime);
    for(cid=0;cid<30 && !found;cid++)
 14b:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
 14f:	83 7d cc 1d          	cmpl   $0x1d,-0x34(%ebp)
 153:	7f 06                	jg     15b <sanity+0xd5>
 155:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 159:	74 ba                	je     115 <sanity+0x8f>
	 wTime[cid] = tempwtime;
	 rTime[cid] = temprtime;
	found = 1;
      }
    }
    avg_all_wtime += wTime[cid];
 15b:	8b 45 cc             	mov    -0x34(%ebp),%eax
 15e:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
 165:	01 45 f4             	add    %eax,-0xc(%ebp)
    avg_all_rtime += rTime[cid];
 168:	8b 45 cc             	mov    -0x34(%ebp),%eax
 16b:	8b 84 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%eax
 172:	01 45 f0             	add    %eax,-0x10(%ebp)
    
    switch(cid%3)
 175:	8b 4d cc             	mov    -0x34(%ebp),%ecx
 178:	ba 56 55 55 55       	mov    $0x55555556,%edx
 17d:	89 c8                	mov    %ecx,%eax
 17f:	f7 ea                	imul   %edx
 181:	89 c8                	mov    %ecx,%eax
 183:	c1 f8 1f             	sar    $0x1f,%eax
 186:	89 d3                	mov    %edx,%ebx
 188:	29 c3                	sub    %eax,%ebx
 18a:	89 d8                	mov    %ebx,%eax
 18c:	89 c2                	mov    %eax,%edx
 18e:	01 d2                	add    %edx,%edx
 190:	01 c2                	add    %eax,%edx
 192:	89 c8                	mov    %ecx,%eax
 194:	29 d0                	sub    %edx,%eax
 196:	83 f8 01             	cmp    $0x1,%eax
 199:	74 25                	je     1c0 <sanity+0x13a>
 19b:	83 f8 02             	cmp    $0x2,%eax
 19e:	74 3c                	je     1dc <sanity+0x156>
 1a0:	85 c0                	test   %eax,%eax
 1a2:	75 53                	jne    1f7 <sanity+0x171>
    {
      case 0:
	avg_medium_wtime += wTime[cid];
 1a4:	8b 45 cc             	mov    -0x34(%ebp),%eax
 1a7:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
 1ae:	01 45 e4             	add    %eax,-0x1c(%ebp)
	avg_medium_rtime += rTime[cid];
 1b1:	8b 45 cc             	mov    -0x34(%ebp),%eax
 1b4:	8b 84 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%eax
 1bb:	01 45 e0             	add    %eax,-0x20(%ebp)
	break;
 1be:	eb 37                	jmp    1f7 <sanity+0x171>
      case 1:
	avg_low_wtime += wTime[cid];
 1c0:	8b 45 cc             	mov    -0x34(%ebp),%eax
 1c3:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
 1ca:	01 45 dc             	add    %eax,-0x24(%ebp)
	avg_low_rtime += rTime[cid];
 1cd:	8b 45 cc             	mov    -0x34(%ebp),%eax
 1d0:	8b 84 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%eax
 1d7:	01 45 d8             	add    %eax,-0x28(%ebp)
	break;
 1da:	eb 1b                	jmp    1f7 <sanity+0x171>
      case 2:
	avg_high_wtime += wTime[cid];
 1dc:	8b 45 cc             	mov    -0x34(%ebp),%eax
 1df:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
 1e6:	01 45 ec             	add    %eax,-0x14(%ebp)
	avg_high_rtime += rTime[cid];
 1e9:	8b 45 cc             	mov    -0x34(%ebp),%eax
 1ec:	8b 84 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%eax
 1f3:	01 45 e8             	add    %eax,-0x18(%ebp)
	break;
 1f6:	90                   	nop
      foo(cid);
      exit();      
    }
  }
  
  for(i=0;i<30;i++,found=0)
 1f7:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
 1fb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 202:	83 7d d0 1d          	cmpl   $0x1d,-0x30(%ebp)
 206:	0f 8e e5 fe ff ff    	jle    f1 <sanity+0x6b>
	avg_high_rtime += rTime[cid];
	break;
    }
  }

  printf(1, "All: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_all_wtime/30, avg_all_rtime/30, (avg_all_wtime + avg_all_rtime)/30);
 20c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 20f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 212:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
 215:	ba 89 88 88 88       	mov    $0x88888889,%edx
 21a:	89 c8                	mov    %ecx,%eax
 21c:	f7 ea                	imul   %edx
 21e:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
 221:	89 c2                	mov    %eax,%edx
 223:	c1 fa 04             	sar    $0x4,%edx
 226:	89 c8                	mov    %ecx,%eax
 228:	c1 f8 1f             	sar    $0x1f,%eax
 22b:	89 d6                	mov    %edx,%esi
 22d:	29 c6                	sub    %eax,%esi
 22f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
 232:	ba 89 88 88 88       	mov    $0x88888889,%edx
 237:	89 c8                	mov    %ecx,%eax
 239:	f7 ea                	imul   %edx
 23b:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
 23e:	89 c2                	mov    %eax,%edx
 240:	c1 fa 04             	sar    $0x4,%edx
 243:	89 c8                	mov    %ecx,%eax
 245:	c1 f8 1f             	sar    $0x1f,%eax
 248:	89 d3                	mov    %edx,%ebx
 24a:	29 c3                	sub    %eax,%ebx
 24c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 24f:	ba 89 88 88 88       	mov    $0x88888889,%edx
 254:	89 c8                	mov    %ecx,%eax
 256:	f7 ea                	imul   %edx
 258:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
 25b:	89 c2                	mov    %eax,%edx
 25d:	c1 fa 04             	sar    $0x4,%edx
 260:	89 c8                	mov    %ecx,%eax
 262:	c1 f8 1f             	sar    $0x1f,%eax
 265:	89 d1                	mov    %edx,%ecx
 267:	29 c1                	sub    %eax,%ecx
 269:	89 c8                	mov    %ecx,%eax
 26b:	89 74 24 10          	mov    %esi,0x10(%esp)
 26f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 273:	89 44 24 08          	mov    %eax,0x8(%esp)
 277:	c7 44 24 04 d4 0d 00 	movl   $0xdd4,0x4(%esp)
 27e:	00 
 27f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 286:	e8 54 07 00 00       	call   9df <printf>
  printf(1, "High priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_high_wtime/10, avg_high_rtime/10, (avg_high_wtime + avg_high_rtime)/10);
 28b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 28e:	8b 55 ec             	mov    -0x14(%ebp),%edx
 291:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
 294:	ba 67 66 66 66       	mov    $0x66666667,%edx
 299:	89 c8                	mov    %ecx,%eax
 29b:	f7 ea                	imul   %edx
 29d:	c1 fa 02             	sar    $0x2,%edx
 2a0:	89 c8                	mov    %ecx,%eax
 2a2:	c1 f8 1f             	sar    $0x1f,%eax
 2a5:	89 d6                	mov    %edx,%esi
 2a7:	29 c6                	sub    %eax,%esi
 2a9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
 2ac:	ba 67 66 66 66       	mov    $0x66666667,%edx
 2b1:	89 c8                	mov    %ecx,%eax
 2b3:	f7 ea                	imul   %edx
 2b5:	c1 fa 02             	sar    $0x2,%edx
 2b8:	89 c8                	mov    %ecx,%eax
 2ba:	c1 f8 1f             	sar    $0x1f,%eax
 2bd:	89 d3                	mov    %edx,%ebx
 2bf:	29 c3                	sub    %eax,%ebx
 2c1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
 2c4:	ba 67 66 66 66       	mov    $0x66666667,%edx
 2c9:	89 c8                	mov    %ecx,%eax
 2cb:	f7 ea                	imul   %edx
 2cd:	c1 fa 02             	sar    $0x2,%edx
 2d0:	89 c8                	mov    %ecx,%eax
 2d2:	c1 f8 1f             	sar    $0x1f,%eax
 2d5:	89 d1                	mov    %edx,%ecx
 2d7:	29 c1                	sub    %eax,%ecx
 2d9:	89 c8                	mov    %ecx,%eax
 2db:	89 74 24 10          	mov    %esi,0x10(%esp)
 2df:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 2e3:	89 44 24 08          	mov    %eax,0x8(%esp)
 2e7:	c7 44 24 04 2c 0e 00 	movl   $0xe2c,0x4(%esp)
 2ee:	00 
 2ef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2f6:	e8 e4 06 00 00       	call   9df <printf>
  printf(1, "Medium priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_medium_wtime/10, avg_medium_rtime/10, (avg_medium_wtime + avg_medium_rtime)/10);
 2fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
 2fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 301:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
 304:	ba 67 66 66 66       	mov    $0x66666667,%edx
 309:	89 c8                	mov    %ecx,%eax
 30b:	f7 ea                	imul   %edx
 30d:	c1 fa 02             	sar    $0x2,%edx
 310:	89 c8                	mov    %ecx,%eax
 312:	c1 f8 1f             	sar    $0x1f,%eax
 315:	89 d6                	mov    %edx,%esi
 317:	29 c6                	sub    %eax,%esi
 319:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 31c:	ba 67 66 66 66       	mov    $0x66666667,%edx
 321:	89 c8                	mov    %ecx,%eax
 323:	f7 ea                	imul   %edx
 325:	c1 fa 02             	sar    $0x2,%edx
 328:	89 c8                	mov    %ecx,%eax
 32a:	c1 f8 1f             	sar    $0x1f,%eax
 32d:	89 d3                	mov    %edx,%ebx
 32f:	29 c3                	sub    %eax,%ebx
 331:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
 334:	ba 67 66 66 66       	mov    $0x66666667,%edx
 339:	89 c8                	mov    %ecx,%eax
 33b:	f7 ea                	imul   %edx
 33d:	c1 fa 02             	sar    $0x2,%edx
 340:	89 c8                	mov    %ecx,%eax
 342:	c1 f8 1f             	sar    $0x1f,%eax
 345:	89 d1                	mov    %edx,%ecx
 347:	29 c1                	sub    %eax,%ecx
 349:	89 c8                	mov    %ecx,%eax
 34b:	89 74 24 10          	mov    %esi,0x10(%esp)
 34f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 353:	89 44 24 08          	mov    %eax,0x8(%esp)
 357:	c7 44 24 04 90 0e 00 	movl   $0xe90,0x4(%esp)
 35e:	00 
 35f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 366:	e8 74 06 00 00       	call   9df <printf>
  printf(1, "Low priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_low_wtime/10, avg_low_rtime/10, (avg_low_wtime + avg_low_rtime)/10);
 36b:	8b 45 d8             	mov    -0x28(%ebp),%eax
 36e:	8b 55 dc             	mov    -0x24(%ebp),%edx
 371:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
 374:	ba 67 66 66 66       	mov    $0x66666667,%edx
 379:	89 c8                	mov    %ecx,%eax
 37b:	f7 ea                	imul   %edx
 37d:	c1 fa 02             	sar    $0x2,%edx
 380:	89 c8                	mov    %ecx,%eax
 382:	c1 f8 1f             	sar    $0x1f,%eax
 385:	89 d6                	mov    %edx,%esi
 387:	29 c6                	sub    %eax,%esi
 389:	8b 4d d8             	mov    -0x28(%ebp),%ecx
 38c:	ba 67 66 66 66       	mov    $0x66666667,%edx
 391:	89 c8                	mov    %ecx,%eax
 393:	f7 ea                	imul   %edx
 395:	c1 fa 02             	sar    $0x2,%edx
 398:	89 c8                	mov    %ecx,%eax
 39a:	c1 f8 1f             	sar    $0x1f,%eax
 39d:	89 d3                	mov    %edx,%ebx
 39f:	29 c3                	sub    %eax,%ebx
 3a1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
 3a4:	ba 67 66 66 66       	mov    $0x66666667,%edx
 3a9:	89 c8                	mov    %ecx,%eax
 3ab:	f7 ea                	imul   %edx
 3ad:	c1 fa 02             	sar    $0x2,%edx
 3b0:	89 c8                	mov    %ecx,%eax
 3b2:	c1 f8 1f             	sar    $0x1f,%eax
 3b5:	89 d1                	mov    %edx,%ecx
 3b7:	29 c1                	sub    %eax,%ecx
 3b9:	89 c8                	mov    %ecx,%eax
 3bb:	89 74 24 10          	mov    %esi,0x10(%esp)
 3bf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 3c3:	89 44 24 08          	mov    %eax,0x8(%esp)
 3c7:	c7 44 24 04 f4 0e 00 	movl   $0xef4,0x4(%esp)
 3ce:	00 
 3cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3d6:	e8 04 06 00 00       	call   9df <printf>

  for(i=0;i<30;i++)
 3db:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
 3e2:	eb 56                	jmp    43a <sanity+0x3b4>
    printf(1, "child %d: Waiting Time: %d Running Time: %d Turnaround Time: %d\n",i,wTime[i],rTime[i],wTime[i]+rTime[i]);
 3e4:	8b 45 d0             	mov    -0x30(%ebp),%eax
 3e7:	8b 94 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%edx
 3ee:	8b 45 d0             	mov    -0x30(%ebp),%eax
 3f1:	8b 84 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%eax
 3f8:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
 3fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
 3fe:	8b 94 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%edx
 405:	8b 45 d0             	mov    -0x30(%ebp),%eax
 408:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
 40f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
 413:	89 54 24 10          	mov    %edx,0x10(%esp)
 417:	89 44 24 0c          	mov    %eax,0xc(%esp)
 41b:	8b 45 d0             	mov    -0x30(%ebp),%eax
 41e:	89 44 24 08          	mov    %eax,0x8(%esp)
 422:	c7 44 24 04 58 0f 00 	movl   $0xf58,0x4(%esp)
 429:	00 
 42a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 431:	e8 a9 05 00 00       	call   9df <printf>
  printf(1, "All: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_all_wtime/30, avg_all_rtime/30, (avg_all_wtime + avg_all_rtime)/30);
  printf(1, "High priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_high_wtime/10, avg_high_rtime/10, (avg_high_wtime + avg_high_rtime)/10);
  printf(1, "Medium priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_medium_wtime/10, avg_medium_rtime/10, (avg_medium_wtime + avg_medium_rtime)/10);
  printf(1, "Low priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_low_wtime/10, avg_low_rtime/10, (avg_low_wtime + avg_low_rtime)/10);

  for(i=0;i<30;i++)
 436:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
 43a:	83 7d d0 1d          	cmpl   $0x1d,-0x30(%ebp)
 43e:	7e a4                	jle    3e4 <sanity+0x35e>
    printf(1, "child %d: Waiting Time: %d Running Time: %d Turnaround Time: %d\n",i,wTime[i],rTime[i],wTime[i]+rTime[i]);

}
 440:	81 c4 c0 01 00 00    	add    $0x1c0,%esp
 446:	5b                   	pop    %ebx
 447:	5e                   	pop    %esi
 448:	5d                   	pop    %ebp
 449:	c3                   	ret    

0000044a <main>:
int
main(void)
{
 44a:	55                   	push   %ebp
 44b:	89 e5                	mov    %esp,%ebp
 44d:	83 e4 f0             	and    $0xfffffff0,%esp
  sanity();
 450:	e8 31 fc ff ff       	call   86 <sanity>
  exit();
 455:	e8 fe 03 00 00       	call   858 <exit>
 45a:	90                   	nop
 45b:	90                   	nop

0000045c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 45c:	55                   	push   %ebp
 45d:	89 e5                	mov    %esp,%ebp
 45f:	57                   	push   %edi
 460:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 461:	8b 4d 08             	mov    0x8(%ebp),%ecx
 464:	8b 55 10             	mov    0x10(%ebp),%edx
 467:	8b 45 0c             	mov    0xc(%ebp),%eax
 46a:	89 cb                	mov    %ecx,%ebx
 46c:	89 df                	mov    %ebx,%edi
 46e:	89 d1                	mov    %edx,%ecx
 470:	fc                   	cld    
 471:	f3 aa                	rep stos %al,%es:(%edi)
 473:	89 ca                	mov    %ecx,%edx
 475:	89 fb                	mov    %edi,%ebx
 477:	89 5d 08             	mov    %ebx,0x8(%ebp)
 47a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 47d:	5b                   	pop    %ebx
 47e:	5f                   	pop    %edi
 47f:	5d                   	pop    %ebp
 480:	c3                   	ret    

00000481 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 481:	55                   	push   %ebp
 482:	89 e5                	mov    %esp,%ebp
 484:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 487:	8b 45 08             	mov    0x8(%ebp),%eax
 48a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 48d:	90                   	nop
 48e:	8b 45 0c             	mov    0xc(%ebp),%eax
 491:	0f b6 10             	movzbl (%eax),%edx
 494:	8b 45 08             	mov    0x8(%ebp),%eax
 497:	88 10                	mov    %dl,(%eax)
 499:	8b 45 08             	mov    0x8(%ebp),%eax
 49c:	0f b6 00             	movzbl (%eax),%eax
 49f:	84 c0                	test   %al,%al
 4a1:	0f 95 c0             	setne  %al
 4a4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4a8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 4ac:	84 c0                	test   %al,%al
 4ae:	75 de                	jne    48e <strcpy+0xd>
    ;
  return os;
 4b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4b3:	c9                   	leave  
 4b4:	c3                   	ret    

000004b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4b5:	55                   	push   %ebp
 4b6:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 4b8:	eb 08                	jmp    4c2 <strcmp+0xd>
    p++, q++;
 4ba:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4be:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 4c2:	8b 45 08             	mov    0x8(%ebp),%eax
 4c5:	0f b6 00             	movzbl (%eax),%eax
 4c8:	84 c0                	test   %al,%al
 4ca:	74 10                	je     4dc <strcmp+0x27>
 4cc:	8b 45 08             	mov    0x8(%ebp),%eax
 4cf:	0f b6 10             	movzbl (%eax),%edx
 4d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d5:	0f b6 00             	movzbl (%eax),%eax
 4d8:	38 c2                	cmp    %al,%dl
 4da:	74 de                	je     4ba <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 4dc:	8b 45 08             	mov    0x8(%ebp),%eax
 4df:	0f b6 00             	movzbl (%eax),%eax
 4e2:	0f b6 d0             	movzbl %al,%edx
 4e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e8:	0f b6 00             	movzbl (%eax),%eax
 4eb:	0f b6 c0             	movzbl %al,%eax
 4ee:	89 d1                	mov    %edx,%ecx
 4f0:	29 c1                	sub    %eax,%ecx
 4f2:	89 c8                	mov    %ecx,%eax
}
 4f4:	5d                   	pop    %ebp
 4f5:	c3                   	ret    

000004f6 <strlen>:

uint
strlen(char *s)
{
 4f6:	55                   	push   %ebp
 4f7:	89 e5                	mov    %esp,%ebp
 4f9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 4fc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 503:	eb 04                	jmp    509 <strlen+0x13>
 505:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 509:	8b 45 fc             	mov    -0x4(%ebp),%eax
 50c:	03 45 08             	add    0x8(%ebp),%eax
 50f:	0f b6 00             	movzbl (%eax),%eax
 512:	84 c0                	test   %al,%al
 514:	75 ef                	jne    505 <strlen+0xf>
  return n;
 516:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 519:	c9                   	leave  
 51a:	c3                   	ret    

0000051b <memset>:

void*
memset(void *dst, int c, uint n)
{
 51b:	55                   	push   %ebp
 51c:	89 e5                	mov    %esp,%ebp
 51e:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 521:	8b 45 10             	mov    0x10(%ebp),%eax
 524:	89 44 24 08          	mov    %eax,0x8(%esp)
 528:	8b 45 0c             	mov    0xc(%ebp),%eax
 52b:	89 44 24 04          	mov    %eax,0x4(%esp)
 52f:	8b 45 08             	mov    0x8(%ebp),%eax
 532:	89 04 24             	mov    %eax,(%esp)
 535:	e8 22 ff ff ff       	call   45c <stosb>
  return dst;
 53a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 53d:	c9                   	leave  
 53e:	c3                   	ret    

0000053f <strchr>:

char*
strchr(const char *s, char c)
{
 53f:	55                   	push   %ebp
 540:	89 e5                	mov    %esp,%ebp
 542:	83 ec 04             	sub    $0x4,%esp
 545:	8b 45 0c             	mov    0xc(%ebp),%eax
 548:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 54b:	eb 14                	jmp    561 <strchr+0x22>
    if(*s == c)
 54d:	8b 45 08             	mov    0x8(%ebp),%eax
 550:	0f b6 00             	movzbl (%eax),%eax
 553:	3a 45 fc             	cmp    -0x4(%ebp),%al
 556:	75 05                	jne    55d <strchr+0x1e>
      return (char*)s;
 558:	8b 45 08             	mov    0x8(%ebp),%eax
 55b:	eb 13                	jmp    570 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 55d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 561:	8b 45 08             	mov    0x8(%ebp),%eax
 564:	0f b6 00             	movzbl (%eax),%eax
 567:	84 c0                	test   %al,%al
 569:	75 e2                	jne    54d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 56b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 570:	c9                   	leave  
 571:	c3                   	ret    

00000572 <gets>:

char*
gets(char *buf, int max)
{
 572:	55                   	push   %ebp
 573:	89 e5                	mov    %esp,%ebp
 575:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 578:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 57f:	eb 44                	jmp    5c5 <gets+0x53>
    cc = read(0, &c, 1);
 581:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 588:	00 
 589:	8d 45 ef             	lea    -0x11(%ebp),%eax
 58c:	89 44 24 04          	mov    %eax,0x4(%esp)
 590:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 597:	e8 e4 02 00 00       	call   880 <read>
 59c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 59f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5a3:	7e 2d                	jle    5d2 <gets+0x60>
      break;
    buf[i++] = c;
 5a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a8:	03 45 08             	add    0x8(%ebp),%eax
 5ab:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 5af:	88 10                	mov    %dl,(%eax)
 5b1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 5b5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5b9:	3c 0a                	cmp    $0xa,%al
 5bb:	74 16                	je     5d3 <gets+0x61>
 5bd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5c1:	3c 0d                	cmp    $0xd,%al
 5c3:	74 0e                	je     5d3 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c8:	83 c0 01             	add    $0x1,%eax
 5cb:	3b 45 0c             	cmp    0xc(%ebp),%eax
 5ce:	7c b1                	jl     581 <gets+0xf>
 5d0:	eb 01                	jmp    5d3 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 5d2:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 5d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d6:	03 45 08             	add    0x8(%ebp),%eax
 5d9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 5dc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5df:	c9                   	leave  
 5e0:	c3                   	ret    

000005e1 <stat>:

int
stat(char *n, struct stat *st)
{
 5e1:	55                   	push   %ebp
 5e2:	89 e5                	mov    %esp,%ebp
 5e4:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 5ee:	00 
 5ef:	8b 45 08             	mov    0x8(%ebp),%eax
 5f2:	89 04 24             	mov    %eax,(%esp)
 5f5:	e8 ae 02 00 00       	call   8a8 <open>
 5fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 5fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 601:	79 07                	jns    60a <stat+0x29>
    return -1;
 603:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 608:	eb 23                	jmp    62d <stat+0x4c>
  r = fstat(fd, st);
 60a:	8b 45 0c             	mov    0xc(%ebp),%eax
 60d:	89 44 24 04          	mov    %eax,0x4(%esp)
 611:	8b 45 f4             	mov    -0xc(%ebp),%eax
 614:	89 04 24             	mov    %eax,(%esp)
 617:	e8 a4 02 00 00       	call   8c0 <fstat>
 61c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 61f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 622:	89 04 24             	mov    %eax,(%esp)
 625:	e8 66 02 00 00       	call   890 <close>
  return r;
 62a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 62d:	c9                   	leave  
 62e:	c3                   	ret    

0000062f <atoi>:

int
atoi(const char *s)
{
 62f:	55                   	push   %ebp
 630:	89 e5                	mov    %esp,%ebp
 632:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 635:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 63c:	eb 23                	jmp    661 <atoi+0x32>
    n = n*10 + *s++ - '0';
 63e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 641:	89 d0                	mov    %edx,%eax
 643:	c1 e0 02             	shl    $0x2,%eax
 646:	01 d0                	add    %edx,%eax
 648:	01 c0                	add    %eax,%eax
 64a:	89 c2                	mov    %eax,%edx
 64c:	8b 45 08             	mov    0x8(%ebp),%eax
 64f:	0f b6 00             	movzbl (%eax),%eax
 652:	0f be c0             	movsbl %al,%eax
 655:	01 d0                	add    %edx,%eax
 657:	83 e8 30             	sub    $0x30,%eax
 65a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 65d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 661:	8b 45 08             	mov    0x8(%ebp),%eax
 664:	0f b6 00             	movzbl (%eax),%eax
 667:	3c 2f                	cmp    $0x2f,%al
 669:	7e 0a                	jle    675 <atoi+0x46>
 66b:	8b 45 08             	mov    0x8(%ebp),%eax
 66e:	0f b6 00             	movzbl (%eax),%eax
 671:	3c 39                	cmp    $0x39,%al
 673:	7e c9                	jle    63e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 675:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 678:	c9                   	leave  
 679:	c3                   	ret    

0000067a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 67a:	55                   	push   %ebp
 67b:	89 e5                	mov    %esp,%ebp
 67d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 680:	8b 45 08             	mov    0x8(%ebp),%eax
 683:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 686:	8b 45 0c             	mov    0xc(%ebp),%eax
 689:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 68c:	eb 13                	jmp    6a1 <memmove+0x27>
    *dst++ = *src++;
 68e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 691:	0f b6 10             	movzbl (%eax),%edx
 694:	8b 45 fc             	mov    -0x4(%ebp),%eax
 697:	88 10                	mov    %dl,(%eax)
 699:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 69d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 6a1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 6a5:	0f 9f c0             	setg   %al
 6a8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 6ac:	84 c0                	test   %al,%al
 6ae:	75 de                	jne    68e <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 6b0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6b3:	c9                   	leave  
 6b4:	c3                   	ret    

000006b5 <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 6b5:	55                   	push   %ebp
 6b6:	89 e5                	mov    %esp,%ebp
 6b8:	83 ec 38             	sub    $0x38,%esp
 6bb:	8b 45 10             	mov    0x10(%ebp),%eax
 6be:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 6c1:	8b 45 14             	mov    0x14(%ebp),%eax
 6c4:	8b 00                	mov    (%eax),%eax
 6c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 6c9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 6d0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6d4:	74 06                	je     6dc <strtok+0x27>
 6d6:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 6da:	75 54                	jne    730 <strtok+0x7b>
    return match;
 6dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6df:	eb 6e                	jmp    74f <strtok+0x9a>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 6e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e4:	03 45 0c             	add    0xc(%ebp),%eax
 6e7:	0f b6 00             	movzbl (%eax),%eax
 6ea:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 6ed:	74 06                	je     6f5 <strtok+0x40>
      {
	index++;
 6ef:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 6f3:	eb 3c                	jmp    731 <strtok+0x7c>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 6f5:	8b 45 14             	mov    0x14(%ebp),%eax
 6f8:	8b 00                	mov    (%eax),%eax
 6fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
 6fd:	29 c2                	sub    %eax,%edx
 6ff:	8b 45 14             	mov    0x14(%ebp),%eax
 702:	8b 00                	mov    (%eax),%eax
 704:	03 45 0c             	add    0xc(%ebp),%eax
 707:	89 54 24 08          	mov    %edx,0x8(%esp)
 70b:	89 44 24 04          	mov    %eax,0x4(%esp)
 70f:	8b 45 08             	mov    0x8(%ebp),%eax
 712:	89 04 24             	mov    %eax,(%esp)
 715:	e8 37 00 00 00       	call   751 <strncpy>
 71a:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 71d:	8b 45 08             	mov    0x8(%ebp),%eax
 720:	0f b6 00             	movzbl (%eax),%eax
 723:	84 c0                	test   %al,%al
 725:	74 19                	je     740 <strtok+0x8b>
	  match = 1;
 727:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 72e:	eb 10                	jmp    740 <strtok+0x8b>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 730:	90                   	nop
 731:	8b 45 f4             	mov    -0xc(%ebp),%eax
 734:	03 45 0c             	add    0xc(%ebp),%eax
 737:	0f b6 00             	movzbl (%eax),%eax
 73a:	84 c0                	test   %al,%al
 73c:	75 a3                	jne    6e1 <strtok+0x2c>
 73e:	eb 01                	jmp    741 <strtok+0x8c>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 740:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 741:	8b 45 f4             	mov    -0xc(%ebp),%eax
 744:	8d 50 01             	lea    0x1(%eax),%edx
 747:	8b 45 14             	mov    0x14(%ebp),%eax
 74a:	89 10                	mov    %edx,(%eax)
  return match;
 74c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 74f:	c9                   	leave  
 750:	c3                   	ret    

00000751 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 751:	55                   	push   %ebp
 752:	89 e5                	mov    %esp,%ebp
 754:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 757:	8b 45 08             	mov    0x8(%ebp),%eax
 75a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 75d:	90                   	nop
 75e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 762:	0f 9f c0             	setg   %al
 765:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 769:	84 c0                	test   %al,%al
 76b:	74 30                	je     79d <strncpy+0x4c>
 76d:	8b 45 0c             	mov    0xc(%ebp),%eax
 770:	0f b6 10             	movzbl (%eax),%edx
 773:	8b 45 08             	mov    0x8(%ebp),%eax
 776:	88 10                	mov    %dl,(%eax)
 778:	8b 45 08             	mov    0x8(%ebp),%eax
 77b:	0f b6 00             	movzbl (%eax),%eax
 77e:	84 c0                	test   %al,%al
 780:	0f 95 c0             	setne  %al
 783:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 787:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 78b:	84 c0                	test   %al,%al
 78d:	75 cf                	jne    75e <strncpy+0xd>
    ;
  while(n-- > 0)
 78f:	eb 0c                	jmp    79d <strncpy+0x4c>
    *s++ = 0;
 791:	8b 45 08             	mov    0x8(%ebp),%eax
 794:	c6 00 00             	movb   $0x0,(%eax)
 797:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 79b:	eb 01                	jmp    79e <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 79d:	90                   	nop
 79e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 7a2:	0f 9f c0             	setg   %al
 7a5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 7a9:	84 c0                	test   %al,%al
 7ab:	75 e4                	jne    791 <strncpy+0x40>
    *s++ = 0;
  return os;
 7ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 7b0:	c9                   	leave  
 7b1:	c3                   	ret    

000007b2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 7b2:	55                   	push   %ebp
 7b3:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 7b5:	eb 0c                	jmp    7c3 <strncmp+0x11>
    n--, p++, q++;
 7b7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 7bb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 7bf:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 7c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 7c7:	74 1a                	je     7e3 <strncmp+0x31>
 7c9:	8b 45 08             	mov    0x8(%ebp),%eax
 7cc:	0f b6 00             	movzbl (%eax),%eax
 7cf:	84 c0                	test   %al,%al
 7d1:	74 10                	je     7e3 <strncmp+0x31>
 7d3:	8b 45 08             	mov    0x8(%ebp),%eax
 7d6:	0f b6 10             	movzbl (%eax),%edx
 7d9:	8b 45 0c             	mov    0xc(%ebp),%eax
 7dc:	0f b6 00             	movzbl (%eax),%eax
 7df:	38 c2                	cmp    %al,%dl
 7e1:	74 d4                	je     7b7 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 7e3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 7e7:	75 07                	jne    7f0 <strncmp+0x3e>
    return 0;
 7e9:	b8 00 00 00 00       	mov    $0x0,%eax
 7ee:	eb 18                	jmp    808 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 7f0:	8b 45 08             	mov    0x8(%ebp),%eax
 7f3:	0f b6 00             	movzbl (%eax),%eax
 7f6:	0f b6 d0             	movzbl %al,%edx
 7f9:	8b 45 0c             	mov    0xc(%ebp),%eax
 7fc:	0f b6 00             	movzbl (%eax),%eax
 7ff:	0f b6 c0             	movzbl %al,%eax
 802:	89 d1                	mov    %edx,%ecx
 804:	29 c1                	sub    %eax,%ecx
 806:	89 c8                	mov    %ecx,%eax
}
 808:	5d                   	pop    %ebp
 809:	c3                   	ret    

0000080a <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 80a:	55                   	push   %ebp
 80b:	89 e5                	mov    %esp,%ebp
  while(*p){
 80d:	eb 13                	jmp    822 <strcat+0x18>
    *dest++ = *p++;
 80f:	8b 45 0c             	mov    0xc(%ebp),%eax
 812:	0f b6 10             	movzbl (%eax),%edx
 815:	8b 45 08             	mov    0x8(%ebp),%eax
 818:	88 10                	mov    %dl,(%eax)
 81a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 81e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 822:	8b 45 0c             	mov    0xc(%ebp),%eax
 825:	0f b6 00             	movzbl (%eax),%eax
 828:	84 c0                	test   %al,%al
 82a:	75 e3                	jne    80f <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 82c:	eb 13                	jmp    841 <strcat+0x37>
    *dest++ = *q++;
 82e:	8b 45 10             	mov    0x10(%ebp),%eax
 831:	0f b6 10             	movzbl (%eax),%edx
 834:	8b 45 08             	mov    0x8(%ebp),%eax
 837:	88 10                	mov    %dl,(%eax)
 839:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 83d:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 841:	8b 45 10             	mov    0x10(%ebp),%eax
 844:	0f b6 00             	movzbl (%eax),%eax
 847:	84 c0                	test   %al,%al
 849:	75 e3                	jne    82e <strcat+0x24>
    *dest++ = *q++;
  }  
 84b:	5d                   	pop    %ebp
 84c:	c3                   	ret    
 84d:	90                   	nop
 84e:	90                   	nop
 84f:	90                   	nop

00000850 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 850:	b8 01 00 00 00       	mov    $0x1,%eax
 855:	cd 40                	int    $0x40
 857:	c3                   	ret    

00000858 <exit>:
SYSCALL(exit)
 858:	b8 02 00 00 00       	mov    $0x2,%eax
 85d:	cd 40                	int    $0x40
 85f:	c3                   	ret    

00000860 <wait>:
SYSCALL(wait)
 860:	b8 03 00 00 00       	mov    $0x3,%eax
 865:	cd 40                	int    $0x40
 867:	c3                   	ret    

00000868 <wait2>:
SYSCALL(wait2)
 868:	b8 16 00 00 00       	mov    $0x16,%eax
 86d:	cd 40                	int    $0x40
 86f:	c3                   	ret    

00000870 <nice>:
SYSCALL(nice)
 870:	b8 17 00 00 00       	mov    $0x17,%eax
 875:	cd 40                	int    $0x40
 877:	c3                   	ret    

00000878 <pipe>:
SYSCALL(pipe)
 878:	b8 04 00 00 00       	mov    $0x4,%eax
 87d:	cd 40                	int    $0x40
 87f:	c3                   	ret    

00000880 <read>:
SYSCALL(read)
 880:	b8 05 00 00 00       	mov    $0x5,%eax
 885:	cd 40                	int    $0x40
 887:	c3                   	ret    

00000888 <write>:
SYSCALL(write)
 888:	b8 10 00 00 00       	mov    $0x10,%eax
 88d:	cd 40                	int    $0x40
 88f:	c3                   	ret    

00000890 <close>:
SYSCALL(close)
 890:	b8 15 00 00 00       	mov    $0x15,%eax
 895:	cd 40                	int    $0x40
 897:	c3                   	ret    

00000898 <kill>:
SYSCALL(kill)
 898:	b8 06 00 00 00       	mov    $0x6,%eax
 89d:	cd 40                	int    $0x40
 89f:	c3                   	ret    

000008a0 <exec>:
SYSCALL(exec)
 8a0:	b8 07 00 00 00       	mov    $0x7,%eax
 8a5:	cd 40                	int    $0x40
 8a7:	c3                   	ret    

000008a8 <open>:
SYSCALL(open)
 8a8:	b8 0f 00 00 00       	mov    $0xf,%eax
 8ad:	cd 40                	int    $0x40
 8af:	c3                   	ret    

000008b0 <mknod>:
SYSCALL(mknod)
 8b0:	b8 11 00 00 00       	mov    $0x11,%eax
 8b5:	cd 40                	int    $0x40
 8b7:	c3                   	ret    

000008b8 <unlink>:
SYSCALL(unlink)
 8b8:	b8 12 00 00 00       	mov    $0x12,%eax
 8bd:	cd 40                	int    $0x40
 8bf:	c3                   	ret    

000008c0 <fstat>:
SYSCALL(fstat)
 8c0:	b8 08 00 00 00       	mov    $0x8,%eax
 8c5:	cd 40                	int    $0x40
 8c7:	c3                   	ret    

000008c8 <link>:
SYSCALL(link)
 8c8:	b8 13 00 00 00       	mov    $0x13,%eax
 8cd:	cd 40                	int    $0x40
 8cf:	c3                   	ret    

000008d0 <mkdir>:
SYSCALL(mkdir)
 8d0:	b8 14 00 00 00       	mov    $0x14,%eax
 8d5:	cd 40                	int    $0x40
 8d7:	c3                   	ret    

000008d8 <chdir>:
SYSCALL(chdir)
 8d8:	b8 09 00 00 00       	mov    $0x9,%eax
 8dd:	cd 40                	int    $0x40
 8df:	c3                   	ret    

000008e0 <dup>:
SYSCALL(dup)
 8e0:	b8 0a 00 00 00       	mov    $0xa,%eax
 8e5:	cd 40                	int    $0x40
 8e7:	c3                   	ret    

000008e8 <getpid>:
SYSCALL(getpid)
 8e8:	b8 0b 00 00 00       	mov    $0xb,%eax
 8ed:	cd 40                	int    $0x40
 8ef:	c3                   	ret    

000008f0 <sbrk>:
SYSCALL(sbrk)
 8f0:	b8 0c 00 00 00       	mov    $0xc,%eax
 8f5:	cd 40                	int    $0x40
 8f7:	c3                   	ret    

000008f8 <sleep>:
SYSCALL(sleep)
 8f8:	b8 0d 00 00 00       	mov    $0xd,%eax
 8fd:	cd 40                	int    $0x40
 8ff:	c3                   	ret    

00000900 <uptime>:
SYSCALL(uptime)
 900:	b8 0e 00 00 00       	mov    $0xe,%eax
 905:	cd 40                	int    $0x40
 907:	c3                   	ret    

00000908 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 908:	55                   	push   %ebp
 909:	89 e5                	mov    %esp,%ebp
 90b:	83 ec 28             	sub    $0x28,%esp
 90e:	8b 45 0c             	mov    0xc(%ebp),%eax
 911:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 914:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 91b:	00 
 91c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 91f:	89 44 24 04          	mov    %eax,0x4(%esp)
 923:	8b 45 08             	mov    0x8(%ebp),%eax
 926:	89 04 24             	mov    %eax,(%esp)
 929:	e8 5a ff ff ff       	call   888 <write>
}
 92e:	c9                   	leave  
 92f:	c3                   	ret    

00000930 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 930:	55                   	push   %ebp
 931:	89 e5                	mov    %esp,%ebp
 933:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 936:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 93d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 941:	74 17                	je     95a <printint+0x2a>
 943:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 947:	79 11                	jns    95a <printint+0x2a>
    neg = 1;
 949:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 950:	8b 45 0c             	mov    0xc(%ebp),%eax
 953:	f7 d8                	neg    %eax
 955:	89 45 ec             	mov    %eax,-0x14(%ebp)
 958:	eb 06                	jmp    960 <printint+0x30>
  } else {
    x = xx;
 95a:	8b 45 0c             	mov    0xc(%ebp),%eax
 95d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 960:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 967:	8b 4d 10             	mov    0x10(%ebp),%ecx
 96a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 96d:	ba 00 00 00 00       	mov    $0x0,%edx
 972:	f7 f1                	div    %ecx
 974:	89 d0                	mov    %edx,%eax
 976:	0f b6 90 ac 12 00 00 	movzbl 0x12ac(%eax),%edx
 97d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 980:	03 45 f4             	add    -0xc(%ebp),%eax
 983:	88 10                	mov    %dl,(%eax)
 985:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 989:	8b 55 10             	mov    0x10(%ebp),%edx
 98c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 98f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 992:	ba 00 00 00 00       	mov    $0x0,%edx
 997:	f7 75 d4             	divl   -0x2c(%ebp)
 99a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 99d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 9a1:	75 c4                	jne    967 <printint+0x37>
  if(neg)
 9a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9a7:	74 2a                	je     9d3 <printint+0xa3>
    buf[i++] = '-';
 9a9:	8d 45 dc             	lea    -0x24(%ebp),%eax
 9ac:	03 45 f4             	add    -0xc(%ebp),%eax
 9af:	c6 00 2d             	movb   $0x2d,(%eax)
 9b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 9b6:	eb 1b                	jmp    9d3 <printint+0xa3>
    putc(fd, buf[i]);
 9b8:	8d 45 dc             	lea    -0x24(%ebp),%eax
 9bb:	03 45 f4             	add    -0xc(%ebp),%eax
 9be:	0f b6 00             	movzbl (%eax),%eax
 9c1:	0f be c0             	movsbl %al,%eax
 9c4:	89 44 24 04          	mov    %eax,0x4(%esp)
 9c8:	8b 45 08             	mov    0x8(%ebp),%eax
 9cb:	89 04 24             	mov    %eax,(%esp)
 9ce:	e8 35 ff ff ff       	call   908 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 9d3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 9d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9db:	79 db                	jns    9b8 <printint+0x88>
    putc(fd, buf[i]);
}
 9dd:	c9                   	leave  
 9de:	c3                   	ret    

000009df <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 9df:	55                   	push   %ebp
 9e0:	89 e5                	mov    %esp,%ebp
 9e2:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 9e5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 9ec:	8d 45 0c             	lea    0xc(%ebp),%eax
 9ef:	83 c0 04             	add    $0x4,%eax
 9f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 9f5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 9fc:	e9 7d 01 00 00       	jmp    b7e <printf+0x19f>
    c = fmt[i] & 0xff;
 a01:	8b 55 0c             	mov    0xc(%ebp),%edx
 a04:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a07:	01 d0                	add    %edx,%eax
 a09:	0f b6 00             	movzbl (%eax),%eax
 a0c:	0f be c0             	movsbl %al,%eax
 a0f:	25 ff 00 00 00       	and    $0xff,%eax
 a14:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 a17:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 a1b:	75 2c                	jne    a49 <printf+0x6a>
      if(c == '%'){
 a1d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a21:	75 0c                	jne    a2f <printf+0x50>
        state = '%';
 a23:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 a2a:	e9 4b 01 00 00       	jmp    b7a <printf+0x19b>
      } else {
        putc(fd, c);
 a2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a32:	0f be c0             	movsbl %al,%eax
 a35:	89 44 24 04          	mov    %eax,0x4(%esp)
 a39:	8b 45 08             	mov    0x8(%ebp),%eax
 a3c:	89 04 24             	mov    %eax,(%esp)
 a3f:	e8 c4 fe ff ff       	call   908 <putc>
 a44:	e9 31 01 00 00       	jmp    b7a <printf+0x19b>
      }
    } else if(state == '%'){
 a49:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 a4d:	0f 85 27 01 00 00    	jne    b7a <printf+0x19b>
      if(c == 'd'){
 a53:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 a57:	75 2d                	jne    a86 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 a59:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a5c:	8b 00                	mov    (%eax),%eax
 a5e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 a65:	00 
 a66:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 a6d:	00 
 a6e:	89 44 24 04          	mov    %eax,0x4(%esp)
 a72:	8b 45 08             	mov    0x8(%ebp),%eax
 a75:	89 04 24             	mov    %eax,(%esp)
 a78:	e8 b3 fe ff ff       	call   930 <printint>
        ap++;
 a7d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a81:	e9 ed 00 00 00       	jmp    b73 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 a86:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 a8a:	74 06                	je     a92 <printf+0xb3>
 a8c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 a90:	75 2d                	jne    abf <printf+0xe0>
        printint(fd, *ap, 16, 0);
 a92:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a95:	8b 00                	mov    (%eax),%eax
 a97:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 a9e:	00 
 a9f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 aa6:	00 
 aa7:	89 44 24 04          	mov    %eax,0x4(%esp)
 aab:	8b 45 08             	mov    0x8(%ebp),%eax
 aae:	89 04 24             	mov    %eax,(%esp)
 ab1:	e8 7a fe ff ff       	call   930 <printint>
        ap++;
 ab6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 aba:	e9 b4 00 00 00       	jmp    b73 <printf+0x194>
      } else if(c == 's'){
 abf:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 ac3:	75 46                	jne    b0b <printf+0x12c>
        s = (char*)*ap;
 ac5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 ac8:	8b 00                	mov    (%eax),%eax
 aca:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 acd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 ad1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ad5:	75 27                	jne    afe <printf+0x11f>
          s = "(null)";
 ad7:	c7 45 f4 99 0f 00 00 	movl   $0xf99,-0xc(%ebp)
        while(*s != 0){
 ade:	eb 1e                	jmp    afe <printf+0x11f>
          putc(fd, *s);
 ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae3:	0f b6 00             	movzbl (%eax),%eax
 ae6:	0f be c0             	movsbl %al,%eax
 ae9:	89 44 24 04          	mov    %eax,0x4(%esp)
 aed:	8b 45 08             	mov    0x8(%ebp),%eax
 af0:	89 04 24             	mov    %eax,(%esp)
 af3:	e8 10 fe ff ff       	call   908 <putc>
          s++;
 af8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 afc:	eb 01                	jmp    aff <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 afe:	90                   	nop
 aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b02:	0f b6 00             	movzbl (%eax),%eax
 b05:	84 c0                	test   %al,%al
 b07:	75 d7                	jne    ae0 <printf+0x101>
 b09:	eb 68                	jmp    b73 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 b0b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 b0f:	75 1d                	jne    b2e <printf+0x14f>
        putc(fd, *ap);
 b11:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b14:	8b 00                	mov    (%eax),%eax
 b16:	0f be c0             	movsbl %al,%eax
 b19:	89 44 24 04          	mov    %eax,0x4(%esp)
 b1d:	8b 45 08             	mov    0x8(%ebp),%eax
 b20:	89 04 24             	mov    %eax,(%esp)
 b23:	e8 e0 fd ff ff       	call   908 <putc>
        ap++;
 b28:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b2c:	eb 45                	jmp    b73 <printf+0x194>
      } else if(c == '%'){
 b2e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 b32:	75 17                	jne    b4b <printf+0x16c>
        putc(fd, c);
 b34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b37:	0f be c0             	movsbl %al,%eax
 b3a:	89 44 24 04          	mov    %eax,0x4(%esp)
 b3e:	8b 45 08             	mov    0x8(%ebp),%eax
 b41:	89 04 24             	mov    %eax,(%esp)
 b44:	e8 bf fd ff ff       	call   908 <putc>
 b49:	eb 28                	jmp    b73 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 b4b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 b52:	00 
 b53:	8b 45 08             	mov    0x8(%ebp),%eax
 b56:	89 04 24             	mov    %eax,(%esp)
 b59:	e8 aa fd ff ff       	call   908 <putc>
        putc(fd, c);
 b5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b61:	0f be c0             	movsbl %al,%eax
 b64:	89 44 24 04          	mov    %eax,0x4(%esp)
 b68:	8b 45 08             	mov    0x8(%ebp),%eax
 b6b:	89 04 24             	mov    %eax,(%esp)
 b6e:	e8 95 fd ff ff       	call   908 <putc>
      }
      state = 0;
 b73:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 b7a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 b7e:	8b 55 0c             	mov    0xc(%ebp),%edx
 b81:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b84:	01 d0                	add    %edx,%eax
 b86:	0f b6 00             	movzbl (%eax),%eax
 b89:	84 c0                	test   %al,%al
 b8b:	0f 85 70 fe ff ff    	jne    a01 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 b91:	c9                   	leave  
 b92:	c3                   	ret    
 b93:	90                   	nop

00000b94 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b94:	55                   	push   %ebp
 b95:	89 e5                	mov    %esp,%ebp
 b97:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b9a:	8b 45 08             	mov    0x8(%ebp),%eax
 b9d:	83 e8 08             	sub    $0x8,%eax
 ba0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ba3:	a1 c8 12 00 00       	mov    0x12c8,%eax
 ba8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 bab:	eb 24                	jmp    bd1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 bad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bb0:	8b 00                	mov    (%eax),%eax
 bb2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 bb5:	77 12                	ja     bc9 <free+0x35>
 bb7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bba:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 bbd:	77 24                	ja     be3 <free+0x4f>
 bbf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bc2:	8b 00                	mov    (%eax),%eax
 bc4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 bc7:	77 1a                	ja     be3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bc9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bcc:	8b 00                	mov    (%eax),%eax
 bce:	89 45 fc             	mov    %eax,-0x4(%ebp)
 bd1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bd4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 bd7:	76 d4                	jbe    bad <free+0x19>
 bd9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bdc:	8b 00                	mov    (%eax),%eax
 bde:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 be1:	76 ca                	jbe    bad <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 be3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 be6:	8b 40 04             	mov    0x4(%eax),%eax
 be9:	c1 e0 03             	shl    $0x3,%eax
 bec:	89 c2                	mov    %eax,%edx
 bee:	03 55 f8             	add    -0x8(%ebp),%edx
 bf1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bf4:	8b 00                	mov    (%eax),%eax
 bf6:	39 c2                	cmp    %eax,%edx
 bf8:	75 24                	jne    c1e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 bfa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bfd:	8b 50 04             	mov    0x4(%eax),%edx
 c00:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c03:	8b 00                	mov    (%eax),%eax
 c05:	8b 40 04             	mov    0x4(%eax),%eax
 c08:	01 c2                	add    %eax,%edx
 c0a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c0d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 c10:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c13:	8b 00                	mov    (%eax),%eax
 c15:	8b 10                	mov    (%eax),%edx
 c17:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c1a:	89 10                	mov    %edx,(%eax)
 c1c:	eb 0a                	jmp    c28 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 c1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c21:	8b 10                	mov    (%eax),%edx
 c23:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c26:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 c28:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c2b:	8b 40 04             	mov    0x4(%eax),%eax
 c2e:	c1 e0 03             	shl    $0x3,%eax
 c31:	03 45 fc             	add    -0x4(%ebp),%eax
 c34:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 c37:	75 20                	jne    c59 <free+0xc5>
    p->s.size += bp->s.size;
 c39:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c3c:	8b 50 04             	mov    0x4(%eax),%edx
 c3f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c42:	8b 40 04             	mov    0x4(%eax),%eax
 c45:	01 c2                	add    %eax,%edx
 c47:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c4a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 c4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c50:	8b 10                	mov    (%eax),%edx
 c52:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c55:	89 10                	mov    %edx,(%eax)
 c57:	eb 08                	jmp    c61 <free+0xcd>
  } else
    p->s.ptr = bp;
 c59:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c5c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 c5f:	89 10                	mov    %edx,(%eax)
  freep = p;
 c61:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c64:	a3 c8 12 00 00       	mov    %eax,0x12c8
}
 c69:	c9                   	leave  
 c6a:	c3                   	ret    

00000c6b <morecore>:

static Header*
morecore(uint nu)
{
 c6b:	55                   	push   %ebp
 c6c:	89 e5                	mov    %esp,%ebp
 c6e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 c71:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 c78:	77 07                	ja     c81 <morecore+0x16>
    nu = 4096;
 c7a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 c81:	8b 45 08             	mov    0x8(%ebp),%eax
 c84:	c1 e0 03             	shl    $0x3,%eax
 c87:	89 04 24             	mov    %eax,(%esp)
 c8a:	e8 61 fc ff ff       	call   8f0 <sbrk>
 c8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 c92:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 c96:	75 07                	jne    c9f <morecore+0x34>
    return 0;
 c98:	b8 00 00 00 00       	mov    $0x0,%eax
 c9d:	eb 22                	jmp    cc1 <morecore+0x56>
  hp = (Header*)p;
 c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ca2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 ca5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ca8:	8b 55 08             	mov    0x8(%ebp),%edx
 cab:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 cae:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cb1:	83 c0 08             	add    $0x8,%eax
 cb4:	89 04 24             	mov    %eax,(%esp)
 cb7:	e8 d8 fe ff ff       	call   b94 <free>
  return freep;
 cbc:	a1 c8 12 00 00       	mov    0x12c8,%eax
}
 cc1:	c9                   	leave  
 cc2:	c3                   	ret    

00000cc3 <malloc>:

void*
malloc(uint nbytes)
{
 cc3:	55                   	push   %ebp
 cc4:	89 e5                	mov    %esp,%ebp
 cc6:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 cc9:	8b 45 08             	mov    0x8(%ebp),%eax
 ccc:	83 c0 07             	add    $0x7,%eax
 ccf:	c1 e8 03             	shr    $0x3,%eax
 cd2:	83 c0 01             	add    $0x1,%eax
 cd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 cd8:	a1 c8 12 00 00       	mov    0x12c8,%eax
 cdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ce0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 ce4:	75 23                	jne    d09 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 ce6:	c7 45 f0 c0 12 00 00 	movl   $0x12c0,-0x10(%ebp)
 ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cf0:	a3 c8 12 00 00       	mov    %eax,0x12c8
 cf5:	a1 c8 12 00 00       	mov    0x12c8,%eax
 cfa:	a3 c0 12 00 00       	mov    %eax,0x12c0
    base.s.size = 0;
 cff:	c7 05 c4 12 00 00 00 	movl   $0x0,0x12c4
 d06:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d09:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d0c:	8b 00                	mov    (%eax),%eax
 d0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d14:	8b 40 04             	mov    0x4(%eax),%eax
 d17:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 d1a:	72 4d                	jb     d69 <malloc+0xa6>
      if(p->s.size == nunits)
 d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d1f:	8b 40 04             	mov    0x4(%eax),%eax
 d22:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 d25:	75 0c                	jne    d33 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d2a:	8b 10                	mov    (%eax),%edx
 d2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d2f:	89 10                	mov    %edx,(%eax)
 d31:	eb 26                	jmp    d59 <malloc+0x96>
      else {
        p->s.size -= nunits;
 d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d36:	8b 40 04             	mov    0x4(%eax),%eax
 d39:	89 c2                	mov    %eax,%edx
 d3b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d41:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d47:	8b 40 04             	mov    0x4(%eax),%eax
 d4a:	c1 e0 03             	shl    $0x3,%eax
 d4d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d53:	8b 55 ec             	mov    -0x14(%ebp),%edx
 d56:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 d59:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d5c:	a3 c8 12 00 00       	mov    %eax,0x12c8
      return (void*)(p + 1);
 d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d64:	83 c0 08             	add    $0x8,%eax
 d67:	eb 38                	jmp    da1 <malloc+0xde>
    }
    if(p == freep)
 d69:	a1 c8 12 00 00       	mov    0x12c8,%eax
 d6e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 d71:	75 1b                	jne    d8e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 d73:	8b 45 ec             	mov    -0x14(%ebp),%eax
 d76:	89 04 24             	mov    %eax,(%esp)
 d79:	e8 ed fe ff ff       	call   c6b <morecore>
 d7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 d81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 d85:	75 07                	jne    d8e <malloc+0xcb>
        return 0;
 d87:	b8 00 00 00 00       	mov    $0x0,%eax
 d8c:	eb 13                	jmp    da1 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d91:	89 45 f0             	mov    %eax,-0x10(%ebp)
 d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d97:	8b 00                	mov    (%eax),%eax
 d99:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 d9c:	e9 70 ff ff ff       	jmp    d11 <malloc+0x4e>
}
 da1:	c9                   	leave  
 da2:	c3                   	ret    

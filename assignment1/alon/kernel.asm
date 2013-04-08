
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 c6 10 80       	mov    $0x8010c650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 2f 37 10 80       	mov    $0x8010372f,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 6c 88 10 	movl   $0x8010886c,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 50 51 00 00       	call   8010519e <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 90 db 10 80 84 	movl   $0x8010db84,0x8010db90
80100055:	db 10 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 94 db 10 80 84 	movl   $0x8010db84,0x8010db94
8010005f:	db 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 c6 10 80 	movl   $0x8010c694,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 94 db 10 80    	mov    0x8010db94,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 84 db 10 80 	movl   $0x8010db84,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 94 db 10 80       	mov    0x8010db94,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 94 db 10 80       	mov    %eax,0x8010db94

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate fresh block.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801000bd:	e8 fd 50 00 00       	call   801051bf <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 94 db 10 80       	mov    0x8010db94,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->sector == sector){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	89 c2                	mov    %eax,%edx
801000f5:	83 ca 01             	or     $0x1,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100104:	e8 18 51 00 00       	call   80105221 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 32 4d 00 00       	call   80104e56 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 90 db 10 80       	mov    0x8010db90,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010017c:	e8 a0 50 00 00       	call   80105221 <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 73 88 10 80 	movl   $0x80108873,(%esp)
8010019f:	e8 99 03 00 00       	call   8010053d <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 04 29 00 00       	call   80102adc <iderw>
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 84 88 10 80 	movl   $0x80108884,(%esp)
801001f6:	e8 42 03 00 00       	call   8010053d <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	89 c2                	mov    %eax,%edx
80100202:	83 ca 04             	or     $0x4,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 c7 28 00 00       	call   80102adc <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 8b 88 10 80 	movl   $0x8010888b,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 7e 4f 00 00       	call   801051bf <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 94 db 10 80    	mov    0x8010db94,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 84 db 10 80 	movl   $0x8010db84,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 94 db 10 80       	mov    0x8010db94,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 94 db 10 80       	mov    %eax,0x8010db94

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	89 c2                	mov    %eax,%edx
8010028f:	83 e2 fe             	and    $0xfffffffe,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 90 4c 00 00       	call   80104f32 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 73 4f 00 00       	call   80105221 <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	53                   	push   %ebx
801002b4:	83 ec 14             	sub    $0x14,%esp
801002b7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ba:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002be:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801002c2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801002c6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801002ca:	ec                   	in     (%dx),%al
801002cb:	89 c3                	mov    %eax,%ebx
801002cd:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801002d0:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801002d4:	83 c4 14             	add    $0x14,%esp
801002d7:	5b                   	pop    %ebx
801002d8:	5d                   	pop    %ebp
801002d9:	c3                   	ret    

801002da <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002da:	55                   	push   %ebp
801002db:	89 e5                	mov    %esp,%ebp
801002dd:	83 ec 08             	sub    $0x8,%esp
801002e0:	8b 55 08             	mov    0x8(%ebp),%edx
801002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801002e6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002ea:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002ed:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002f1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002f5:	ee                   	out    %al,(%dx)
}
801002f6:	c9                   	leave  
801002f7:	c3                   	ret    

801002f8 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002f8:	55                   	push   %ebp
801002f9:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002fb:	fa                   	cli    
}
801002fc:	5d                   	pop    %ebp
801002fd:	c3                   	ret    

801002fe <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002fe:	55                   	push   %ebp
801002ff:	89 e5                	mov    %esp,%ebp
80100301:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100304:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100308:	74 19                	je     80100323 <printint+0x25>
8010030a:	8b 45 08             	mov    0x8(%ebp),%eax
8010030d:	c1 e8 1f             	shr    $0x1f,%eax
80100310:	89 45 10             	mov    %eax,0x10(%ebp)
80100313:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100317:	74 0a                	je     80100323 <printint+0x25>
    x = -xx;
80100319:	8b 45 08             	mov    0x8(%ebp),%eax
8010031c:	f7 d8                	neg    %eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100321:	eb 06                	jmp    80100329 <printint+0x2b>
  else
    x = xx;
80100323:	8b 45 08             	mov    0x8(%ebp),%eax
80100326:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100329:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100333:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100336:	ba 00 00 00 00       	mov    $0x0,%edx
8010033b:	f7 f1                	div    %ecx
8010033d:	89 d0                	mov    %edx,%eax
8010033f:	0f b6 90 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%edx
80100346:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100349:	03 45 f4             	add    -0xc(%ebp),%eax
8010034c:	88 10                	mov    %dl,(%eax)
8010034e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
80100352:	8b 55 0c             	mov    0xc(%ebp),%edx
80100355:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035b:	ba 00 00 00 00       	mov    $0x0,%edx
80100360:	f7 75 d4             	divl   -0x2c(%ebp)
80100363:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100366:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010036a:	75 c4                	jne    80100330 <printint+0x32>

  if(sign)
8010036c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100370:	74 23                	je     80100395 <printint+0x97>
    buf[i++] = '-';
80100372:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100375:	03 45 f4             	add    -0xc(%ebp),%eax
80100378:	c6 00 2d             	movb   $0x2d,(%eax)
8010037b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
8010037f:	eb 14                	jmp    80100395 <printint+0x97>
    consputc(buf[i]);
80100381:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100384:	03 45 f4             	add    -0xc(%ebp),%eax
80100387:	0f b6 00             	movzbl (%eax),%eax
8010038a:	0f be c0             	movsbl %al,%eax
8010038d:	89 04 24             	mov    %eax,(%esp)
80100390:	e8 eb 03 00 00       	call   80100780 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
80100395:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100399:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010039d:	79 e2                	jns    80100381 <printint+0x83>
    consputc(buf[i]);
}
8010039f:	c9                   	leave  
801003a0:	c3                   	ret    

801003a1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a1:	55                   	push   %ebp
801003a2:	89 e5                	mov    %esp,%ebp
801003a4:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a7:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b3:	74 0c                	je     801003c1 <cprintf+0x20>
    acquire(&cons.lock);
801003b5:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801003bc:	e8 fe 4d 00 00       	call   801051bf <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 92 88 10 80 	movl   $0x80108892,(%esp)
801003cf:	e8 69 01 00 00       	call   8010053d <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d4:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e1:	e9 20 01 00 00       	jmp    80100506 <cprintf+0x165>
    if(c != '%'){
801003e6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003ea:	74 10                	je     801003fc <cprintf+0x5b>
      consputc(c);
801003ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ef:	89 04 24             	mov    %eax,(%esp)
801003f2:	e8 89 03 00 00       	call   80100780 <consputc>
      continue;
801003f7:	e9 06 01 00 00       	jmp    80100502 <cprintf+0x161>
    }
    c = fmt[++i] & 0xff;
801003fc:	8b 55 08             	mov    0x8(%ebp),%edx
801003ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100406:	01 d0                	add    %edx,%eax
80100408:	0f b6 00             	movzbl (%eax),%eax
8010040b:	0f be c0             	movsbl %al,%eax
8010040e:	25 ff 00 00 00       	and    $0xff,%eax
80100413:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100416:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010041a:	0f 84 08 01 00 00    	je     80100528 <cprintf+0x187>
      break;
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4d                	je     80100475 <cprintf+0xd4>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0x9f>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13b>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xae>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x149>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 53                	je     80100498 <cprintf+0xf7>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2b                	je     80100475 <cprintf+0xd4>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x149>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8b 00                	mov    (%eax),%eax
80100454:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
80100458:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010045f:	00 
80100460:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100467:	00 
80100468:	89 04 24             	mov    %eax,(%esp)
8010046b:	e8 8e fe ff ff       	call   801002fe <printint>
      break;
80100470:	e9 8d 00 00 00       	jmp    80100502 <cprintf+0x161>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100478:	8b 00                	mov    (%eax),%eax
8010047a:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
8010047e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100485:	00 
80100486:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
8010048d:	00 
8010048e:	89 04 24             	mov    %eax,(%esp)
80100491:	e8 68 fe ff ff       	call   801002fe <printint>
      break;
80100496:	eb 6a                	jmp    80100502 <cprintf+0x161>
    case 's':
      if((s = (char*)*argp++) == 0)
80100498:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049b:	8b 00                	mov    (%eax),%eax
8010049d:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004a0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004a4:	0f 94 c0             	sete   %al
801004a7:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
801004ab:	84 c0                	test   %al,%al
801004ad:	74 20                	je     801004cf <cprintf+0x12e>
        s = "(null)";
801004af:	c7 45 ec 9b 88 10 80 	movl   $0x8010889b,-0x14(%ebp)
      for(; *s; s++)
801004b6:	eb 17                	jmp    801004cf <cprintf+0x12e>
        consputc(*s);
801004b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004bb:	0f b6 00             	movzbl (%eax),%eax
801004be:	0f be c0             	movsbl %al,%eax
801004c1:	89 04 24             	mov    %eax,(%esp)
801004c4:	e8 b7 02 00 00       	call   80100780 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004c9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004cd:	eb 01                	jmp    801004d0 <cprintf+0x12f>
801004cf:	90                   	nop
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 de                	jne    801004b8 <cprintf+0x117>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x161>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 98 02 00 00       	call   80100780 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x161>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 8a 02 00 00       	call   80100780 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 7f 02 00 00       	call   80100780 <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 c0 fe ff ff    	jne    801003e6 <cprintf+0x45>
80100526:	eb 01                	jmp    80100529 <cprintf+0x188>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
80100528:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
80100529:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052d:	74 0c                	je     8010053b <cprintf+0x19a>
    release(&cons.lock);
8010052f:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100536:	e8 e6 4c 00 00       	call   80105221 <release>
}
8010053b:	c9                   	leave  
8010053c:	c3                   	ret    

8010053d <panic>:

void
panic(char *s)
{
8010053d:	55                   	push   %ebp
8010053e:	89 e5                	mov    %esp,%ebp
80100540:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100543:	e8 b0 fd ff ff       	call   801002f8 <cli>
  cons.locking = 0;
80100548:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
8010054f:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100552:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f b6 c0             	movzbl %al,%eax
8010055e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100562:	c7 04 24 a2 88 10 80 	movl   $0x801088a2,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 b1 88 10 80 	movl   $0x801088b1,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 d9 4c 00 00       	call   80105270 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 b3 88 10 80 	movl   $0x801088b3,(%esp)
801005b2:	e8 ea fd ff ff       	call   801003a1 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005bb:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bf:	7e df                	jle    801005a0 <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005c1:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
801005c8:	00 00 00 
  for(;;)
    ;
801005cb:	eb fe                	jmp    801005cb <panic+0x8e>

801005cd <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005cd:	55                   	push   %ebp
801005ce:	89 e5                	mov    %esp,%ebp
801005d0:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d3:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005da:	00 
801005db:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005e2:	e8 f3 fc ff ff       	call   801002da <outb>
  pos = inb(CRTPORT+1) << 8;
801005e7:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005ee:	e8 bd fc ff ff       	call   801002b0 <inb>
801005f3:	0f b6 c0             	movzbl %al,%eax
801005f6:	c1 e0 08             	shl    $0x8,%eax
801005f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005fc:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100603:	00 
80100604:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010060b:	e8 ca fc ff ff       	call   801002da <outb>
  pos |= inb(CRTPORT+1);
80100610:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100617:	e8 94 fc ff ff       	call   801002b0 <inb>
8010061c:	0f b6 c0             	movzbl %al,%eax
8010061f:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100622:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100626:	75 30                	jne    80100658 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100628:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010062b:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100630:	89 c8                	mov    %ecx,%eax
80100632:	f7 ea                	imul   %edx
80100634:	c1 fa 05             	sar    $0x5,%edx
80100637:	89 c8                	mov    %ecx,%eax
80100639:	c1 f8 1f             	sar    $0x1f,%eax
8010063c:	29 c2                	sub    %eax,%edx
8010063e:	89 d0                	mov    %edx,%eax
80100640:	c1 e0 02             	shl    $0x2,%eax
80100643:	01 d0                	add    %edx,%eax
80100645:	c1 e0 04             	shl    $0x4,%eax
80100648:	89 ca                	mov    %ecx,%edx
8010064a:	29 c2                	sub    %eax,%edx
8010064c:	b8 50 00 00 00       	mov    $0x50,%eax
80100651:	29 d0                	sub    %edx,%eax
80100653:	01 45 f4             	add    %eax,-0xc(%ebp)
80100656:	eb 50                	jmp    801006a8 <cgaputc+0xdb>
  else if(c == BACKSPACE){
80100658:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065f:	75 0c                	jne    8010066d <cgaputc+0xa0>
    if(pos > 0) --pos;
80100661:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100665:	7e 41                	jle    801006a8 <cgaputc+0xdb>
80100667:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010066b:	eb 3b                	jmp    801006a8 <cgaputc+0xdb>
  }
  else if(c == KEY_LF){
8010066d:	81 7d 08 e4 00 00 00 	cmpl   $0xe4,0x8(%ebp)
80100674:	75 06                	jne    8010067c <cgaputc+0xaf>
    --pos;
80100676:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010067a:	eb 2c                	jmp    801006a8 <cgaputc+0xdb>
  }
  else if(c == KEY_RT){
8010067c:	81 7d 08 e5 00 00 00 	cmpl   $0xe5,0x8(%ebp)
80100683:	75 06                	jne    8010068b <cgaputc+0xbe>
    ++pos;
80100685:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100689:	eb 1d                	jmp    801006a8 <cgaputc+0xdb>
  }
  else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010068b:	a1 00 90 10 80       	mov    0x80109000,%eax
80100690:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100693:	01 d2                	add    %edx,%edx
80100695:	01 c2                	add    %eax,%edx
80100697:	8b 45 08             	mov    0x8(%ebp),%eax
8010069a:	66 25 ff 00          	and    $0xff,%ax
8010069e:	80 cc 07             	or     $0x7,%ah
801006a1:	66 89 02             	mov    %ax,(%edx)
801006a4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  if((pos/80) >= 24){  // Scroll up.
801006a8:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006af:	7e 53                	jle    80100704 <cgaputc+0x137>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006b1:	a1 00 90 10 80       	mov    0x80109000,%eax
801006b6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006bc:	a1 00 90 10 80       	mov    0x80109000,%eax
801006c1:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006c8:	00 
801006c9:	89 54 24 04          	mov    %edx,0x4(%esp)
801006cd:	89 04 24             	mov    %eax,(%esp)
801006d0:	e8 0c 4e 00 00       	call   801054e1 <memmove>
    pos -= 80;
801006d5:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006d9:	b8 80 07 00 00       	mov    $0x780,%eax
801006de:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006e1:	01 c0                	add    %eax,%eax
801006e3:	8b 15 00 90 10 80    	mov    0x80109000,%edx
801006e9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006ec:	01 c9                	add    %ecx,%ecx
801006ee:	01 ca                	add    %ecx,%edx
801006f0:	89 44 24 08          	mov    %eax,0x8(%esp)
801006f4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006fb:	00 
801006fc:	89 14 24             	mov    %edx,(%esp)
801006ff:	e8 0a 4d 00 00       	call   8010540e <memset>
  }
  
  outb(CRTPORT, 14);
80100704:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
8010070b:	00 
8010070c:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100713:	e8 c2 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos>>8);
80100718:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010071b:	c1 f8 08             	sar    $0x8,%eax
8010071e:	0f b6 c0             	movzbl %al,%eax
80100721:	89 44 24 04          	mov    %eax,0x4(%esp)
80100725:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010072c:	e8 a9 fb ff ff       	call   801002da <outb>
  outb(CRTPORT, 15);
80100731:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100738:	00 
80100739:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100740:	e8 95 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos);
80100745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100748:	0f b6 c0             	movzbl %al,%eax
8010074b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010074f:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100756:	e8 7f fb ff ff       	call   801002da <outb>
  if(c != KEY_LF && c != KEY_RT)
8010075b:	81 7d 08 e4 00 00 00 	cmpl   $0xe4,0x8(%ebp)
80100762:	74 1a                	je     8010077e <cgaputc+0x1b1>
80100764:	81 7d 08 e5 00 00 00 	cmpl   $0xe5,0x8(%ebp)
8010076b:	74 11                	je     8010077e <cgaputc+0x1b1>
    crt[pos] = ' ' | 0x0700;
8010076d:	a1 00 90 10 80       	mov    0x80109000,%eax
80100772:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100775:	01 d2                	add    %edx,%edx
80100777:	01 d0                	add    %edx,%eax
80100779:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010077e:	c9                   	leave  
8010077f:	c3                   	ret    

80100780 <consputc>:

void
consputc(int c)
{
80100780:	55                   	push   %ebp
80100781:	89 e5                	mov    %esp,%ebp
80100783:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100786:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
8010078b:	85 c0                	test   %eax,%eax
8010078d:	74 07                	je     80100796 <consputc+0x16>
    cli();
8010078f:	e8 64 fb ff ff       	call   801002f8 <cli>
    for(;;)
      ;
80100794:	eb fe                	jmp    80100794 <consputc+0x14>
  }

  if(c == BACKSPACE){
80100796:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010079d:	75 26                	jne    801007c5 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 26 67 00 00       	call   80106ed1 <uartputc>
801007ab:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801007b2:	e8 1a 67 00 00       	call   80106ed1 <uartputc>
801007b7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007be:	e8 0e 67 00 00       	call   80106ed1 <uartputc>
801007c3:	eb 0b                	jmp    801007d0 <consputc+0x50>
  }
  else if (c == KEY_RT){
    uartputc(0x601);
  }*/
  else
    uartputc(c);
801007c5:	8b 45 08             	mov    0x8(%ebp),%eax
801007c8:	89 04 24             	mov    %eax,(%esp)
801007cb:	e8 01 67 00 00       	call   80106ed1 <uartputc>
  cgaputc(c);
801007d0:	8b 45 08             	mov    0x8(%ebp),%eax
801007d3:	89 04 24             	mov    %eax,(%esp)
801007d6:	e8 f2 fd ff ff       	call   801005cd <cgaputc>
}
801007db:	c9                   	leave  
801007dc:	c3                   	ret    

801007dd <shiftRightBuf>:

#define C(x)  ((x)-'@')  // Control-x

void
shiftRightBuf(uint e, uint k)
{
801007dd:	55                   	push   %ebp
801007de:	89 e5                	mov    %esp,%ebp
801007e0:	83 ec 10             	sub    $0x10,%esp
  uint j=0;
801007e3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(;j < k;e--,j++){
801007ea:	eb 21                	jmp    8010080d <shiftRightBuf+0x30>
    input.buf[e] = input.buf[e-1];
801007ec:	8b 45 08             	mov    0x8(%ebp),%eax
801007ef:	83 e8 01             	sub    $0x1,%eax
801007f2:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
801007f9:	8b 55 08             	mov    0x8(%ebp),%edx
801007fc:	81 c2 d0 dd 10 80    	add    $0x8010ddd0,%edx
80100802:	88 42 04             	mov    %al,0x4(%edx)

void
shiftRightBuf(uint e, uint k)
{
  uint j=0;
  for(;j < k;e--,j++){
80100805:	83 6d 08 01          	subl   $0x1,0x8(%ebp)
80100809:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010080d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100810:	3b 45 0c             	cmp    0xc(%ebp),%eax
80100813:	72 d7                	jb     801007ec <shiftRightBuf+0xf>
    input.buf[e] = input.buf[e-1];
  }
}
80100815:	c9                   	leave  
80100816:	c3                   	ret    

80100817 <shiftLeftBuf>:

void
shiftLeftBuf(uint e, uint k)
{
80100817:	55                   	push   %ebp
80100818:	89 e5                	mov    %esp,%ebp
8010081a:	83 ec 10             	sub    $0x10,%esp
  uint i = e-k;
8010081d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100820:	8b 55 08             	mov    0x8(%ebp),%edx
80100823:	89 d1                	mov    %edx,%ecx
80100825:	29 c1                	sub    %eax,%ecx
80100827:	89 c8                	mov    %ecx,%eax
80100829:	89 45 fc             	mov    %eax,-0x4(%ebp)
  uint j=0;
8010082c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(;j < k ;i++,j++){
80100833:	eb 21                	jmp    80100856 <shiftLeftBuf+0x3f>
    input.buf[i] = input.buf[i+1];
80100835:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100838:	83 c0 01             	add    $0x1,%eax
8010083b:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
80100842:	8b 55 fc             	mov    -0x4(%ebp),%edx
80100845:	81 c2 d0 dd 10 80    	add    $0x8010ddd0,%edx
8010084b:	88 42 04             	mov    %al,0x4(%edx)
void
shiftLeftBuf(uint e, uint k)
{
  uint i = e-k;
  uint j=0;
  for(;j < k ;i++,j++){
8010084e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80100852:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80100856:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100859:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010085c:	72 d7                	jb     80100835 <shiftLeftBuf+0x1e>
    input.buf[i] = input.buf[i+1];
  }
  input.buf[e] = ' ';
8010085e:	8b 45 08             	mov    0x8(%ebp),%eax
80100861:	05 d0 dd 10 80       	add    $0x8010ddd0,%eax
80100866:	c6 40 04 20          	movb   $0x20,0x4(%eax)
}
8010086a:	c9                   	leave  
8010086b:	c3                   	ret    

8010086c <consoleintr>:

void
consoleintr(int (*getc)(void))
{
8010086c:	55                   	push   %ebp
8010086d:	89 e5                	mov    %esp,%ebp
8010086f:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
80100872:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100879:	e8 41 49 00 00       	call   801051bf <acquire>
  while((c = getc()) >= 0){
8010087e:	e9 a8 03 00 00       	jmp    80100c2b <consoleintr+0x3bf>
    switch(c){
80100883:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100886:	83 f8 15             	cmp    $0x15,%eax
80100889:	74 59                	je     801008e4 <consoleintr+0x78>
8010088b:	83 f8 15             	cmp    $0x15,%eax
8010088e:	7f 0f                	jg     8010089f <consoleintr+0x33>
80100890:	83 f8 08             	cmp    $0x8,%eax
80100893:	74 7e                	je     80100913 <consoleintr+0xa7>
80100895:	83 f8 10             	cmp    $0x10,%eax
80100898:	74 25                	je     801008bf <consoleintr+0x53>
8010089a:	e9 e4 01 00 00       	jmp    80100a83 <consoleintr+0x217>
8010089f:	3d e4 00 00 00       	cmp    $0xe4,%eax
801008a4:	0f 84 44 01 00 00    	je     801009ee <consoleintr+0x182>
801008aa:	3d e5 00 00 00       	cmp    $0xe5,%eax
801008af:	0f 84 88 01 00 00    	je     80100a3d <consoleintr+0x1d1>
801008b5:	83 f8 7f             	cmp    $0x7f,%eax
801008b8:	74 59                	je     80100913 <consoleintr+0xa7>
801008ba:	e9 c4 01 00 00       	jmp    80100a83 <consoleintr+0x217>
    case C('P'):  // Process listing.
      procdump();
801008bf:	e8 14 47 00 00       	call   80104fd8 <procdump>
      break;
801008c4:	e9 62 03 00 00       	jmp    80100c2b <consoleintr+0x3bf>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801008c9:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008ce:	83 e8 01             	sub    $0x1,%eax
801008d1:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(BACKSPACE);
801008d6:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
801008dd:	e8 9e fe ff ff       	call   80100780 <consputc>
801008e2:	eb 01                	jmp    801008e5 <consoleintr+0x79>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008e4:	90                   	nop
801008e5:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
801008eb:	a1 58 de 10 80       	mov    0x8010de58,%eax
801008f0:	39 c2                	cmp    %eax,%edx
801008f2:	0f 84 26 03 00 00    	je     80100c1e <consoleintr+0x3b2>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008f8:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008fd:	83 e8 01             	sub    $0x1,%eax
80100900:	83 e0 7f             	and    $0x7f,%eax
80100903:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010090a:	3c 0a                	cmp    $0xa,%al
8010090c:	75 bb                	jne    801008c9 <consoleintr+0x5d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
8010090e:	e9 0b 03 00 00       	jmp    80100c1e <consoleintr+0x3b2>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100913:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100919:	a1 58 de 10 80       	mov    0x8010de58,%eax
8010091e:	39 c2                	cmp    %eax,%edx
80100920:	0f 84 fb 02 00 00    	je     80100c21 <consoleintr+0x3b5>
	if(input.a > 0)
80100926:	a1 60 de 10 80       	mov    0x8010de60,%eax
8010092b:	85 c0                	test   %eax,%eax
8010092d:	0f 84 9d 00 00 00    	je     801009d0 <consoleintr+0x164>
	{
	    shiftLeftBuf((input.e-1) % INPUT_BUF,input.a);
80100933:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100938:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
8010093e:	83 ea 01             	sub    $0x1,%edx
80100941:	83 e2 7f             	and    $0x7f,%edx
80100944:	89 44 24 04          	mov    %eax,0x4(%esp)
80100948:	89 14 24             	mov    %edx,(%esp)
8010094b:	e8 c7 fe ff ff       	call   80100817 <shiftLeftBuf>
	    uint i = input.e-input.a-1;
80100950:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100956:	a1 60 de 10 80       	mov    0x8010de60,%eax
8010095b:	89 d1                	mov    %edx,%ecx
8010095d:	29 c1                	sub    %eax,%ecx
8010095f:	89 c8                	mov    %ecx,%eax
80100961:	83 e8 01             	sub    $0x1,%eax
80100964:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    consputc(KEY_LF);
80100967:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
8010096e:	e8 0d fe ff ff       	call   80100780 <consputc>
	    for(;i<input.e;i++){
80100973:	eb 1c                	jmp    80100991 <consoleintr+0x125>
	      consputc(input.buf[i%INPUT_BUF]);
80100975:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100978:	83 e0 7f             	and    $0x7f,%eax
8010097b:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
80100982:	0f be c0             	movsbl %al,%eax
80100985:	89 04 24             	mov    %eax,(%esp)
80100988:	e8 f3 fd ff ff       	call   80100780 <consputc>
	if(input.a > 0)
	{
	    shiftLeftBuf((input.e-1) % INPUT_BUF,input.a);
	    uint i = input.e-input.a-1;
	    consputc(KEY_LF);
	    for(;i<input.e;i++){
8010098d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100991:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100996:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100999:	77 da                	ja     80100975 <consoleintr+0x109>
	      consputc(input.buf[i%INPUT_BUF]);
	    }
	    i = input.e-input.a;
8010099b:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
801009a1:	a1 60 de 10 80       	mov    0x8010de60,%eax
801009a6:	89 d1                	mov    %edx,%ecx
801009a8:	29 c1                	sub    %eax,%ecx
801009aa:	89 c8                	mov    %ecx,%eax
801009ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    for(;i<input.e+1;i++){
801009af:	eb 10                	jmp    801009c1 <consoleintr+0x155>
	      consputc(KEY_LF);
801009b1:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
801009b8:	e8 c3 fd ff ff       	call   80100780 <consputc>
	    consputc(KEY_LF);
	    for(;i<input.e;i++){
	      consputc(input.buf[i%INPUT_BUF]);
	    }
	    i = input.e-input.a;
	    for(;i<input.e+1;i++){
801009bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801009c1:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801009c6:	83 c0 01             	add    $0x1,%eax
801009c9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009cc:	77 e3                	ja     801009b1 <consoleintr+0x145>
801009ce:	eb 0c                	jmp    801009dc <consoleintr+0x170>
	      consputc(KEY_LF);
	    }
	}
	else
	{
	  consputc(BACKSPACE);
801009d0:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
801009d7:	e8 a4 fd ff ff       	call   80100780 <consputc>
	}
	input.e--;
801009dc:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801009e1:	83 e8 01             	sub    $0x1,%eax
801009e4:	a3 5c de 10 80       	mov    %eax,0x8010de5c
      }
      break;
801009e9:	e9 33 02 00 00       	jmp    80100c21 <consoleintr+0x3b5>
    case KEY_LF: //LEFT KEY
     if(c != 0 && input.e - input.a > input.w && input.size > 0)
801009ee:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801009f2:	0f 84 2c 02 00 00    	je     80100c24 <consoleintr+0x3b8>
801009f8:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
801009fe:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a03:	29 c2                	sub    %eax,%edx
80100a05:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100a0a:	39 c2                	cmp    %eax,%edx
80100a0c:	0f 86 12 02 00 00    	jbe    80100c24 <consoleintr+0x3b8>
80100a12:	a1 64 de 10 80       	mov    0x8010de64,%eax
80100a17:	85 c0                	test   %eax,%eax
80100a19:	0f 84 05 02 00 00    	je     80100c24 <consoleintr+0x3b8>
      {
        consputc(KEY_LF);
80100a1f:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100a26:	e8 55 fd ff ff       	call   80100780 <consputc>
	input.a++;
80100a2b:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a30:	83 c0 01             	add    $0x1,%eax
80100a33:	a3 60 de 10 80       	mov    %eax,0x8010de60
      }
      break;
80100a38:	e9 e7 01 00 00       	jmp    80100c24 <consoleintr+0x3b8>
    case KEY_RT: //RIGHT KEY
      if(c != 0 && input.a > 0 && input.e % INPUT_BUF < INPUT_BUF-1)
80100a3d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100a41:	0f 84 e0 01 00 00    	je     80100c27 <consoleintr+0x3bb>
80100a47:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a4c:	85 c0                	test   %eax,%eax
80100a4e:	0f 84 d3 01 00 00    	je     80100c27 <consoleintr+0x3bb>
80100a54:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100a59:	83 e0 7f             	and    $0x7f,%eax
80100a5c:	83 f8 7e             	cmp    $0x7e,%eax
80100a5f:	0f 87 c2 01 00 00    	ja     80100c27 <consoleintr+0x3bb>
      {
        consputc(KEY_RT);
80100a65:	c7 04 24 e5 00 00 00 	movl   $0xe5,(%esp)
80100a6c:	e8 0f fd ff ff       	call   80100780 <consputc>
	input.a--;
80100a71:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a76:	83 e8 01             	sub    $0x1,%eax
80100a79:	a3 60 de 10 80       	mov    %eax,0x8010de60
      }
      break;
80100a7e:	e9 a4 01 00 00       	jmp    80100c27 <consoleintr+0x3bb>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF)
80100a83:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100a87:	0f 84 9d 01 00 00    	je     80100c2a <consoleintr+0x3be>
80100a8d:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100a93:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100a98:	89 d1                	mov    %edx,%ecx
80100a9a:	29 c1                	sub    %eax,%ecx
80100a9c:	89 c8                	mov    %ecx,%eax
80100a9e:	83 f8 7f             	cmp    $0x7f,%eax
80100aa1:	0f 87 83 01 00 00    	ja     80100c2a <consoleintr+0x3be>
      {
	c = (c == '\r') ? '\n' : c;
80100aa7:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
80100aab:	74 05                	je     80100ab2 <consoleintr+0x246>
80100aad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100ab0:	eb 05                	jmp    80100ab7 <consoleintr+0x24b>
80100ab2:	b8 0a 00 00 00       	mov    $0xa,%eax
80100ab7:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(c != '\n' && input.a > 0 && c != C('D') && input.e != input.r+INPUT_BUF)
80100aba:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100abe:	0f 84 dd 00 00 00    	je     80100ba1 <consoleintr+0x335>
80100ac4:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100ac9:	85 c0                	test   %eax,%eax
80100acb:	0f 84 d0 00 00 00    	je     80100ba1 <consoleintr+0x335>
80100ad1:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80100ad5:	0f 84 c6 00 00 00    	je     80100ba1 <consoleintr+0x335>
80100adb:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100ae0:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
80100ae6:	83 ea 80             	sub    $0xffffff80,%edx
80100ae9:	39 d0                	cmp    %edx,%eax
80100aeb:	0f 84 b0 00 00 00    	je     80100ba1 <consoleintr+0x335>
	{
	    uint k = input.a;
80100af1:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100af6:	89 45 e8             	mov    %eax,-0x18(%ebp)
	    shiftRightBuf((input.e) % INPUT_BUF,k);
80100af9:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100afe:	89 c2                	mov    %eax,%edx
80100b00:	83 e2 7f             	and    $0x7f,%edx
80100b03:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100b06:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b0a:	89 14 24             	mov    %edx,(%esp)
80100b0d:	e8 cb fc ff ff       	call   801007dd <shiftRightBuf>
	    input.buf[(input.e-k) % INPUT_BUF] = c;
80100b12:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b17:	2b 45 e8             	sub    -0x18(%ebp),%eax
80100b1a:	89 c2                	mov    %eax,%edx
80100b1c:	83 e2 7f             	and    $0x7f,%edx
80100b1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100b22:	88 82 d4 dd 10 80    	mov    %al,-0x7fef222c(%edx)
	    
	    uint i = input.e-k;
80100b28:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b2d:	2b 45 e8             	sub    -0x18(%ebp),%eax
80100b30:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    for(;i<input.e+1;i++)
80100b33:	eb 1c                	jmp    80100b51 <consoleintr+0x2e5>
	      consputc(input.buf[i%INPUT_BUF]);
80100b35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100b38:	83 e0 7f             	and    $0x7f,%eax
80100b3b:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
80100b42:	0f be c0             	movsbl %al,%eax
80100b45:	89 04 24             	mov    %eax,(%esp)
80100b48:	e8 33 fc ff ff       	call   80100780 <consputc>
	    uint k = input.a;
	    shiftRightBuf((input.e) % INPUT_BUF,k);
	    input.buf[(input.e-k) % INPUT_BUF] = c;
	    
	    uint i = input.e-k;
	    for(;i<input.e+1;i++)
80100b4d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100b51:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b56:	83 c0 01             	add    $0x1,%eax
80100b59:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80100b5c:	77 d7                	ja     80100b35 <consoleintr+0x2c9>
	      consputc(input.buf[i%INPUT_BUF]);
	    
	    i = input.e-k;
80100b5e:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b63:	2b 45 e8             	sub    -0x18(%ebp),%eax
80100b66:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    for(;i<input.e;i++)
80100b69:	eb 10                	jmp    80100b7b <consoleintr+0x30f>
	      consputc(KEY_LF);
80100b6b:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100b72:	e8 09 fc ff ff       	call   80100780 <consputc>
	    uint i = input.e-k;
	    for(;i<input.e+1;i++)
	      consputc(input.buf[i%INPUT_BUF]);
	    
	    i = input.e-k;
	    for(;i<input.e;i++)
80100b77:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100b7b:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b80:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80100b83:	77 e6                	ja     80100b6b <consoleintr+0x2ff>
	      consputc(KEY_LF);
	
	    input.e++;
80100b85:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b8a:	83 c0 01             	add    $0x1,%eax
80100b8d:	a3 5c de 10 80       	mov    %eax,0x8010de5c
	    input.size++;
80100b92:	a1 64 de 10 80       	mov    0x8010de64,%eax
80100b97:	83 c0 01             	add    $0x1,%eax
80100b9a:	a3 64 de 10 80       	mov    %eax,0x8010de64
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF)
      {
	c = (c == '\r') ? '\n' : c;
	if(c != '\n' && input.a > 0 && c != C('D') && input.e != input.r+INPUT_BUF)
	{
80100b9f:	eb 33                	jmp    80100bd4 <consoleintr+0x368>
	
	    input.e++;
	    input.size++;
	}
	else {
	  input.buf[input.e++ % INPUT_BUF] = c;
80100ba1:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100ba6:	89 c1                	mov    %eax,%ecx
80100ba8:	83 e1 7f             	and    $0x7f,%ecx
80100bab:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100bae:	88 91 d4 dd 10 80    	mov    %dl,-0x7fef222c(%ecx)
80100bb4:	83 c0 01             	add    $0x1,%eax
80100bb7:	a3 5c de 10 80       	mov    %eax,0x8010de5c
          consputc(c);
80100bbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100bbf:	89 04 24             	mov    %eax,(%esp)
80100bc2:	e8 b9 fb ff ff       	call   80100780 <consputc>
	  input.size++;
80100bc7:	a1 64 de 10 80       	mov    0x8010de64,%eax
80100bcc:	83 c0 01             	add    $0x1,%eax
80100bcf:	a3 64 de 10 80       	mov    %eax,0x8010de64
	}
	
	if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF)
80100bd4:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100bd8:	74 18                	je     80100bf2 <consoleintr+0x386>
80100bda:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80100bde:	74 12                	je     80100bf2 <consoleintr+0x386>
80100be0:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100be5:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
80100beb:	83 ea 80             	sub    $0xffffff80,%edx
80100bee:	39 d0                	cmp    %edx,%eax
80100bf0:	75 38                	jne    80100c2a <consoleintr+0x3be>
	{
	  input.w = input.e;
80100bf2:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100bf7:	a3 58 de 10 80       	mov    %eax,0x8010de58
          wakeup(&input.r);
80100bfc:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100c03:	e8 2a 43 00 00       	call   80104f32 <wakeup>
	  input.a = 0;
80100c08:	c7 05 60 de 10 80 00 	movl   $0x0,0x8010de60
80100c0f:	00 00 00 
	  input.size = 0;
80100c12:	c7 05 64 de 10 80 00 	movl   $0x0,0x8010de64
80100c19:	00 00 00 
        }
      }
      break;
80100c1c:	eb 0c                	jmp    80100c2a <consoleintr+0x3be>
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100c1e:	90                   	nop
80100c1f:	eb 0a                	jmp    80100c2b <consoleintr+0x3bf>
	{
	  consputc(BACKSPACE);
	}
	input.e--;
      }
      break;
80100c21:	90                   	nop
80100c22:	eb 07                	jmp    80100c2b <consoleintr+0x3bf>
     if(c != 0 && input.e - input.a > input.w && input.size > 0)
      {
        consputc(KEY_LF);
	input.a++;
      }
      break;
80100c24:	90                   	nop
80100c25:	eb 04                	jmp    80100c2b <consoleintr+0x3bf>
      if(c != 0 && input.a > 0 && input.e % INPUT_BUF < INPUT_BUF-1)
      {
        consputc(KEY_RT);
	input.a--;
      }
      break;
80100c27:	90                   	nop
80100c28:	eb 01                	jmp    80100c2b <consoleintr+0x3bf>
          wakeup(&input.r);
	  input.a = 0;
	  input.size = 0;
        }
      }
      break;
80100c2a:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100c2b:	8b 45 08             	mov    0x8(%ebp),%eax
80100c2e:	ff d0                	call   *%eax
80100c30:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100c33:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100c37:	0f 89 46 fc ff ff    	jns    80100883 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100c3d:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100c44:	e8 d8 45 00 00       	call   80105221 <release>
}
80100c49:	c9                   	leave  
80100c4a:	c3                   	ret    

80100c4b <consoleread>:


int
consoleread(struct inode *ip, char *dst, int n)
{
80100c4b:	55                   	push   %ebp
80100c4c:	89 e5                	mov    %esp,%ebp
80100c4e:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100c51:	8b 45 08             	mov    0x8(%ebp),%eax
80100c54:	89 04 24             	mov    %eax,(%esp)
80100c57:	e8 82 10 00 00       	call   80101cde <iunlock>
  target = n;
80100c5c:	8b 45 10             	mov    0x10(%ebp),%eax
80100c5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100c62:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100c69:	e8 51 45 00 00       	call   801051bf <acquire>
  while(n > 0){
80100c6e:	e9 a8 00 00 00       	jmp    80100d1b <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
80100c73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c79:	8b 40 24             	mov    0x24(%eax),%eax
80100c7c:	85 c0                	test   %eax,%eax
80100c7e:	74 21                	je     80100ca1 <consoleread+0x56>
        release(&input.lock);
80100c80:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100c87:	e8 95 45 00 00       	call   80105221 <release>
        ilock(ip);
80100c8c:	8b 45 08             	mov    0x8(%ebp),%eax
80100c8f:	89 04 24             	mov    %eax,(%esp)
80100c92:	e8 f9 0e 00 00       	call   80101b90 <ilock>
        return -1;
80100c97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c9c:	e9 a9 00 00 00       	jmp    80100d4a <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
80100ca1:	c7 44 24 04 a0 dd 10 	movl   $0x8010dda0,0x4(%esp)
80100ca8:	80 
80100ca9:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100cb0:	e8 a1 41 00 00       	call   80104e56 <sleep>
80100cb5:	eb 01                	jmp    80100cb8 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100cb7:	90                   	nop
80100cb8:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
80100cbe:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100cc3:	39 c2                	cmp    %eax,%edx
80100cc5:	74 ac                	je     80100c73 <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100cc7:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100ccc:	89 c2                	mov    %eax,%edx
80100cce:	83 e2 7f             	and    $0x7f,%edx
80100cd1:	0f b6 92 d4 dd 10 80 	movzbl -0x7fef222c(%edx),%edx
80100cd8:	0f be d2             	movsbl %dl,%edx
80100cdb:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100cde:	83 c0 01             	add    $0x1,%eax
80100ce1:	a3 54 de 10 80       	mov    %eax,0x8010de54
    if(c == C('D')){  // EOF
80100ce6:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100cea:	75 17                	jne    80100d03 <consoleread+0xb8>
      if(n < target){
80100cec:	8b 45 10             	mov    0x10(%ebp),%eax
80100cef:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100cf2:	73 2f                	jae    80100d23 <consoleread+0xd8>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100cf4:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100cf9:	83 e8 01             	sub    $0x1,%eax
80100cfc:	a3 54 de 10 80       	mov    %eax,0x8010de54
      }
      break;
80100d01:	eb 20                	jmp    80100d23 <consoleread+0xd8>
    }
    *dst++ = c;
80100d03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100d06:	89 c2                	mov    %eax,%edx
80100d08:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d0b:	88 10                	mov    %dl,(%eax)
80100d0d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    --n;
80100d11:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100d15:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100d19:	74 0b                	je     80100d26 <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100d1b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100d1f:	7f 96                	jg     80100cb7 <consoleread+0x6c>
80100d21:	eb 04                	jmp    80100d27 <consoleread+0xdc>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100d23:	90                   	nop
80100d24:	eb 01                	jmp    80100d27 <consoleread+0xdc>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100d26:	90                   	nop
  }
  release(&input.lock);
80100d27:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100d2e:	e8 ee 44 00 00       	call   80105221 <release>
  ilock(ip);
80100d33:	8b 45 08             	mov    0x8(%ebp),%eax
80100d36:	89 04 24             	mov    %eax,(%esp)
80100d39:	e8 52 0e 00 00       	call   80101b90 <ilock>

  return target - n;
80100d3e:	8b 45 10             	mov    0x10(%ebp),%eax
80100d41:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100d44:	89 d1                	mov    %edx,%ecx
80100d46:	29 c1                	sub    %eax,%ecx
80100d48:	89 c8                	mov    %ecx,%eax
}
80100d4a:	c9                   	leave  
80100d4b:	c3                   	ret    

80100d4c <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100d4c:	55                   	push   %ebp
80100d4d:	89 e5                	mov    %esp,%ebp
80100d4f:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100d52:	8b 45 08             	mov    0x8(%ebp),%eax
80100d55:	89 04 24             	mov    %eax,(%esp)
80100d58:	e8 81 0f 00 00       	call   80101cde <iunlock>
  acquire(&cons.lock);
80100d5d:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100d64:	e8 56 44 00 00       	call   801051bf <acquire>
  for(i = 0; i < n; i++)
80100d69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100d70:	eb 1d                	jmp    80100d8f <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100d75:	03 45 0c             	add    0xc(%ebp),%eax
80100d78:	0f b6 00             	movzbl (%eax),%eax
80100d7b:	0f be c0             	movsbl %al,%eax
80100d7e:	25 ff 00 00 00       	and    $0xff,%eax
80100d83:	89 04 24             	mov    %eax,(%esp)
80100d86:	e8 f5 f9 ff ff       	call   80100780 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100d8b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100d92:	3b 45 10             	cmp    0x10(%ebp),%eax
80100d95:	7c db                	jl     80100d72 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100d97:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100d9e:	e8 7e 44 00 00       	call   80105221 <release>
  ilock(ip);
80100da3:	8b 45 08             	mov    0x8(%ebp),%eax
80100da6:	89 04 24             	mov    %eax,(%esp)
80100da9:	e8 e2 0d 00 00       	call   80101b90 <ilock>

  return n;
80100dae:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100db1:	c9                   	leave  
80100db2:	c3                   	ret    

80100db3 <consoleinit>:

void
consoleinit(void)
{
80100db3:	55                   	push   %ebp
80100db4:	89 e5                	mov    %esp,%ebp
80100db6:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100db9:	c7 44 24 04 b7 88 10 	movl   $0x801088b7,0x4(%esp)
80100dc0:	80 
80100dc1:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100dc8:	e8 d1 43 00 00       	call   8010519e <initlock>
  initlock(&input.lock, "input");
80100dcd:	c7 44 24 04 bf 88 10 	movl   $0x801088bf,0x4(%esp)
80100dd4:	80 
80100dd5:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100ddc:	e8 bd 43 00 00       	call   8010519e <initlock>

  devsw[CONSOLE].write = consolewrite;
80100de1:	c7 05 2c e8 10 80 4c 	movl   $0x80100d4c,0x8010e82c
80100de8:	0d 10 80 
  devsw[CONSOLE].read = consoleread;
80100deb:	c7 05 28 e8 10 80 4b 	movl   $0x80100c4b,0x8010e828
80100df2:	0c 10 80 
  cons.locking = 1;
80100df5:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100dfc:	00 00 00 

  picenable(IRQ_KBD);
80100dff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100e06:	e8 de 2f 00 00       	call   80103de9 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100e0b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100e12:	00 
80100e13:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100e1a:	e8 7f 1e 00 00       	call   80102c9e <ioapicenable>
}
80100e1f:	c9                   	leave  
80100e20:	c3                   	ret    
80100e21:	00 00                	add    %al,(%eax)
	...

80100e24 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100e24:	55                   	push   %ebp
80100e25:	89 e5                	mov    %esp,%ebp
80100e27:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100e2d:	8b 45 08             	mov    0x8(%ebp),%eax
80100e30:	89 04 24             	mov    %eax,(%esp)
80100e33:	e8 fa 18 00 00       	call   80102732 <namei>
80100e38:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100e3b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100e3f:	75 0a                	jne    80100e4b <exec+0x27>
    return -1;
80100e41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100e46:	e9 da 03 00 00       	jmp    80101225 <exec+0x401>
  ilock(ip);
80100e4b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e4e:	89 04 24             	mov    %eax,(%esp)
80100e51:	e8 3a 0d 00 00       	call   80101b90 <ilock>
  pgdir = 0;
80100e56:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100e5d:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100e64:	00 
80100e65:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100e6c:	00 
80100e6d:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100e73:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e77:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e7a:	89 04 24             	mov    %eax,(%esp)
80100e7d:	e8 04 12 00 00       	call   80102086 <readi>
80100e82:	83 f8 33             	cmp    $0x33,%eax
80100e85:	0f 86 54 03 00 00    	jbe    801011df <exec+0x3bb>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100e8b:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100e91:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100e96:	0f 85 46 03 00 00    	jne    801011e2 <exec+0x3be>
    goto bad;

  if((pgdir = setupkvm(kalloc)) == 0)
80100e9c:	c7 04 24 27 2e 10 80 	movl   $0x80102e27,(%esp)
80100ea3:	e8 6d 71 00 00       	call   80108015 <setupkvm>
80100ea8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100eab:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100eaf:	0f 84 30 03 00 00    	je     801011e5 <exec+0x3c1>
    goto bad;

  // Load program into memory.
  sz = 0;
80100eb5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ebc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100ec3:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100ec9:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ecc:	e9 c5 00 00 00       	jmp    80100f96 <exec+0x172>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100ed1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ed4:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100edb:	00 
80100edc:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ee0:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100ee6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100eea:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100eed:	89 04 24             	mov    %eax,(%esp)
80100ef0:	e8 91 11 00 00       	call   80102086 <readi>
80100ef5:	83 f8 20             	cmp    $0x20,%eax
80100ef8:	0f 85 ea 02 00 00    	jne    801011e8 <exec+0x3c4>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100efe:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100f04:	83 f8 01             	cmp    $0x1,%eax
80100f07:	75 7f                	jne    80100f88 <exec+0x164>
      continue;
    if(ph.memsz < ph.filesz)
80100f09:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100f0f:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100f15:	39 c2                	cmp    %eax,%edx
80100f17:	0f 82 ce 02 00 00    	jb     801011eb <exec+0x3c7>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100f1d:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100f23:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100f29:	01 d0                	add    %edx,%eax
80100f2b:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f32:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f36:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f39:	89 04 24             	mov    %eax,(%esp)
80100f3c:	e8 a6 74 00 00       	call   801083e7 <allocuvm>
80100f41:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100f44:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100f48:	0f 84 a0 02 00 00    	je     801011ee <exec+0x3ca>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100f4e:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100f54:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100f5a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100f60:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100f64:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100f68:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100f6b:	89 54 24 08          	mov    %edx,0x8(%esp)
80100f6f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f73:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f76:	89 04 24             	mov    %eax,(%esp)
80100f79:	e8 7a 73 00 00       	call   801082f8 <loaduvm>
80100f7e:	85 c0                	test   %eax,%eax
80100f80:	0f 88 6b 02 00 00    	js     801011f1 <exec+0x3cd>
80100f86:	eb 01                	jmp    80100f89 <exec+0x165>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100f88:	90                   	nop
  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100f89:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100f8d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100f90:	83 c0 20             	add    $0x20,%eax
80100f93:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100f96:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100f9d:	0f b7 c0             	movzwl %ax,%eax
80100fa0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100fa3:	0f 8f 28 ff ff ff    	jg     80100ed1 <exec+0xad>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100fa9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100fac:	89 04 24             	mov    %eax,(%esp)
80100faf:	e8 60 0e 00 00       	call   80101e14 <iunlockput>
  ip = 0;
80100fb4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100fbb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fbe:	05 ff 0f 00 00       	add    $0xfff,%eax
80100fc3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100fc8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100fcb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fce:	05 00 20 00 00       	add    $0x2000,%eax
80100fd3:	89 44 24 08          	mov    %eax,0x8(%esp)
80100fd7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fda:	89 44 24 04          	mov    %eax,0x4(%esp)
80100fde:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100fe1:	89 04 24             	mov    %eax,(%esp)
80100fe4:	e8 fe 73 00 00       	call   801083e7 <allocuvm>
80100fe9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100fec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ff0:	0f 84 fe 01 00 00    	je     801011f4 <exec+0x3d0>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100ff6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ff9:	2d 00 20 00 00       	sub    $0x2000,%eax
80100ffe:	89 44 24 04          	mov    %eax,0x4(%esp)
80101002:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101005:	89 04 24             	mov    %eax,(%esp)
80101008:	e8 fe 75 00 00       	call   8010860b <clearpteu>
  sp = sz;
8010100d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101010:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80101013:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010101a:	e9 81 00 00 00       	jmp    801010a0 <exec+0x27c>
    if(argc >= MAXARG)
8010101f:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80101023:	0f 87 ce 01 00 00    	ja     801011f7 <exec+0x3d3>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80101029:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010102c:	c1 e0 02             	shl    $0x2,%eax
8010102f:	03 45 0c             	add    0xc(%ebp),%eax
80101032:	8b 00                	mov    (%eax),%eax
80101034:	89 04 24             	mov    %eax,(%esp)
80101037:	e8 50 46 00 00       	call   8010568c <strlen>
8010103c:	f7 d0                	not    %eax
8010103e:	03 45 dc             	add    -0x24(%ebp),%eax
80101041:	83 e0 fc             	and    $0xfffffffc,%eax
80101044:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80101047:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010104a:	c1 e0 02             	shl    $0x2,%eax
8010104d:	03 45 0c             	add    0xc(%ebp),%eax
80101050:	8b 00                	mov    (%eax),%eax
80101052:	89 04 24             	mov    %eax,(%esp)
80101055:	e8 32 46 00 00       	call   8010568c <strlen>
8010105a:	83 c0 01             	add    $0x1,%eax
8010105d:	89 c2                	mov    %eax,%edx
8010105f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101062:	c1 e0 02             	shl    $0x2,%eax
80101065:	03 45 0c             	add    0xc(%ebp),%eax
80101068:	8b 00                	mov    (%eax),%eax
8010106a:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010106e:	89 44 24 08          	mov    %eax,0x8(%esp)
80101072:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101075:	89 44 24 04          	mov    %eax,0x4(%esp)
80101079:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010107c:	89 04 24             	mov    %eax,(%esp)
8010107f:	e8 3b 77 00 00       	call   801087bf <copyout>
80101084:	85 c0                	test   %eax,%eax
80101086:	0f 88 6e 01 00 00    	js     801011fa <exec+0x3d6>
      goto bad;
    ustack[3+argc] = sp;
8010108c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010108f:	8d 50 03             	lea    0x3(%eax),%edx
80101092:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101095:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
8010109c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801010a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010a3:	c1 e0 02             	shl    $0x2,%eax
801010a6:	03 45 0c             	add    0xc(%ebp),%eax
801010a9:	8b 00                	mov    (%eax),%eax
801010ab:	85 c0                	test   %eax,%eax
801010ad:	0f 85 6c ff ff ff    	jne    8010101f <exec+0x1fb>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
801010b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010b6:	83 c0 03             	add    $0x3,%eax
801010b9:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
801010c0:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
801010c4:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
801010cb:	ff ff ff 
  ustack[1] = argc;
801010ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010d1:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
801010d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010da:	83 c0 01             	add    $0x1,%eax
801010dd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801010e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010e7:	29 d0                	sub    %edx,%eax
801010e9:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
801010ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010f2:	83 c0 04             	add    $0x4,%eax
801010f5:	c1 e0 02             	shl    $0x2,%eax
801010f8:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
801010fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010fe:	83 c0 04             	add    $0x4,%eax
80101101:	c1 e0 02             	shl    $0x2,%eax
80101104:	89 44 24 0c          	mov    %eax,0xc(%esp)
80101108:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
8010110e:	89 44 24 08          	mov    %eax,0x8(%esp)
80101112:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101115:	89 44 24 04          	mov    %eax,0x4(%esp)
80101119:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010111c:	89 04 24             	mov    %eax,(%esp)
8010111f:	e8 9b 76 00 00       	call   801087bf <copyout>
80101124:	85 c0                	test   %eax,%eax
80101126:	0f 88 d1 00 00 00    	js     801011fd <exec+0x3d9>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
8010112c:	8b 45 08             	mov    0x8(%ebp),%eax
8010112f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101135:	89 45 f0             	mov    %eax,-0x10(%ebp)
80101138:	eb 17                	jmp    80101151 <exec+0x32d>
    if(*s == '/')
8010113a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010113d:	0f b6 00             	movzbl (%eax),%eax
80101140:	3c 2f                	cmp    $0x2f,%al
80101142:	75 09                	jne    8010114d <exec+0x329>
      last = s+1;
80101144:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101147:	83 c0 01             	add    $0x1,%eax
8010114a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
8010114d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101154:	0f b6 00             	movzbl (%eax),%eax
80101157:	84 c0                	test   %al,%al
80101159:	75 df                	jne    8010113a <exec+0x316>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
8010115b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101161:	8d 50 6c             	lea    0x6c(%eax),%edx
80101164:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010116b:	00 
8010116c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010116f:	89 44 24 04          	mov    %eax,0x4(%esp)
80101173:	89 14 24             	mov    %edx,(%esp)
80101176:	e8 c3 44 00 00       	call   8010563e <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
8010117b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101181:	8b 40 04             	mov    0x4(%eax),%eax
80101184:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80101187:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010118d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80101190:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80101193:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101199:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010119c:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
8010119e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011a4:	8b 40 18             	mov    0x18(%eax),%eax
801011a7:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
801011ad:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
801011b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011b6:	8b 40 18             	mov    0x18(%eax),%eax
801011b9:	8b 55 dc             	mov    -0x24(%ebp),%edx
801011bc:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
801011bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011c5:	89 04 24             	mov    %eax,(%esp)
801011c8:	e8 39 6f 00 00       	call   80108106 <switchuvm>
  freevm(oldpgdir);
801011cd:	8b 45 d0             	mov    -0x30(%ebp),%eax
801011d0:	89 04 24             	mov    %eax,(%esp)
801011d3:	e8 a5 73 00 00       	call   8010857d <freevm>
  return 0;
801011d8:	b8 00 00 00 00       	mov    $0x0,%eax
801011dd:	eb 46                	jmp    80101225 <exec+0x401>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
801011df:	90                   	nop
801011e0:	eb 1c                	jmp    801011fe <exec+0x3da>
  if(elf.magic != ELF_MAGIC)
    goto bad;
801011e2:	90                   	nop
801011e3:	eb 19                	jmp    801011fe <exec+0x3da>

  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;
801011e5:	90                   	nop
801011e6:	eb 16                	jmp    801011fe <exec+0x3da>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
801011e8:	90                   	nop
801011e9:	eb 13                	jmp    801011fe <exec+0x3da>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
801011eb:	90                   	nop
801011ec:	eb 10                	jmp    801011fe <exec+0x3da>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
801011ee:	90                   	nop
801011ef:	eb 0d                	jmp    801011fe <exec+0x3da>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
801011f1:	90                   	nop
801011f2:	eb 0a                	jmp    801011fe <exec+0x3da>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
801011f4:	90                   	nop
801011f5:	eb 07                	jmp    801011fe <exec+0x3da>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
801011f7:	90                   	nop
801011f8:	eb 04                	jmp    801011fe <exec+0x3da>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
801011fa:	90                   	nop
801011fb:	eb 01                	jmp    801011fe <exec+0x3da>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
801011fd:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
801011fe:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101202:	74 0b                	je     8010120f <exec+0x3eb>
    freevm(pgdir);
80101204:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101207:	89 04 24             	mov    %eax,(%esp)
8010120a:	e8 6e 73 00 00       	call   8010857d <freevm>
  if(ip)
8010120f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101213:	74 0b                	je     80101220 <exec+0x3fc>
    iunlockput(ip);
80101215:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101218:	89 04 24             	mov    %eax,(%esp)
8010121b:	e8 f4 0b 00 00       	call   80101e14 <iunlockput>
  return -1;
80101220:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101225:	c9                   	leave  
80101226:	c3                   	ret    
	...

80101228 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101228:	55                   	push   %ebp
80101229:	89 e5                	mov    %esp,%ebp
8010122b:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
8010122e:	c7 44 24 04 c5 88 10 	movl   $0x801088c5,0x4(%esp)
80101235:	80 
80101236:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
8010123d:	e8 5c 3f 00 00       	call   8010519e <initlock>
}
80101242:	c9                   	leave  
80101243:	c3                   	ret    

80101244 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101244:	55                   	push   %ebp
80101245:	89 e5                	mov    %esp,%ebp
80101247:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
8010124a:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101251:	e8 69 3f 00 00       	call   801051bf <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101256:	c7 45 f4 b4 de 10 80 	movl   $0x8010deb4,-0xc(%ebp)
8010125d:	eb 29                	jmp    80101288 <filealloc+0x44>
    if(f->ref == 0){
8010125f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101262:	8b 40 04             	mov    0x4(%eax),%eax
80101265:	85 c0                	test   %eax,%eax
80101267:	75 1b                	jne    80101284 <filealloc+0x40>
      f->ref = 1;
80101269:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010126c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101273:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
8010127a:	e8 a2 3f 00 00       	call   80105221 <release>
      return f;
8010127f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101282:	eb 1e                	jmp    801012a2 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101284:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101288:	81 7d f4 14 e8 10 80 	cmpl   $0x8010e814,-0xc(%ebp)
8010128f:	72 ce                	jb     8010125f <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101291:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101298:	e8 84 3f 00 00       	call   80105221 <release>
  return 0;
8010129d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801012a2:	c9                   	leave  
801012a3:	c3                   	ret    

801012a4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801012a4:	55                   	push   %ebp
801012a5:	89 e5                	mov    %esp,%ebp
801012a7:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
801012aa:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012b1:	e8 09 3f 00 00       	call   801051bf <acquire>
  if(f->ref < 1)
801012b6:	8b 45 08             	mov    0x8(%ebp),%eax
801012b9:	8b 40 04             	mov    0x4(%eax),%eax
801012bc:	85 c0                	test   %eax,%eax
801012be:	7f 0c                	jg     801012cc <filedup+0x28>
    panic("filedup");
801012c0:	c7 04 24 cc 88 10 80 	movl   $0x801088cc,(%esp)
801012c7:	e8 71 f2 ff ff       	call   8010053d <panic>
  f->ref++;
801012cc:	8b 45 08             	mov    0x8(%ebp),%eax
801012cf:	8b 40 04             	mov    0x4(%eax),%eax
801012d2:	8d 50 01             	lea    0x1(%eax),%edx
801012d5:	8b 45 08             	mov    0x8(%ebp),%eax
801012d8:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801012db:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012e2:	e8 3a 3f 00 00       	call   80105221 <release>
  return f;
801012e7:	8b 45 08             	mov    0x8(%ebp),%eax
}
801012ea:	c9                   	leave  
801012eb:	c3                   	ret    

801012ec <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801012ec:	55                   	push   %ebp
801012ed:	89 e5                	mov    %esp,%ebp
801012ef:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
801012f2:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012f9:	e8 c1 3e 00 00       	call   801051bf <acquire>
  if(f->ref < 1)
801012fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101301:	8b 40 04             	mov    0x4(%eax),%eax
80101304:	85 c0                	test   %eax,%eax
80101306:	7f 0c                	jg     80101314 <fileclose+0x28>
    panic("fileclose");
80101308:	c7 04 24 d4 88 10 80 	movl   $0x801088d4,(%esp)
8010130f:	e8 29 f2 ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
80101314:	8b 45 08             	mov    0x8(%ebp),%eax
80101317:	8b 40 04             	mov    0x4(%eax),%eax
8010131a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010131d:	8b 45 08             	mov    0x8(%ebp),%eax
80101320:	89 50 04             	mov    %edx,0x4(%eax)
80101323:	8b 45 08             	mov    0x8(%ebp),%eax
80101326:	8b 40 04             	mov    0x4(%eax),%eax
80101329:	85 c0                	test   %eax,%eax
8010132b:	7e 11                	jle    8010133e <fileclose+0x52>
    release(&ftable.lock);
8010132d:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101334:	e8 e8 3e 00 00       	call   80105221 <release>
    return;
80101339:	e9 82 00 00 00       	jmp    801013c0 <fileclose+0xd4>
  }
  ff = *f;
8010133e:	8b 45 08             	mov    0x8(%ebp),%eax
80101341:	8b 10                	mov    (%eax),%edx
80101343:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101346:	8b 50 04             	mov    0x4(%eax),%edx
80101349:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010134c:	8b 50 08             	mov    0x8(%eax),%edx
8010134f:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101352:	8b 50 0c             	mov    0xc(%eax),%edx
80101355:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101358:	8b 50 10             	mov    0x10(%eax),%edx
8010135b:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010135e:	8b 40 14             	mov    0x14(%eax),%eax
80101361:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101364:	8b 45 08             	mov    0x8(%ebp),%eax
80101367:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010136e:	8b 45 08             	mov    0x8(%ebp),%eax
80101371:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101377:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
8010137e:	e8 9e 3e 00 00       	call   80105221 <release>
  
  if(ff.type == FD_PIPE)
80101383:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101386:	83 f8 01             	cmp    $0x1,%eax
80101389:	75 18                	jne    801013a3 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
8010138b:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010138f:	0f be d0             	movsbl %al,%edx
80101392:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101395:	89 54 24 04          	mov    %edx,0x4(%esp)
80101399:	89 04 24             	mov    %eax,(%esp)
8010139c:	e8 02 2d 00 00       	call   801040a3 <pipeclose>
801013a1:	eb 1d                	jmp    801013c0 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801013a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013a6:	83 f8 02             	cmp    $0x2,%eax
801013a9:	75 15                	jne    801013c0 <fileclose+0xd4>
    begin_trans();
801013ab:	e8 95 21 00 00       	call   80103545 <begin_trans>
    iput(ff.ip);
801013b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013b3:	89 04 24             	mov    %eax,(%esp)
801013b6:	e8 88 09 00 00       	call   80101d43 <iput>
    commit_trans();
801013bb:	e8 ce 21 00 00       	call   8010358e <commit_trans>
  }
}
801013c0:	c9                   	leave  
801013c1:	c3                   	ret    

801013c2 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801013c2:	55                   	push   %ebp
801013c3:	89 e5                	mov    %esp,%ebp
801013c5:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801013c8:	8b 45 08             	mov    0x8(%ebp),%eax
801013cb:	8b 00                	mov    (%eax),%eax
801013cd:	83 f8 02             	cmp    $0x2,%eax
801013d0:	75 38                	jne    8010140a <filestat+0x48>
    ilock(f->ip);
801013d2:	8b 45 08             	mov    0x8(%ebp),%eax
801013d5:	8b 40 10             	mov    0x10(%eax),%eax
801013d8:	89 04 24             	mov    %eax,(%esp)
801013db:	e8 b0 07 00 00       	call   80101b90 <ilock>
    stati(f->ip, st);
801013e0:	8b 45 08             	mov    0x8(%ebp),%eax
801013e3:	8b 40 10             	mov    0x10(%eax),%eax
801013e6:	8b 55 0c             	mov    0xc(%ebp),%edx
801013e9:	89 54 24 04          	mov    %edx,0x4(%esp)
801013ed:	89 04 24             	mov    %eax,(%esp)
801013f0:	e8 4c 0c 00 00       	call   80102041 <stati>
    iunlock(f->ip);
801013f5:	8b 45 08             	mov    0x8(%ebp),%eax
801013f8:	8b 40 10             	mov    0x10(%eax),%eax
801013fb:	89 04 24             	mov    %eax,(%esp)
801013fe:	e8 db 08 00 00       	call   80101cde <iunlock>
    return 0;
80101403:	b8 00 00 00 00       	mov    $0x0,%eax
80101408:	eb 05                	jmp    8010140f <filestat+0x4d>
  }
  return -1;
8010140a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010140f:	c9                   	leave  
80101410:	c3                   	ret    

80101411 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101411:	55                   	push   %ebp
80101412:	89 e5                	mov    %esp,%ebp
80101414:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101417:	8b 45 08             	mov    0x8(%ebp),%eax
8010141a:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010141e:	84 c0                	test   %al,%al
80101420:	75 0a                	jne    8010142c <fileread+0x1b>
    return -1;
80101422:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101427:	e9 9f 00 00 00       	jmp    801014cb <fileread+0xba>
  if(f->type == FD_PIPE)
8010142c:	8b 45 08             	mov    0x8(%ebp),%eax
8010142f:	8b 00                	mov    (%eax),%eax
80101431:	83 f8 01             	cmp    $0x1,%eax
80101434:	75 1e                	jne    80101454 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101436:	8b 45 08             	mov    0x8(%ebp),%eax
80101439:	8b 40 0c             	mov    0xc(%eax),%eax
8010143c:	8b 55 10             	mov    0x10(%ebp),%edx
8010143f:	89 54 24 08          	mov    %edx,0x8(%esp)
80101443:	8b 55 0c             	mov    0xc(%ebp),%edx
80101446:	89 54 24 04          	mov    %edx,0x4(%esp)
8010144a:	89 04 24             	mov    %eax,(%esp)
8010144d:	e8 d3 2d 00 00       	call   80104225 <piperead>
80101452:	eb 77                	jmp    801014cb <fileread+0xba>
  if(f->type == FD_INODE){
80101454:	8b 45 08             	mov    0x8(%ebp),%eax
80101457:	8b 00                	mov    (%eax),%eax
80101459:	83 f8 02             	cmp    $0x2,%eax
8010145c:	75 61                	jne    801014bf <fileread+0xae>
    ilock(f->ip);
8010145e:	8b 45 08             	mov    0x8(%ebp),%eax
80101461:	8b 40 10             	mov    0x10(%eax),%eax
80101464:	89 04 24             	mov    %eax,(%esp)
80101467:	e8 24 07 00 00       	call   80101b90 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010146c:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010146f:	8b 45 08             	mov    0x8(%ebp),%eax
80101472:	8b 50 14             	mov    0x14(%eax),%edx
80101475:	8b 45 08             	mov    0x8(%ebp),%eax
80101478:	8b 40 10             	mov    0x10(%eax),%eax
8010147b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010147f:	89 54 24 08          	mov    %edx,0x8(%esp)
80101483:	8b 55 0c             	mov    0xc(%ebp),%edx
80101486:	89 54 24 04          	mov    %edx,0x4(%esp)
8010148a:	89 04 24             	mov    %eax,(%esp)
8010148d:	e8 f4 0b 00 00       	call   80102086 <readi>
80101492:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101495:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101499:	7e 11                	jle    801014ac <fileread+0x9b>
      f->off += r;
8010149b:	8b 45 08             	mov    0x8(%ebp),%eax
8010149e:	8b 50 14             	mov    0x14(%eax),%edx
801014a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014a4:	01 c2                	add    %eax,%edx
801014a6:	8b 45 08             	mov    0x8(%ebp),%eax
801014a9:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801014ac:	8b 45 08             	mov    0x8(%ebp),%eax
801014af:	8b 40 10             	mov    0x10(%eax),%eax
801014b2:	89 04 24             	mov    %eax,(%esp)
801014b5:	e8 24 08 00 00       	call   80101cde <iunlock>
    return r;
801014ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014bd:	eb 0c                	jmp    801014cb <fileread+0xba>
  }
  panic("fileread");
801014bf:	c7 04 24 de 88 10 80 	movl   $0x801088de,(%esp)
801014c6:	e8 72 f0 ff ff       	call   8010053d <panic>
}
801014cb:	c9                   	leave  
801014cc:	c3                   	ret    

801014cd <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801014cd:	55                   	push   %ebp
801014ce:	89 e5                	mov    %esp,%ebp
801014d0:	53                   	push   %ebx
801014d1:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801014d4:	8b 45 08             	mov    0x8(%ebp),%eax
801014d7:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801014db:	84 c0                	test   %al,%al
801014dd:	75 0a                	jne    801014e9 <filewrite+0x1c>
    return -1;
801014df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014e4:	e9 23 01 00 00       	jmp    8010160c <filewrite+0x13f>
  if(f->type == FD_PIPE)
801014e9:	8b 45 08             	mov    0x8(%ebp),%eax
801014ec:	8b 00                	mov    (%eax),%eax
801014ee:	83 f8 01             	cmp    $0x1,%eax
801014f1:	75 21                	jne    80101514 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801014f3:	8b 45 08             	mov    0x8(%ebp),%eax
801014f6:	8b 40 0c             	mov    0xc(%eax),%eax
801014f9:	8b 55 10             	mov    0x10(%ebp),%edx
801014fc:	89 54 24 08          	mov    %edx,0x8(%esp)
80101500:	8b 55 0c             	mov    0xc(%ebp),%edx
80101503:	89 54 24 04          	mov    %edx,0x4(%esp)
80101507:	89 04 24             	mov    %eax,(%esp)
8010150a:	e8 26 2c 00 00       	call   80104135 <pipewrite>
8010150f:	e9 f8 00 00 00       	jmp    8010160c <filewrite+0x13f>
  if(f->type == FD_INODE){
80101514:	8b 45 08             	mov    0x8(%ebp),%eax
80101517:	8b 00                	mov    (%eax),%eax
80101519:	83 f8 02             	cmp    $0x2,%eax
8010151c:	0f 85 de 00 00 00    	jne    80101600 <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101522:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101529:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101530:	e9 a8 00 00 00       	jmp    801015dd <filewrite+0x110>
      int n1 = n - i;
80101535:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101538:	8b 55 10             	mov    0x10(%ebp),%edx
8010153b:	89 d1                	mov    %edx,%ecx
8010153d:	29 c1                	sub    %eax,%ecx
8010153f:	89 c8                	mov    %ecx,%eax
80101541:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101544:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101547:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010154a:	7e 06                	jle    80101552 <filewrite+0x85>
        n1 = max;
8010154c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010154f:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
80101552:	e8 ee 1f 00 00       	call   80103545 <begin_trans>
      ilock(f->ip);
80101557:	8b 45 08             	mov    0x8(%ebp),%eax
8010155a:	8b 40 10             	mov    0x10(%eax),%eax
8010155d:	89 04 24             	mov    %eax,(%esp)
80101560:	e8 2b 06 00 00       	call   80101b90 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101565:	8b 5d f0             	mov    -0x10(%ebp),%ebx
80101568:	8b 45 08             	mov    0x8(%ebp),%eax
8010156b:	8b 48 14             	mov    0x14(%eax),%ecx
8010156e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101571:	89 c2                	mov    %eax,%edx
80101573:	03 55 0c             	add    0xc(%ebp),%edx
80101576:	8b 45 08             	mov    0x8(%ebp),%eax
80101579:	8b 40 10             	mov    0x10(%eax),%eax
8010157c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80101580:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80101584:	89 54 24 04          	mov    %edx,0x4(%esp)
80101588:	89 04 24             	mov    %eax,(%esp)
8010158b:	e8 61 0c 00 00       	call   801021f1 <writei>
80101590:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101593:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101597:	7e 11                	jle    801015aa <filewrite+0xdd>
        f->off += r;
80101599:	8b 45 08             	mov    0x8(%ebp),%eax
8010159c:	8b 50 14             	mov    0x14(%eax),%edx
8010159f:	8b 45 e8             	mov    -0x18(%ebp),%eax
801015a2:	01 c2                	add    %eax,%edx
801015a4:	8b 45 08             	mov    0x8(%ebp),%eax
801015a7:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801015aa:	8b 45 08             	mov    0x8(%ebp),%eax
801015ad:	8b 40 10             	mov    0x10(%eax),%eax
801015b0:	89 04 24             	mov    %eax,(%esp)
801015b3:	e8 26 07 00 00       	call   80101cde <iunlock>
      commit_trans();
801015b8:	e8 d1 1f 00 00       	call   8010358e <commit_trans>

      if(r < 0)
801015bd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801015c1:	78 28                	js     801015eb <filewrite+0x11e>
        break;
      if(r != n1)
801015c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801015c6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801015c9:	74 0c                	je     801015d7 <filewrite+0x10a>
        panic("short filewrite");
801015cb:	c7 04 24 e7 88 10 80 	movl   $0x801088e7,(%esp)
801015d2:	e8 66 ef ff ff       	call   8010053d <panic>
      i += r;
801015d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801015da:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801015dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015e0:	3b 45 10             	cmp    0x10(%ebp),%eax
801015e3:	0f 8c 4c ff ff ff    	jl     80101535 <filewrite+0x68>
801015e9:	eb 01                	jmp    801015ec <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
801015eb:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801015ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015ef:	3b 45 10             	cmp    0x10(%ebp),%eax
801015f2:	75 05                	jne    801015f9 <filewrite+0x12c>
801015f4:	8b 45 10             	mov    0x10(%ebp),%eax
801015f7:	eb 05                	jmp    801015fe <filewrite+0x131>
801015f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801015fe:	eb 0c                	jmp    8010160c <filewrite+0x13f>
  }
  panic("filewrite");
80101600:	c7 04 24 f7 88 10 80 	movl   $0x801088f7,(%esp)
80101607:	e8 31 ef ff ff       	call   8010053d <panic>
}
8010160c:	83 c4 24             	add    $0x24,%esp
8010160f:	5b                   	pop    %ebx
80101610:	5d                   	pop    %ebp
80101611:	c3                   	ret    
	...

80101614 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101614:	55                   	push   %ebp
80101615:	89 e5                	mov    %esp,%ebp
80101617:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010161a:	8b 45 08             	mov    0x8(%ebp),%eax
8010161d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101624:	00 
80101625:	89 04 24             	mov    %eax,(%esp)
80101628:	e8 79 eb ff ff       	call   801001a6 <bread>
8010162d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101630:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101633:	83 c0 18             	add    $0x18,%eax
80101636:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010163d:	00 
8010163e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101642:	8b 45 0c             	mov    0xc(%ebp),%eax
80101645:	89 04 24             	mov    %eax,(%esp)
80101648:	e8 94 3e 00 00       	call   801054e1 <memmove>
  brelse(bp);
8010164d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101650:	89 04 24             	mov    %eax,(%esp)
80101653:	e8 bf eb ff ff       	call   80100217 <brelse>
}
80101658:	c9                   	leave  
80101659:	c3                   	ret    

8010165a <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010165a:	55                   	push   %ebp
8010165b:	89 e5                	mov    %esp,%ebp
8010165d:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101660:	8b 55 0c             	mov    0xc(%ebp),%edx
80101663:	8b 45 08             	mov    0x8(%ebp),%eax
80101666:	89 54 24 04          	mov    %edx,0x4(%esp)
8010166a:	89 04 24             	mov    %eax,(%esp)
8010166d:	e8 34 eb ff ff       	call   801001a6 <bread>
80101672:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101675:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101678:	83 c0 18             	add    $0x18,%eax
8010167b:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80101682:	00 
80101683:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010168a:	00 
8010168b:	89 04 24             	mov    %eax,(%esp)
8010168e:	e8 7b 3d 00 00       	call   8010540e <memset>
  log_write(bp);
80101693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101696:	89 04 24             	mov    %eax,(%esp)
80101699:	e8 48 1f 00 00       	call   801035e6 <log_write>
  brelse(bp);
8010169e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016a1:	89 04 24             	mov    %eax,(%esp)
801016a4:	e8 6e eb ff ff       	call   80100217 <brelse>
}
801016a9:	c9                   	leave  
801016aa:	c3                   	ret    

801016ab <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801016ab:	55                   	push   %ebp
801016ac:	89 e5                	mov    %esp,%ebp
801016ae:	53                   	push   %ebx
801016af:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
801016b2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
801016b9:	8b 45 08             	mov    0x8(%ebp),%eax
801016bc:	8d 55 d8             	lea    -0x28(%ebp),%edx
801016bf:	89 54 24 04          	mov    %edx,0x4(%esp)
801016c3:	89 04 24             	mov    %eax,(%esp)
801016c6:	e8 49 ff ff ff       	call   80101614 <readsb>
  for(b = 0; b < sb.size; b += BPB){
801016cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801016d2:	e9 11 01 00 00       	jmp    801017e8 <balloc+0x13d>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801016d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016da:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801016e0:	85 c0                	test   %eax,%eax
801016e2:	0f 48 c2             	cmovs  %edx,%eax
801016e5:	c1 f8 0c             	sar    $0xc,%eax
801016e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
801016eb:	c1 ea 03             	shr    $0x3,%edx
801016ee:	01 d0                	add    %edx,%eax
801016f0:	83 c0 03             	add    $0x3,%eax
801016f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801016f7:	8b 45 08             	mov    0x8(%ebp),%eax
801016fa:	89 04 24             	mov    %eax,(%esp)
801016fd:	e8 a4 ea ff ff       	call   801001a6 <bread>
80101702:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101705:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010170c:	e9 a7 00 00 00       	jmp    801017b8 <balloc+0x10d>
      m = 1 << (bi % 8);
80101711:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101714:	89 c2                	mov    %eax,%edx
80101716:	c1 fa 1f             	sar    $0x1f,%edx
80101719:	c1 ea 1d             	shr    $0x1d,%edx
8010171c:	01 d0                	add    %edx,%eax
8010171e:	83 e0 07             	and    $0x7,%eax
80101721:	29 d0                	sub    %edx,%eax
80101723:	ba 01 00 00 00       	mov    $0x1,%edx
80101728:	89 d3                	mov    %edx,%ebx
8010172a:	89 c1                	mov    %eax,%ecx
8010172c:	d3 e3                	shl    %cl,%ebx
8010172e:	89 d8                	mov    %ebx,%eax
80101730:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101733:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101736:	8d 50 07             	lea    0x7(%eax),%edx
80101739:	85 c0                	test   %eax,%eax
8010173b:	0f 48 c2             	cmovs  %edx,%eax
8010173e:	c1 f8 03             	sar    $0x3,%eax
80101741:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101744:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101749:	0f b6 c0             	movzbl %al,%eax
8010174c:	23 45 e8             	and    -0x18(%ebp),%eax
8010174f:	85 c0                	test   %eax,%eax
80101751:	75 61                	jne    801017b4 <balloc+0x109>
        bp->data[bi/8] |= m;  // Mark block in use.
80101753:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101756:	8d 50 07             	lea    0x7(%eax),%edx
80101759:	85 c0                	test   %eax,%eax
8010175b:	0f 48 c2             	cmovs  %edx,%eax
8010175e:	c1 f8 03             	sar    $0x3,%eax
80101761:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101764:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101769:	89 d1                	mov    %edx,%ecx
8010176b:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010176e:	09 ca                	or     %ecx,%edx
80101770:	89 d1                	mov    %edx,%ecx
80101772:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101775:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101779:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010177c:	89 04 24             	mov    %eax,(%esp)
8010177f:	e8 62 1e 00 00       	call   801035e6 <log_write>
        brelse(bp);
80101784:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101787:	89 04 24             	mov    %eax,(%esp)
8010178a:	e8 88 ea ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
8010178f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101792:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101795:	01 c2                	add    %eax,%edx
80101797:	8b 45 08             	mov    0x8(%ebp),%eax
8010179a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010179e:	89 04 24             	mov    %eax,(%esp)
801017a1:	e8 b4 fe ff ff       	call   8010165a <bzero>
        return b + bi;
801017a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017ac:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
801017ae:	83 c4 34             	add    $0x34,%esp
801017b1:	5b                   	pop    %ebx
801017b2:	5d                   	pop    %ebp
801017b3:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801017b4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801017b8:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801017bf:	7f 15                	jg     801017d6 <balloc+0x12b>
801017c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017c7:	01 d0                	add    %edx,%eax
801017c9:	89 c2                	mov    %eax,%edx
801017cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
801017ce:	39 c2                	cmp    %eax,%edx
801017d0:	0f 82 3b ff ff ff    	jb     80101711 <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801017d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017d9:	89 04 24             	mov    %eax,(%esp)
801017dc:	e8 36 ea ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
801017e1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801017e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017eb:	8b 45 d8             	mov    -0x28(%ebp),%eax
801017ee:	39 c2                	cmp    %eax,%edx
801017f0:	0f 82 e1 fe ff ff    	jb     801016d7 <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801017f6:	c7 04 24 01 89 10 80 	movl   $0x80108901,(%esp)
801017fd:	e8 3b ed ff ff       	call   8010053d <panic>

80101802 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101802:	55                   	push   %ebp
80101803:	89 e5                	mov    %esp,%ebp
80101805:	53                   	push   %ebx
80101806:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
80101809:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010180c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101810:	8b 45 08             	mov    0x8(%ebp),%eax
80101813:	89 04 24             	mov    %eax,(%esp)
80101816:	e8 f9 fd ff ff       	call   80101614 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
8010181b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010181e:	89 c2                	mov    %eax,%edx
80101820:	c1 ea 0c             	shr    $0xc,%edx
80101823:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101826:	c1 e8 03             	shr    $0x3,%eax
80101829:	01 d0                	add    %edx,%eax
8010182b:	8d 50 03             	lea    0x3(%eax),%edx
8010182e:	8b 45 08             	mov    0x8(%ebp),%eax
80101831:	89 54 24 04          	mov    %edx,0x4(%esp)
80101835:	89 04 24             	mov    %eax,(%esp)
80101838:	e8 69 e9 ff ff       	call   801001a6 <bread>
8010183d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101840:	8b 45 0c             	mov    0xc(%ebp),%eax
80101843:	25 ff 0f 00 00       	and    $0xfff,%eax
80101848:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010184b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010184e:	89 c2                	mov    %eax,%edx
80101850:	c1 fa 1f             	sar    $0x1f,%edx
80101853:	c1 ea 1d             	shr    $0x1d,%edx
80101856:	01 d0                	add    %edx,%eax
80101858:	83 e0 07             	and    $0x7,%eax
8010185b:	29 d0                	sub    %edx,%eax
8010185d:	ba 01 00 00 00       	mov    $0x1,%edx
80101862:	89 d3                	mov    %edx,%ebx
80101864:	89 c1                	mov    %eax,%ecx
80101866:	d3 e3                	shl    %cl,%ebx
80101868:	89 d8                	mov    %ebx,%eax
8010186a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010186d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101870:	8d 50 07             	lea    0x7(%eax),%edx
80101873:	85 c0                	test   %eax,%eax
80101875:	0f 48 c2             	cmovs  %edx,%eax
80101878:	c1 f8 03             	sar    $0x3,%eax
8010187b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010187e:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101883:	0f b6 c0             	movzbl %al,%eax
80101886:	23 45 ec             	and    -0x14(%ebp),%eax
80101889:	85 c0                	test   %eax,%eax
8010188b:	75 0c                	jne    80101899 <bfree+0x97>
    panic("freeing free block");
8010188d:	c7 04 24 17 89 10 80 	movl   $0x80108917,(%esp)
80101894:	e8 a4 ec ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
80101899:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189c:	8d 50 07             	lea    0x7(%eax),%edx
8010189f:	85 c0                	test   %eax,%eax
801018a1:	0f 48 c2             	cmovs  %edx,%eax
801018a4:	c1 f8 03             	sar    $0x3,%eax
801018a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018aa:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801018af:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801018b2:	f7 d1                	not    %ecx
801018b4:	21 ca                	and    %ecx,%edx
801018b6:	89 d1                	mov    %edx,%ecx
801018b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018bb:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801018bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c2:	89 04 24             	mov    %eax,(%esp)
801018c5:	e8 1c 1d 00 00       	call   801035e6 <log_write>
  brelse(bp);
801018ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018cd:	89 04 24             	mov    %eax,(%esp)
801018d0:	e8 42 e9 ff ff       	call   80100217 <brelse>
}
801018d5:	83 c4 34             	add    $0x34,%esp
801018d8:	5b                   	pop    %ebx
801018d9:	5d                   	pop    %ebp
801018da:	c3                   	ret    

801018db <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
801018db:	55                   	push   %ebp
801018dc:	89 e5                	mov    %esp,%ebp
801018de:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
801018e1:	c7 44 24 04 2a 89 10 	movl   $0x8010892a,0x4(%esp)
801018e8:	80 
801018e9:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
801018f0:	e8 a9 38 00 00       	call   8010519e <initlock>
}
801018f5:	c9                   	leave  
801018f6:	c3                   	ret    

801018f7 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801018f7:	55                   	push   %ebp
801018f8:	89 e5                	mov    %esp,%ebp
801018fa:	83 ec 48             	sub    $0x48,%esp
801018fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101900:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
80101904:	8b 45 08             	mov    0x8(%ebp),%eax
80101907:	8d 55 dc             	lea    -0x24(%ebp),%edx
8010190a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010190e:	89 04 24             	mov    %eax,(%esp)
80101911:	e8 fe fc ff ff       	call   80101614 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
80101916:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010191d:	e9 98 00 00 00       	jmp    801019ba <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
80101922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101925:	c1 e8 03             	shr    $0x3,%eax
80101928:	83 c0 02             	add    $0x2,%eax
8010192b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010192f:	8b 45 08             	mov    0x8(%ebp),%eax
80101932:	89 04 24             	mov    %eax,(%esp)
80101935:	e8 6c e8 ff ff       	call   801001a6 <bread>
8010193a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010193d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101940:	8d 50 18             	lea    0x18(%eax),%edx
80101943:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101946:	83 e0 07             	and    $0x7,%eax
80101949:	c1 e0 06             	shl    $0x6,%eax
8010194c:	01 d0                	add    %edx,%eax
8010194e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101951:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101954:	0f b7 00             	movzwl (%eax),%eax
80101957:	66 85 c0             	test   %ax,%ax
8010195a:	75 4f                	jne    801019ab <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
8010195c:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101963:	00 
80101964:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010196b:	00 
8010196c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010196f:	89 04 24             	mov    %eax,(%esp)
80101972:	e8 97 3a 00 00       	call   8010540e <memset>
      dip->type = type;
80101977:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010197a:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
8010197e:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101981:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101984:	89 04 24             	mov    %eax,(%esp)
80101987:	e8 5a 1c 00 00       	call   801035e6 <log_write>
      brelse(bp);
8010198c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010198f:	89 04 24             	mov    %eax,(%esp)
80101992:	e8 80 e8 ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
80101997:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010199e:	8b 45 08             	mov    0x8(%ebp),%eax
801019a1:	89 04 24             	mov    %eax,(%esp)
801019a4:	e8 e3 00 00 00       	call   80101a8c <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
801019a9:	c9                   	leave  
801019aa:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
801019ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ae:	89 04 24             	mov    %eax,(%esp)
801019b1:	e8 61 e8 ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
801019b6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801019ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801019bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801019c0:	39 c2                	cmp    %eax,%edx
801019c2:	0f 82 5a ff ff ff    	jb     80101922 <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801019c8:	c7 04 24 31 89 10 80 	movl   $0x80108931,(%esp)
801019cf:	e8 69 eb ff ff       	call   8010053d <panic>

801019d4 <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801019d4:	55                   	push   %ebp
801019d5:	89 e5                	mov    %esp,%ebp
801019d7:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
801019da:	8b 45 08             	mov    0x8(%ebp),%eax
801019dd:	8b 40 04             	mov    0x4(%eax),%eax
801019e0:	c1 e8 03             	shr    $0x3,%eax
801019e3:	8d 50 02             	lea    0x2(%eax),%edx
801019e6:	8b 45 08             	mov    0x8(%ebp),%eax
801019e9:	8b 00                	mov    (%eax),%eax
801019eb:	89 54 24 04          	mov    %edx,0x4(%esp)
801019ef:	89 04 24             	mov    %eax,(%esp)
801019f2:	e8 af e7 ff ff       	call   801001a6 <bread>
801019f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801019fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019fd:	8d 50 18             	lea    0x18(%eax),%edx
80101a00:	8b 45 08             	mov    0x8(%ebp),%eax
80101a03:	8b 40 04             	mov    0x4(%eax),%eax
80101a06:	83 e0 07             	and    $0x7,%eax
80101a09:	c1 e0 06             	shl    $0x6,%eax
80101a0c:	01 d0                	add    %edx,%eax
80101a0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101a11:	8b 45 08             	mov    0x8(%ebp),%eax
80101a14:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101a18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a1b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101a1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a21:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101a25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a28:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101a2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2f:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101a33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a36:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101a3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3d:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101a41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a44:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101a48:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4b:	8b 50 18             	mov    0x18(%eax),%edx
80101a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a51:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101a54:	8b 45 08             	mov    0x8(%ebp),%eax
80101a57:	8d 50 1c             	lea    0x1c(%eax),%edx
80101a5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a5d:	83 c0 0c             	add    $0xc,%eax
80101a60:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101a67:	00 
80101a68:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a6c:	89 04 24             	mov    %eax,(%esp)
80101a6f:	e8 6d 3a 00 00       	call   801054e1 <memmove>
  log_write(bp);
80101a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a77:	89 04 24             	mov    %eax,(%esp)
80101a7a:	e8 67 1b 00 00       	call   801035e6 <log_write>
  brelse(bp);
80101a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a82:	89 04 24             	mov    %eax,(%esp)
80101a85:	e8 8d e7 ff ff       	call   80100217 <brelse>
}
80101a8a:	c9                   	leave  
80101a8b:	c3                   	ret    

80101a8c <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101a8c:	55                   	push   %ebp
80101a8d:	89 e5                	mov    %esp,%ebp
80101a8f:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a92:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101a99:	e8 21 37 00 00       	call   801051bf <acquire>

  // Is the inode already cached?
  empty = 0;
80101a9e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101aa5:	c7 45 f4 b4 e8 10 80 	movl   $0x8010e8b4,-0xc(%ebp)
80101aac:	eb 59                	jmp    80101b07 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab1:	8b 40 08             	mov    0x8(%eax),%eax
80101ab4:	85 c0                	test   %eax,%eax
80101ab6:	7e 35                	jle    80101aed <iget+0x61>
80101ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101abb:	8b 00                	mov    (%eax),%eax
80101abd:	3b 45 08             	cmp    0x8(%ebp),%eax
80101ac0:	75 2b                	jne    80101aed <iget+0x61>
80101ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ac5:	8b 40 04             	mov    0x4(%eax),%eax
80101ac8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101acb:	75 20                	jne    80101aed <iget+0x61>
      ip->ref++;
80101acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ad0:	8b 40 08             	mov    0x8(%eax),%eax
80101ad3:	8d 50 01             	lea    0x1(%eax),%edx
80101ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ad9:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101adc:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101ae3:	e8 39 37 00 00       	call   80105221 <release>
      return ip;
80101ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aeb:	eb 6f                	jmp    80101b5c <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101aed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101af1:	75 10                	jne    80101b03 <iget+0x77>
80101af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101af6:	8b 40 08             	mov    0x8(%eax),%eax
80101af9:	85 c0                	test   %eax,%eax
80101afb:	75 06                	jne    80101b03 <iget+0x77>
      empty = ip;
80101afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b00:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101b03:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101b07:	81 7d f4 54 f8 10 80 	cmpl   $0x8010f854,-0xc(%ebp)
80101b0e:	72 9e                	jb     80101aae <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101b10:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101b14:	75 0c                	jne    80101b22 <iget+0x96>
    panic("iget: no inodes");
80101b16:	c7 04 24 43 89 10 80 	movl   $0x80108943,(%esp)
80101b1d:	e8 1b ea ff ff       	call   8010053d <panic>

  ip = empty;
80101b22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b25:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b2b:	8b 55 08             	mov    0x8(%ebp),%edx
80101b2e:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b33:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b36:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b3c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b46:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101b4d:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b54:	e8 c8 36 00 00       	call   80105221 <release>

  return ip;
80101b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101b5c:	c9                   	leave  
80101b5d:	c3                   	ret    

80101b5e <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101b5e:	55                   	push   %ebp
80101b5f:	89 e5                	mov    %esp,%ebp
80101b61:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101b64:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b6b:	e8 4f 36 00 00       	call   801051bf <acquire>
  ip->ref++;
80101b70:	8b 45 08             	mov    0x8(%ebp),%eax
80101b73:	8b 40 08             	mov    0x8(%eax),%eax
80101b76:	8d 50 01             	lea    0x1(%eax),%edx
80101b79:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7c:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b7f:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b86:	e8 96 36 00 00       	call   80105221 <release>
  return ip;
80101b8b:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b8e:	c9                   	leave  
80101b8f:	c3                   	ret    

80101b90 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b90:	55                   	push   %ebp
80101b91:	89 e5                	mov    %esp,%ebp
80101b93:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b96:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b9a:	74 0a                	je     80101ba6 <ilock+0x16>
80101b9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9f:	8b 40 08             	mov    0x8(%eax),%eax
80101ba2:	85 c0                	test   %eax,%eax
80101ba4:	7f 0c                	jg     80101bb2 <ilock+0x22>
    panic("ilock");
80101ba6:	c7 04 24 53 89 10 80 	movl   $0x80108953,(%esp)
80101bad:	e8 8b e9 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101bb2:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101bb9:	e8 01 36 00 00       	call   801051bf <acquire>
  while(ip->flags & I_BUSY)
80101bbe:	eb 13                	jmp    80101bd3 <ilock+0x43>
    sleep(ip, &icache.lock);
80101bc0:	c7 44 24 04 80 e8 10 	movl   $0x8010e880,0x4(%esp)
80101bc7:	80 
80101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcb:	89 04 24             	mov    %eax,(%esp)
80101bce:	e8 83 32 00 00       	call   80104e56 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd6:	8b 40 0c             	mov    0xc(%eax),%eax
80101bd9:	83 e0 01             	and    $0x1,%eax
80101bdc:	84 c0                	test   %al,%al
80101bde:	75 e0                	jne    80101bc0 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101be0:	8b 45 08             	mov    0x8(%ebp),%eax
80101be3:	8b 40 0c             	mov    0xc(%eax),%eax
80101be6:	89 c2                	mov    %eax,%edx
80101be8:	83 ca 01             	or     $0x1,%edx
80101beb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bee:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101bf1:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101bf8:	e8 24 36 00 00       	call   80105221 <release>

  if(!(ip->flags & I_VALID)){
80101bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80101c00:	8b 40 0c             	mov    0xc(%eax),%eax
80101c03:	83 e0 02             	and    $0x2,%eax
80101c06:	85 c0                	test   %eax,%eax
80101c08:	0f 85 ce 00 00 00    	jne    80101cdc <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
80101c0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c11:	8b 40 04             	mov    0x4(%eax),%eax
80101c14:	c1 e8 03             	shr    $0x3,%eax
80101c17:	8d 50 02             	lea    0x2(%eax),%edx
80101c1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1d:	8b 00                	mov    (%eax),%eax
80101c1f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c23:	89 04 24             	mov    %eax,(%esp)
80101c26:	e8 7b e5 ff ff       	call   801001a6 <bread>
80101c2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c31:	8d 50 18             	lea    0x18(%eax),%edx
80101c34:	8b 45 08             	mov    0x8(%ebp),%eax
80101c37:	8b 40 04             	mov    0x4(%eax),%eax
80101c3a:	83 e0 07             	and    $0x7,%eax
80101c3d:	c1 e0 06             	shl    $0x6,%eax
80101c40:	01 d0                	add    %edx,%eax
80101c42:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101c45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c48:	0f b7 10             	movzwl (%eax),%edx
80101c4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4e:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101c52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c55:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101c59:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5c:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c63:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101c67:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6a:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101c6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c71:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101c75:	8b 45 08             	mov    0x8(%ebp),%eax
80101c78:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101c7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c7f:	8b 50 08             	mov    0x8(%eax),%edx
80101c82:	8b 45 08             	mov    0x8(%ebp),%eax
80101c85:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101c88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c8b:	8d 50 0c             	lea    0xc(%eax),%edx
80101c8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c91:	83 c0 1c             	add    $0x1c,%eax
80101c94:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101c9b:	00 
80101c9c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ca0:	89 04 24             	mov    %eax,(%esp)
80101ca3:	e8 39 38 00 00       	call   801054e1 <memmove>
    brelse(bp);
80101ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cab:	89 04 24             	mov    %eax,(%esp)
80101cae:	e8 64 e5 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101cb3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb6:	8b 40 0c             	mov    0xc(%eax),%eax
80101cb9:	89 c2                	mov    %eax,%edx
80101cbb:	83 ca 02             	or     $0x2,%edx
80101cbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc1:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101cc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc7:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ccb:	66 85 c0             	test   %ax,%ax
80101cce:	75 0c                	jne    80101cdc <ilock+0x14c>
      panic("ilock: no type");
80101cd0:	c7 04 24 59 89 10 80 	movl   $0x80108959,(%esp)
80101cd7:	e8 61 e8 ff ff       	call   8010053d <panic>
  }
}
80101cdc:	c9                   	leave  
80101cdd:	c3                   	ret    

80101cde <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101cde:	55                   	push   %ebp
80101cdf:	89 e5                	mov    %esp,%ebp
80101ce1:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101ce4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ce8:	74 17                	je     80101d01 <iunlock+0x23>
80101cea:	8b 45 08             	mov    0x8(%ebp),%eax
80101ced:	8b 40 0c             	mov    0xc(%eax),%eax
80101cf0:	83 e0 01             	and    $0x1,%eax
80101cf3:	85 c0                	test   %eax,%eax
80101cf5:	74 0a                	je     80101d01 <iunlock+0x23>
80101cf7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfa:	8b 40 08             	mov    0x8(%eax),%eax
80101cfd:	85 c0                	test   %eax,%eax
80101cff:	7f 0c                	jg     80101d0d <iunlock+0x2f>
    panic("iunlock");
80101d01:	c7 04 24 68 89 10 80 	movl   $0x80108968,(%esp)
80101d08:	e8 30 e8 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101d0d:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d14:	e8 a6 34 00 00       	call   801051bf <acquire>
  ip->flags &= ~I_BUSY;
80101d19:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1c:	8b 40 0c             	mov    0xc(%eax),%eax
80101d1f:	89 c2                	mov    %eax,%edx
80101d21:	83 e2 fe             	and    $0xfffffffe,%edx
80101d24:	8b 45 08             	mov    0x8(%ebp),%eax
80101d27:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101d2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2d:	89 04 24             	mov    %eax,(%esp)
80101d30:	e8 fd 31 00 00       	call   80104f32 <wakeup>
  release(&icache.lock);
80101d35:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d3c:	e8 e0 34 00 00       	call   80105221 <release>
}
80101d41:	c9                   	leave  
80101d42:	c3                   	ret    

80101d43 <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101d43:	55                   	push   %ebp
80101d44:	89 e5                	mov    %esp,%ebp
80101d46:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101d49:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d50:	e8 6a 34 00 00       	call   801051bf <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101d55:	8b 45 08             	mov    0x8(%ebp),%eax
80101d58:	8b 40 08             	mov    0x8(%eax),%eax
80101d5b:	83 f8 01             	cmp    $0x1,%eax
80101d5e:	0f 85 93 00 00 00    	jne    80101df7 <iput+0xb4>
80101d64:	8b 45 08             	mov    0x8(%ebp),%eax
80101d67:	8b 40 0c             	mov    0xc(%eax),%eax
80101d6a:	83 e0 02             	and    $0x2,%eax
80101d6d:	85 c0                	test   %eax,%eax
80101d6f:	0f 84 82 00 00 00    	je     80101df7 <iput+0xb4>
80101d75:	8b 45 08             	mov    0x8(%ebp),%eax
80101d78:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101d7c:	66 85 c0             	test   %ax,%ax
80101d7f:	75 76                	jne    80101df7 <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101d81:	8b 45 08             	mov    0x8(%ebp),%eax
80101d84:	8b 40 0c             	mov    0xc(%eax),%eax
80101d87:	83 e0 01             	and    $0x1,%eax
80101d8a:	84 c0                	test   %al,%al
80101d8c:	74 0c                	je     80101d9a <iput+0x57>
      panic("iput busy");
80101d8e:	c7 04 24 70 89 10 80 	movl   $0x80108970,(%esp)
80101d95:	e8 a3 e7 ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80101d9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9d:	8b 40 0c             	mov    0xc(%eax),%eax
80101da0:	89 c2                	mov    %eax,%edx
80101da2:	83 ca 01             	or     $0x1,%edx
80101da5:	8b 45 08             	mov    0x8(%ebp),%eax
80101da8:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101dab:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101db2:	e8 6a 34 00 00       	call   80105221 <release>
    itrunc(ip);
80101db7:	8b 45 08             	mov    0x8(%ebp),%eax
80101dba:	89 04 24             	mov    %eax,(%esp)
80101dbd:	e8 72 01 00 00       	call   80101f34 <itrunc>
    ip->type = 0;
80101dc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc5:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101dcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dce:	89 04 24             	mov    %eax,(%esp)
80101dd1:	e8 fe fb ff ff       	call   801019d4 <iupdate>
    acquire(&icache.lock);
80101dd6:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101ddd:	e8 dd 33 00 00       	call   801051bf <acquire>
    ip->flags = 0;
80101de2:	8b 45 08             	mov    0x8(%ebp),%eax
80101de5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101dec:	8b 45 08             	mov    0x8(%ebp),%eax
80101def:	89 04 24             	mov    %eax,(%esp)
80101df2:	e8 3b 31 00 00       	call   80104f32 <wakeup>
  }
  ip->ref--;
80101df7:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfa:	8b 40 08             	mov    0x8(%eax),%eax
80101dfd:	8d 50 ff             	lea    -0x1(%eax),%edx
80101e00:	8b 45 08             	mov    0x8(%ebp),%eax
80101e03:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101e06:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101e0d:	e8 0f 34 00 00       	call   80105221 <release>
}
80101e12:	c9                   	leave  
80101e13:	c3                   	ret    

80101e14 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101e14:	55                   	push   %ebp
80101e15:	89 e5                	mov    %esp,%ebp
80101e17:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101e1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1d:	89 04 24             	mov    %eax,(%esp)
80101e20:	e8 b9 fe ff ff       	call   80101cde <iunlock>
  iput(ip);
80101e25:	8b 45 08             	mov    0x8(%ebp),%eax
80101e28:	89 04 24             	mov    %eax,(%esp)
80101e2b:	e8 13 ff ff ff       	call   80101d43 <iput>
}
80101e30:	c9                   	leave  
80101e31:	c3                   	ret    

80101e32 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101e32:	55                   	push   %ebp
80101e33:	89 e5                	mov    %esp,%ebp
80101e35:	53                   	push   %ebx
80101e36:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101e39:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101e3d:	77 3e                	ja     80101e7d <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101e3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e42:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e45:	83 c2 04             	add    $0x4,%edx
80101e48:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e4f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e53:	75 20                	jne    80101e75 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101e55:	8b 45 08             	mov    0x8(%ebp),%eax
80101e58:	8b 00                	mov    (%eax),%eax
80101e5a:	89 04 24             	mov    %eax,(%esp)
80101e5d:	e8 49 f8 ff ff       	call   801016ab <balloc>
80101e62:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e65:	8b 45 08             	mov    0x8(%ebp),%eax
80101e68:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e6b:	8d 4a 04             	lea    0x4(%edx),%ecx
80101e6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e71:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e78:	e9 b1 00 00 00       	jmp    80101f2e <bmap+0xfc>
  }
  bn -= NDIRECT;
80101e7d:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101e81:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101e85:	0f 87 97 00 00 00    	ja     80101f22 <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101e8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8e:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e91:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e94:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e98:	75 19                	jne    80101eb3 <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101e9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9d:	8b 00                	mov    (%eax),%eax
80101e9f:	89 04 24             	mov    %eax,(%esp)
80101ea2:	e8 04 f8 ff ff       	call   801016ab <balloc>
80101ea7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101eaa:	8b 45 08             	mov    0x8(%ebp),%eax
80101ead:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101eb0:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101eb3:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb6:	8b 00                	mov    (%eax),%eax
80101eb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ebb:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ebf:	89 04 24             	mov    %eax,(%esp)
80101ec2:	e8 df e2 ff ff       	call   801001a6 <bread>
80101ec7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101eca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ecd:	83 c0 18             	add    $0x18,%eax
80101ed0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101ed3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed6:	c1 e0 02             	shl    $0x2,%eax
80101ed9:	03 45 ec             	add    -0x14(%ebp),%eax
80101edc:	8b 00                	mov    (%eax),%eax
80101ede:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ee1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ee5:	75 2b                	jne    80101f12 <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80101ee7:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eea:	c1 e0 02             	shl    $0x2,%eax
80101eed:	89 c3                	mov    %eax,%ebx
80101eef:	03 5d ec             	add    -0x14(%ebp),%ebx
80101ef2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef5:	8b 00                	mov    (%eax),%eax
80101ef7:	89 04 24             	mov    %eax,(%esp)
80101efa:	e8 ac f7 ff ff       	call   801016ab <balloc>
80101eff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f05:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101f07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f0a:	89 04 24             	mov    %eax,(%esp)
80101f0d:	e8 d4 16 00 00       	call   801035e6 <log_write>
    }
    brelse(bp);
80101f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f15:	89 04 24             	mov    %eax,(%esp)
80101f18:	e8 fa e2 ff ff       	call   80100217 <brelse>
    return addr;
80101f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f20:	eb 0c                	jmp    80101f2e <bmap+0xfc>
  }

  panic("bmap: out of range");
80101f22:	c7 04 24 7a 89 10 80 	movl   $0x8010897a,(%esp)
80101f29:	e8 0f e6 ff ff       	call   8010053d <panic>
}
80101f2e:	83 c4 24             	add    $0x24,%esp
80101f31:	5b                   	pop    %ebx
80101f32:	5d                   	pop    %ebp
80101f33:	c3                   	ret    

80101f34 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101f34:	55                   	push   %ebp
80101f35:	89 e5                	mov    %esp,%ebp
80101f37:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f3a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f41:	eb 44                	jmp    80101f87 <itrunc+0x53>
    if(ip->addrs[i]){
80101f43:	8b 45 08             	mov    0x8(%ebp),%eax
80101f46:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f49:	83 c2 04             	add    $0x4,%edx
80101f4c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f50:	85 c0                	test   %eax,%eax
80101f52:	74 2f                	je     80101f83 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101f54:	8b 45 08             	mov    0x8(%ebp),%eax
80101f57:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f5a:	83 c2 04             	add    $0x4,%edx
80101f5d:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101f61:	8b 45 08             	mov    0x8(%ebp),%eax
80101f64:	8b 00                	mov    (%eax),%eax
80101f66:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f6a:	89 04 24             	mov    %eax,(%esp)
80101f6d:	e8 90 f8 ff ff       	call   80101802 <bfree>
      ip->addrs[i] = 0;
80101f72:	8b 45 08             	mov    0x8(%ebp),%eax
80101f75:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f78:	83 c2 04             	add    $0x4,%edx
80101f7b:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101f82:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f83:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101f87:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101f8b:	7e b6                	jle    80101f43 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101f8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f90:	8b 40 4c             	mov    0x4c(%eax),%eax
80101f93:	85 c0                	test   %eax,%eax
80101f95:	0f 84 8f 00 00 00    	je     8010202a <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9e:	8b 50 4c             	mov    0x4c(%eax),%edx
80101fa1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa4:	8b 00                	mov    (%eax),%eax
80101fa6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101faa:	89 04 24             	mov    %eax,(%esp)
80101fad:	e8 f4 e1 ff ff       	call   801001a6 <bread>
80101fb2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101fb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fb8:	83 c0 18             	add    $0x18,%eax
80101fbb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101fbe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101fc5:	eb 2f                	jmp    80101ff6 <itrunc+0xc2>
      if(a[j])
80101fc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fca:	c1 e0 02             	shl    $0x2,%eax
80101fcd:	03 45 e8             	add    -0x18(%ebp),%eax
80101fd0:	8b 00                	mov    (%eax),%eax
80101fd2:	85 c0                	test   %eax,%eax
80101fd4:	74 1c                	je     80101ff2 <itrunc+0xbe>
        bfree(ip->dev, a[j]);
80101fd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fd9:	c1 e0 02             	shl    $0x2,%eax
80101fdc:	03 45 e8             	add    -0x18(%ebp),%eax
80101fdf:	8b 10                	mov    (%eax),%edx
80101fe1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe4:	8b 00                	mov    (%eax),%eax
80101fe6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fea:	89 04 24             	mov    %eax,(%esp)
80101fed:	e8 10 f8 ff ff       	call   80101802 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101ff2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ff6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ff9:	83 f8 7f             	cmp    $0x7f,%eax
80101ffc:	76 c9                	jbe    80101fc7 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101ffe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102001:	89 04 24             	mov    %eax,(%esp)
80102004:	e8 0e e2 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80102009:	8b 45 08             	mov    0x8(%ebp),%eax
8010200c:	8b 50 4c             	mov    0x4c(%eax),%edx
8010200f:	8b 45 08             	mov    0x8(%ebp),%eax
80102012:	8b 00                	mov    (%eax),%eax
80102014:	89 54 24 04          	mov    %edx,0x4(%esp)
80102018:	89 04 24             	mov    %eax,(%esp)
8010201b:	e8 e2 f7 ff ff       	call   80101802 <bfree>
    ip->addrs[NDIRECT] = 0;
80102020:	8b 45 08             	mov    0x8(%ebp),%eax
80102023:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
8010202a:	8b 45 08             	mov    0x8(%ebp),%eax
8010202d:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80102034:	8b 45 08             	mov    0x8(%ebp),%eax
80102037:	89 04 24             	mov    %eax,(%esp)
8010203a:	e8 95 f9 ff ff       	call   801019d4 <iupdate>
}
8010203f:	c9                   	leave  
80102040:	c3                   	ret    

80102041 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80102041:	55                   	push   %ebp
80102042:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80102044:	8b 45 08             	mov    0x8(%ebp),%eax
80102047:	8b 00                	mov    (%eax),%eax
80102049:	89 c2                	mov    %eax,%edx
8010204b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010204e:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80102051:	8b 45 08             	mov    0x8(%ebp),%eax
80102054:	8b 50 04             	mov    0x4(%eax),%edx
80102057:	8b 45 0c             	mov    0xc(%ebp),%eax
8010205a:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
8010205d:	8b 45 08             	mov    0x8(%ebp),%eax
80102060:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80102064:	8b 45 0c             	mov    0xc(%ebp),%eax
80102067:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
8010206a:	8b 45 08             	mov    0x8(%ebp),%eax
8010206d:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80102071:	8b 45 0c             	mov    0xc(%ebp),%eax
80102074:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80102078:	8b 45 08             	mov    0x8(%ebp),%eax
8010207b:	8b 50 18             	mov    0x18(%eax),%edx
8010207e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102081:	89 50 10             	mov    %edx,0x10(%eax)
}
80102084:	5d                   	pop    %ebp
80102085:	c3                   	ret    

80102086 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80102086:	55                   	push   %ebp
80102087:	89 e5                	mov    %esp,%ebp
80102089:	53                   	push   %ebx
8010208a:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010208d:	8b 45 08             	mov    0x8(%ebp),%eax
80102090:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102094:	66 83 f8 03          	cmp    $0x3,%ax
80102098:	75 60                	jne    801020fa <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
8010209a:	8b 45 08             	mov    0x8(%ebp),%eax
8010209d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020a1:	66 85 c0             	test   %ax,%ax
801020a4:	78 20                	js     801020c6 <readi+0x40>
801020a6:	8b 45 08             	mov    0x8(%ebp),%eax
801020a9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020ad:	66 83 f8 09          	cmp    $0x9,%ax
801020b1:	7f 13                	jg     801020c6 <readi+0x40>
801020b3:	8b 45 08             	mov    0x8(%ebp),%eax
801020b6:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020ba:	98                   	cwtl   
801020bb:	8b 04 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%eax
801020c2:	85 c0                	test   %eax,%eax
801020c4:	75 0a                	jne    801020d0 <readi+0x4a>
      return -1;
801020c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020cb:	e9 1b 01 00 00       	jmp    801021eb <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
801020d0:	8b 45 08             	mov    0x8(%ebp),%eax
801020d3:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020d7:	98                   	cwtl   
801020d8:	8b 14 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%edx
801020df:	8b 45 14             	mov    0x14(%ebp),%eax
801020e2:	89 44 24 08          	mov    %eax,0x8(%esp)
801020e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801020e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801020ed:	8b 45 08             	mov    0x8(%ebp),%eax
801020f0:	89 04 24             	mov    %eax,(%esp)
801020f3:	ff d2                	call   *%edx
801020f5:	e9 f1 00 00 00       	jmp    801021eb <readi+0x165>
  }

  if(off > ip->size || off + n < off)
801020fa:	8b 45 08             	mov    0x8(%ebp),%eax
801020fd:	8b 40 18             	mov    0x18(%eax),%eax
80102100:	3b 45 10             	cmp    0x10(%ebp),%eax
80102103:	72 0d                	jb     80102112 <readi+0x8c>
80102105:	8b 45 14             	mov    0x14(%ebp),%eax
80102108:	8b 55 10             	mov    0x10(%ebp),%edx
8010210b:	01 d0                	add    %edx,%eax
8010210d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102110:	73 0a                	jae    8010211c <readi+0x96>
    return -1;
80102112:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102117:	e9 cf 00 00 00       	jmp    801021eb <readi+0x165>
  if(off + n > ip->size)
8010211c:	8b 45 14             	mov    0x14(%ebp),%eax
8010211f:	8b 55 10             	mov    0x10(%ebp),%edx
80102122:	01 c2                	add    %eax,%edx
80102124:	8b 45 08             	mov    0x8(%ebp),%eax
80102127:	8b 40 18             	mov    0x18(%eax),%eax
8010212a:	39 c2                	cmp    %eax,%edx
8010212c:	76 0c                	jbe    8010213a <readi+0xb4>
    n = ip->size - off;
8010212e:	8b 45 08             	mov    0x8(%ebp),%eax
80102131:	8b 40 18             	mov    0x18(%eax),%eax
80102134:	2b 45 10             	sub    0x10(%ebp),%eax
80102137:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010213a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102141:	e9 96 00 00 00       	jmp    801021dc <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102146:	8b 45 10             	mov    0x10(%ebp),%eax
80102149:	c1 e8 09             	shr    $0x9,%eax
8010214c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102150:	8b 45 08             	mov    0x8(%ebp),%eax
80102153:	89 04 24             	mov    %eax,(%esp)
80102156:	e8 d7 fc ff ff       	call   80101e32 <bmap>
8010215b:	8b 55 08             	mov    0x8(%ebp),%edx
8010215e:	8b 12                	mov    (%edx),%edx
80102160:	89 44 24 04          	mov    %eax,0x4(%esp)
80102164:	89 14 24             	mov    %edx,(%esp)
80102167:	e8 3a e0 ff ff       	call   801001a6 <bread>
8010216c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010216f:	8b 45 10             	mov    0x10(%ebp),%eax
80102172:	89 c2                	mov    %eax,%edx
80102174:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
8010217a:	b8 00 02 00 00       	mov    $0x200,%eax
8010217f:	89 c1                	mov    %eax,%ecx
80102181:	29 d1                	sub    %edx,%ecx
80102183:	89 ca                	mov    %ecx,%edx
80102185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102188:	8b 4d 14             	mov    0x14(%ebp),%ecx
8010218b:	89 cb                	mov    %ecx,%ebx
8010218d:	29 c3                	sub    %eax,%ebx
8010218f:	89 d8                	mov    %ebx,%eax
80102191:	39 c2                	cmp    %eax,%edx
80102193:	0f 46 c2             	cmovbe %edx,%eax
80102196:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102199:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010219c:	8d 50 18             	lea    0x18(%eax),%edx
8010219f:	8b 45 10             	mov    0x10(%ebp),%eax
801021a2:	25 ff 01 00 00       	and    $0x1ff,%eax
801021a7:	01 c2                	add    %eax,%edx
801021a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021ac:	89 44 24 08          	mov    %eax,0x8(%esp)
801021b0:	89 54 24 04          	mov    %edx,0x4(%esp)
801021b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801021b7:	89 04 24             	mov    %eax,(%esp)
801021ba:	e8 22 33 00 00       	call   801054e1 <memmove>
    brelse(bp);
801021bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021c2:	89 04 24             	mov    %eax,(%esp)
801021c5:	e8 4d e0 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801021ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021cd:	01 45 f4             	add    %eax,-0xc(%ebp)
801021d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021d3:	01 45 10             	add    %eax,0x10(%ebp)
801021d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021d9:	01 45 0c             	add    %eax,0xc(%ebp)
801021dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021df:	3b 45 14             	cmp    0x14(%ebp),%eax
801021e2:	0f 82 5e ff ff ff    	jb     80102146 <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801021e8:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021eb:	83 c4 24             	add    $0x24,%esp
801021ee:	5b                   	pop    %ebx
801021ef:	5d                   	pop    %ebp
801021f0:	c3                   	ret    

801021f1 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801021f1:	55                   	push   %ebp
801021f2:	89 e5                	mov    %esp,%ebp
801021f4:	53                   	push   %ebx
801021f5:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801021f8:	8b 45 08             	mov    0x8(%ebp),%eax
801021fb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021ff:	66 83 f8 03          	cmp    $0x3,%ax
80102203:	75 60                	jne    80102265 <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102205:	8b 45 08             	mov    0x8(%ebp),%eax
80102208:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010220c:	66 85 c0             	test   %ax,%ax
8010220f:	78 20                	js     80102231 <writei+0x40>
80102211:	8b 45 08             	mov    0x8(%ebp),%eax
80102214:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102218:	66 83 f8 09          	cmp    $0x9,%ax
8010221c:	7f 13                	jg     80102231 <writei+0x40>
8010221e:	8b 45 08             	mov    0x8(%ebp),%eax
80102221:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102225:	98                   	cwtl   
80102226:	8b 04 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%eax
8010222d:	85 c0                	test   %eax,%eax
8010222f:	75 0a                	jne    8010223b <writei+0x4a>
      return -1;
80102231:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102236:	e9 46 01 00 00       	jmp    80102381 <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
8010223b:	8b 45 08             	mov    0x8(%ebp),%eax
8010223e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102242:	98                   	cwtl   
80102243:	8b 14 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%edx
8010224a:	8b 45 14             	mov    0x14(%ebp),%eax
8010224d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102251:	8b 45 0c             	mov    0xc(%ebp),%eax
80102254:	89 44 24 04          	mov    %eax,0x4(%esp)
80102258:	8b 45 08             	mov    0x8(%ebp),%eax
8010225b:	89 04 24             	mov    %eax,(%esp)
8010225e:	ff d2                	call   *%edx
80102260:	e9 1c 01 00 00       	jmp    80102381 <writei+0x190>
  }

  if(off > ip->size || off + n < off)
80102265:	8b 45 08             	mov    0x8(%ebp),%eax
80102268:	8b 40 18             	mov    0x18(%eax),%eax
8010226b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010226e:	72 0d                	jb     8010227d <writei+0x8c>
80102270:	8b 45 14             	mov    0x14(%ebp),%eax
80102273:	8b 55 10             	mov    0x10(%ebp),%edx
80102276:	01 d0                	add    %edx,%eax
80102278:	3b 45 10             	cmp    0x10(%ebp),%eax
8010227b:	73 0a                	jae    80102287 <writei+0x96>
    return -1;
8010227d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102282:	e9 fa 00 00 00       	jmp    80102381 <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
80102287:	8b 45 14             	mov    0x14(%ebp),%eax
8010228a:	8b 55 10             	mov    0x10(%ebp),%edx
8010228d:	01 d0                	add    %edx,%eax
8010228f:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102294:	76 0a                	jbe    801022a0 <writei+0xaf>
    return -1;
80102296:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010229b:	e9 e1 00 00 00       	jmp    80102381 <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022a7:	e9 a1 00 00 00       	jmp    8010234d <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801022ac:	8b 45 10             	mov    0x10(%ebp),%eax
801022af:	c1 e8 09             	shr    $0x9,%eax
801022b2:	89 44 24 04          	mov    %eax,0x4(%esp)
801022b6:	8b 45 08             	mov    0x8(%ebp),%eax
801022b9:	89 04 24             	mov    %eax,(%esp)
801022bc:	e8 71 fb ff ff       	call   80101e32 <bmap>
801022c1:	8b 55 08             	mov    0x8(%ebp),%edx
801022c4:	8b 12                	mov    (%edx),%edx
801022c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801022ca:	89 14 24             	mov    %edx,(%esp)
801022cd:	e8 d4 de ff ff       	call   801001a6 <bread>
801022d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801022d5:	8b 45 10             	mov    0x10(%ebp),%eax
801022d8:	89 c2                	mov    %eax,%edx
801022da:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801022e0:	b8 00 02 00 00       	mov    $0x200,%eax
801022e5:	89 c1                	mov    %eax,%ecx
801022e7:	29 d1                	sub    %edx,%ecx
801022e9:	89 ca                	mov    %ecx,%edx
801022eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022ee:	8b 4d 14             	mov    0x14(%ebp),%ecx
801022f1:	89 cb                	mov    %ecx,%ebx
801022f3:	29 c3                	sub    %eax,%ebx
801022f5:	89 d8                	mov    %ebx,%eax
801022f7:	39 c2                	cmp    %eax,%edx
801022f9:	0f 46 c2             	cmovbe %edx,%eax
801022fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801022ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102302:	8d 50 18             	lea    0x18(%eax),%edx
80102305:	8b 45 10             	mov    0x10(%ebp),%eax
80102308:	25 ff 01 00 00       	and    $0x1ff,%eax
8010230d:	01 c2                	add    %eax,%edx
8010230f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102312:	89 44 24 08          	mov    %eax,0x8(%esp)
80102316:	8b 45 0c             	mov    0xc(%ebp),%eax
80102319:	89 44 24 04          	mov    %eax,0x4(%esp)
8010231d:	89 14 24             	mov    %edx,(%esp)
80102320:	e8 bc 31 00 00       	call   801054e1 <memmove>
    log_write(bp);
80102325:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102328:	89 04 24             	mov    %eax,(%esp)
8010232b:	e8 b6 12 00 00       	call   801035e6 <log_write>
    brelse(bp);
80102330:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102333:	89 04 24             	mov    %eax,(%esp)
80102336:	e8 dc de ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010233b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010233e:	01 45 f4             	add    %eax,-0xc(%ebp)
80102341:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102344:	01 45 10             	add    %eax,0x10(%ebp)
80102347:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010234a:	01 45 0c             	add    %eax,0xc(%ebp)
8010234d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102350:	3b 45 14             	cmp    0x14(%ebp),%eax
80102353:	0f 82 53 ff ff ff    	jb     801022ac <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102359:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010235d:	74 1f                	je     8010237e <writei+0x18d>
8010235f:	8b 45 08             	mov    0x8(%ebp),%eax
80102362:	8b 40 18             	mov    0x18(%eax),%eax
80102365:	3b 45 10             	cmp    0x10(%ebp),%eax
80102368:	73 14                	jae    8010237e <writei+0x18d>
    ip->size = off;
8010236a:	8b 45 08             	mov    0x8(%ebp),%eax
8010236d:	8b 55 10             	mov    0x10(%ebp),%edx
80102370:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102373:	8b 45 08             	mov    0x8(%ebp),%eax
80102376:	89 04 24             	mov    %eax,(%esp)
80102379:	e8 56 f6 ff ff       	call   801019d4 <iupdate>
  }
  return n;
8010237e:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102381:	83 c4 24             	add    $0x24,%esp
80102384:	5b                   	pop    %ebx
80102385:	5d                   	pop    %ebp
80102386:	c3                   	ret    

80102387 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102387:	55                   	push   %ebp
80102388:	89 e5                	mov    %esp,%ebp
8010238a:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
8010238d:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102394:	00 
80102395:	8b 45 0c             	mov    0xc(%ebp),%eax
80102398:	89 44 24 04          	mov    %eax,0x4(%esp)
8010239c:	8b 45 08             	mov    0x8(%ebp),%eax
8010239f:	89 04 24             	mov    %eax,(%esp)
801023a2:	e8 de 31 00 00       	call   80105585 <strncmp>
}
801023a7:	c9                   	leave  
801023a8:	c3                   	ret    

801023a9 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801023a9:	55                   	push   %ebp
801023aa:	89 e5                	mov    %esp,%ebp
801023ac:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801023af:	8b 45 08             	mov    0x8(%ebp),%eax
801023b2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023b6:	66 83 f8 01          	cmp    $0x1,%ax
801023ba:	74 0c                	je     801023c8 <dirlookup+0x1f>
    panic("dirlookup not DIR");
801023bc:	c7 04 24 8d 89 10 80 	movl   $0x8010898d,(%esp)
801023c3:	e8 75 e1 ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801023c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023cf:	e9 87 00 00 00       	jmp    8010245b <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023d4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801023db:	00 
801023dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023df:	89 44 24 08          	mov    %eax,0x8(%esp)
801023e3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801023ea:	8b 45 08             	mov    0x8(%ebp),%eax
801023ed:	89 04 24             	mov    %eax,(%esp)
801023f0:	e8 91 fc ff ff       	call   80102086 <readi>
801023f5:	83 f8 10             	cmp    $0x10,%eax
801023f8:	74 0c                	je     80102406 <dirlookup+0x5d>
      panic("dirlink read");
801023fa:	c7 04 24 9f 89 10 80 	movl   $0x8010899f,(%esp)
80102401:	e8 37 e1 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
80102406:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010240a:	66 85 c0             	test   %ax,%ax
8010240d:	74 47                	je     80102456 <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
8010240f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102412:	83 c0 02             	add    $0x2,%eax
80102415:	89 44 24 04          	mov    %eax,0x4(%esp)
80102419:	8b 45 0c             	mov    0xc(%ebp),%eax
8010241c:	89 04 24             	mov    %eax,(%esp)
8010241f:	e8 63 ff ff ff       	call   80102387 <namecmp>
80102424:	85 c0                	test   %eax,%eax
80102426:	75 2f                	jne    80102457 <dirlookup+0xae>
      // entry matches path element
      if(poff)
80102428:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010242c:	74 08                	je     80102436 <dirlookup+0x8d>
        *poff = off;
8010242e:	8b 45 10             	mov    0x10(%ebp),%eax
80102431:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102434:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102436:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010243a:	0f b7 c0             	movzwl %ax,%eax
8010243d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102440:	8b 45 08             	mov    0x8(%ebp),%eax
80102443:	8b 00                	mov    (%eax),%eax
80102445:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102448:	89 54 24 04          	mov    %edx,0x4(%esp)
8010244c:	89 04 24             	mov    %eax,(%esp)
8010244f:	e8 38 f6 ff ff       	call   80101a8c <iget>
80102454:	eb 19                	jmp    8010246f <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102456:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102457:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010245b:	8b 45 08             	mov    0x8(%ebp),%eax
8010245e:	8b 40 18             	mov    0x18(%eax),%eax
80102461:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102464:	0f 87 6a ff ff ff    	ja     801023d4 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010246a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010246f:	c9                   	leave  
80102470:	c3                   	ret    

80102471 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102471:	55                   	push   %ebp
80102472:	89 e5                	mov    %esp,%ebp
80102474:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102477:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010247e:	00 
8010247f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102482:	89 44 24 04          	mov    %eax,0x4(%esp)
80102486:	8b 45 08             	mov    0x8(%ebp),%eax
80102489:	89 04 24             	mov    %eax,(%esp)
8010248c:	e8 18 ff ff ff       	call   801023a9 <dirlookup>
80102491:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102494:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102498:	74 15                	je     801024af <dirlink+0x3e>
    iput(ip);
8010249a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010249d:	89 04 24             	mov    %eax,(%esp)
801024a0:	e8 9e f8 ff ff       	call   80101d43 <iput>
    return -1;
801024a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801024aa:	e9 b8 00 00 00       	jmp    80102567 <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801024af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801024b6:	eb 44                	jmp    801024fc <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024bb:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801024c2:	00 
801024c3:	89 44 24 08          	mov    %eax,0x8(%esp)
801024c7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801024ce:	8b 45 08             	mov    0x8(%ebp),%eax
801024d1:	89 04 24             	mov    %eax,(%esp)
801024d4:	e8 ad fb ff ff       	call   80102086 <readi>
801024d9:	83 f8 10             	cmp    $0x10,%eax
801024dc:	74 0c                	je     801024ea <dirlink+0x79>
      panic("dirlink read");
801024de:	c7 04 24 9f 89 10 80 	movl   $0x8010899f,(%esp)
801024e5:	e8 53 e0 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
801024ea:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801024ee:	66 85 c0             	test   %ax,%ax
801024f1:	74 18                	je     8010250b <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801024f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024f6:	83 c0 10             	add    $0x10,%eax
801024f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801024ff:	8b 45 08             	mov    0x8(%ebp),%eax
80102502:	8b 40 18             	mov    0x18(%eax),%eax
80102505:	39 c2                	cmp    %eax,%edx
80102507:	72 af                	jb     801024b8 <dirlink+0x47>
80102509:	eb 01                	jmp    8010250c <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
8010250b:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010250c:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102513:	00 
80102514:	8b 45 0c             	mov    0xc(%ebp),%eax
80102517:	89 44 24 04          	mov    %eax,0x4(%esp)
8010251b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010251e:	83 c0 02             	add    $0x2,%eax
80102521:	89 04 24             	mov    %eax,(%esp)
80102524:	e8 b4 30 00 00       	call   801055dd <strncpy>
  de.inum = inum;
80102529:	8b 45 10             	mov    0x10(%ebp),%eax
8010252c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102530:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102533:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010253a:	00 
8010253b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010253f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102542:	89 44 24 04          	mov    %eax,0x4(%esp)
80102546:	8b 45 08             	mov    0x8(%ebp),%eax
80102549:	89 04 24             	mov    %eax,(%esp)
8010254c:	e8 a0 fc ff ff       	call   801021f1 <writei>
80102551:	83 f8 10             	cmp    $0x10,%eax
80102554:	74 0c                	je     80102562 <dirlink+0xf1>
    panic("dirlink");
80102556:	c7 04 24 ac 89 10 80 	movl   $0x801089ac,(%esp)
8010255d:	e8 db df ff ff       	call   8010053d <panic>
  
  return 0;
80102562:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102567:	c9                   	leave  
80102568:	c3                   	ret    

80102569 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102569:	55                   	push   %ebp
8010256a:	89 e5                	mov    %esp,%ebp
8010256c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010256f:	eb 04                	jmp    80102575 <skipelem+0xc>
    path++;
80102571:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102575:	8b 45 08             	mov    0x8(%ebp),%eax
80102578:	0f b6 00             	movzbl (%eax),%eax
8010257b:	3c 2f                	cmp    $0x2f,%al
8010257d:	74 f2                	je     80102571 <skipelem+0x8>
    path++;
  if(*path == 0)
8010257f:	8b 45 08             	mov    0x8(%ebp),%eax
80102582:	0f b6 00             	movzbl (%eax),%eax
80102585:	84 c0                	test   %al,%al
80102587:	75 0a                	jne    80102593 <skipelem+0x2a>
    return 0;
80102589:	b8 00 00 00 00       	mov    $0x0,%eax
8010258e:	e9 86 00 00 00       	jmp    80102619 <skipelem+0xb0>
  s = path;
80102593:	8b 45 08             	mov    0x8(%ebp),%eax
80102596:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102599:	eb 04                	jmp    8010259f <skipelem+0x36>
    path++;
8010259b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010259f:	8b 45 08             	mov    0x8(%ebp),%eax
801025a2:	0f b6 00             	movzbl (%eax),%eax
801025a5:	3c 2f                	cmp    $0x2f,%al
801025a7:	74 0a                	je     801025b3 <skipelem+0x4a>
801025a9:	8b 45 08             	mov    0x8(%ebp),%eax
801025ac:	0f b6 00             	movzbl (%eax),%eax
801025af:	84 c0                	test   %al,%al
801025b1:	75 e8                	jne    8010259b <skipelem+0x32>
    path++;
  len = path - s;
801025b3:	8b 55 08             	mov    0x8(%ebp),%edx
801025b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025b9:	89 d1                	mov    %edx,%ecx
801025bb:	29 c1                	sub    %eax,%ecx
801025bd:	89 c8                	mov    %ecx,%eax
801025bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801025c2:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801025c6:	7e 1c                	jle    801025e4 <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
801025c8:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801025cf:	00 
801025d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801025d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801025da:	89 04 24             	mov    %eax,(%esp)
801025dd:	e8 ff 2e 00 00       	call   801054e1 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801025e2:	eb 28                	jmp    8010260c <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801025e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025e7:	89 44 24 08          	mov    %eax,0x8(%esp)
801025eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025ee:	89 44 24 04          	mov    %eax,0x4(%esp)
801025f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801025f5:	89 04 24             	mov    %eax,(%esp)
801025f8:	e8 e4 2e 00 00       	call   801054e1 <memmove>
    name[len] = 0;
801025fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102600:	03 45 0c             	add    0xc(%ebp),%eax
80102603:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102606:	eb 04                	jmp    8010260c <skipelem+0xa3>
    path++;
80102608:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010260c:	8b 45 08             	mov    0x8(%ebp),%eax
8010260f:	0f b6 00             	movzbl (%eax),%eax
80102612:	3c 2f                	cmp    $0x2f,%al
80102614:	74 f2                	je     80102608 <skipelem+0x9f>
    path++;
  return path;
80102616:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102619:	c9                   	leave  
8010261a:	c3                   	ret    

8010261b <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010261b:	55                   	push   %ebp
8010261c:	89 e5                	mov    %esp,%ebp
8010261e:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102621:	8b 45 08             	mov    0x8(%ebp),%eax
80102624:	0f b6 00             	movzbl (%eax),%eax
80102627:	3c 2f                	cmp    $0x2f,%al
80102629:	75 1c                	jne    80102647 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
8010262b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102632:	00 
80102633:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010263a:	e8 4d f4 ff ff       	call   80101a8c <iget>
8010263f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102642:	e9 af 00 00 00       	jmp    801026f6 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102647:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010264d:	8b 40 68             	mov    0x68(%eax),%eax
80102650:	89 04 24             	mov    %eax,(%esp)
80102653:	e8 06 f5 ff ff       	call   80101b5e <idup>
80102658:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010265b:	e9 96 00 00 00       	jmp    801026f6 <namex+0xdb>
    ilock(ip);
80102660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102663:	89 04 24             	mov    %eax,(%esp)
80102666:	e8 25 f5 ff ff       	call   80101b90 <ilock>
    if(ip->type != T_DIR){
8010266b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010266e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102672:	66 83 f8 01          	cmp    $0x1,%ax
80102676:	74 15                	je     8010268d <namex+0x72>
      iunlockput(ip);
80102678:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010267b:	89 04 24             	mov    %eax,(%esp)
8010267e:	e8 91 f7 ff ff       	call   80101e14 <iunlockput>
      return 0;
80102683:	b8 00 00 00 00       	mov    $0x0,%eax
80102688:	e9 a3 00 00 00       	jmp    80102730 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
8010268d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102691:	74 1d                	je     801026b0 <namex+0x95>
80102693:	8b 45 08             	mov    0x8(%ebp),%eax
80102696:	0f b6 00             	movzbl (%eax),%eax
80102699:	84 c0                	test   %al,%al
8010269b:	75 13                	jne    801026b0 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
8010269d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026a0:	89 04 24             	mov    %eax,(%esp)
801026a3:	e8 36 f6 ff ff       	call   80101cde <iunlock>
      return ip;
801026a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026ab:	e9 80 00 00 00       	jmp    80102730 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801026b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801026b7:	00 
801026b8:	8b 45 10             	mov    0x10(%ebp),%eax
801026bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801026bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026c2:	89 04 24             	mov    %eax,(%esp)
801026c5:	e8 df fc ff ff       	call   801023a9 <dirlookup>
801026ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
801026cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801026d1:	75 12                	jne    801026e5 <namex+0xca>
      iunlockput(ip);
801026d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d6:	89 04 24             	mov    %eax,(%esp)
801026d9:	e8 36 f7 ff ff       	call   80101e14 <iunlockput>
      return 0;
801026de:	b8 00 00 00 00       	mov    $0x0,%eax
801026e3:	eb 4b                	jmp    80102730 <namex+0x115>
    }
    iunlockput(ip);
801026e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e8:	89 04 24             	mov    %eax,(%esp)
801026eb:	e8 24 f7 ff ff       	call   80101e14 <iunlockput>
    ip = next;
801026f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801026f6:	8b 45 10             	mov    0x10(%ebp),%eax
801026f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801026fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102700:	89 04 24             	mov    %eax,(%esp)
80102703:	e8 61 fe ff ff       	call   80102569 <skipelem>
80102708:	89 45 08             	mov    %eax,0x8(%ebp)
8010270b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010270f:	0f 85 4b ff ff ff    	jne    80102660 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102715:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102719:	74 12                	je     8010272d <namex+0x112>
    iput(ip);
8010271b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010271e:	89 04 24             	mov    %eax,(%esp)
80102721:	e8 1d f6 ff ff       	call   80101d43 <iput>
    return 0;
80102726:	b8 00 00 00 00       	mov    $0x0,%eax
8010272b:	eb 03                	jmp    80102730 <namex+0x115>
  }
  return ip;
8010272d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102730:	c9                   	leave  
80102731:	c3                   	ret    

80102732 <namei>:

struct inode*
namei(char *path)
{
80102732:	55                   	push   %ebp
80102733:	89 e5                	mov    %esp,%ebp
80102735:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102738:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010273b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010273f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102746:	00 
80102747:	8b 45 08             	mov    0x8(%ebp),%eax
8010274a:	89 04 24             	mov    %eax,(%esp)
8010274d:	e8 c9 fe ff ff       	call   8010261b <namex>
}
80102752:	c9                   	leave  
80102753:	c3                   	ret    

80102754 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102754:	55                   	push   %ebp
80102755:	89 e5                	mov    %esp,%ebp
80102757:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010275a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010275d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102761:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102768:	00 
80102769:	8b 45 08             	mov    0x8(%ebp),%eax
8010276c:	89 04 24             	mov    %eax,(%esp)
8010276f:	e8 a7 fe ff ff       	call   8010261b <namex>
}
80102774:	c9                   	leave  
80102775:	c3                   	ret    
	...

80102778 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102778:	55                   	push   %ebp
80102779:	89 e5                	mov    %esp,%ebp
8010277b:	53                   	push   %ebx
8010277c:	83 ec 14             	sub    $0x14,%esp
8010277f:	8b 45 08             	mov    0x8(%ebp),%eax
80102782:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102786:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010278a:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
8010278e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102792:	ec                   	in     (%dx),%al
80102793:	89 c3                	mov    %eax,%ebx
80102795:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102798:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
8010279c:	83 c4 14             	add    $0x14,%esp
8010279f:	5b                   	pop    %ebx
801027a0:	5d                   	pop    %ebp
801027a1:	c3                   	ret    

801027a2 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801027a2:	55                   	push   %ebp
801027a3:	89 e5                	mov    %esp,%ebp
801027a5:	57                   	push   %edi
801027a6:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801027a7:	8b 55 08             	mov    0x8(%ebp),%edx
801027aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801027ad:	8b 45 10             	mov    0x10(%ebp),%eax
801027b0:	89 cb                	mov    %ecx,%ebx
801027b2:	89 df                	mov    %ebx,%edi
801027b4:	89 c1                	mov    %eax,%ecx
801027b6:	fc                   	cld    
801027b7:	f3 6d                	rep insl (%dx),%es:(%edi)
801027b9:	89 c8                	mov    %ecx,%eax
801027bb:	89 fb                	mov    %edi,%ebx
801027bd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801027c0:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801027c3:	5b                   	pop    %ebx
801027c4:	5f                   	pop    %edi
801027c5:	5d                   	pop    %ebp
801027c6:	c3                   	ret    

801027c7 <outb>:

static inline void
outb(ushort port, uchar data)
{
801027c7:	55                   	push   %ebp
801027c8:	89 e5                	mov    %esp,%ebp
801027ca:	83 ec 08             	sub    $0x8,%esp
801027cd:	8b 55 08             	mov    0x8(%ebp),%edx
801027d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801027d3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801027d7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801027da:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801027de:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801027e2:	ee                   	out    %al,(%dx)
}
801027e3:	c9                   	leave  
801027e4:	c3                   	ret    

801027e5 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801027e5:	55                   	push   %ebp
801027e6:	89 e5                	mov    %esp,%ebp
801027e8:	56                   	push   %esi
801027e9:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801027ea:	8b 55 08             	mov    0x8(%ebp),%edx
801027ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801027f0:	8b 45 10             	mov    0x10(%ebp),%eax
801027f3:	89 cb                	mov    %ecx,%ebx
801027f5:	89 de                	mov    %ebx,%esi
801027f7:	89 c1                	mov    %eax,%ecx
801027f9:	fc                   	cld    
801027fa:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801027fc:	89 c8                	mov    %ecx,%eax
801027fe:	89 f3                	mov    %esi,%ebx
80102800:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102803:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102806:	5b                   	pop    %ebx
80102807:	5e                   	pop    %esi
80102808:	5d                   	pop    %ebp
80102809:	c3                   	ret    

8010280a <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010280a:	55                   	push   %ebp
8010280b:	89 e5                	mov    %esp,%ebp
8010280d:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102810:	90                   	nop
80102811:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102818:	e8 5b ff ff ff       	call   80102778 <inb>
8010281d:	0f b6 c0             	movzbl %al,%eax
80102820:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102823:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102826:	25 c0 00 00 00       	and    $0xc0,%eax
8010282b:	83 f8 40             	cmp    $0x40,%eax
8010282e:	75 e1                	jne    80102811 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102830:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102834:	74 11                	je     80102847 <idewait+0x3d>
80102836:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102839:	83 e0 21             	and    $0x21,%eax
8010283c:	85 c0                	test   %eax,%eax
8010283e:	74 07                	je     80102847 <idewait+0x3d>
    return -1;
80102840:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102845:	eb 05                	jmp    8010284c <idewait+0x42>
  return 0;
80102847:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010284c:	c9                   	leave  
8010284d:	c3                   	ret    

8010284e <ideinit>:

void
ideinit(void)
{
8010284e:	55                   	push   %ebp
8010284f:	89 e5                	mov    %esp,%ebp
80102851:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102854:	c7 44 24 04 b4 89 10 	movl   $0x801089b4,0x4(%esp)
8010285b:	80 
8010285c:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102863:	e8 36 29 00 00       	call   8010519e <initlock>
  picenable(IRQ_IDE);
80102868:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010286f:	e8 75 15 00 00       	call   80103de9 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102874:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80102879:	83 e8 01             	sub    $0x1,%eax
8010287c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102880:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102887:	e8 12 04 00 00       	call   80102c9e <ioapicenable>
  idewait(0);
8010288c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102893:	e8 72 ff ff ff       	call   8010280a <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102898:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
8010289f:	00 
801028a0:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028a7:	e8 1b ff ff ff       	call   801027c7 <outb>
  for(i=0; i<1000; i++){
801028ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801028b3:	eb 20                	jmp    801028d5 <ideinit+0x87>
    if(inb(0x1f7) != 0){
801028b5:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801028bc:	e8 b7 fe ff ff       	call   80102778 <inb>
801028c1:	84 c0                	test   %al,%al
801028c3:	74 0c                	je     801028d1 <ideinit+0x83>
      havedisk1 = 1;
801028c5:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
801028cc:	00 00 00 
      break;
801028cf:	eb 0d                	jmp    801028de <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801028d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801028d5:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801028dc:	7e d7                	jle    801028b5 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801028de:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801028e5:	00 
801028e6:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028ed:	e8 d5 fe ff ff       	call   801027c7 <outb>
}
801028f2:	c9                   	leave  
801028f3:	c3                   	ret    

801028f4 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801028f4:	55                   	push   %ebp
801028f5:	89 e5                	mov    %esp,%ebp
801028f7:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801028fa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801028fe:	75 0c                	jne    8010290c <idestart+0x18>
    panic("idestart");
80102900:	c7 04 24 b8 89 10 80 	movl   $0x801089b8,(%esp)
80102907:	e8 31 dc ff ff       	call   8010053d <panic>

  idewait(0);
8010290c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102913:	e8 f2 fe ff ff       	call   8010280a <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102918:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010291f:	00 
80102920:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102927:	e8 9b fe ff ff       	call   801027c7 <outb>
  outb(0x1f2, 1);  // number of sectors
8010292c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102933:	00 
80102934:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
8010293b:	e8 87 fe ff ff       	call   801027c7 <outb>
  outb(0x1f3, b->sector & 0xff);
80102940:	8b 45 08             	mov    0x8(%ebp),%eax
80102943:	8b 40 08             	mov    0x8(%eax),%eax
80102946:	0f b6 c0             	movzbl %al,%eax
80102949:	89 44 24 04          	mov    %eax,0x4(%esp)
8010294d:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102954:	e8 6e fe ff ff       	call   801027c7 <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
80102959:	8b 45 08             	mov    0x8(%ebp),%eax
8010295c:	8b 40 08             	mov    0x8(%eax),%eax
8010295f:	c1 e8 08             	shr    $0x8,%eax
80102962:	0f b6 c0             	movzbl %al,%eax
80102965:	89 44 24 04          	mov    %eax,0x4(%esp)
80102969:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102970:	e8 52 fe ff ff       	call   801027c7 <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102975:	8b 45 08             	mov    0x8(%ebp),%eax
80102978:	8b 40 08             	mov    0x8(%eax),%eax
8010297b:	c1 e8 10             	shr    $0x10,%eax
8010297e:	0f b6 c0             	movzbl %al,%eax
80102981:	89 44 24 04          	mov    %eax,0x4(%esp)
80102985:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
8010298c:	e8 36 fe ff ff       	call   801027c7 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102991:	8b 45 08             	mov    0x8(%ebp),%eax
80102994:	8b 40 04             	mov    0x4(%eax),%eax
80102997:	83 e0 01             	and    $0x1,%eax
8010299a:	89 c2                	mov    %eax,%edx
8010299c:	c1 e2 04             	shl    $0x4,%edx
8010299f:	8b 45 08             	mov    0x8(%ebp),%eax
801029a2:	8b 40 08             	mov    0x8(%eax),%eax
801029a5:	c1 e8 18             	shr    $0x18,%eax
801029a8:	83 e0 0f             	and    $0xf,%eax
801029ab:	09 d0                	or     %edx,%eax
801029ad:	83 c8 e0             	or     $0xffffffe0,%eax
801029b0:	0f b6 c0             	movzbl %al,%eax
801029b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801029b7:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801029be:	e8 04 fe ff ff       	call   801027c7 <outb>
  if(b->flags & B_DIRTY){
801029c3:	8b 45 08             	mov    0x8(%ebp),%eax
801029c6:	8b 00                	mov    (%eax),%eax
801029c8:	83 e0 04             	and    $0x4,%eax
801029cb:	85 c0                	test   %eax,%eax
801029cd:	74 34                	je     80102a03 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
801029cf:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801029d6:	00 
801029d7:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801029de:	e8 e4 fd ff ff       	call   801027c7 <outb>
    outsl(0x1f0, b->data, 512/4);
801029e3:	8b 45 08             	mov    0x8(%ebp),%eax
801029e6:	83 c0 18             	add    $0x18,%eax
801029e9:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801029f0:	00 
801029f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801029f5:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801029fc:	e8 e4 fd ff ff       	call   801027e5 <outsl>
80102a01:	eb 14                	jmp    80102a17 <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102a03:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102a0a:	00 
80102a0b:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a12:	e8 b0 fd ff ff       	call   801027c7 <outb>
  }
}
80102a17:	c9                   	leave  
80102a18:	c3                   	ret    

80102a19 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102a19:	55                   	push   %ebp
80102a1a:	89 e5                	mov    %esp,%ebp
80102a1c:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a1f:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102a26:	e8 94 27 00 00       	call   801051bf <acquire>
  if((b = idequeue) == 0){
80102a2b:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102a30:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a33:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a37:	75 11                	jne    80102a4a <ideintr+0x31>
    release(&idelock);
80102a39:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102a40:	e8 dc 27 00 00       	call   80105221 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102a45:	e9 90 00 00 00       	jmp    80102ada <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a4d:	8b 40 14             	mov    0x14(%eax),%eax
80102a50:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a58:	8b 00                	mov    (%eax),%eax
80102a5a:	83 e0 04             	and    $0x4,%eax
80102a5d:	85 c0                	test   %eax,%eax
80102a5f:	75 2e                	jne    80102a8f <ideintr+0x76>
80102a61:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102a68:	e8 9d fd ff ff       	call   8010280a <idewait>
80102a6d:	85 c0                	test   %eax,%eax
80102a6f:	78 1e                	js     80102a8f <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a74:	83 c0 18             	add    $0x18,%eax
80102a77:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102a7e:	00 
80102a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a83:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102a8a:	e8 13 fd ff ff       	call   801027a2 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a92:	8b 00                	mov    (%eax),%eax
80102a94:	89 c2                	mov    %eax,%edx
80102a96:	83 ca 02             	or     $0x2,%edx
80102a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a9c:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa1:	8b 00                	mov    (%eax),%eax
80102aa3:	89 c2                	mov    %eax,%edx
80102aa5:	83 e2 fb             	and    $0xfffffffb,%edx
80102aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aab:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab0:	89 04 24             	mov    %eax,(%esp)
80102ab3:	e8 7a 24 00 00       	call   80104f32 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102ab8:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102abd:	85 c0                	test   %eax,%eax
80102abf:	74 0d                	je     80102ace <ideintr+0xb5>
    idestart(idequeue);
80102ac1:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102ac6:	89 04 24             	mov    %eax,(%esp)
80102ac9:	e8 26 fe ff ff       	call   801028f4 <idestart>

  release(&idelock);
80102ace:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102ad5:	e8 47 27 00 00       	call   80105221 <release>
}
80102ada:	c9                   	leave  
80102adb:	c3                   	ret    

80102adc <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102adc:	55                   	push   %ebp
80102add:	89 e5                	mov    %esp,%ebp
80102adf:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae5:	8b 00                	mov    (%eax),%eax
80102ae7:	83 e0 01             	and    $0x1,%eax
80102aea:	85 c0                	test   %eax,%eax
80102aec:	75 0c                	jne    80102afa <iderw+0x1e>
    panic("iderw: buf not busy");
80102aee:	c7 04 24 c1 89 10 80 	movl   $0x801089c1,(%esp)
80102af5:	e8 43 da ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102afa:	8b 45 08             	mov    0x8(%ebp),%eax
80102afd:	8b 00                	mov    (%eax),%eax
80102aff:	83 e0 06             	and    $0x6,%eax
80102b02:	83 f8 02             	cmp    $0x2,%eax
80102b05:	75 0c                	jne    80102b13 <iderw+0x37>
    panic("iderw: nothing to do");
80102b07:	c7 04 24 d5 89 10 80 	movl   $0x801089d5,(%esp)
80102b0e:	e8 2a da ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
80102b13:	8b 45 08             	mov    0x8(%ebp),%eax
80102b16:	8b 40 04             	mov    0x4(%eax),%eax
80102b19:	85 c0                	test   %eax,%eax
80102b1b:	74 15                	je     80102b32 <iderw+0x56>
80102b1d:	a1 38 b6 10 80       	mov    0x8010b638,%eax
80102b22:	85 c0                	test   %eax,%eax
80102b24:	75 0c                	jne    80102b32 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80102b26:	c7 04 24 ea 89 10 80 	movl   $0x801089ea,(%esp)
80102b2d:	e8 0b da ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC: acquire-lock
80102b32:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102b39:	e8 81 26 00 00       	call   801051bf <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80102b41:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC: insert-queue
80102b48:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102b4f:	eb 0b                	jmp    80102b5c <iderw+0x80>
80102b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b54:	8b 00                	mov    (%eax),%eax
80102b56:	83 c0 14             	add    $0x14,%eax
80102b59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b5f:	8b 00                	mov    (%eax),%eax
80102b61:	85 c0                	test   %eax,%eax
80102b63:	75 ec                	jne    80102b51 <iderw+0x75>
    ;
  *pp = b;
80102b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b68:	8b 55 08             	mov    0x8(%ebp),%edx
80102b6b:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102b6d:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102b72:	3b 45 08             	cmp    0x8(%ebp),%eax
80102b75:	75 22                	jne    80102b99 <iderw+0xbd>
    idestart(b);
80102b77:	8b 45 08             	mov    0x8(%ebp),%eax
80102b7a:	89 04 24             	mov    %eax,(%esp)
80102b7d:	e8 72 fd ff ff       	call   801028f4 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b82:	eb 15                	jmp    80102b99 <iderw+0xbd>
    sleep(b, &idelock);
80102b84:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
80102b8b:	80 
80102b8c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b8f:	89 04 24             	mov    %eax,(%esp)
80102b92:	e8 bf 22 00 00       	call   80104e56 <sleep>
80102b97:	eb 01                	jmp    80102b9a <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b99:	90                   	nop
80102b9a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b9d:	8b 00                	mov    (%eax),%eax
80102b9f:	83 e0 06             	and    $0x6,%eax
80102ba2:	83 f8 02             	cmp    $0x2,%eax
80102ba5:	75 dd                	jne    80102b84 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
80102ba7:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102bae:	e8 6e 26 00 00       	call   80105221 <release>
}
80102bb3:	c9                   	leave  
80102bb4:	c3                   	ret    
80102bb5:	00 00                	add    %al,(%eax)
	...

80102bb8 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102bb8:	55                   	push   %ebp
80102bb9:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bbb:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102bc0:	8b 55 08             	mov    0x8(%ebp),%edx
80102bc3:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102bc5:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102bca:	8b 40 10             	mov    0x10(%eax),%eax
}
80102bcd:	5d                   	pop    %ebp
80102bce:	c3                   	ret    

80102bcf <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102bcf:	55                   	push   %ebp
80102bd0:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bd2:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102bd7:	8b 55 08             	mov    0x8(%ebp),%edx
80102bda:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102bdc:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102be1:	8b 55 0c             	mov    0xc(%ebp),%edx
80102be4:	89 50 10             	mov    %edx,0x10(%eax)
}
80102be7:	5d                   	pop    %ebp
80102be8:	c3                   	ret    

80102be9 <ioapicinit>:

void
ioapicinit(void)
{
80102be9:	55                   	push   %ebp
80102bea:	89 e5                	mov    %esp,%ebp
80102bec:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102bef:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102bf4:	85 c0                	test   %eax,%eax
80102bf6:	0f 84 9f 00 00 00    	je     80102c9b <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102bfc:	c7 05 54 f8 10 80 00 	movl   $0xfec00000,0x8010f854
80102c03:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c06:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102c0d:	e8 a6 ff ff ff       	call   80102bb8 <ioapicread>
80102c12:	c1 e8 10             	shr    $0x10,%eax
80102c15:	25 ff 00 00 00       	and    $0xff,%eax
80102c1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102c24:	e8 8f ff ff ff       	call   80102bb8 <ioapicread>
80102c29:	c1 e8 18             	shr    $0x18,%eax
80102c2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c2f:	0f b6 05 20 f9 10 80 	movzbl 0x8010f920,%eax
80102c36:	0f b6 c0             	movzbl %al,%eax
80102c39:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102c3c:	74 0c                	je     80102c4a <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c3e:	c7 04 24 08 8a 10 80 	movl   $0x80108a08,(%esp)
80102c45:	e8 57 d7 ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c51:	eb 3e                	jmp    80102c91 <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c56:	83 c0 20             	add    $0x20,%eax
80102c59:	0d 00 00 01 00       	or     $0x10000,%eax
80102c5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102c61:	83 c2 08             	add    $0x8,%edx
80102c64:	01 d2                	add    %edx,%edx
80102c66:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c6a:	89 14 24             	mov    %edx,(%esp)
80102c6d:	e8 5d ff ff ff       	call   80102bcf <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c75:	83 c0 08             	add    $0x8,%eax
80102c78:	01 c0                	add    %eax,%eax
80102c7a:	83 c0 01             	add    $0x1,%eax
80102c7d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102c84:	00 
80102c85:	89 04 24             	mov    %eax,(%esp)
80102c88:	e8 42 ff ff ff       	call   80102bcf <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c8d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102c91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c94:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102c97:	7e ba                	jle    80102c53 <ioapicinit+0x6a>
80102c99:	eb 01                	jmp    80102c9c <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102c9b:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102c9c:	c9                   	leave  
80102c9d:	c3                   	ret    

80102c9e <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102c9e:	55                   	push   %ebp
80102c9f:	89 e5                	mov    %esp,%ebp
80102ca1:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102ca4:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102ca9:	85 c0                	test   %eax,%eax
80102cab:	74 39                	je     80102ce6 <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102cad:	8b 45 08             	mov    0x8(%ebp),%eax
80102cb0:	83 c0 20             	add    $0x20,%eax
80102cb3:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb6:	83 c2 08             	add    $0x8,%edx
80102cb9:	01 d2                	add    %edx,%edx
80102cbb:	89 44 24 04          	mov    %eax,0x4(%esp)
80102cbf:	89 14 24             	mov    %edx,(%esp)
80102cc2:	e8 08 ff ff ff       	call   80102bcf <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cca:	c1 e0 18             	shl    $0x18,%eax
80102ccd:	8b 55 08             	mov    0x8(%ebp),%edx
80102cd0:	83 c2 08             	add    $0x8,%edx
80102cd3:	01 d2                	add    %edx,%edx
80102cd5:	83 c2 01             	add    $0x1,%edx
80102cd8:	89 44 24 04          	mov    %eax,0x4(%esp)
80102cdc:	89 14 24             	mov    %edx,(%esp)
80102cdf:	e8 eb fe ff ff       	call   80102bcf <ioapicwrite>
80102ce4:	eb 01                	jmp    80102ce7 <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102ce6:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102ce7:	c9                   	leave  
80102ce8:	c3                   	ret    
80102ce9:	00 00                	add    %al,(%eax)
	...

80102cec <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102cec:	55                   	push   %ebp
80102ced:	89 e5                	mov    %esp,%ebp
80102cef:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf2:	05 00 00 00 80       	add    $0x80000000,%eax
80102cf7:	5d                   	pop    %ebp
80102cf8:	c3                   	ret    

80102cf9 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102cf9:	55                   	push   %ebp
80102cfa:	89 e5                	mov    %esp,%ebp
80102cfc:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102cff:	c7 44 24 04 3a 8a 10 	movl   $0x80108a3a,0x4(%esp)
80102d06:	80 
80102d07:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102d0e:	e8 8b 24 00 00       	call   8010519e <initlock>
  kmem.use_lock = 0;
80102d13:	c7 05 94 f8 10 80 00 	movl   $0x0,0x8010f894
80102d1a:	00 00 00 
  freerange(vstart, vend);
80102d1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d20:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d24:	8b 45 08             	mov    0x8(%ebp),%eax
80102d27:	89 04 24             	mov    %eax,(%esp)
80102d2a:	e8 26 00 00 00       	call   80102d55 <freerange>
}
80102d2f:	c9                   	leave  
80102d30:	c3                   	ret    

80102d31 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d31:	55                   	push   %ebp
80102d32:	89 e5                	mov    %esp,%ebp
80102d34:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102d37:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d3a:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d3e:	8b 45 08             	mov    0x8(%ebp),%eax
80102d41:	89 04 24             	mov    %eax,(%esp)
80102d44:	e8 0c 00 00 00       	call   80102d55 <freerange>
  kmem.use_lock = 1;
80102d49:	c7 05 94 f8 10 80 01 	movl   $0x1,0x8010f894
80102d50:	00 00 00 
}
80102d53:	c9                   	leave  
80102d54:	c3                   	ret    

80102d55 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d55:	55                   	push   %ebp
80102d56:	89 e5                	mov    %esp,%ebp
80102d58:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d5b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d5e:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d63:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d68:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d6b:	eb 12                	jmp    80102d7f <freerange+0x2a>
    kfree(p);
80102d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d70:	89 04 24             	mov    %eax,(%esp)
80102d73:	e8 16 00 00 00       	call   80102d8e <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d78:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d82:	05 00 10 00 00       	add    $0x1000,%eax
80102d87:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102d8a:	76 e1                	jbe    80102d6d <freerange+0x18>
    kfree(p);
}
80102d8c:	c9                   	leave  
80102d8d:	c3                   	ret    

80102d8e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102d8e:	55                   	push   %ebp
80102d8f:	89 e5                	mov    %esp,%ebp
80102d91:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102d94:	8b 45 08             	mov    0x8(%ebp),%eax
80102d97:	25 ff 0f 00 00       	and    $0xfff,%eax
80102d9c:	85 c0                	test   %eax,%eax
80102d9e:	75 1b                	jne    80102dbb <kfree+0x2d>
80102da0:	81 7d 08 1c 2d 11 80 	cmpl   $0x80112d1c,0x8(%ebp)
80102da7:	72 12                	jb     80102dbb <kfree+0x2d>
80102da9:	8b 45 08             	mov    0x8(%ebp),%eax
80102dac:	89 04 24             	mov    %eax,(%esp)
80102daf:	e8 38 ff ff ff       	call   80102cec <v2p>
80102db4:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102db9:	76 0c                	jbe    80102dc7 <kfree+0x39>
    panic("kfree");
80102dbb:	c7 04 24 3f 8a 10 80 	movl   $0x80108a3f,(%esp)
80102dc2:	e8 76 d7 ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102dc7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102dce:	00 
80102dcf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102dd6:	00 
80102dd7:	8b 45 08             	mov    0x8(%ebp),%eax
80102dda:	89 04 24             	mov    %eax,(%esp)
80102ddd:	e8 2c 26 00 00       	call   8010540e <memset>

  if(kmem.use_lock)
80102de2:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102de7:	85 c0                	test   %eax,%eax
80102de9:	74 0c                	je     80102df7 <kfree+0x69>
    acquire(&kmem.lock);
80102deb:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102df2:	e8 c8 23 00 00       	call   801051bf <acquire>
  r = (struct run*)v;
80102df7:	8b 45 08             	mov    0x8(%ebp),%eax
80102dfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102dfd:	8b 15 98 f8 10 80    	mov    0x8010f898,%edx
80102e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e06:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e0b:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102e10:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e15:	85 c0                	test   %eax,%eax
80102e17:	74 0c                	je     80102e25 <kfree+0x97>
    release(&kmem.lock);
80102e19:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e20:	e8 fc 23 00 00       	call   80105221 <release>
}
80102e25:	c9                   	leave  
80102e26:	c3                   	ret    

80102e27 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e27:	55                   	push   %ebp
80102e28:	89 e5                	mov    %esp,%ebp
80102e2a:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102e2d:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e32:	85 c0                	test   %eax,%eax
80102e34:	74 0c                	je     80102e42 <kalloc+0x1b>
    acquire(&kmem.lock);
80102e36:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e3d:	e8 7d 23 00 00       	call   801051bf <acquire>
  r = kmem.freelist;
80102e42:	a1 98 f8 10 80       	mov    0x8010f898,%eax
80102e47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e4e:	74 0a                	je     80102e5a <kalloc+0x33>
    kmem.freelist = r->next;
80102e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e53:	8b 00                	mov    (%eax),%eax
80102e55:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102e5a:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e5f:	85 c0                	test   %eax,%eax
80102e61:	74 0c                	je     80102e6f <kalloc+0x48>
    release(&kmem.lock);
80102e63:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e6a:	e8 b2 23 00 00       	call   80105221 <release>
  return (char*)r;
80102e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102e72:	c9                   	leave  
80102e73:	c3                   	ret    

80102e74 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e74:	55                   	push   %ebp
80102e75:	89 e5                	mov    %esp,%ebp
80102e77:	53                   	push   %ebx
80102e78:	83 ec 14             	sub    $0x14,%esp
80102e7b:	8b 45 08             	mov    0x8(%ebp),%eax
80102e7e:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e82:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102e86:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102e8a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102e8e:	ec                   	in     (%dx),%al
80102e8f:	89 c3                	mov    %eax,%ebx
80102e91:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102e94:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102e98:	83 c4 14             	add    $0x14,%esp
80102e9b:	5b                   	pop    %ebx
80102e9c:	5d                   	pop    %ebp
80102e9d:	c3                   	ret    

80102e9e <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102e9e:	55                   	push   %ebp
80102e9f:	89 e5                	mov    %esp,%ebp
80102ea1:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102ea4:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102eab:	e8 c4 ff ff ff       	call   80102e74 <inb>
80102eb0:	0f b6 c0             	movzbl %al,%eax
80102eb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102eb9:	83 e0 01             	and    $0x1,%eax
80102ebc:	85 c0                	test   %eax,%eax
80102ebe:	75 0a                	jne    80102eca <kbdgetc+0x2c>
    return -1;
80102ec0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ec5:	e9 23 01 00 00       	jmp    80102fed <kbdgetc+0x14f>
  data = inb(KBDATAP);
80102eca:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102ed1:	e8 9e ff ff ff       	call   80102e74 <inb>
80102ed6:	0f b6 c0             	movzbl %al,%eax
80102ed9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    
  if(data == 0xE0){
80102edc:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102ee3:	75 17                	jne    80102efc <kbdgetc+0x5e>
    shift |= E0ESC;
80102ee5:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102eea:	83 c8 40             	or     $0x40,%eax
80102eed:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102ef2:	b8 00 00 00 00       	mov    $0x0,%eax
80102ef7:	e9 f1 00 00 00       	jmp    80102fed <kbdgetc+0x14f>
  } else if(data & 0x80){
80102efc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102eff:	25 80 00 00 00       	and    $0x80,%eax
80102f04:	85 c0                	test   %eax,%eax
80102f06:	74 45                	je     80102f4d <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102f08:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f0d:	83 e0 40             	and    $0x40,%eax
80102f10:	85 c0                	test   %eax,%eax
80102f12:	75 08                	jne    80102f1c <kbdgetc+0x7e>
80102f14:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f17:	83 e0 7f             	and    $0x7f,%eax
80102f1a:	eb 03                	jmp    80102f1f <kbdgetc+0x81>
80102f1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f1f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f22:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f25:	05 20 90 10 80       	add    $0x80109020,%eax
80102f2a:	0f b6 00             	movzbl (%eax),%eax
80102f2d:	83 c8 40             	or     $0x40,%eax
80102f30:	0f b6 c0             	movzbl %al,%eax
80102f33:	f7 d0                	not    %eax
80102f35:	89 c2                	mov    %eax,%edx
80102f37:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f3c:	21 d0                	and    %edx,%eax
80102f3e:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102f43:	b8 00 00 00 00       	mov    $0x0,%eax
80102f48:	e9 a0 00 00 00       	jmp    80102fed <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80102f4d:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f52:	83 e0 40             	and    $0x40,%eax
80102f55:	85 c0                	test   %eax,%eax
80102f57:	74 14                	je     80102f6d <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f59:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f60:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f65:	83 e0 bf             	and    $0xffffffbf,%eax
80102f68:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102f6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f70:	05 20 90 10 80       	add    $0x80109020,%eax
80102f75:	0f b6 00             	movzbl (%eax),%eax
80102f78:	0f b6 d0             	movzbl %al,%edx
80102f7b:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f80:	09 d0                	or     %edx,%eax
80102f82:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102f87:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f8a:	05 20 91 10 80       	add    $0x80109120,%eax
80102f8f:	0f b6 00             	movzbl (%eax),%eax
80102f92:	0f b6 d0             	movzbl %al,%edx
80102f95:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f9a:	31 d0                	xor    %edx,%eax
80102f9c:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102fa1:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fa6:	83 e0 03             	and    $0x3,%eax
80102fa9:	8b 04 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%eax
80102fb0:	03 45 fc             	add    -0x4(%ebp),%eax
80102fb3:	0f b6 00             	movzbl (%eax),%eax
80102fb6:	0f b6 c0             	movzbl %al,%eax
80102fb9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102fbc:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fc1:	83 e0 08             	and    $0x8,%eax
80102fc4:	85 c0                	test   %eax,%eax
80102fc6:	74 22                	je     80102fea <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
80102fc8:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102fcc:	76 0c                	jbe    80102fda <kbdgetc+0x13c>
80102fce:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102fd2:	77 06                	ja     80102fda <kbdgetc+0x13c>
      c += 'A' - 'a';
80102fd4:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102fd8:	eb 10                	jmp    80102fea <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
80102fda:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102fde:	76 0a                	jbe    80102fea <kbdgetc+0x14c>
80102fe0:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102fe4:	77 04                	ja     80102fea <kbdgetc+0x14c>
      c += 'a' - 'A';
80102fe6:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102fea:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102fed:	c9                   	leave  
80102fee:	c3                   	ret    

80102fef <kbdintr>:

void
kbdintr(void)
{
80102fef:	55                   	push   %ebp
80102ff0:	89 e5                	mov    %esp,%ebp
80102ff2:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102ff5:	c7 04 24 9e 2e 10 80 	movl   $0x80102e9e,(%esp)
80102ffc:	e8 6b d8 ff ff       	call   8010086c <consoleintr>
}
80103001:	c9                   	leave  
80103002:	c3                   	ret    
	...

80103004 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103004:	55                   	push   %ebp
80103005:	89 e5                	mov    %esp,%ebp
80103007:	83 ec 08             	sub    $0x8,%esp
8010300a:	8b 55 08             	mov    0x8(%ebp),%edx
8010300d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103010:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103014:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103017:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010301b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010301f:	ee                   	out    %al,(%dx)
}
80103020:	c9                   	leave  
80103021:	c3                   	ret    

80103022 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103022:	55                   	push   %ebp
80103023:	89 e5                	mov    %esp,%ebp
80103025:	53                   	push   %ebx
80103026:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103029:	9c                   	pushf  
8010302a:	5b                   	pop    %ebx
8010302b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
8010302e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103031:	83 c4 10             	add    $0x10,%esp
80103034:	5b                   	pop    %ebx
80103035:	5d                   	pop    %ebp
80103036:	c3                   	ret    

80103037 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103037:	55                   	push   %ebp
80103038:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010303a:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
8010303f:	8b 55 08             	mov    0x8(%ebp),%edx
80103042:	c1 e2 02             	shl    $0x2,%edx
80103045:	01 c2                	add    %eax,%edx
80103047:	8b 45 0c             	mov    0xc(%ebp),%eax
8010304a:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
8010304c:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103051:	83 c0 20             	add    $0x20,%eax
80103054:	8b 00                	mov    (%eax),%eax
}
80103056:	5d                   	pop    %ebp
80103057:	c3                   	ret    

80103058 <lapicinit>:
//PAGEBREAK!

void
lapicinit(int c)
{
80103058:	55                   	push   %ebp
80103059:	89 e5                	mov    %esp,%ebp
8010305b:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
8010305e:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103063:	85 c0                	test   %eax,%eax
80103065:	0f 84 47 01 00 00    	je     801031b2 <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
8010306b:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80103072:	00 
80103073:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
8010307a:	e8 b8 ff ff ff       	call   80103037 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
8010307f:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80103086:	00 
80103087:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
8010308e:	e8 a4 ff ff ff       	call   80103037 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103093:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
8010309a:	00 
8010309b:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030a2:	e8 90 ff ff ff       	call   80103037 <lapicw>
  lapicw(TICR, 10000000); 
801030a7:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
801030ae:	00 
801030af:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
801030b6:	e8 7c ff ff ff       	call   80103037 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801030bb:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801030c2:	00 
801030c3:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
801030ca:	e8 68 ff ff ff       	call   80103037 <lapicw>
  lapicw(LINT1, MASKED);
801030cf:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801030d6:	00 
801030d7:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
801030de:	e8 54 ff ff ff       	call   80103037 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801030e3:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
801030e8:	83 c0 30             	add    $0x30,%eax
801030eb:	8b 00                	mov    (%eax),%eax
801030ed:	c1 e8 10             	shr    $0x10,%eax
801030f0:	25 ff 00 00 00       	and    $0xff,%eax
801030f5:	83 f8 03             	cmp    $0x3,%eax
801030f8:	76 14                	jbe    8010310e <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
801030fa:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103101:	00 
80103102:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80103109:	e8 29 ff ff ff       	call   80103037 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010310e:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80103115:	00 
80103116:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
8010311d:	e8 15 ff ff ff       	call   80103037 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103122:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103129:	00 
8010312a:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103131:	e8 01 ff ff ff       	call   80103037 <lapicw>
  lapicw(ESR, 0);
80103136:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010313d:	00 
8010313e:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103145:	e8 ed fe ff ff       	call   80103037 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010314a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103151:	00 
80103152:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103159:	e8 d9 fe ff ff       	call   80103037 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010315e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103165:	00 
80103166:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010316d:	e8 c5 fe ff ff       	call   80103037 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103172:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80103179:	00 
8010317a:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103181:	e8 b1 fe ff ff       	call   80103037 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80103186:	90                   	nop
80103187:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
8010318c:	05 00 03 00 00       	add    $0x300,%eax
80103191:	8b 00                	mov    (%eax),%eax
80103193:	25 00 10 00 00       	and    $0x1000,%eax
80103198:	85 c0                	test   %eax,%eax
8010319a:	75 eb                	jne    80103187 <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010319c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031a3:	00 
801031a4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801031ab:	e8 87 fe ff ff       	call   80103037 <lapicw>
801031b0:	eb 01                	jmp    801031b3 <lapicinit+0x15b>

void
lapicinit(int c)
{
  if(!lapic) 
    return;
801031b2:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801031b3:	c9                   	leave  
801031b4:	c3                   	ret    

801031b5 <cpunum>:

int
cpunum(void)
{
801031b5:	55                   	push   %ebp
801031b6:	89 e5                	mov    %esp,%ebp
801031b8:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801031bb:	e8 62 fe ff ff       	call   80103022 <readeflags>
801031c0:	25 00 02 00 00       	and    $0x200,%eax
801031c5:	85 c0                	test   %eax,%eax
801031c7:	74 29                	je     801031f2 <cpunum+0x3d>
    static int n;
    if(n++ == 0)
801031c9:	a1 40 b6 10 80       	mov    0x8010b640,%eax
801031ce:	85 c0                	test   %eax,%eax
801031d0:	0f 94 c2             	sete   %dl
801031d3:	83 c0 01             	add    $0x1,%eax
801031d6:	a3 40 b6 10 80       	mov    %eax,0x8010b640
801031db:	84 d2                	test   %dl,%dl
801031dd:	74 13                	je     801031f2 <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
801031df:	8b 45 04             	mov    0x4(%ebp),%eax
801031e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801031e6:	c7 04 24 48 8a 10 80 	movl   $0x80108a48,(%esp)
801031ed:	e8 af d1 ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
801031f2:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
801031f7:	85 c0                	test   %eax,%eax
801031f9:	74 0f                	je     8010320a <cpunum+0x55>
    return lapic[ID]>>24;
801031fb:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103200:	83 c0 20             	add    $0x20,%eax
80103203:	8b 00                	mov    (%eax),%eax
80103205:	c1 e8 18             	shr    $0x18,%eax
80103208:	eb 05                	jmp    8010320f <cpunum+0x5a>
  return 0;
8010320a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010320f:	c9                   	leave  
80103210:	c3                   	ret    

80103211 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103211:	55                   	push   %ebp
80103212:	89 e5                	mov    %esp,%ebp
80103214:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103217:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
8010321c:	85 c0                	test   %eax,%eax
8010321e:	74 14                	je     80103234 <lapiceoi+0x23>
    lapicw(EOI, 0);
80103220:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103227:	00 
80103228:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
8010322f:	e8 03 fe ff ff       	call   80103037 <lapicw>
}
80103234:	c9                   	leave  
80103235:	c3                   	ret    

80103236 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103236:	55                   	push   %ebp
80103237:	89 e5                	mov    %esp,%ebp
}
80103239:	5d                   	pop    %ebp
8010323a:	c3                   	ret    

8010323b <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010323b:	55                   	push   %ebp
8010323c:	89 e5                	mov    %esp,%ebp
8010323e:	83 ec 1c             	sub    $0x1c,%esp
80103241:	8b 45 08             	mov    0x8(%ebp),%eax
80103244:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
80103247:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010324e:	00 
8010324f:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103256:	e8 a9 fd ff ff       	call   80103004 <outb>
  outb(IO_RTC+1, 0x0A);
8010325b:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103262:	00 
80103263:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
8010326a:	e8 95 fd ff ff       	call   80103004 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010326f:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103276:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103279:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010327e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103281:	8d 50 02             	lea    0x2(%eax),%edx
80103284:	8b 45 0c             	mov    0xc(%ebp),%eax
80103287:	c1 e8 04             	shr    $0x4,%eax
8010328a:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010328d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103291:	c1 e0 18             	shl    $0x18,%eax
80103294:	89 44 24 04          	mov    %eax,0x4(%esp)
80103298:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010329f:	e8 93 fd ff ff       	call   80103037 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801032a4:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801032ab:	00 
801032ac:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801032b3:	e8 7f fd ff ff       	call   80103037 <lapicw>
  microdelay(200);
801032b8:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801032bf:	e8 72 ff ff ff       	call   80103236 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
801032c4:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801032cb:	00 
801032cc:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801032d3:	e8 5f fd ff ff       	call   80103037 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801032d8:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801032df:	e8 52 ff ff ff       	call   80103236 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801032e4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801032eb:	eb 40                	jmp    8010332d <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
801032ed:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801032f1:	c1 e0 18             	shl    $0x18,%eax
801032f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801032f8:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801032ff:	e8 33 fd ff ff       	call   80103037 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103304:	8b 45 0c             	mov    0xc(%ebp),%eax
80103307:	c1 e8 0c             	shr    $0xc,%eax
8010330a:	80 cc 06             	or     $0x6,%ah
8010330d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103311:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103318:	e8 1a fd ff ff       	call   80103037 <lapicw>
    microdelay(200);
8010331d:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103324:	e8 0d ff ff ff       	call   80103236 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103329:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010332d:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103331:	7e ba                	jle    801032ed <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103333:	c9                   	leave  
80103334:	c3                   	ret    
80103335:	00 00                	add    %al,(%eax)
	...

80103338 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103338:	55                   	push   %ebp
80103339:	89 e5                	mov    %esp,%ebp
8010333b:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010333e:	c7 44 24 04 74 8a 10 	movl   $0x80108a74,0x4(%esp)
80103345:	80 
80103346:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010334d:	e8 4c 1e 00 00       	call   8010519e <initlock>
  readsb(ROOTDEV, &sb);
80103352:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103355:	89 44 24 04          	mov    %eax,0x4(%esp)
80103359:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103360:	e8 af e2 ff ff       	call   80101614 <readsb>
  log.start = sb.size - sb.nlog;
80103365:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010336b:	89 d1                	mov    %edx,%ecx
8010336d:	29 c1                	sub    %eax,%ecx
8010336f:	89 c8                	mov    %ecx,%eax
80103371:	a3 d4 f8 10 80       	mov    %eax,0x8010f8d4
  log.size = sb.nlog;
80103376:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103379:	a3 d8 f8 10 80       	mov    %eax,0x8010f8d8
  log.dev = ROOTDEV;
8010337e:	c7 05 e0 f8 10 80 01 	movl   $0x1,0x8010f8e0
80103385:	00 00 00 
  recover_from_log();
80103388:	e8 97 01 00 00       	call   80103524 <recover_from_log>
}
8010338d:	c9                   	leave  
8010338e:	c3                   	ret    

8010338f <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
8010338f:	55                   	push   %ebp
80103390:	89 e5                	mov    %esp,%ebp
80103392:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103395:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010339c:	e9 89 00 00 00       	jmp    8010342a <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801033a1:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
801033a6:	03 45 f4             	add    -0xc(%ebp),%eax
801033a9:	83 c0 01             	add    $0x1,%eax
801033ac:	89 c2                	mov    %eax,%edx
801033ae:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801033b3:	89 54 24 04          	mov    %edx,0x4(%esp)
801033b7:	89 04 24             	mov    %eax,(%esp)
801033ba:	e8 e7 cd ff ff       	call   801001a6 <bread>
801033bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801033c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033c5:	83 c0 10             	add    $0x10,%eax
801033c8:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
801033cf:	89 c2                	mov    %eax,%edx
801033d1:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801033d6:	89 54 24 04          	mov    %edx,0x4(%esp)
801033da:	89 04 24             	mov    %eax,(%esp)
801033dd:	e8 c4 cd ff ff       	call   801001a6 <bread>
801033e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033e8:	8d 50 18             	lea    0x18(%eax),%edx
801033eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033ee:	83 c0 18             	add    $0x18,%eax
801033f1:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801033f8:	00 
801033f9:	89 54 24 04          	mov    %edx,0x4(%esp)
801033fd:	89 04 24             	mov    %eax,(%esp)
80103400:	e8 dc 20 00 00       	call   801054e1 <memmove>
    bwrite(dbuf);  // write dst to disk
80103405:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103408:	89 04 24             	mov    %eax,(%esp)
8010340b:	e8 cd cd ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
80103410:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103413:	89 04 24             	mov    %eax,(%esp)
80103416:	e8 fc cd ff ff       	call   80100217 <brelse>
    brelse(dbuf);
8010341b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010341e:	89 04 24             	mov    %eax,(%esp)
80103421:	e8 f1 cd ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103426:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010342a:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010342f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103432:	0f 8f 69 ff ff ff    	jg     801033a1 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103438:	c9                   	leave  
80103439:	c3                   	ret    

8010343a <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010343a:	55                   	push   %ebp
8010343b:	89 e5                	mov    %esp,%ebp
8010343d:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103440:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
80103445:	89 c2                	mov    %eax,%edx
80103447:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
8010344c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103450:	89 04 24             	mov    %eax,(%esp)
80103453:	e8 4e cd ff ff       	call   801001a6 <bread>
80103458:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010345b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010345e:	83 c0 18             	add    $0x18,%eax
80103461:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103464:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103467:	8b 00                	mov    (%eax),%eax
80103469:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  for (i = 0; i < log.lh.n; i++) {
8010346e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103475:	eb 1b                	jmp    80103492 <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
80103477:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010347a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010347d:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103481:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103484:	83 c2 10             	add    $0x10,%edx
80103487:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010348e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103492:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103497:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010349a:	7f db                	jg     80103477 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
8010349c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010349f:	89 04 24             	mov    %eax,(%esp)
801034a2:	e8 70 cd ff ff       	call   80100217 <brelse>
}
801034a7:	c9                   	leave  
801034a8:	c3                   	ret    

801034a9 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034a9:	55                   	push   %ebp
801034aa:	89 e5                	mov    %esp,%ebp
801034ac:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801034af:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
801034b4:	89 c2                	mov    %eax,%edx
801034b6:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801034bb:	89 54 24 04          	mov    %edx,0x4(%esp)
801034bf:	89 04 24             	mov    %eax,(%esp)
801034c2:	e8 df cc ff ff       	call   801001a6 <bread>
801034c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034cd:	83 c0 18             	add    $0x18,%eax
801034d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034d3:	8b 15 e4 f8 10 80    	mov    0x8010f8e4,%edx
801034d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034dc:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034e5:	eb 1b                	jmp    80103502 <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801034e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034ea:	83 c0 10             	add    $0x10,%eax
801034ed:	8b 0c 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%ecx
801034f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034fa:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801034fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103502:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103507:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010350a:	7f db                	jg     801034e7 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
8010350c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010350f:	89 04 24             	mov    %eax,(%esp)
80103512:	e8 c6 cc ff ff       	call   801001dd <bwrite>
  brelse(buf);
80103517:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010351a:	89 04 24             	mov    %eax,(%esp)
8010351d:	e8 f5 cc ff ff       	call   80100217 <brelse>
}
80103522:	c9                   	leave  
80103523:	c3                   	ret    

80103524 <recover_from_log>:

static void
recover_from_log(void)
{
80103524:	55                   	push   %ebp
80103525:	89 e5                	mov    %esp,%ebp
80103527:	83 ec 08             	sub    $0x8,%esp
  read_head();      
8010352a:	e8 0b ff ff ff       	call   8010343a <read_head>
  install_trans(); // if committed, copy from log to disk
8010352f:	e8 5b fe ff ff       	call   8010338f <install_trans>
  log.lh.n = 0;
80103534:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
8010353b:	00 00 00 
  write_head(); // clear the log
8010353e:	e8 66 ff ff ff       	call   801034a9 <write_head>
}
80103543:	c9                   	leave  
80103544:	c3                   	ret    

80103545 <begin_trans>:

void
begin_trans(void)
{
80103545:	55                   	push   %ebp
80103546:	89 e5                	mov    %esp,%ebp
80103548:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
8010354b:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103552:	e8 68 1c 00 00       	call   801051bf <acquire>
  while (log.busy) {
80103557:	eb 14                	jmp    8010356d <begin_trans+0x28>
    sleep(&log, &log.lock);
80103559:	c7 44 24 04 a0 f8 10 	movl   $0x8010f8a0,0x4(%esp)
80103560:	80 
80103561:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103568:	e8 e9 18 00 00       	call   80104e56 <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
8010356d:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
80103572:	85 c0                	test   %eax,%eax
80103574:	75 e3                	jne    80103559 <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
80103576:	c7 05 dc f8 10 80 01 	movl   $0x1,0x8010f8dc
8010357d:	00 00 00 
  release(&log.lock);
80103580:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103587:	e8 95 1c 00 00       	call   80105221 <release>
}
8010358c:	c9                   	leave  
8010358d:	c3                   	ret    

8010358e <commit_trans>:

void
commit_trans(void)
{
8010358e:	55                   	push   %ebp
8010358f:	89 e5                	mov    %esp,%ebp
80103591:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
80103594:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103599:	85 c0                	test   %eax,%eax
8010359b:	7e 19                	jle    801035b6 <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
8010359d:	e8 07 ff ff ff       	call   801034a9 <write_head>
    install_trans(); // Now install writes to home locations
801035a2:	e8 e8 fd ff ff       	call   8010338f <install_trans>
    log.lh.n = 0; 
801035a7:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
801035ae:	00 00 00 
    write_head();    // Erase the transaction from the log
801035b1:	e8 f3 fe ff ff       	call   801034a9 <write_head>
  }
  
  acquire(&log.lock);
801035b6:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801035bd:	e8 fd 1b 00 00       	call   801051bf <acquire>
  log.busy = 0;
801035c2:	c7 05 dc f8 10 80 00 	movl   $0x0,0x8010f8dc
801035c9:	00 00 00 
  wakeup(&log);
801035cc:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801035d3:	e8 5a 19 00 00       	call   80104f32 <wakeup>
  release(&log.lock);
801035d8:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801035df:	e8 3d 1c 00 00       	call   80105221 <release>
}
801035e4:	c9                   	leave  
801035e5:	c3                   	ret    

801035e6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801035e6:	55                   	push   %ebp
801035e7:	89 e5                	mov    %esp,%ebp
801035e9:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801035ec:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801035f1:	83 f8 09             	cmp    $0x9,%eax
801035f4:	7f 12                	jg     80103608 <log_write+0x22>
801035f6:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801035fb:	8b 15 d8 f8 10 80    	mov    0x8010f8d8,%edx
80103601:	83 ea 01             	sub    $0x1,%edx
80103604:	39 d0                	cmp    %edx,%eax
80103606:	7c 0c                	jl     80103614 <log_write+0x2e>
    panic("too big a transaction");
80103608:	c7 04 24 78 8a 10 80 	movl   $0x80108a78,(%esp)
8010360f:	e8 29 cf ff ff       	call   8010053d <panic>
  if (!log.busy)
80103614:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
80103619:	85 c0                	test   %eax,%eax
8010361b:	75 0c                	jne    80103629 <log_write+0x43>
    panic("write outside of trans");
8010361d:	c7 04 24 8e 8a 10 80 	movl   $0x80108a8e,(%esp)
80103624:	e8 14 cf ff ff       	call   8010053d <panic>

  for (i = 0; i < log.lh.n; i++) {
80103629:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103630:	eb 1d                	jmp    8010364f <log_write+0x69>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
80103632:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103635:	83 c0 10             	add    $0x10,%eax
80103638:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
8010363f:	89 c2                	mov    %eax,%edx
80103641:	8b 45 08             	mov    0x8(%ebp),%eax
80103644:	8b 40 08             	mov    0x8(%eax),%eax
80103647:	39 c2                	cmp    %eax,%edx
80103649:	74 10                	je     8010365b <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
8010364b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010364f:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103654:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103657:	7f d9                	jg     80103632 <log_write+0x4c>
80103659:	eb 01                	jmp    8010365c <log_write+0x76>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
8010365b:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
8010365c:	8b 45 08             	mov    0x8(%ebp),%eax
8010365f:	8b 40 08             	mov    0x8(%eax),%eax
80103662:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103665:	83 c2 10             	add    $0x10,%edx
80103668:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
8010366f:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
80103674:	03 45 f4             	add    -0xc(%ebp),%eax
80103677:	83 c0 01             	add    $0x1,%eax
8010367a:	89 c2                	mov    %eax,%edx
8010367c:	8b 45 08             	mov    0x8(%ebp),%eax
8010367f:	8b 40 04             	mov    0x4(%eax),%eax
80103682:	89 54 24 04          	mov    %edx,0x4(%esp)
80103686:	89 04 24             	mov    %eax,(%esp)
80103689:	e8 18 cb ff ff       	call   801001a6 <bread>
8010368e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
80103691:	8b 45 08             	mov    0x8(%ebp),%eax
80103694:	8d 50 18             	lea    0x18(%eax),%edx
80103697:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010369a:	83 c0 18             	add    $0x18,%eax
8010369d:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801036a4:	00 
801036a5:	89 54 24 04          	mov    %edx,0x4(%esp)
801036a9:	89 04 24             	mov    %eax,(%esp)
801036ac:	e8 30 1e 00 00       	call   801054e1 <memmove>
  bwrite(lbuf);
801036b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036b4:	89 04 24             	mov    %eax,(%esp)
801036b7:	e8 21 cb ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
801036bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036bf:	89 04 24             	mov    %eax,(%esp)
801036c2:	e8 50 cb ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
801036c7:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801036cc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036cf:	75 0d                	jne    801036de <log_write+0xf8>
    log.lh.n++;
801036d1:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801036d6:	83 c0 01             	add    $0x1,%eax
801036d9:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  b->flags |= B_DIRTY; // XXX prevent eviction
801036de:	8b 45 08             	mov    0x8(%ebp),%eax
801036e1:	8b 00                	mov    (%eax),%eax
801036e3:	89 c2                	mov    %eax,%edx
801036e5:	83 ca 04             	or     $0x4,%edx
801036e8:	8b 45 08             	mov    0x8(%ebp),%eax
801036eb:	89 10                	mov    %edx,(%eax)
}
801036ed:	c9                   	leave  
801036ee:	c3                   	ret    
	...

801036f0 <v2p>:
801036f0:	55                   	push   %ebp
801036f1:	89 e5                	mov    %esp,%ebp
801036f3:	8b 45 08             	mov    0x8(%ebp),%eax
801036f6:	05 00 00 00 80       	add    $0x80000000,%eax
801036fb:	5d                   	pop    %ebp
801036fc:	c3                   	ret    

801036fd <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801036fd:	55                   	push   %ebp
801036fe:	89 e5                	mov    %esp,%ebp
80103700:	8b 45 08             	mov    0x8(%ebp),%eax
80103703:	05 00 00 00 80       	add    $0x80000000,%eax
80103708:	5d                   	pop    %ebp
80103709:	c3                   	ret    

8010370a <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010370a:	55                   	push   %ebp
8010370b:	89 e5                	mov    %esp,%ebp
8010370d:	53                   	push   %ebx
8010370e:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80103711:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103714:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80103717:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010371a:	89 c3                	mov    %eax,%ebx
8010371c:	89 d8                	mov    %ebx,%eax
8010371e:	f0 87 02             	lock xchg %eax,(%edx)
80103721:	89 c3                	mov    %eax,%ebx
80103723:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103726:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103729:	83 c4 10             	add    $0x10,%esp
8010372c:	5b                   	pop    %ebx
8010372d:	5d                   	pop    %ebp
8010372e:	c3                   	ret    

8010372f <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010372f:	55                   	push   %ebp
80103730:	89 e5                	mov    %esp,%ebp
80103732:	83 e4 f0             	and    $0xfffffff0,%esp
80103735:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103738:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
8010373f:	80 
80103740:	c7 04 24 1c 2d 11 80 	movl   $0x80112d1c,(%esp)
80103747:	e8 ad f5 ff ff       	call   80102cf9 <kinit1>
  kvmalloc();      // kernel page table
8010374c:	e8 81 49 00 00       	call   801080d2 <kvmalloc>
  mpinit();        // collect info about this machine
80103751:	e8 63 04 00 00       	call   80103bb9 <mpinit>
  lapicinit(mpbcpu());
80103756:	e8 2e 02 00 00       	call   80103989 <mpbcpu>
8010375b:	89 04 24             	mov    %eax,(%esp)
8010375e:	e8 f5 f8 ff ff       	call   80103058 <lapicinit>
  seginit();       // set up segments
80103763:	e8 0d 43 00 00       	call   80107a75 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103768:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010376e:	0f b6 00             	movzbl (%eax),%eax
80103771:	0f b6 c0             	movzbl %al,%eax
80103774:	89 44 24 04          	mov    %eax,0x4(%esp)
80103778:	c7 04 24 a5 8a 10 80 	movl   $0x80108aa5,(%esp)
8010377f:	e8 1d cc ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
80103784:	e8 95 06 00 00       	call   80103e1e <picinit>
  ioapicinit();    // another interrupt controller
80103789:	e8 5b f4 ff ff       	call   80102be9 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010378e:	e8 20 d6 ff ff       	call   80100db3 <consoleinit>
  uartinit();      // serial port
80103793:	e8 28 36 00 00       	call   80106dc0 <uartinit>
  pinit();         // process table
80103798:	e8 96 0b 00 00       	call   80104333 <pinit>
  tvinit();        // trap vectors
8010379d:	e8 7d 31 00 00       	call   8010691f <tvinit>
  binit();         // buffer cache
801037a2:	e8 8d c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801037a7:	e8 7c da ff ff       	call   80101228 <fileinit>
  iinit();         // inode cache
801037ac:	e8 2a e1 ff ff       	call   801018db <iinit>
  ideinit();       // disk
801037b1:	e8 98 f0 ff ff       	call   8010284e <ideinit>
  if(!ismp)
801037b6:	a1 24 f9 10 80       	mov    0x8010f924,%eax
801037bb:	85 c0                	test   %eax,%eax
801037bd:	75 05                	jne    801037c4 <main+0x95>
    timerinit();   // uniprocessor timer
801037bf:	e8 9e 30 00 00       	call   80106862 <timerinit>
  startothers();   // start other processors
801037c4:	e8 87 00 00 00       	call   80103850 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037c9:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801037d0:	8e 
801037d1:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801037d8:	e8 54 f5 ff ff       	call   80102d31 <kinit2>
  userinit();      // first user process
801037dd:	e8 6f 0c 00 00       	call   80104451 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801037e2:	e8 22 00 00 00       	call   80103809 <mpmain>

801037e7 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801037e7:	55                   	push   %ebp
801037e8:	89 e5                	mov    %esp,%ebp
801037ea:	83 ec 18             	sub    $0x18,%esp
  switchkvm(); 
801037ed:	e8 f7 48 00 00       	call   801080e9 <switchkvm>
  seginit();
801037f2:	e8 7e 42 00 00       	call   80107a75 <seginit>
  lapicinit(cpunum());
801037f7:	e8 b9 f9 ff ff       	call   801031b5 <cpunum>
801037fc:	89 04 24             	mov    %eax,(%esp)
801037ff:	e8 54 f8 ff ff       	call   80103058 <lapicinit>
  mpmain();
80103804:	e8 00 00 00 00       	call   80103809 <mpmain>

80103809 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103809:	55                   	push   %ebp
8010380a:	89 e5                	mov    %esp,%ebp
8010380c:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010380f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103815:	0f b6 00             	movzbl (%eax),%eax
80103818:	0f b6 c0             	movzbl %al,%eax
8010381b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010381f:	c7 04 24 bc 8a 10 80 	movl   $0x80108abc,(%esp)
80103826:	e8 76 cb ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
8010382b:	e8 63 32 00 00       	call   80106a93 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103830:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103836:	05 a8 00 00 00       	add    $0xa8,%eax
8010383b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103842:	00 
80103843:	89 04 24             	mov    %eax,(%esp)
80103846:	e8 bf fe ff ff       	call   8010370a <xchg>
  scheduler();     // start running processes
8010384b:	e8 ae 13 00 00       	call   80104bfe <scheduler>

80103850 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103850:	55                   	push   %ebp
80103851:	89 e5                	mov    %esp,%ebp
80103853:	53                   	push   %ebx
80103854:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103857:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
8010385e:	e8 9a fe ff ff       	call   801036fd <p2v>
80103863:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103866:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010386b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010386f:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
80103876:	80 
80103877:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010387a:	89 04 24             	mov    %eax,(%esp)
8010387d:	e8 5f 1c 00 00       	call   801054e1 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103882:	c7 45 f4 40 f9 10 80 	movl   $0x8010f940,-0xc(%ebp)
80103889:	e9 86 00 00 00       	jmp    80103914 <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
8010388e:	e8 22 f9 ff ff       	call   801031b5 <cpunum>
80103893:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103899:	05 40 f9 10 80       	add    $0x8010f940,%eax
8010389e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038a1:	74 69                	je     8010390c <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801038a3:	e8 7f f5 ff ff       	call   80102e27 <kalloc>
801038a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801038ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038ae:	83 e8 04             	sub    $0x4,%eax
801038b1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801038b4:	81 c2 00 10 00 00    	add    $0x1000,%edx
801038ba:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801038bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038bf:	83 e8 08             	sub    $0x8,%eax
801038c2:	c7 00 e7 37 10 80    	movl   $0x801037e7,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801038c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038cb:	8d 58 f4             	lea    -0xc(%eax),%ebx
801038ce:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
801038d5:	e8 16 fe ff ff       	call   801036f0 <v2p>
801038da:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801038dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038df:	89 04 24             	mov    %eax,(%esp)
801038e2:	e8 09 fe ff ff       	call   801036f0 <v2p>
801038e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801038ea:	0f b6 12             	movzbl (%edx),%edx
801038ed:	0f b6 d2             	movzbl %dl,%edx
801038f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801038f4:	89 14 24             	mov    %edx,(%esp)
801038f7:	e8 3f f9 ff ff       	call   8010323b <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801038fc:	90                   	nop
801038fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103900:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103906:	85 c0                	test   %eax,%eax
80103908:	74 f3                	je     801038fd <startothers+0xad>
8010390a:	eb 01                	jmp    8010390d <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
8010390c:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
8010390d:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103914:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103919:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010391f:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103924:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103927:	0f 87 61 ff ff ff    	ja     8010388e <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
8010392d:	83 c4 24             	add    $0x24,%esp
80103930:	5b                   	pop    %ebx
80103931:	5d                   	pop    %ebp
80103932:	c3                   	ret    
	...

80103934 <p2v>:
80103934:	55                   	push   %ebp
80103935:	89 e5                	mov    %esp,%ebp
80103937:	8b 45 08             	mov    0x8(%ebp),%eax
8010393a:	05 00 00 00 80       	add    $0x80000000,%eax
8010393f:	5d                   	pop    %ebp
80103940:	c3                   	ret    

80103941 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103941:	55                   	push   %ebp
80103942:	89 e5                	mov    %esp,%ebp
80103944:	53                   	push   %ebx
80103945:	83 ec 14             	sub    $0x14,%esp
80103948:	8b 45 08             	mov    0x8(%ebp),%eax
8010394b:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010394f:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80103953:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80103957:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
8010395b:	ec                   	in     (%dx),%al
8010395c:	89 c3                	mov    %eax,%ebx
8010395e:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80103961:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80103965:	83 c4 14             	add    $0x14,%esp
80103968:	5b                   	pop    %ebx
80103969:	5d                   	pop    %ebp
8010396a:	c3                   	ret    

8010396b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010396b:	55                   	push   %ebp
8010396c:	89 e5                	mov    %esp,%ebp
8010396e:	83 ec 08             	sub    $0x8,%esp
80103971:	8b 55 08             	mov    0x8(%ebp),%edx
80103974:	8b 45 0c             	mov    0xc(%ebp),%eax
80103977:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010397b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010397e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103982:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103986:	ee                   	out    %al,(%dx)
}
80103987:	c9                   	leave  
80103988:	c3                   	ret    

80103989 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103989:	55                   	push   %ebp
8010398a:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
8010398c:	a1 44 b6 10 80       	mov    0x8010b644,%eax
80103991:	89 c2                	mov    %eax,%edx
80103993:	b8 40 f9 10 80       	mov    $0x8010f940,%eax
80103998:	89 d1                	mov    %edx,%ecx
8010399a:	29 c1                	sub    %eax,%ecx
8010399c:	89 c8                	mov    %ecx,%eax
8010399e:	c1 f8 02             	sar    $0x2,%eax
801039a1:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801039a7:	5d                   	pop    %ebp
801039a8:	c3                   	ret    

801039a9 <sum>:

static uchar
sum(uchar *addr, int len)
{
801039a9:	55                   	push   %ebp
801039aa:	89 e5                	mov    %esp,%ebp
801039ac:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801039af:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801039b6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801039bd:	eb 13                	jmp    801039d2 <sum+0x29>
    sum += addr[i];
801039bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801039c2:	03 45 08             	add    0x8(%ebp),%eax
801039c5:	0f b6 00             	movzbl (%eax),%eax
801039c8:	0f b6 c0             	movzbl %al,%eax
801039cb:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
801039ce:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801039d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801039d5:	3b 45 0c             	cmp    0xc(%ebp),%eax
801039d8:	7c e5                	jl     801039bf <sum+0x16>
    sum += addr[i];
  return sum;
801039da:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801039dd:	c9                   	leave  
801039de:	c3                   	ret    

801039df <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801039df:	55                   	push   %ebp
801039e0:	89 e5                	mov    %esp,%ebp
801039e2:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801039e5:	8b 45 08             	mov    0x8(%ebp),%eax
801039e8:	89 04 24             	mov    %eax,(%esp)
801039eb:	e8 44 ff ff ff       	call   80103934 <p2v>
801039f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801039f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801039f6:	03 45 f0             	add    -0x10(%ebp),%eax
801039f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801039fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a02:	eb 3f                	jmp    80103a43 <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a04:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a0b:	00 
80103a0c:	c7 44 24 04 d0 8a 10 	movl   $0x80108ad0,0x4(%esp)
80103a13:	80 
80103a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a17:	89 04 24             	mov    %eax,(%esp)
80103a1a:	e8 66 1a 00 00       	call   80105485 <memcmp>
80103a1f:	85 c0                	test   %eax,%eax
80103a21:	75 1c                	jne    80103a3f <mpsearch1+0x60>
80103a23:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a2a:	00 
80103a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a2e:	89 04 24             	mov    %eax,(%esp)
80103a31:	e8 73 ff ff ff       	call   801039a9 <sum>
80103a36:	84 c0                	test   %al,%al
80103a38:	75 05                	jne    80103a3f <mpsearch1+0x60>
      return (struct mp*)p;
80103a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a3d:	eb 11                	jmp    80103a50 <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a3f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a49:	72 b9                	jb     80103a04 <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a50:	c9                   	leave  
80103a51:	c3                   	ret    

80103a52 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a52:	55                   	push   %ebp
80103a53:	89 e5                	mov    %esp,%ebp
80103a55:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a58:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a62:	83 c0 0f             	add    $0xf,%eax
80103a65:	0f b6 00             	movzbl (%eax),%eax
80103a68:	0f b6 c0             	movzbl %al,%eax
80103a6b:	89 c2                	mov    %eax,%edx
80103a6d:	c1 e2 08             	shl    $0x8,%edx
80103a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a73:	83 c0 0e             	add    $0xe,%eax
80103a76:	0f b6 00             	movzbl (%eax),%eax
80103a79:	0f b6 c0             	movzbl %al,%eax
80103a7c:	09 d0                	or     %edx,%eax
80103a7e:	c1 e0 04             	shl    $0x4,%eax
80103a81:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103a84:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a88:	74 21                	je     80103aab <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103a8a:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103a91:	00 
80103a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a95:	89 04 24             	mov    %eax,(%esp)
80103a98:	e8 42 ff ff ff       	call   801039df <mpsearch1>
80103a9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103aa0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103aa4:	74 50                	je     80103af6 <mpsearch+0xa4>
      return mp;
80103aa6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103aa9:	eb 5f                	jmp    80103b0a <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aae:	83 c0 14             	add    $0x14,%eax
80103ab1:	0f b6 00             	movzbl (%eax),%eax
80103ab4:	0f b6 c0             	movzbl %al,%eax
80103ab7:	89 c2                	mov    %eax,%edx
80103ab9:	c1 e2 08             	shl    $0x8,%edx
80103abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103abf:	83 c0 13             	add    $0x13,%eax
80103ac2:	0f b6 00             	movzbl (%eax),%eax
80103ac5:	0f b6 c0             	movzbl %al,%eax
80103ac8:	09 d0                	or     %edx,%eax
80103aca:	c1 e0 0a             	shl    $0xa,%eax
80103acd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103ad0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ad3:	2d 00 04 00 00       	sub    $0x400,%eax
80103ad8:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103adf:	00 
80103ae0:	89 04 24             	mov    %eax,(%esp)
80103ae3:	e8 f7 fe ff ff       	call   801039df <mpsearch1>
80103ae8:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103aeb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103aef:	74 05                	je     80103af6 <mpsearch+0xa4>
      return mp;
80103af1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103af4:	eb 14                	jmp    80103b0a <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103af6:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103afd:	00 
80103afe:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b05:	e8 d5 fe ff ff       	call   801039df <mpsearch1>
}
80103b0a:	c9                   	leave  
80103b0b:	c3                   	ret    

80103b0c <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b0c:	55                   	push   %ebp
80103b0d:	89 e5                	mov    %esp,%ebp
80103b0f:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b12:	e8 3b ff ff ff       	call   80103a52 <mpsearch>
80103b17:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b1a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b1e:	74 0a                	je     80103b2a <mpconfig+0x1e>
80103b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b23:	8b 40 04             	mov    0x4(%eax),%eax
80103b26:	85 c0                	test   %eax,%eax
80103b28:	75 0a                	jne    80103b34 <mpconfig+0x28>
    return 0;
80103b2a:	b8 00 00 00 00       	mov    $0x0,%eax
80103b2f:	e9 83 00 00 00       	jmp    80103bb7 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b37:	8b 40 04             	mov    0x4(%eax),%eax
80103b3a:	89 04 24             	mov    %eax,(%esp)
80103b3d:	e8 f2 fd ff ff       	call   80103934 <p2v>
80103b42:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b45:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b4c:	00 
80103b4d:	c7 44 24 04 d5 8a 10 	movl   $0x80108ad5,0x4(%esp)
80103b54:	80 
80103b55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b58:	89 04 24             	mov    %eax,(%esp)
80103b5b:	e8 25 19 00 00       	call   80105485 <memcmp>
80103b60:	85 c0                	test   %eax,%eax
80103b62:	74 07                	je     80103b6b <mpconfig+0x5f>
    return 0;
80103b64:	b8 00 00 00 00       	mov    $0x0,%eax
80103b69:	eb 4c                	jmp    80103bb7 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b6e:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b72:	3c 01                	cmp    $0x1,%al
80103b74:	74 12                	je     80103b88 <mpconfig+0x7c>
80103b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b79:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b7d:	3c 04                	cmp    $0x4,%al
80103b7f:	74 07                	je     80103b88 <mpconfig+0x7c>
    return 0;
80103b81:	b8 00 00 00 00       	mov    $0x0,%eax
80103b86:	eb 2f                	jmp    80103bb7 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103b88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b8b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103b8f:	0f b7 c0             	movzwl %ax,%eax
80103b92:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b99:	89 04 24             	mov    %eax,(%esp)
80103b9c:	e8 08 fe ff ff       	call   801039a9 <sum>
80103ba1:	84 c0                	test   %al,%al
80103ba3:	74 07                	je     80103bac <mpconfig+0xa0>
    return 0;
80103ba5:	b8 00 00 00 00       	mov    $0x0,%eax
80103baa:	eb 0b                	jmp    80103bb7 <mpconfig+0xab>
  *pmp = mp;
80103bac:	8b 45 08             	mov    0x8(%ebp),%eax
80103baf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bb2:	89 10                	mov    %edx,(%eax)
  return conf;
80103bb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103bb7:	c9                   	leave  
80103bb8:	c3                   	ret    

80103bb9 <mpinit>:

void
mpinit(void)
{
80103bb9:	55                   	push   %ebp
80103bba:	89 e5                	mov    %esp,%ebp
80103bbc:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103bbf:	c7 05 44 b6 10 80 40 	movl   $0x8010f940,0x8010b644
80103bc6:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
80103bc9:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103bcc:	89 04 24             	mov    %eax,(%esp)
80103bcf:	e8 38 ff ff ff       	call   80103b0c <mpconfig>
80103bd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bd7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bdb:	0f 84 9c 01 00 00    	je     80103d7d <mpinit+0x1c4>
    return;
  ismp = 1;
80103be1:	c7 05 24 f9 10 80 01 	movl   $0x1,0x8010f924
80103be8:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bee:	8b 40 24             	mov    0x24(%eax),%eax
80103bf1:	a3 9c f8 10 80       	mov    %eax,0x8010f89c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103bf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bf9:	83 c0 2c             	add    $0x2c,%eax
80103bfc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c02:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c06:	0f b7 c0             	movzwl %ax,%eax
80103c09:	03 45 f0             	add    -0x10(%ebp),%eax
80103c0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c0f:	e9 f4 00 00 00       	jmp    80103d08 <mpinit+0x14f>
    switch(*p){
80103c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c17:	0f b6 00             	movzbl (%eax),%eax
80103c1a:	0f b6 c0             	movzbl %al,%eax
80103c1d:	83 f8 04             	cmp    $0x4,%eax
80103c20:	0f 87 bf 00 00 00    	ja     80103ce5 <mpinit+0x12c>
80103c26:	8b 04 85 18 8b 10 80 	mov    -0x7fef74e8(,%eax,4),%eax
80103c2d:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c32:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c35:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c38:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c3c:	0f b6 d0             	movzbl %al,%edx
80103c3f:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c44:	39 c2                	cmp    %eax,%edx
80103c46:	74 2d                	je     80103c75 <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c48:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c4b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c4f:	0f b6 d0             	movzbl %al,%edx
80103c52:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c57:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c5b:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c5f:	c7 04 24 da 8a 10 80 	movl   $0x80108ada,(%esp)
80103c66:	e8 36 c7 ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80103c6b:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103c72:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103c75:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c78:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103c7c:	0f b6 c0             	movzbl %al,%eax
80103c7f:	83 e0 02             	and    $0x2,%eax
80103c82:	85 c0                	test   %eax,%eax
80103c84:	74 15                	je     80103c9b <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80103c86:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c8b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103c91:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103c96:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103c9b:	8b 15 20 ff 10 80    	mov    0x8010ff20,%edx
80103ca1:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103ca6:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103cac:	81 c2 40 f9 10 80    	add    $0x8010f940,%edx
80103cb2:	88 02                	mov    %al,(%edx)
      ncpu++;
80103cb4:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103cb9:	83 c0 01             	add    $0x1,%eax
80103cbc:	a3 20 ff 10 80       	mov    %eax,0x8010ff20
      p += sizeof(struct mpproc);
80103cc1:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103cc5:	eb 41                	jmp    80103d08 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103ccd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103cd0:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cd4:	a2 20 f9 10 80       	mov    %al,0x8010f920
      p += sizeof(struct mpioapic);
80103cd9:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cdd:	eb 29                	jmp    80103d08 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103cdf:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ce3:	eb 23                	jmp    80103d08 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce8:	0f b6 00             	movzbl (%eax),%eax
80103ceb:	0f b6 c0             	movzbl %al,%eax
80103cee:	89 44 24 04          	mov    %eax,0x4(%esp)
80103cf2:	c7 04 24 f8 8a 10 80 	movl   $0x80108af8,(%esp)
80103cf9:	e8 a3 c6 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
80103cfe:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103d05:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d0e:	0f 82 00 ff ff ff    	jb     80103c14 <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103d14:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80103d19:	85 c0                	test   %eax,%eax
80103d1b:	75 1d                	jne    80103d3a <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103d1d:	c7 05 20 ff 10 80 01 	movl   $0x1,0x8010ff20
80103d24:	00 00 00 
    lapic = 0;
80103d27:	c7 05 9c f8 10 80 00 	movl   $0x0,0x8010f89c
80103d2e:	00 00 00 
    ioapicid = 0;
80103d31:	c6 05 20 f9 10 80 00 	movb   $0x0,0x8010f920
    return;
80103d38:	eb 44                	jmp    80103d7e <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103d3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d3d:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d41:	84 c0                	test   %al,%al
80103d43:	74 39                	je     80103d7e <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d45:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d4c:	00 
80103d4d:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d54:	e8 12 fc ff ff       	call   8010396b <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d59:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d60:	e8 dc fb ff ff       	call   80103941 <inb>
80103d65:	83 c8 01             	or     $0x1,%eax
80103d68:	0f b6 c0             	movzbl %al,%eax
80103d6b:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d6f:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d76:	e8 f0 fb ff ff       	call   8010396b <outb>
80103d7b:	eb 01                	jmp    80103d7e <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103d7d:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103d7e:	c9                   	leave  
80103d7f:	c3                   	ret    

80103d80 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d80:	55                   	push   %ebp
80103d81:	89 e5                	mov    %esp,%ebp
80103d83:	83 ec 08             	sub    $0x8,%esp
80103d86:	8b 55 08             	mov    0x8(%ebp),%edx
80103d89:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d8c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103d90:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d93:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103d97:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103d9b:	ee                   	out    %al,(%dx)
}
80103d9c:	c9                   	leave  
80103d9d:	c3                   	ret    

80103d9e <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103d9e:	55                   	push   %ebp
80103d9f:	89 e5                	mov    %esp,%ebp
80103da1:	83 ec 0c             	sub    $0xc,%esp
80103da4:	8b 45 08             	mov    0x8(%ebp),%eax
80103da7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103dab:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103daf:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103db5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103db9:	0f b6 c0             	movzbl %al,%eax
80103dbc:	89 44 24 04          	mov    %eax,0x4(%esp)
80103dc0:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103dc7:	e8 b4 ff ff ff       	call   80103d80 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103dcc:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103dd0:	66 c1 e8 08          	shr    $0x8,%ax
80103dd4:	0f b6 c0             	movzbl %al,%eax
80103dd7:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ddb:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103de2:	e8 99 ff ff ff       	call   80103d80 <outb>
}
80103de7:	c9                   	leave  
80103de8:	c3                   	ret    

80103de9 <picenable>:

void
picenable(int irq)
{
80103de9:	55                   	push   %ebp
80103dea:	89 e5                	mov    %esp,%ebp
80103dec:	53                   	push   %ebx
80103ded:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103df0:	8b 45 08             	mov    0x8(%ebp),%eax
80103df3:	ba 01 00 00 00       	mov    $0x1,%edx
80103df8:	89 d3                	mov    %edx,%ebx
80103dfa:	89 c1                	mov    %eax,%ecx
80103dfc:	d3 e3                	shl    %cl,%ebx
80103dfe:	89 d8                	mov    %ebx,%eax
80103e00:	89 c2                	mov    %eax,%edx
80103e02:	f7 d2                	not    %edx
80103e04:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103e0b:	21 d0                	and    %edx,%eax
80103e0d:	0f b7 c0             	movzwl %ax,%eax
80103e10:	89 04 24             	mov    %eax,(%esp)
80103e13:	e8 86 ff ff ff       	call   80103d9e <picsetmask>
}
80103e18:	83 c4 04             	add    $0x4,%esp
80103e1b:	5b                   	pop    %ebx
80103e1c:	5d                   	pop    %ebp
80103e1d:	c3                   	ret    

80103e1e <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e1e:	55                   	push   %ebp
80103e1f:	89 e5                	mov    %esp,%ebp
80103e21:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e24:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e2b:	00 
80103e2c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e33:	e8 48 ff ff ff       	call   80103d80 <outb>
  outb(IO_PIC2+1, 0xFF);
80103e38:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e3f:	00 
80103e40:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e47:	e8 34 ff ff ff       	call   80103d80 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e4c:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e53:	00 
80103e54:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e5b:	e8 20 ff ff ff       	call   80103d80 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103e60:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103e67:	00 
80103e68:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e6f:	e8 0c ff ff ff       	call   80103d80 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103e74:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103e7b:	00 
80103e7c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e83:	e8 f8 fe ff ff       	call   80103d80 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103e88:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103e8f:	00 
80103e90:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e97:	e8 e4 fe ff ff       	call   80103d80 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103e9c:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103ea3:	00 
80103ea4:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103eab:	e8 d0 fe ff ff       	call   80103d80 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103eb0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103eb7:	00 
80103eb8:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ebf:	e8 bc fe ff ff       	call   80103d80 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103ec4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103ecb:	00 
80103ecc:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ed3:	e8 a8 fe ff ff       	call   80103d80 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103ed8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103edf:	00 
80103ee0:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ee7:	e8 94 fe ff ff       	call   80103d80 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103eec:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103ef3:	00 
80103ef4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103efb:	e8 80 fe ff ff       	call   80103d80 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f00:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f07:	00 
80103f08:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f0f:	e8 6c fe ff ff       	call   80103d80 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103f14:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f1b:	00 
80103f1c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f23:	e8 58 fe ff ff       	call   80103d80 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103f28:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f2f:	00 
80103f30:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f37:	e8 44 fe ff ff       	call   80103d80 <outb>

  if(irqmask != 0xFFFF)
80103f3c:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f43:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f47:	74 12                	je     80103f5b <picinit+0x13d>
    picsetmask(irqmask);
80103f49:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f50:	0f b7 c0             	movzwl %ax,%eax
80103f53:	89 04 24             	mov    %eax,(%esp)
80103f56:	e8 43 fe ff ff       	call   80103d9e <picsetmask>
}
80103f5b:	c9                   	leave  
80103f5c:	c3                   	ret    
80103f5d:	00 00                	add    %al,(%eax)
	...

80103f60 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103f60:	55                   	push   %ebp
80103f61:	89 e5                	mov    %esp,%ebp
80103f63:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103f66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f70:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103f76:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f79:	8b 10                	mov    (%eax),%edx
80103f7b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7e:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103f80:	e8 bf d2 ff ff       	call   80101244 <filealloc>
80103f85:	8b 55 08             	mov    0x8(%ebp),%edx
80103f88:	89 02                	mov    %eax,(%edx)
80103f8a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8d:	8b 00                	mov    (%eax),%eax
80103f8f:	85 c0                	test   %eax,%eax
80103f91:	0f 84 c8 00 00 00    	je     8010405f <pipealloc+0xff>
80103f97:	e8 a8 d2 ff ff       	call   80101244 <filealloc>
80103f9c:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f9f:	89 02                	mov    %eax,(%edx)
80103fa1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fa4:	8b 00                	mov    (%eax),%eax
80103fa6:	85 c0                	test   %eax,%eax
80103fa8:	0f 84 b1 00 00 00    	je     8010405f <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103fae:	e8 74 ee ff ff       	call   80102e27 <kalloc>
80103fb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103fb6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103fba:	0f 84 9e 00 00 00    	je     8010405e <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80103fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc3:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103fca:	00 00 00 
  p->writeopen = 1;
80103fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fd0:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103fd7:	00 00 00 
  p->nwrite = 0;
80103fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fdd:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103fe4:	00 00 00 
  p->nread = 0;
80103fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fea:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103ff1:	00 00 00 
  initlock(&p->lock, "pipe");
80103ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff7:	c7 44 24 04 2c 8b 10 	movl   $0x80108b2c,0x4(%esp)
80103ffe:	80 
80103fff:	89 04 24             	mov    %eax,(%esp)
80104002:	e8 97 11 00 00       	call   8010519e <initlock>
  (*f0)->type = FD_PIPE;
80104007:	8b 45 08             	mov    0x8(%ebp),%eax
8010400a:	8b 00                	mov    (%eax),%eax
8010400c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104012:	8b 45 08             	mov    0x8(%ebp),%eax
80104015:	8b 00                	mov    (%eax),%eax
80104017:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010401b:	8b 45 08             	mov    0x8(%ebp),%eax
8010401e:	8b 00                	mov    (%eax),%eax
80104020:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104024:	8b 45 08             	mov    0x8(%ebp),%eax
80104027:	8b 00                	mov    (%eax),%eax
80104029:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010402c:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010402f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104032:	8b 00                	mov    (%eax),%eax
80104034:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010403a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010403d:	8b 00                	mov    (%eax),%eax
8010403f:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104043:	8b 45 0c             	mov    0xc(%ebp),%eax
80104046:	8b 00                	mov    (%eax),%eax
80104048:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010404c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010404f:	8b 00                	mov    (%eax),%eax
80104051:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104054:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104057:	b8 00 00 00 00       	mov    $0x0,%eax
8010405c:	eb 43                	jmp    801040a1 <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
8010405e:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
8010405f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104063:	74 0b                	je     80104070 <pipealloc+0x110>
    kfree((char*)p);
80104065:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104068:	89 04 24             	mov    %eax,(%esp)
8010406b:	e8 1e ed ff ff       	call   80102d8e <kfree>
  if(*f0)
80104070:	8b 45 08             	mov    0x8(%ebp),%eax
80104073:	8b 00                	mov    (%eax),%eax
80104075:	85 c0                	test   %eax,%eax
80104077:	74 0d                	je     80104086 <pipealloc+0x126>
    fileclose(*f0);
80104079:	8b 45 08             	mov    0x8(%ebp),%eax
8010407c:	8b 00                	mov    (%eax),%eax
8010407e:	89 04 24             	mov    %eax,(%esp)
80104081:	e8 66 d2 ff ff       	call   801012ec <fileclose>
  if(*f1)
80104086:	8b 45 0c             	mov    0xc(%ebp),%eax
80104089:	8b 00                	mov    (%eax),%eax
8010408b:	85 c0                	test   %eax,%eax
8010408d:	74 0d                	je     8010409c <pipealloc+0x13c>
    fileclose(*f1);
8010408f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104092:	8b 00                	mov    (%eax),%eax
80104094:	89 04 24             	mov    %eax,(%esp)
80104097:	e8 50 d2 ff ff       	call   801012ec <fileclose>
  return -1;
8010409c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801040a1:	c9                   	leave  
801040a2:	c3                   	ret    

801040a3 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801040a3:	55                   	push   %ebp
801040a4:	89 e5                	mov    %esp,%ebp
801040a6:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
801040a9:	8b 45 08             	mov    0x8(%ebp),%eax
801040ac:	89 04 24             	mov    %eax,(%esp)
801040af:	e8 0b 11 00 00       	call   801051bf <acquire>
  if(writable){
801040b4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801040b8:	74 1f                	je     801040d9 <pipeclose+0x36>
    p->writeopen = 0;
801040ba:	8b 45 08             	mov    0x8(%ebp),%eax
801040bd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801040c4:	00 00 00 
    wakeup(&p->nread);
801040c7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ca:	05 34 02 00 00       	add    $0x234,%eax
801040cf:	89 04 24             	mov    %eax,(%esp)
801040d2:	e8 5b 0e 00 00       	call   80104f32 <wakeup>
801040d7:	eb 1d                	jmp    801040f6 <pipeclose+0x53>
  } else {
    p->readopen = 0;
801040d9:	8b 45 08             	mov    0x8(%ebp),%eax
801040dc:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801040e3:	00 00 00 
    wakeup(&p->nwrite);
801040e6:	8b 45 08             	mov    0x8(%ebp),%eax
801040e9:	05 38 02 00 00       	add    $0x238,%eax
801040ee:	89 04 24             	mov    %eax,(%esp)
801040f1:	e8 3c 0e 00 00       	call   80104f32 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801040f6:	8b 45 08             	mov    0x8(%ebp),%eax
801040f9:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801040ff:	85 c0                	test   %eax,%eax
80104101:	75 25                	jne    80104128 <pipeclose+0x85>
80104103:	8b 45 08             	mov    0x8(%ebp),%eax
80104106:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010410c:	85 c0                	test   %eax,%eax
8010410e:	75 18                	jne    80104128 <pipeclose+0x85>
    release(&p->lock);
80104110:	8b 45 08             	mov    0x8(%ebp),%eax
80104113:	89 04 24             	mov    %eax,(%esp)
80104116:	e8 06 11 00 00       	call   80105221 <release>
    kfree((char*)p);
8010411b:	8b 45 08             	mov    0x8(%ebp),%eax
8010411e:	89 04 24             	mov    %eax,(%esp)
80104121:	e8 68 ec ff ff       	call   80102d8e <kfree>
80104126:	eb 0b                	jmp    80104133 <pipeclose+0x90>
  } else
    release(&p->lock);
80104128:	8b 45 08             	mov    0x8(%ebp),%eax
8010412b:	89 04 24             	mov    %eax,(%esp)
8010412e:	e8 ee 10 00 00       	call   80105221 <release>
}
80104133:	c9                   	leave  
80104134:	c3                   	ret    

80104135 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104135:	55                   	push   %ebp
80104136:	89 e5                	mov    %esp,%ebp
80104138:	53                   	push   %ebx
80104139:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
8010413c:	8b 45 08             	mov    0x8(%ebp),%eax
8010413f:	89 04 24             	mov    %eax,(%esp)
80104142:	e8 78 10 00 00       	call   801051bf <acquire>
  for(i = 0; i < n; i++){
80104147:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010414e:	e9 a6 00 00 00       	jmp    801041f9 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104153:	8b 45 08             	mov    0x8(%ebp),%eax
80104156:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010415c:	85 c0                	test   %eax,%eax
8010415e:	74 0d                	je     8010416d <pipewrite+0x38>
80104160:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104166:	8b 40 24             	mov    0x24(%eax),%eax
80104169:	85 c0                	test   %eax,%eax
8010416b:	74 15                	je     80104182 <pipewrite+0x4d>
        release(&p->lock);
8010416d:	8b 45 08             	mov    0x8(%ebp),%eax
80104170:	89 04 24             	mov    %eax,(%esp)
80104173:	e8 a9 10 00 00       	call   80105221 <release>
        return -1;
80104178:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010417d:	e9 9d 00 00 00       	jmp    8010421f <pipewrite+0xea>
      }
      wakeup(&p->nread);
80104182:	8b 45 08             	mov    0x8(%ebp),%eax
80104185:	05 34 02 00 00       	add    $0x234,%eax
8010418a:	89 04 24             	mov    %eax,(%esp)
8010418d:	e8 a0 0d 00 00       	call   80104f32 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104192:	8b 45 08             	mov    0x8(%ebp),%eax
80104195:	8b 55 08             	mov    0x8(%ebp),%edx
80104198:	81 c2 38 02 00 00    	add    $0x238,%edx
8010419e:	89 44 24 04          	mov    %eax,0x4(%esp)
801041a2:	89 14 24             	mov    %edx,(%esp)
801041a5:	e8 ac 0c 00 00       	call   80104e56 <sleep>
801041aa:	eb 01                	jmp    801041ad <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801041ac:	90                   	nop
801041ad:	8b 45 08             	mov    0x8(%ebp),%eax
801041b0:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801041b6:	8b 45 08             	mov    0x8(%ebp),%eax
801041b9:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041bf:	05 00 02 00 00       	add    $0x200,%eax
801041c4:	39 c2                	cmp    %eax,%edx
801041c6:	74 8b                	je     80104153 <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801041c8:	8b 45 08             	mov    0x8(%ebp),%eax
801041cb:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041d1:	89 c3                	mov    %eax,%ebx
801041d3:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
801041d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041dc:	03 55 0c             	add    0xc(%ebp),%edx
801041df:	0f b6 0a             	movzbl (%edx),%ecx
801041e2:	8b 55 08             	mov    0x8(%ebp),%edx
801041e5:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
801041e9:	8d 50 01             	lea    0x1(%eax),%edx
801041ec:	8b 45 08             	mov    0x8(%ebp),%eax
801041ef:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801041f5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041fc:	3b 45 10             	cmp    0x10(%ebp),%eax
801041ff:	7c ab                	jl     801041ac <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104201:	8b 45 08             	mov    0x8(%ebp),%eax
80104204:	05 34 02 00 00       	add    $0x234,%eax
80104209:	89 04 24             	mov    %eax,(%esp)
8010420c:	e8 21 0d 00 00       	call   80104f32 <wakeup>
  release(&p->lock);
80104211:	8b 45 08             	mov    0x8(%ebp),%eax
80104214:	89 04 24             	mov    %eax,(%esp)
80104217:	e8 05 10 00 00       	call   80105221 <release>
  return n;
8010421c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010421f:	83 c4 24             	add    $0x24,%esp
80104222:	5b                   	pop    %ebx
80104223:	5d                   	pop    %ebp
80104224:	c3                   	ret    

80104225 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104225:	55                   	push   %ebp
80104226:	89 e5                	mov    %esp,%ebp
80104228:	53                   	push   %ebx
80104229:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
8010422c:	8b 45 08             	mov    0x8(%ebp),%eax
8010422f:	89 04 24             	mov    %eax,(%esp)
80104232:	e8 88 0f 00 00       	call   801051bf <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104237:	eb 3a                	jmp    80104273 <piperead+0x4e>
    if(proc->killed){
80104239:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010423f:	8b 40 24             	mov    0x24(%eax),%eax
80104242:	85 c0                	test   %eax,%eax
80104244:	74 15                	je     8010425b <piperead+0x36>
      release(&p->lock);
80104246:	8b 45 08             	mov    0x8(%ebp),%eax
80104249:	89 04 24             	mov    %eax,(%esp)
8010424c:	e8 d0 0f 00 00       	call   80105221 <release>
      return -1;
80104251:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104256:	e9 b6 00 00 00       	jmp    80104311 <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010425b:	8b 45 08             	mov    0x8(%ebp),%eax
8010425e:	8b 55 08             	mov    0x8(%ebp),%edx
80104261:	81 c2 34 02 00 00    	add    $0x234,%edx
80104267:	89 44 24 04          	mov    %eax,0x4(%esp)
8010426b:	89 14 24             	mov    %edx,(%esp)
8010426e:	e8 e3 0b 00 00       	call   80104e56 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104273:	8b 45 08             	mov    0x8(%ebp),%eax
80104276:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010427c:	8b 45 08             	mov    0x8(%ebp),%eax
8010427f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104285:	39 c2                	cmp    %eax,%edx
80104287:	75 0d                	jne    80104296 <piperead+0x71>
80104289:	8b 45 08             	mov    0x8(%ebp),%eax
8010428c:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104292:	85 c0                	test   %eax,%eax
80104294:	75 a3                	jne    80104239 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104296:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010429d:	eb 49                	jmp    801042e8 <piperead+0xc3>
    if(p->nread == p->nwrite)
8010429f:	8b 45 08             	mov    0x8(%ebp),%eax
801042a2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042a8:	8b 45 08             	mov    0x8(%ebp),%eax
801042ab:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042b1:	39 c2                	cmp    %eax,%edx
801042b3:	74 3d                	je     801042f2 <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801042b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b8:	89 c2                	mov    %eax,%edx
801042ba:	03 55 0c             	add    0xc(%ebp),%edx
801042bd:	8b 45 08             	mov    0x8(%ebp),%eax
801042c0:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042c6:	89 c3                	mov    %eax,%ebx
801042c8:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
801042ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
801042d1:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
801042d6:	88 0a                	mov    %cl,(%edx)
801042d8:	8d 50 01             	lea    0x1(%eax),%edx
801042db:	8b 45 08             	mov    0x8(%ebp),%eax
801042de:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042e4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042eb:	3b 45 10             	cmp    0x10(%ebp),%eax
801042ee:	7c af                	jl     8010429f <piperead+0x7a>
801042f0:	eb 01                	jmp    801042f3 <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
801042f2:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801042f3:	8b 45 08             	mov    0x8(%ebp),%eax
801042f6:	05 38 02 00 00       	add    $0x238,%eax
801042fb:	89 04 24             	mov    %eax,(%esp)
801042fe:	e8 2f 0c 00 00       	call   80104f32 <wakeup>
  release(&p->lock);
80104303:	8b 45 08             	mov    0x8(%ebp),%eax
80104306:	89 04 24             	mov    %eax,(%esp)
80104309:	e8 13 0f 00 00       	call   80105221 <release>
  return i;
8010430e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104311:	83 c4 24             	add    $0x24,%esp
80104314:	5b                   	pop    %ebx
80104315:	5d                   	pop    %ebp
80104316:	c3                   	ret    
	...

80104318 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104318:	55                   	push   %ebp
80104319:	89 e5                	mov    %esp,%ebp
8010431b:	53                   	push   %ebx
8010431c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010431f:	9c                   	pushf  
80104320:	5b                   	pop    %ebx
80104321:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104324:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104327:	83 c4 10             	add    $0x10,%esp
8010432a:	5b                   	pop    %ebx
8010432b:	5d                   	pop    %ebp
8010432c:	c3                   	ret    

8010432d <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010432d:	55                   	push   %ebp
8010432e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104330:	fb                   	sti    
}
80104331:	5d                   	pop    %ebp
80104332:	c3                   	ret    

80104333 <pinit>:
extern void trapret(void);

static void wakeup1(void *chan);
void
pinit(void)
{
80104333:	55                   	push   %ebp
80104334:	89 e5                	mov    %esp,%ebp
80104336:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104339:	c7 44 24 04 31 8b 10 	movl   $0x80108b31,0x4(%esp)
80104340:	80 
80104341:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104348:	e8 51 0e 00 00       	call   8010519e <initlock>
}
8010434d:	c9                   	leave  
8010434e:	c3                   	ret    

8010434f <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010434f:	55                   	push   %ebp
80104350:	89 e5                	mov    %esp,%ebp
80104352:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104355:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010435c:	e8 5e 0e 00 00       	call   801051bf <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104361:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104368:	eb 11                	jmp    8010437b <allocproc+0x2c>
    if(p->state == UNUSED)
8010436a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010436d:	8b 40 0c             	mov    0xc(%eax),%eax
80104370:	85 c0                	test   %eax,%eax
80104372:	74 26                	je     8010439a <allocproc+0x4b>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104374:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
8010437b:	81 7d f4 74 24 11 80 	cmpl   $0x80112474,-0xc(%ebp)
80104382:	72 e6                	jb     8010436a <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104384:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010438b:	e8 91 0e 00 00       	call   80105221 <release>
  return 0;
80104390:	b8 00 00 00 00       	mov    $0x0,%eax
80104395:	e9 b5 00 00 00       	jmp    8010444f <allocproc+0x100>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
8010439a:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010439b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010439e:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801043a5:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801043aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ad:	89 42 10             	mov    %eax,0x10(%edx)
801043b0:	83 c0 01             	add    $0x1,%eax
801043b3:	a3 04 b0 10 80       	mov    %eax,0x8010b004
  release(&ptable.lock);
801043b8:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801043bf:	e8 5d 0e 00 00       	call   80105221 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043c4:	e8 5e ea ff ff       	call   80102e27 <kalloc>
801043c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043cc:	89 42 08             	mov    %eax,0x8(%edx)
801043cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d2:	8b 40 08             	mov    0x8(%eax),%eax
801043d5:	85 c0                	test   %eax,%eax
801043d7:	75 11                	jne    801043ea <allocproc+0x9b>
    p->state = UNUSED;
801043d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043dc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043e3:	b8 00 00 00 00       	mov    $0x0,%eax
801043e8:	eb 65                	jmp    8010444f <allocproc+0x100>
  }
  sp = p->kstack + KSTACKSIZE;
801043ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ed:	8b 40 08             	mov    0x8(%eax),%eax
801043f0:	05 00 10 00 00       	add    $0x1000,%eax
801043f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801043f8:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801043fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104402:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104405:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104409:	ba d4 68 10 80       	mov    $0x801068d4,%edx
8010440e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104411:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104413:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104417:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010441d:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104420:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104423:	8b 40 1c             	mov    0x1c(%eax),%eax
80104426:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010442d:	00 
8010442e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104435:	00 
80104436:	89 04 24             	mov    %eax,(%esp)
80104439:	e8 d0 0f 00 00       	call   8010540e <memset>
  p->context->eip = (uint)forkret;
8010443e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104441:	8b 40 1c             	mov    0x1c(%eax),%eax
80104444:	ba 2a 4e 10 80       	mov    $0x80104e2a,%edx
80104449:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010444c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010444f:	c9                   	leave  
80104450:	c3                   	ret    

80104451 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104451:	55                   	push   %ebp
80104452:	89 e5                	mov    %esp,%ebp
80104454:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104457:	e8 f3 fe ff ff       	call   8010434f <allocproc>
8010445c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
8010445f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104462:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm(kalloc)) == 0)
80104467:	c7 04 24 27 2e 10 80 	movl   $0x80102e27,(%esp)
8010446e:	e8 a2 3b 00 00       	call   80108015 <setupkvm>
80104473:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104476:	89 42 04             	mov    %eax,0x4(%edx)
80104479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447c:	8b 40 04             	mov    0x4(%eax),%eax
8010447f:	85 c0                	test   %eax,%eax
80104481:	75 0c                	jne    8010448f <userinit+0x3e>
    panic("userinit: out of memory?");
80104483:	c7 04 24 38 8b 10 80 	movl   $0x80108b38,(%esp)
8010448a:	e8 ae c0 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010448f:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104497:	8b 40 04             	mov    0x4(%eax),%eax
8010449a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010449e:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
801044a5:	80 
801044a6:	89 04 24             	mov    %eax,(%esp)
801044a9:	e8 bf 3d 00 00       	call   8010826d <inituvm>
  p->sz = PGSIZE;
801044ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b1:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ba:	8b 40 18             	mov    0x18(%eax),%eax
801044bd:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801044c4:	00 
801044c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801044cc:	00 
801044cd:	89 04 24             	mov    %eax,(%esp)
801044d0:	e8 39 0f 00 00       	call   8010540e <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801044d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d8:	8b 40 18             	mov    0x18(%eax),%eax
801044db:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801044e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e4:	8b 40 18             	mov    0x18(%eax),%eax
801044e7:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801044ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f0:	8b 40 18             	mov    0x18(%eax),%eax
801044f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044f6:	8b 52 18             	mov    0x18(%edx),%edx
801044f9:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801044fd:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104504:	8b 40 18             	mov    0x18(%eax),%eax
80104507:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010450a:	8b 52 18             	mov    0x18(%edx),%edx
8010450d:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104511:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104518:	8b 40 18             	mov    0x18(%eax),%eax
8010451b:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104522:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104525:	8b 40 18             	mov    0x18(%eax),%eax
80104528:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010452f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104532:	8b 40 18             	mov    0x18(%eax),%eax
80104535:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010453c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453f:	83 c0 6c             	add    $0x6c,%eax
80104542:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104549:	00 
8010454a:	c7 44 24 04 51 8b 10 	movl   $0x80108b51,0x4(%esp)
80104551:	80 
80104552:	89 04 24             	mov    %eax,(%esp)
80104555:	e8 e4 10 00 00       	call   8010563e <safestrcpy>
  p->cwd = namei("/");
8010455a:	c7 04 24 5a 8b 10 80 	movl   $0x80108b5a,(%esp)
80104561:	e8 cc e1 ff ff       	call   80102732 <namei>
80104566:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104569:	89 42 68             	mov    %eax,0x68(%edx)
  p->state = RUNNABLE;
8010456c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104576:	c9                   	leave  
80104577:	c3                   	ret    

80104578 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104578:	55                   	push   %ebp
80104579:	89 e5                	mov    %esp,%ebp
8010457b:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
8010457e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104584:	8b 00                	mov    (%eax),%eax
80104586:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104589:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010458d:	7e 34                	jle    801045c3 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
8010458f:	8b 45 08             	mov    0x8(%ebp),%eax
80104592:	89 c2                	mov    %eax,%edx
80104594:	03 55 f4             	add    -0xc(%ebp),%edx
80104597:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010459d:	8b 40 04             	mov    0x4(%eax),%eax
801045a0:	89 54 24 08          	mov    %edx,0x8(%esp)
801045a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045a7:	89 54 24 04          	mov    %edx,0x4(%esp)
801045ab:	89 04 24             	mov    %eax,(%esp)
801045ae:	e8 34 3e 00 00       	call   801083e7 <allocuvm>
801045b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045ba:	75 41                	jne    801045fd <growproc+0x85>
      return -1;
801045bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045c1:	eb 58                	jmp    8010461b <growproc+0xa3>
  } else if(n < 0){
801045c3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045c7:	79 34                	jns    801045fd <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801045c9:	8b 45 08             	mov    0x8(%ebp),%eax
801045cc:	89 c2                	mov    %eax,%edx
801045ce:	03 55 f4             	add    -0xc(%ebp),%edx
801045d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045d7:	8b 40 04             	mov    0x4(%eax),%eax
801045da:	89 54 24 08          	mov    %edx,0x8(%esp)
801045de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045e1:	89 54 24 04          	mov    %edx,0x4(%esp)
801045e5:	89 04 24             	mov    %eax,(%esp)
801045e8:	e8 d4 3e 00 00       	call   801084c1 <deallocuvm>
801045ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045f4:	75 07                	jne    801045fd <growproc+0x85>
      return -1;
801045f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045fb:	eb 1e                	jmp    8010461b <growproc+0xa3>
  }
  proc->sz = sz;
801045fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104603:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104606:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104608:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010460e:	89 04 24             	mov    %eax,(%esp)
80104611:	e8 f0 3a 00 00       	call   80108106 <switchuvm>
  return 0;
80104616:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010461b:	c9                   	leave  
8010461c:	c3                   	ret    

8010461d <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010461d:	55                   	push   %ebp
8010461e:	89 e5                	mov    %esp,%ebp
80104620:	57                   	push   %edi
80104621:	56                   	push   %esi
80104622:	53                   	push   %ebx
80104623:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104626:	e8 24 fd ff ff       	call   8010434f <allocproc>
8010462b:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010462e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104632:	75 0a                	jne    8010463e <fork+0x21>
    return -1;
80104634:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104639:	e9 6c 01 00 00       	jmp    801047aa <fork+0x18d>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010463e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104644:	8b 10                	mov    (%eax),%edx
80104646:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010464c:	8b 40 04             	mov    0x4(%eax),%eax
8010464f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104653:	89 04 24             	mov    %eax,(%esp)
80104656:	e8 f6 3f 00 00       	call   80108651 <copyuvm>
8010465b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010465e:	89 42 04             	mov    %eax,0x4(%edx)
80104661:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104664:	8b 40 04             	mov    0x4(%eax),%eax
80104667:	85 c0                	test   %eax,%eax
80104669:	75 2c                	jne    80104697 <fork+0x7a>
    kfree(np->kstack);
8010466b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010466e:	8b 40 08             	mov    0x8(%eax),%eax
80104671:	89 04 24             	mov    %eax,(%esp)
80104674:	e8 15 e7 ff ff       	call   80102d8e <kfree>
    np->kstack = 0;
80104679:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010467c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104683:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104686:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010468d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104692:	e9 13 01 00 00       	jmp    801047aa <fork+0x18d>
  }
  np->sz = proc->sz;
80104697:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010469d:	8b 10                	mov    (%eax),%edx
8010469f:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a2:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801046a4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ae:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801046b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046b4:	8b 50 18             	mov    0x18(%eax),%edx
801046b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046bd:	8b 40 18             	mov    0x18(%eax),%eax
801046c0:	89 c3                	mov    %eax,%ebx
801046c2:	b8 13 00 00 00       	mov    $0x13,%eax
801046c7:	89 d7                	mov    %edx,%edi
801046c9:	89 de                	mov    %ebx,%esi
801046cb:	89 c1                	mov    %eax,%ecx
801046cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801046cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046d2:	8b 40 18             	mov    0x18(%eax),%eax
801046d5:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801046dc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801046e3:	eb 3d                	jmp    80104722 <fork+0x105>
    if(proc->ofile[i])
801046e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046ee:	83 c2 08             	add    $0x8,%edx
801046f1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046f5:	85 c0                	test   %eax,%eax
801046f7:	74 25                	je     8010471e <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
801046f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104702:	83 c2 08             	add    $0x8,%edx
80104705:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104709:	89 04 24             	mov    %eax,(%esp)
8010470c:	e8 93 cb ff ff       	call   801012a4 <filedup>
80104711:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104714:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104717:	83 c1 08             	add    $0x8,%ecx
8010471a:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010471e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104722:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104726:	7e bd                	jle    801046e5 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104728:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010472e:	8b 40 68             	mov    0x68(%eax),%eax
80104731:	89 04 24             	mov    %eax,(%esp)
80104734:	e8 25 d4 ff ff       	call   80101b5e <idup>
80104739:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010473c:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
8010473f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104742:	8b 40 10             	mov    0x10(%eax),%eax
80104745:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
80104748:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010474b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104752:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104758:	8d 50 6c             	lea    0x6c(%eax),%edx
8010475b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010475e:	83 c0 6c             	add    $0x6c,%eax
80104761:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104768:	00 
80104769:	89 54 24 04          	mov    %edx,0x4(%esp)
8010476d:	89 04 24             	mov    %eax,(%esp)
80104770:	e8 c9 0e 00 00       	call   8010563e <safestrcpy>
  acquire(&tickslock);
80104775:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
8010477c:	e8 3e 0a 00 00       	call   801051bf <acquire>
  np->ctime = ticks;
80104781:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
80104786:	89 c2                	mov    %eax,%edx
80104788:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010478b:	89 50 7c             	mov    %edx,0x7c(%eax)
  release(&tickslock);
8010478e:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80104795:	e8 87 0a 00 00       	call   80105221 <release>
  np->rtime = 0;
8010479a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010479d:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
801047a4:	00 00 00 
    case _3Q:
      np->priority = HIGH;
      np->qvalue = 0;
      break;
  }
  return pid;
801047a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801047aa:	83 c4 2c             	add    $0x2c,%esp
801047ad:	5b                   	pop    %ebx
801047ae:	5e                   	pop    %esi
801047af:	5f                   	pop    %edi
801047b0:	5d                   	pop    %ebp
801047b1:	c3                   	ret    

801047b2 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801047b2:	55                   	push   %ebp
801047b3:	89 e5                	mov    %esp,%ebp
801047b5:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;
  
  if(proc == initproc)
801047b8:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047bf:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801047c4:	39 c2                	cmp    %eax,%edx
801047c6:	75 0c                	jne    801047d4 <exit+0x22>
    panic("init exiting");
801047c8:	c7 04 24 5c 8b 10 80 	movl   $0x80108b5c,(%esp)
801047cf:	e8 69 bd ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801047d4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801047db:	eb 44                	jmp    80104821 <exit+0x6f>
    if(proc->ofile[fd]){
801047dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047e6:	83 c2 08             	add    $0x8,%edx
801047e9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047ed:	85 c0                	test   %eax,%eax
801047ef:	74 2c                	je     8010481d <exit+0x6b>
      fileclose(proc->ofile[fd]);
801047f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047fa:	83 c2 08             	add    $0x8,%edx
801047fd:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104801:	89 04 24             	mov    %eax,(%esp)
80104804:	e8 e3 ca ff ff       	call   801012ec <fileclose>
      proc->ofile[fd] = 0;
80104809:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010480f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104812:	83 c2 08             	add    $0x8,%edx
80104815:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010481c:	00 
  
  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010481d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104821:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104825:	7e b6                	jle    801047dd <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
80104827:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010482d:	8b 40 68             	mov    0x68(%eax),%eax
80104830:	89 04 24             	mov    %eax,(%esp)
80104833:	e8 0b d5 ff ff       	call   80101d43 <iput>
  proc->cwd = 0;
80104838:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010483e:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104845:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010484c:	e8 6e 09 00 00       	call   801051bf <acquire>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104851:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104857:	8b 40 14             	mov    0x14(%eax),%eax
8010485a:	89 04 24             	mov    %eax,(%esp)
8010485d:	e8 8f 06 00 00       	call   80104ef1 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104862:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104869:	eb 3b                	jmp    801048a6 <exit+0xf4>
    if(p->parent == proc){
8010486b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010486e:	8b 50 14             	mov    0x14(%eax),%edx
80104871:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104877:	39 c2                	cmp    %eax,%edx
80104879:	75 24                	jne    8010489f <exit+0xed>
      p->parent = initproc;
8010487b:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
80104881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104884:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010488a:	8b 40 0c             	mov    0xc(%eax),%eax
8010488d:	83 f8 05             	cmp    $0x5,%eax
80104890:	75 0d                	jne    8010489f <exit+0xed>
        wakeup1(initproc);
80104892:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80104897:	89 04 24             	mov    %eax,(%esp)
8010489a:	e8 52 06 00 00       	call   80104ef1 <wakeup1>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010489f:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
801048a6:	81 7d f4 74 24 11 80 	cmpl   $0x80112474,-0xc(%ebp)
801048ad:	72 bc                	jb     8010486b <exit+0xb9>
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }
  // Jump into the scheduler, never to return.
  proc->priority = -1;
801048af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048b5:	c7 80 8c 00 00 00 ff 	movl   $0xffffffff,0x8c(%eax)
801048bc:	ff ff ff 
  acquire(&tickslock);
801048bf:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
801048c6:	e8 f4 08 00 00       	call   801051bf <acquire>
  proc->etime = ticks;
801048cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048d1:	8b 15 c0 2c 11 80    	mov    0x80112cc0,%edx
801048d7:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  release(&tickslock);
801048dd:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
801048e4:	e8 38 09 00 00       	call   80105221 <release>
  proc->state = ZOMBIE;
801048e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ef:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801048f6:	e8 4b 04 00 00       	call   80104d46 <sched>
  panic("zombie exit");
801048fb:	c7 04 24 69 8b 10 80 	movl   $0x80108b69,(%esp)
80104902:	e8 36 bc ff ff       	call   8010053d <panic>

80104907 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104907:	55                   	push   %ebp
80104908:	89 e5                	mov    %esp,%ebp
8010490a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
8010490d:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104914:	e8 a6 08 00 00       	call   801051bf <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104919:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104920:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104927:	e9 9d 00 00 00       	jmp    801049c9 <wait+0xc2>
      if(p->parent != proc)
8010492c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492f:	8b 50 14             	mov    0x14(%eax),%edx
80104932:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104938:	39 c2                	cmp    %eax,%edx
8010493a:	0f 85 81 00 00 00    	jne    801049c1 <wait+0xba>
        continue;
      havekids = 1;
80104940:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494a:	8b 40 0c             	mov    0xc(%eax),%eax
8010494d:	83 f8 05             	cmp    $0x5,%eax
80104950:	75 70                	jne    801049c2 <wait+0xbb>
        // Found one.
        pid = p->pid;
80104952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104955:	8b 40 10             	mov    0x10(%eax),%eax
80104958:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
8010495b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495e:	8b 40 08             	mov    0x8(%eax),%eax
80104961:	89 04 24             	mov    %eax,(%esp)
80104964:	e8 25 e4 ff ff       	call   80102d8e <kfree>
        p->kstack = 0;
80104969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104976:	8b 40 04             	mov    0x4(%eax),%eax
80104979:	89 04 24             	mov    %eax,(%esp)
8010497c:	e8 fc 3b 00 00       	call   8010857d <freevm>
        p->state = UNUSED;
80104981:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104984:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
8010498b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498e:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104995:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104998:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010499f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a2:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801049a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a9:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
801049b0:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801049b7:	e8 65 08 00 00       	call   80105221 <release>
        return pid;
801049bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049bf:	eb 56                	jmp    80104a17 <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801049c1:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049c2:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
801049c9:	81 7d f4 74 24 11 80 	cmpl   $0x80112474,-0xc(%ebp)
801049d0:	0f 82 56 ff ff ff    	jb     8010492c <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801049d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049da:	74 0d                	je     801049e9 <wait+0xe2>
801049dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049e2:	8b 40 24             	mov    0x24(%eax),%eax
801049e5:	85 c0                	test   %eax,%eax
801049e7:	74 13                	je     801049fc <wait+0xf5>
      release(&ptable.lock);
801049e9:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801049f0:	e8 2c 08 00 00       	call   80105221 <release>
      return -1;
801049f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049fa:	eb 1b                	jmp    80104a17 <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801049fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a02:	c7 44 24 04 40 ff 10 	movl   $0x8010ff40,0x4(%esp)
80104a09:	80 
80104a0a:	89 04 24             	mov    %eax,(%esp)
80104a0d:	e8 44 04 00 00       	call   80104e56 <sleep>
  }
80104a12:	e9 02 ff ff ff       	jmp    80104919 <wait+0x12>
}
80104a17:	c9                   	leave  
80104a18:	c3                   	ret    

80104a19 <wait2>:

int
wait2(int *wtime, int *rtime)
{
80104a19:	55                   	push   %ebp
80104a1a:	89 e5                	mov    %esp,%ebp
80104a1c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a1f:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104a26:	e8 94 07 00 00       	call   801051bf <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a2b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a32:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104a39:	e9 d0 00 00 00       	jmp    80104b0e <wait2+0xf5>
      if(p->parent != proc)
80104a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a41:	8b 50 14             	mov    0x14(%eax),%edx
80104a44:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a4a:	39 c2                	cmp    %eax,%edx
80104a4c:	0f 85 b4 00 00 00    	jne    80104b06 <wait2+0xed>
        continue;
      havekids = 1;
80104a52:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a5c:	8b 40 0c             	mov    0xc(%eax),%eax
80104a5f:	83 f8 05             	cmp    $0x5,%eax
80104a62:	0f 85 9f 00 00 00    	jne    80104b07 <wait2+0xee>
	*rtime = p->rtime;
80104a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a6b:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104a71:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a74:	89 10                	mov    %edx,(%eax)
	*wtime = p->etime - p->ctime - p->rtime;
80104a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a79:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a82:	8b 40 7c             	mov    0x7c(%eax),%eax
80104a85:	29 c2                	sub    %eax,%edx
80104a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8a:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104a90:	29 c2                	sub    %eax,%edx
80104a92:	8b 45 08             	mov    0x8(%ebp),%eax
80104a95:	89 10                	mov    %edx,(%eax)
	// Found one.
        pid = p->pid;
80104a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9a:	8b 40 10             	mov    0x10(%eax),%eax
80104a9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa3:	8b 40 08             	mov    0x8(%eax),%eax
80104aa6:	89 04 24             	mov    %eax,(%esp)
80104aa9:	e8 e0 e2 ff ff       	call   80102d8e <kfree>
        p->kstack = 0;
80104aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abb:	8b 40 04             	mov    0x4(%eax),%eax
80104abe:	89 04 24             	mov    %eax,(%esp)
80104ac1:	e8 b7 3a 00 00       	call   8010857d <freevm>
        p->state = UNUSED;
80104ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad3:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104add:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae7:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aee:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104af5:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104afc:	e8 20 07 00 00       	call   80105221 <release>
        return pid;
80104b01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b04:	eb 56                	jmp    80104b5c <wait2+0x143>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104b06:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b07:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80104b0e:	81 7d f4 74 24 11 80 	cmpl   $0x80112474,-0xc(%ebp)
80104b15:	0f 82 23 ff ff ff    	jb     80104a3e <wait2+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b1b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b1f:	74 0d                	je     80104b2e <wait2+0x115>
80104b21:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b27:	8b 40 24             	mov    0x24(%eax),%eax
80104b2a:	85 c0                	test   %eax,%eax
80104b2c:	74 13                	je     80104b41 <wait2+0x128>
      release(&ptable.lock);
80104b2e:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104b35:	e8 e7 06 00 00       	call   80105221 <release>
      return -1;
80104b3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b3f:	eb 1b                	jmp    80104b5c <wait2+0x143>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b41:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b47:	c7 44 24 04 40 ff 10 	movl   $0x8010ff40,0x4(%esp)
80104b4e:	80 
80104b4f:	89 04 24             	mov    %eax,(%esp)
80104b52:	e8 ff 02 00 00       	call   80104e56 <sleep>
  }
80104b57:	e9 cf fe ff ff       	jmp    80104a2b <wait2+0x12>
  
  
  return proc->pid;
}
80104b5c:	c9                   	leave  
80104b5d:	c3                   	ret    

80104b5e <register_handler>:

void
register_handler(sighandler_t sighandler)
{
80104b5e:	55                   	push   %ebp
80104b5f:	89 e5                	mov    %esp,%ebp
80104b61:	83 ec 28             	sub    $0x28,%esp
  char* addr = uva2ka(proc->pgdir, (char*)proc->tf->esp);
80104b64:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b6a:	8b 40 18             	mov    0x18(%eax),%eax
80104b6d:	8b 40 44             	mov    0x44(%eax),%eax
80104b70:	89 c2                	mov    %eax,%edx
80104b72:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b78:	8b 40 04             	mov    0x4(%eax),%eax
80104b7b:	89 54 24 04          	mov    %edx,0x4(%esp)
80104b7f:	89 04 24             	mov    %eax,(%esp)
80104b82:	e8 db 3b 00 00       	call   80108762 <uva2ka>
80104b87:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if ((proc->tf->esp & 0xFFF) == 0)
80104b8a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b90:	8b 40 18             	mov    0x18(%eax),%eax
80104b93:	8b 40 44             	mov    0x44(%eax),%eax
80104b96:	25 ff 0f 00 00       	and    $0xfff,%eax
80104b9b:	85 c0                	test   %eax,%eax
80104b9d:	75 0c                	jne    80104bab <register_handler+0x4d>
    panic("esp_offset == 0");
80104b9f:	c7 04 24 75 8b 10 80 	movl   $0x80108b75,(%esp)
80104ba6:	e8 92 b9 ff ff       	call   8010053d <panic>

    /* open a new frame */
  *(int*)(addr + ((proc->tf->esp - 4) & 0xFFF))
80104bab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bb1:	8b 40 18             	mov    0x18(%eax),%eax
80104bb4:	8b 40 44             	mov    0x44(%eax),%eax
80104bb7:	83 e8 04             	sub    $0x4,%eax
80104bba:	25 ff 0f 00 00       	and    $0xfff,%eax
80104bbf:	03 45 f4             	add    -0xc(%ebp),%eax
          = proc->tf->eip;
80104bc2:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104bc9:	8b 52 18             	mov    0x18(%edx),%edx
80104bcc:	8b 52 38             	mov    0x38(%edx),%edx
80104bcf:	89 10                	mov    %edx,(%eax)
  proc->tf->esp -= 4;
80104bd1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bd7:	8b 40 18             	mov    0x18(%eax),%eax
80104bda:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104be1:	8b 52 18             	mov    0x18(%edx),%edx
80104be4:	8b 52 44             	mov    0x44(%edx),%edx
80104be7:	83 ea 04             	sub    $0x4,%edx
80104bea:	89 50 44             	mov    %edx,0x44(%eax)

    /* update eip */
  proc->tf->eip = (uint)sighandler;
80104bed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bf3:	8b 40 18             	mov    0x18(%eax),%eax
80104bf6:	8b 55 08             	mov    0x8(%ebp),%edx
80104bf9:	89 50 38             	mov    %edx,0x38(%eax)
}
80104bfc:	c9                   	leave  
80104bfd:	c3                   	ret    

80104bfe <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104bfe:	55                   	push   %ebp
80104bff:	89 e5                	mov    %esp,%ebp
80104c01:	83 ec 48             	sub    $0x48,%esp
  struct proc *p;
  struct proc *medium;
  struct proc *high;
  struct proc *head = 0;
80104c04:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  struct proc *t = ptable.proc;
80104c0b:	c7 45 ec 74 ff 10 80 	movl   $0x8010ff74,-0x14(%ebp)
  uint grt_min;
  
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c12:	e8 16 f7 ff ff       	call   8010432d <sti>
    highflag = 0;
80104c17:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    mediumflag = 0;
80104c1e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    lowflag = 0;
80104c25:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    frr_min = 0;
80104c2c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
    grt_min = 0;
80104c33:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    
    if(head && p==head)
80104c3a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c3e:	74 17                	je     80104c57 <scheduler+0x59>
80104c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c43:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104c46:	75 0f                	jne    80104c57 <scheduler+0x59>
      t = ++head;
80104c48:	81 45 f0 94 00 00 00 	addl   $0x94,-0x10(%ebp)
80104c4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c52:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104c55:	eb 0c                	jmp    80104c63 <scheduler+0x65>
    else if(head)
80104c57:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c5b:	74 06                	je     80104c63 <scheduler+0x65>
      t = head;
80104c5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c60:	89 45 ec             	mov    %eax,-0x14(%ebp)
    
    acquire(&tickslock);
80104c63:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80104c6a:	e8 50 05 00 00       	call   801051bf <acquire>
    currentime = ticks;
80104c6f:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
80104c74:	89 45 d0             	mov    %eax,-0x30(%ebp)
    release(&tickslock);  
80104c77:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80104c7e:	e8 9e 05 00 00       	call   80105221 <release>
    int i=0;
80104c83:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    acquire(&ptable.lock); 
80104c8a:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104c91:	e8 29 05 00 00       	call   801051bf <acquire>
    for(; i<NPROC; i++)			// Loop over process table looking for process to run.
80104c96:	e9 90 00 00 00       	jmp    80104d2b <scheduler+0x12d>
    {
      if(t >= &ptable.proc[NPROC])
80104c9b:	81 7d ec 74 24 11 80 	cmpl   $0x80112474,-0x14(%ebp)
80104ca2:	72 07                	jb     80104cab <scheduler+0xad>
	t = ptable.proc;
80104ca4:	c7 45 ec 74 ff 10 80 	movl   $0x8010ff74,-0x14(%ebp)
      if(t->state != RUNNABLE)
80104cab:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cae:	8b 40 0c             	mov    0xc(%eax),%eax
80104cb1:	83 f8 03             	cmp    $0x3,%eax
80104cb4:	74 09                	je     80104cbf <scheduler+0xc1>
      {
	t++;
80104cb6:	81 45 ec 94 00 00 00 	addl   $0x94,-0x14(%ebp)
	continue;
80104cbd:	eb 68                	jmp    80104d27 <scheduler+0x129>
      }
      switch(SCHEDFLAG)
      {
	default:
	  p = t;
80104cbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	  proc = p;
80104cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc8:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
	  switchuvm(p);
80104cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd1:	89 04 24             	mov    %eax,(%esp)
80104cd4:	e8 2d 34 00 00       	call   80108106 <switchuvm>
	  p->state = RUNNING;
80104cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cdc:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
	  p->quanta = QUANTA;
80104ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce6:	c7 80 88 00 00 00 05 	movl   $0x5,0x88(%eax)
80104ced:	00 00 00 
	  swtch(&cpu->scheduler, proc->context);
80104cf0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cf6:	8b 40 1c             	mov    0x1c(%eax),%eax
80104cf9:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104d00:	83 c2 04             	add    $0x4,%edx
80104d03:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d07:	89 14 24             	mov    %edx,(%esp)
80104d0a:	e8 a5 09 00 00       	call   801056b4 <swtch>
	  switchkvm();
80104d0f:	e8 d5 33 00 00       	call   801080e9 <switchkvm>
	  // Process is done running for now.
	  // It should have changed its p->state before coming back.
	  proc = 0;
80104d14:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104d1b:	00 00 00 00 
	  break;
80104d1f:	90                   	nop
	    lowflag = 1;
	    t->quanta = QUANTA;
	  }
	  break;
      }
      t++;
80104d20:	81 45 ec 94 00 00 00 	addl   $0x94,-0x14(%ebp)
    acquire(&tickslock);
    currentime = ticks;
    release(&tickslock);  
    int i=0;
    acquire(&ptable.lock); 
    for(; i<NPROC; i++)			// Loop over process table looking for process to run.
80104d27:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80104d2b:	83 7d e8 3f          	cmpl   $0x3f,-0x18(%ebp)
80104d2f:	0f 8e 66 ff ff ff    	jle    80104c9b <scheduler+0x9d>
	// Process is done running for now.
	// It should have changed its p->state before coming back.
	proc = 0;
      }
    }
    release(&ptable.lock);
80104d35:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104d3c:	e8 e0 04 00 00       	call   80105221 <release>
    }
80104d41:	e9 cc fe ff ff       	jmp    80104c12 <scheduler+0x14>

80104d46 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104d46:	55                   	push   %ebp
80104d47:	89 e5                	mov    %esp,%ebp
80104d49:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104d4c:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104d53:	e8 85 05 00 00       	call   801052dd <holding>
80104d58:	85 c0                	test   %eax,%eax
80104d5a:	75 0c                	jne    80104d68 <sched+0x22>
    panic("sched ptable.lock");
80104d5c:	c7 04 24 85 8b 10 80 	movl   $0x80108b85,(%esp)
80104d63:	e8 d5 b7 ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80104d68:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d6e:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104d74:	83 f8 01             	cmp    $0x1,%eax
80104d77:	74 0c                	je     80104d85 <sched+0x3f>
    panic("sched locks");
80104d79:	c7 04 24 97 8b 10 80 	movl   $0x80108b97,(%esp)
80104d80:	e8 b8 b7 ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104d85:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d8b:	8b 40 0c             	mov    0xc(%eax),%eax
80104d8e:	83 f8 04             	cmp    $0x4,%eax
80104d91:	75 0c                	jne    80104d9f <sched+0x59>
    panic("sched running");
80104d93:	c7 04 24 a3 8b 10 80 	movl   $0x80108ba3,(%esp)
80104d9a:	e8 9e b7 ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104d9f:	e8 74 f5 ff ff       	call   80104318 <readeflags>
80104da4:	25 00 02 00 00       	and    $0x200,%eax
80104da9:	85 c0                	test   %eax,%eax
80104dab:	74 0c                	je     80104db9 <sched+0x73>
    panic("sched interruptible");
80104dad:	c7 04 24 b1 8b 10 80 	movl   $0x80108bb1,(%esp)
80104db4:	e8 84 b7 ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80104db9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104dbf:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104dc5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104dc8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104dce:	8b 40 04             	mov    0x4(%eax),%eax
80104dd1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104dd8:	83 c2 1c             	add    $0x1c,%edx
80104ddb:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ddf:	89 14 24             	mov    %edx,(%esp)
80104de2:	e8 cd 08 00 00       	call   801056b4 <swtch>
  cpu->intena = intena;
80104de7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ded:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104df0:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104df6:	c9                   	leave  
80104df7:	c3                   	ret    

80104df8 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104df8:	55                   	push   %ebp
80104df9:	89 e5                	mov    %esp,%ebp
80104dfb:	83 ec 18             	sub    $0x18,%esp
	proc->qvalue = ticks;
	release(&tickslock);
      }
      break;
  }
  acquire(&ptable.lock);  //DOC: yieldlock
80104dfe:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e05:	e8 b5 03 00 00       	call   801051bf <acquire>
  proc->state = RUNNABLE;
80104e0a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e10:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104e17:	e8 2a ff ff ff       	call   80104d46 <sched>
  release(&ptable.lock);
80104e1c:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e23:	e8 f9 03 00 00       	call   80105221 <release>
  
}
80104e28:	c9                   	leave  
80104e29:	c3                   	ret    

80104e2a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104e2a:	55                   	push   %ebp
80104e2b:	89 e5                	mov    %esp,%ebp
80104e2d:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104e30:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e37:	e8 e5 03 00 00       	call   80105221 <release>

  if (first) {
80104e3c:	a1 20 b0 10 80       	mov    0x8010b020,%eax
80104e41:	85 c0                	test   %eax,%eax
80104e43:	74 0f                	je     80104e54 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104e45:	c7 05 20 b0 10 80 00 	movl   $0x0,0x8010b020
80104e4c:	00 00 00 
    initlog();
80104e4f:	e8 e4 e4 ff ff       	call   80103338 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104e54:	c9                   	leave  
80104e55:	c3                   	ret    

80104e56 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e56:	55                   	push   %ebp
80104e57:	89 e5                	mov    %esp,%ebp
80104e59:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104e5c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e62:	85 c0                	test   %eax,%eax
80104e64:	75 0c                	jne    80104e72 <sleep+0x1c>
    panic("sleep");
80104e66:	c7 04 24 c5 8b 10 80 	movl   $0x80108bc5,(%esp)
80104e6d:	e8 cb b6 ff ff       	call   8010053d <panic>

  if(lk == 0)
80104e72:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e76:	75 0c                	jne    80104e84 <sleep+0x2e>
    panic("sleep without lk");
80104e78:	c7 04 24 cb 8b 10 80 	movl   $0x80108bcb,(%esp)
80104e7f:	e8 b9 b6 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104e84:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104e8b:	74 17                	je     80104ea4 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104e8d:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e94:	e8 26 03 00 00       	call   801051bf <acquire>
    release(lk);
80104e99:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e9c:	89 04 24             	mov    %eax,(%esp)
80104e9f:	e8 7d 03 00 00       	call   80105221 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104ea4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eaa:	8b 55 08             	mov    0x8(%ebp),%edx
80104ead:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104eb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eb6:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104ebd:	e8 84 fe ff ff       	call   80104d46 <sched>

  // Tidy up.
  proc->chan = 0;
80104ec2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ec8:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104ecf:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104ed6:	74 17                	je     80104eef <sleep+0x99>
    release(&ptable.lock);
80104ed8:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104edf:	e8 3d 03 00 00       	call   80105221 <release>
    acquire(lk);
80104ee4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ee7:	89 04 24             	mov    %eax,(%esp)
80104eea:	e8 d0 02 00 00       	call   801051bf <acquire>
  }
}
80104eef:	c9                   	leave  
80104ef0:	c3                   	ret    

80104ef1 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104ef1:	55                   	push   %ebp
80104ef2:	89 e5                	mov    %esp,%ebp
80104ef4:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ef7:	c7 45 fc 74 ff 10 80 	movl   $0x8010ff74,-0x4(%ebp)
80104efe:	eb 27                	jmp    80104f27 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104f00:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f03:	8b 40 0c             	mov    0xc(%eax),%eax
80104f06:	83 f8 02             	cmp    $0x2,%eax
80104f09:	75 15                	jne    80104f20 <wakeup1+0x2f>
80104f0b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f0e:	8b 40 20             	mov    0x20(%eax),%eax
80104f11:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f14:	75 0a                	jne    80104f20 <wakeup1+0x2f>
    {
      p->state = RUNNABLE;
80104f16:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f19:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f20:	81 45 fc 94 00 00 00 	addl   $0x94,-0x4(%ebp)
80104f27:	81 7d fc 74 24 11 80 	cmpl   $0x80112474,-0x4(%ebp)
80104f2e:	72 d0                	jb     80104f00 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
    {
      p->state = RUNNABLE;
    }
}
80104f30:	c9                   	leave  
80104f31:	c3                   	ret    

80104f32 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f32:	55                   	push   %ebp
80104f33:	89 e5                	mov    %esp,%ebp
80104f35:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104f38:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f3f:	e8 7b 02 00 00       	call   801051bf <acquire>
  wakeup1(chan);
80104f44:	8b 45 08             	mov    0x8(%ebp),%eax
80104f47:	89 04 24             	mov    %eax,(%esp)
80104f4a:	e8 a2 ff ff ff       	call   80104ef1 <wakeup1>
  release(&ptable.lock);
80104f4f:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f56:	e8 c6 02 00 00       	call   80105221 <release>
}
80104f5b:	c9                   	leave  
80104f5c:	c3                   	ret    

80104f5d <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f5d:	55                   	push   %ebp
80104f5e:	89 e5                	mov    %esp,%ebp
80104f60:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f63:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f6a:	e8 50 02 00 00       	call   801051bf <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f6f:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104f76:	eb 44                	jmp    80104fbc <kill+0x5f>
    if(p->pid == pid){
80104f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f7b:	8b 40 10             	mov    0x10(%eax),%eax
80104f7e:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f81:	75 32                	jne    80104fb5 <kill+0x58>
      p->killed = 1;
80104f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f86:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f90:	8b 40 0c             	mov    0xc(%eax),%eax
80104f93:	83 f8 02             	cmp    $0x2,%eax
80104f96:	75 0a                	jne    80104fa2 <kill+0x45>
        p->state = RUNNABLE;
80104f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f9b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104fa2:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104fa9:	e8 73 02 00 00       	call   80105221 <release>
      return 0;
80104fae:	b8 00 00 00 00       	mov    $0x0,%eax
80104fb3:	eb 21                	jmp    80104fd6 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fb5:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80104fbc:	81 7d f4 74 24 11 80 	cmpl   $0x80112474,-0xc(%ebp)
80104fc3:	72 b3                	jb     80104f78 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104fc5:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104fcc:	e8 50 02 00 00       	call   80105221 <release>
  return -1;
80104fd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104fd6:	c9                   	leave  
80104fd7:	c3                   	ret    

80104fd8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104fd8:	55                   	push   %ebp
80104fd9:	89 e5                	mov    %esp,%ebp
80104fdb:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fde:	c7 45 f0 74 ff 10 80 	movl   $0x8010ff74,-0x10(%ebp)
80104fe5:	e9 db 00 00 00       	jmp    801050c5 <procdump+0xed>
    if(p->state == UNUSED)
80104fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fed:	8b 40 0c             	mov    0xc(%eax),%eax
80104ff0:	85 c0                	test   %eax,%eax
80104ff2:	0f 84 c5 00 00 00    	je     801050bd <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104ff8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ffb:	8b 40 0c             	mov    0xc(%eax),%eax
80104ffe:	83 f8 05             	cmp    $0x5,%eax
80105001:	77 23                	ja     80105026 <procdump+0x4e>
80105003:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105006:	8b 40 0c             	mov    0xc(%eax),%eax
80105009:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80105010:	85 c0                	test   %eax,%eax
80105012:	74 12                	je     80105026 <procdump+0x4e>
      state = states[p->state];
80105014:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105017:	8b 40 0c             	mov    0xc(%eax),%eax
8010501a:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80105021:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105024:	eb 07                	jmp    8010502d <procdump+0x55>
    else
      state = "???";
80105026:	c7 45 ec dc 8b 10 80 	movl   $0x80108bdc,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010502d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105030:	8d 50 6c             	lea    0x6c(%eax),%edx
80105033:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105036:	8b 40 10             	mov    0x10(%eax),%eax
80105039:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010503d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105040:	89 54 24 08          	mov    %edx,0x8(%esp)
80105044:	89 44 24 04          	mov    %eax,0x4(%esp)
80105048:	c7 04 24 e0 8b 10 80 	movl   $0x80108be0,(%esp)
8010504f:	e8 4d b3 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
80105054:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105057:	8b 40 0c             	mov    0xc(%eax),%eax
8010505a:	83 f8 02             	cmp    $0x2,%eax
8010505d:	75 50                	jne    801050af <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010505f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105062:	8b 40 1c             	mov    0x1c(%eax),%eax
80105065:	8b 40 0c             	mov    0xc(%eax),%eax
80105068:	83 c0 08             	add    $0x8,%eax
8010506b:	8d 55 c4             	lea    -0x3c(%ebp),%edx
8010506e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105072:	89 04 24             	mov    %eax,(%esp)
80105075:	e8 f6 01 00 00       	call   80105270 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
8010507a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105081:	eb 1b                	jmp    8010509e <procdump+0xc6>
        cprintf(" %p", pc[i]);
80105083:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105086:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010508a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010508e:	c7 04 24 e9 8b 10 80 	movl   $0x80108be9,(%esp)
80105095:	e8 07 b3 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
8010509a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010509e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801050a2:	7f 0b                	jg     801050af <procdump+0xd7>
801050a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a7:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050ab:	85 c0                	test   %eax,%eax
801050ad:	75 d4                	jne    80105083 <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801050af:	c7 04 24 ed 8b 10 80 	movl   $0x80108bed,(%esp)
801050b6:	e8 e6 b2 ff ff       	call   801003a1 <cprintf>
801050bb:	eb 01                	jmp    801050be <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
801050bd:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050be:	81 45 f0 94 00 00 00 	addl   $0x94,-0x10(%ebp)
801050c5:	81 7d f0 74 24 11 80 	cmpl   $0x80112474,-0x10(%ebp)
801050cc:	0f 82 18 ff ff ff    	jb     80104fea <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
801050d2:	c9                   	leave  
801050d3:	c3                   	ret    

801050d4 <nice>:

int
nice(void)
{
801050d4:	55                   	push   %ebp
801050d5:	89 e5                	mov    %esp,%ebp
  if(proc)
801050d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050dd:	85 c0                	test   %eax,%eax
801050df:	74 70                	je     80105151 <nice+0x7d>
  {
    if(proc->priority == HIGH)
801050e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050e7:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801050ed:	83 f8 03             	cmp    $0x3,%eax
801050f0:	75 32                	jne    80105124 <nice+0x50>
    {
      proc->priority--;
801050f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050f8:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
801050fe:	83 ea 01             	sub    $0x1,%edx
80105101:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
      proc->qvalue = proc->ctime;
80105107:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010510d:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105114:	8b 52 7c             	mov    0x7c(%edx),%edx
80105117:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
      return 0;
8010511d:	b8 00 00 00 00       	mov    $0x0,%eax
80105122:	eb 32                	jmp    80105156 <nice+0x82>
    }
    else if(proc->priority == MEDIUM)
80105124:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010512a:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80105130:	83 f8 02             	cmp    $0x2,%eax
80105133:	75 1c                	jne    80105151 <nice+0x7d>
    {
      proc->priority--;
80105135:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010513b:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80105141:	83 ea 01             	sub    $0x1,%edx
80105144:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
      return 0;
8010514a:	b8 00 00 00 00       	mov    $0x0,%eax
8010514f:	eb 05                	jmp    80105156 <nice+0x82>
    }
    
  }
  return -1;
80105151:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105156:	5d                   	pop    %ebp
80105157:	c3                   	ret    

80105158 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105158:	55                   	push   %ebp
80105159:	89 e5                	mov    %esp,%ebp
8010515b:	53                   	push   %ebx
8010515c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010515f:	9c                   	pushf  
80105160:	5b                   	pop    %ebx
80105161:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80105164:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105167:	83 c4 10             	add    $0x10,%esp
8010516a:	5b                   	pop    %ebx
8010516b:	5d                   	pop    %ebp
8010516c:	c3                   	ret    

8010516d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010516d:	55                   	push   %ebp
8010516e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105170:	fa                   	cli    
}
80105171:	5d                   	pop    %ebp
80105172:	c3                   	ret    

80105173 <sti>:

static inline void
sti(void)
{
80105173:	55                   	push   %ebp
80105174:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105176:	fb                   	sti    
}
80105177:	5d                   	pop    %ebp
80105178:	c3                   	ret    

80105179 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105179:	55                   	push   %ebp
8010517a:	89 e5                	mov    %esp,%ebp
8010517c:	53                   	push   %ebx
8010517d:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80105180:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105183:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80105186:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105189:	89 c3                	mov    %eax,%ebx
8010518b:	89 d8                	mov    %ebx,%eax
8010518d:	f0 87 02             	lock xchg %eax,(%edx)
80105190:	89 c3                	mov    %eax,%ebx
80105192:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105195:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105198:	83 c4 10             	add    $0x10,%esp
8010519b:	5b                   	pop    %ebx
8010519c:	5d                   	pop    %ebp
8010519d:	c3                   	ret    

8010519e <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010519e:	55                   	push   %ebp
8010519f:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801051a1:	8b 45 08             	mov    0x8(%ebp),%eax
801051a4:	8b 55 0c             	mov    0xc(%ebp),%edx
801051a7:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801051aa:	8b 45 08             	mov    0x8(%ebp),%eax
801051ad:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801051b3:	8b 45 08             	mov    0x8(%ebp),%eax
801051b6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801051bd:	5d                   	pop    %ebp
801051be:	c3                   	ret    

801051bf <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801051bf:	55                   	push   %ebp
801051c0:	89 e5                	mov    %esp,%ebp
801051c2:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801051c5:	e8 3d 01 00 00       	call   80105307 <pushcli>
  if(holding(lk))
801051ca:	8b 45 08             	mov    0x8(%ebp),%eax
801051cd:	89 04 24             	mov    %eax,(%esp)
801051d0:	e8 08 01 00 00       	call   801052dd <holding>
801051d5:	85 c0                	test   %eax,%eax
801051d7:	74 0c                	je     801051e5 <acquire+0x26>
    panic("acquire");
801051d9:	c7 04 24 19 8c 10 80 	movl   $0x80108c19,(%esp)
801051e0:	e8 58 b3 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801051e5:	90                   	nop
801051e6:	8b 45 08             	mov    0x8(%ebp),%eax
801051e9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801051f0:	00 
801051f1:	89 04 24             	mov    %eax,(%esp)
801051f4:	e8 80 ff ff ff       	call   80105179 <xchg>
801051f9:	85 c0                	test   %eax,%eax
801051fb:	75 e9                	jne    801051e6 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801051fd:	8b 45 08             	mov    0x8(%ebp),%eax
80105200:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105207:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
8010520a:	8b 45 08             	mov    0x8(%ebp),%eax
8010520d:	83 c0 0c             	add    $0xc,%eax
80105210:	89 44 24 04          	mov    %eax,0x4(%esp)
80105214:	8d 45 08             	lea    0x8(%ebp),%eax
80105217:	89 04 24             	mov    %eax,(%esp)
8010521a:	e8 51 00 00 00       	call   80105270 <getcallerpcs>
}
8010521f:	c9                   	leave  
80105220:	c3                   	ret    

80105221 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105221:	55                   	push   %ebp
80105222:	89 e5                	mov    %esp,%ebp
80105224:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105227:	8b 45 08             	mov    0x8(%ebp),%eax
8010522a:	89 04 24             	mov    %eax,(%esp)
8010522d:	e8 ab 00 00 00       	call   801052dd <holding>
80105232:	85 c0                	test   %eax,%eax
80105234:	75 0c                	jne    80105242 <release+0x21>
    panic("release");
80105236:	c7 04 24 21 8c 10 80 	movl   $0x80108c21,(%esp)
8010523d:	e8 fb b2 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
80105242:	8b 45 08             	mov    0x8(%ebp),%eax
80105245:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010524c:	8b 45 08             	mov    0x8(%ebp),%eax
8010524f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105256:	8b 45 08             	mov    0x8(%ebp),%eax
80105259:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105260:	00 
80105261:	89 04 24             	mov    %eax,(%esp)
80105264:	e8 10 ff ff ff       	call   80105179 <xchg>

  popcli();
80105269:	e8 e1 00 00 00       	call   8010534f <popcli>
}
8010526e:	c9                   	leave  
8010526f:	c3                   	ret    

80105270 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105270:	55                   	push   %ebp
80105271:	89 e5                	mov    %esp,%ebp
80105273:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105276:	8b 45 08             	mov    0x8(%ebp),%eax
80105279:	83 e8 08             	sub    $0x8,%eax
8010527c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010527f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105286:	eb 32                	jmp    801052ba <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105288:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010528c:	74 47                	je     801052d5 <getcallerpcs+0x65>
8010528e:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105295:	76 3e                	jbe    801052d5 <getcallerpcs+0x65>
80105297:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010529b:	74 38                	je     801052d5 <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010529d:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052a0:	c1 e0 02             	shl    $0x2,%eax
801052a3:	03 45 0c             	add    0xc(%ebp),%eax
801052a6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052a9:	8b 52 04             	mov    0x4(%edx),%edx
801052ac:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
801052ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052b1:	8b 00                	mov    (%eax),%eax
801052b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801052b6:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801052ba:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801052be:	7e c8                	jle    80105288 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801052c0:	eb 13                	jmp    801052d5 <getcallerpcs+0x65>
    pcs[i] = 0;
801052c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052c5:	c1 e0 02             	shl    $0x2,%eax
801052c8:	03 45 0c             	add    0xc(%ebp),%eax
801052cb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801052d1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801052d5:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801052d9:	7e e7                	jle    801052c2 <getcallerpcs+0x52>
    pcs[i] = 0;
}
801052db:	c9                   	leave  
801052dc:	c3                   	ret    

801052dd <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801052dd:	55                   	push   %ebp
801052de:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801052e0:	8b 45 08             	mov    0x8(%ebp),%eax
801052e3:	8b 00                	mov    (%eax),%eax
801052e5:	85 c0                	test   %eax,%eax
801052e7:	74 17                	je     80105300 <holding+0x23>
801052e9:	8b 45 08             	mov    0x8(%ebp),%eax
801052ec:	8b 50 08             	mov    0x8(%eax),%edx
801052ef:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052f5:	39 c2                	cmp    %eax,%edx
801052f7:	75 07                	jne    80105300 <holding+0x23>
801052f9:	b8 01 00 00 00       	mov    $0x1,%eax
801052fe:	eb 05                	jmp    80105305 <holding+0x28>
80105300:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105305:	5d                   	pop    %ebp
80105306:	c3                   	ret    

80105307 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105307:	55                   	push   %ebp
80105308:	89 e5                	mov    %esp,%ebp
8010530a:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
8010530d:	e8 46 fe ff ff       	call   80105158 <readeflags>
80105312:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105315:	e8 53 fe ff ff       	call   8010516d <cli>
  if(cpu->ncli++ == 0)
8010531a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105320:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105326:	85 d2                	test   %edx,%edx
80105328:	0f 94 c1             	sete   %cl
8010532b:	83 c2 01             	add    $0x1,%edx
8010532e:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105334:	84 c9                	test   %cl,%cl
80105336:	74 15                	je     8010534d <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80105338:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010533e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105341:	81 e2 00 02 00 00    	and    $0x200,%edx
80105347:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010534d:	c9                   	leave  
8010534e:	c3                   	ret    

8010534f <popcli>:

void
popcli(void)
{
8010534f:	55                   	push   %ebp
80105350:	89 e5                	mov    %esp,%ebp
80105352:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105355:	e8 fe fd ff ff       	call   80105158 <readeflags>
8010535a:	25 00 02 00 00       	and    $0x200,%eax
8010535f:	85 c0                	test   %eax,%eax
80105361:	74 0c                	je     8010536f <popcli+0x20>
    panic("popcli - interruptible");
80105363:	c7 04 24 29 8c 10 80 	movl   $0x80108c29,(%esp)
8010536a:	e8 ce b1 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
8010536f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105375:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010537b:	83 ea 01             	sub    $0x1,%edx
8010537e:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105384:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010538a:	85 c0                	test   %eax,%eax
8010538c:	79 0c                	jns    8010539a <popcli+0x4b>
    panic("popcli");
8010538e:	c7 04 24 40 8c 10 80 	movl   $0x80108c40,(%esp)
80105395:	e8 a3 b1 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
8010539a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053a0:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801053a6:	85 c0                	test   %eax,%eax
801053a8:	75 15                	jne    801053bf <popcli+0x70>
801053aa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053b0:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801053b6:	85 c0                	test   %eax,%eax
801053b8:	74 05                	je     801053bf <popcli+0x70>
    sti();
801053ba:	e8 b4 fd ff ff       	call   80105173 <sti>
}
801053bf:	c9                   	leave  
801053c0:	c3                   	ret    
801053c1:	00 00                	add    %al,(%eax)
	...

801053c4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801053c4:	55                   	push   %ebp
801053c5:	89 e5                	mov    %esp,%ebp
801053c7:	57                   	push   %edi
801053c8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801053c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053cc:	8b 55 10             	mov    0x10(%ebp),%edx
801053cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801053d2:	89 cb                	mov    %ecx,%ebx
801053d4:	89 df                	mov    %ebx,%edi
801053d6:	89 d1                	mov    %edx,%ecx
801053d8:	fc                   	cld    
801053d9:	f3 aa                	rep stos %al,%es:(%edi)
801053db:	89 ca                	mov    %ecx,%edx
801053dd:	89 fb                	mov    %edi,%ebx
801053df:	89 5d 08             	mov    %ebx,0x8(%ebp)
801053e2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801053e5:	5b                   	pop    %ebx
801053e6:	5f                   	pop    %edi
801053e7:	5d                   	pop    %ebp
801053e8:	c3                   	ret    

801053e9 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801053e9:	55                   	push   %ebp
801053ea:	89 e5                	mov    %esp,%ebp
801053ec:	57                   	push   %edi
801053ed:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801053ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053f1:	8b 55 10             	mov    0x10(%ebp),%edx
801053f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801053f7:	89 cb                	mov    %ecx,%ebx
801053f9:	89 df                	mov    %ebx,%edi
801053fb:	89 d1                	mov    %edx,%ecx
801053fd:	fc                   	cld    
801053fe:	f3 ab                	rep stos %eax,%es:(%edi)
80105400:	89 ca                	mov    %ecx,%edx
80105402:	89 fb                	mov    %edi,%ebx
80105404:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105407:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010540a:	5b                   	pop    %ebx
8010540b:	5f                   	pop    %edi
8010540c:	5d                   	pop    %ebp
8010540d:	c3                   	ret    

8010540e <memset>:
#include "x86.h"
#include "string.h"

void*
memset(void *dst, int c, uint n)
{
8010540e:	55                   	push   %ebp
8010540f:	89 e5                	mov    %esp,%ebp
80105411:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105414:	8b 45 08             	mov    0x8(%ebp),%eax
80105417:	83 e0 03             	and    $0x3,%eax
8010541a:	85 c0                	test   %eax,%eax
8010541c:	75 49                	jne    80105467 <memset+0x59>
8010541e:	8b 45 10             	mov    0x10(%ebp),%eax
80105421:	83 e0 03             	and    $0x3,%eax
80105424:	85 c0                	test   %eax,%eax
80105426:	75 3f                	jne    80105467 <memset+0x59>
    c &= 0xFF;
80105428:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010542f:	8b 45 10             	mov    0x10(%ebp),%eax
80105432:	c1 e8 02             	shr    $0x2,%eax
80105435:	89 c2                	mov    %eax,%edx
80105437:	8b 45 0c             	mov    0xc(%ebp),%eax
8010543a:	89 c1                	mov    %eax,%ecx
8010543c:	c1 e1 18             	shl    $0x18,%ecx
8010543f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105442:	c1 e0 10             	shl    $0x10,%eax
80105445:	09 c1                	or     %eax,%ecx
80105447:	8b 45 0c             	mov    0xc(%ebp),%eax
8010544a:	c1 e0 08             	shl    $0x8,%eax
8010544d:	09 c8                	or     %ecx,%eax
8010544f:	0b 45 0c             	or     0xc(%ebp),%eax
80105452:	89 54 24 08          	mov    %edx,0x8(%esp)
80105456:	89 44 24 04          	mov    %eax,0x4(%esp)
8010545a:	8b 45 08             	mov    0x8(%ebp),%eax
8010545d:	89 04 24             	mov    %eax,(%esp)
80105460:	e8 84 ff ff ff       	call   801053e9 <stosl>
80105465:	eb 19                	jmp    80105480 <memset+0x72>
  } else
    stosb(dst, c, n);
80105467:	8b 45 10             	mov    0x10(%ebp),%eax
8010546a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010546e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105471:	89 44 24 04          	mov    %eax,0x4(%esp)
80105475:	8b 45 08             	mov    0x8(%ebp),%eax
80105478:	89 04 24             	mov    %eax,(%esp)
8010547b:	e8 44 ff ff ff       	call   801053c4 <stosb>
  return dst;
80105480:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105483:	c9                   	leave  
80105484:	c3                   	ret    

80105485 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105485:	55                   	push   %ebp
80105486:	89 e5                	mov    %esp,%ebp
80105488:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010548b:	8b 45 08             	mov    0x8(%ebp),%eax
8010548e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105491:	8b 45 0c             	mov    0xc(%ebp),%eax
80105494:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105497:	eb 32                	jmp    801054cb <memcmp+0x46>
    if(*s1 != *s2)
80105499:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010549c:	0f b6 10             	movzbl (%eax),%edx
8010549f:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054a2:	0f b6 00             	movzbl (%eax),%eax
801054a5:	38 c2                	cmp    %al,%dl
801054a7:	74 1a                	je     801054c3 <memcmp+0x3e>
      return *s1 - *s2;
801054a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054ac:	0f b6 00             	movzbl (%eax),%eax
801054af:	0f b6 d0             	movzbl %al,%edx
801054b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054b5:	0f b6 00             	movzbl (%eax),%eax
801054b8:	0f b6 c0             	movzbl %al,%eax
801054bb:	89 d1                	mov    %edx,%ecx
801054bd:	29 c1                	sub    %eax,%ecx
801054bf:	89 c8                	mov    %ecx,%eax
801054c1:	eb 1c                	jmp    801054df <memcmp+0x5a>
    s1++, s2++;
801054c3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054c7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801054cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054cf:	0f 95 c0             	setne  %al
801054d2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054d6:	84 c0                	test   %al,%al
801054d8:	75 bf                	jne    80105499 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801054da:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054df:	c9                   	leave  
801054e0:	c3                   	ret    

801054e1 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801054e1:	55                   	push   %ebp
801054e2:	89 e5                	mov    %esp,%ebp
801054e4:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801054e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ea:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801054ed:	8b 45 08             	mov    0x8(%ebp),%eax
801054f0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801054f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054f6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054f9:	73 54                	jae    8010554f <memmove+0x6e>
801054fb:	8b 45 10             	mov    0x10(%ebp),%eax
801054fe:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105501:	01 d0                	add    %edx,%eax
80105503:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105506:	76 47                	jbe    8010554f <memmove+0x6e>
    s += n;
80105508:	8b 45 10             	mov    0x10(%ebp),%eax
8010550b:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010550e:	8b 45 10             	mov    0x10(%ebp),%eax
80105511:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105514:	eb 13                	jmp    80105529 <memmove+0x48>
      *--d = *--s;
80105516:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010551a:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010551e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105521:	0f b6 10             	movzbl (%eax),%edx
80105524:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105527:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105529:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010552d:	0f 95 c0             	setne  %al
80105530:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105534:	84 c0                	test   %al,%al
80105536:	75 de                	jne    80105516 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105538:	eb 25                	jmp    8010555f <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
8010553a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010553d:	0f b6 10             	movzbl (%eax),%edx
80105540:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105543:	88 10                	mov    %dl,(%eax)
80105545:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105549:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010554d:	eb 01                	jmp    80105550 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010554f:	90                   	nop
80105550:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105554:	0f 95 c0             	setne  %al
80105557:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010555b:	84 c0                	test   %al,%al
8010555d:	75 db                	jne    8010553a <memmove+0x59>
      *d++ = *s++;

  return dst;
8010555f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105562:	c9                   	leave  
80105563:	c3                   	ret    

80105564 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105564:	55                   	push   %ebp
80105565:	89 e5                	mov    %esp,%ebp
80105567:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010556a:	8b 45 10             	mov    0x10(%ebp),%eax
8010556d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105571:	8b 45 0c             	mov    0xc(%ebp),%eax
80105574:	89 44 24 04          	mov    %eax,0x4(%esp)
80105578:	8b 45 08             	mov    0x8(%ebp),%eax
8010557b:	89 04 24             	mov    %eax,(%esp)
8010557e:	e8 5e ff ff ff       	call   801054e1 <memmove>
}
80105583:	c9                   	leave  
80105584:	c3                   	ret    

80105585 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105585:	55                   	push   %ebp
80105586:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105588:	eb 0c                	jmp    80105596 <strncmp+0x11>
    n--, p++, q++;
8010558a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010558e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105592:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105596:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010559a:	74 1a                	je     801055b6 <strncmp+0x31>
8010559c:	8b 45 08             	mov    0x8(%ebp),%eax
8010559f:	0f b6 00             	movzbl (%eax),%eax
801055a2:	84 c0                	test   %al,%al
801055a4:	74 10                	je     801055b6 <strncmp+0x31>
801055a6:	8b 45 08             	mov    0x8(%ebp),%eax
801055a9:	0f b6 10             	movzbl (%eax),%edx
801055ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801055af:	0f b6 00             	movzbl (%eax),%eax
801055b2:	38 c2                	cmp    %al,%dl
801055b4:	74 d4                	je     8010558a <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801055b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055ba:	75 07                	jne    801055c3 <strncmp+0x3e>
    return 0;
801055bc:	b8 00 00 00 00       	mov    $0x0,%eax
801055c1:	eb 18                	jmp    801055db <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
801055c3:	8b 45 08             	mov    0x8(%ebp),%eax
801055c6:	0f b6 00             	movzbl (%eax),%eax
801055c9:	0f b6 d0             	movzbl %al,%edx
801055cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801055cf:	0f b6 00             	movzbl (%eax),%eax
801055d2:	0f b6 c0             	movzbl %al,%eax
801055d5:	89 d1                	mov    %edx,%ecx
801055d7:	29 c1                	sub    %eax,%ecx
801055d9:	89 c8                	mov    %ecx,%eax
}
801055db:	5d                   	pop    %ebp
801055dc:	c3                   	ret    

801055dd <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801055dd:	55                   	push   %ebp
801055de:	89 e5                	mov    %esp,%ebp
801055e0:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801055e3:	8b 45 08             	mov    0x8(%ebp),%eax
801055e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801055e9:	90                   	nop
801055ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055ee:	0f 9f c0             	setg   %al
801055f1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801055f5:	84 c0                	test   %al,%al
801055f7:	74 30                	je     80105629 <strncpy+0x4c>
801055f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801055fc:	0f b6 10             	movzbl (%eax),%edx
801055ff:	8b 45 08             	mov    0x8(%ebp),%eax
80105602:	88 10                	mov    %dl,(%eax)
80105604:	8b 45 08             	mov    0x8(%ebp),%eax
80105607:	0f b6 00             	movzbl (%eax),%eax
8010560a:	84 c0                	test   %al,%al
8010560c:	0f 95 c0             	setne  %al
8010560f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105613:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105617:	84 c0                	test   %al,%al
80105619:	75 cf                	jne    801055ea <strncpy+0xd>
    ;
  while(n-- > 0)
8010561b:	eb 0c                	jmp    80105629 <strncpy+0x4c>
    *s++ = 0;
8010561d:	8b 45 08             	mov    0x8(%ebp),%eax
80105620:	c6 00 00             	movb   $0x0,(%eax)
80105623:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105627:	eb 01                	jmp    8010562a <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105629:	90                   	nop
8010562a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010562e:	0f 9f c0             	setg   %al
80105631:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105635:	84 c0                	test   %al,%al
80105637:	75 e4                	jne    8010561d <strncpy+0x40>
    *s++ = 0;
  return os;
80105639:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010563c:	c9                   	leave  
8010563d:	c3                   	ret    

8010563e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010563e:	55                   	push   %ebp
8010563f:	89 e5                	mov    %esp,%ebp
80105641:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105644:	8b 45 08             	mov    0x8(%ebp),%eax
80105647:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010564a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010564e:	7f 05                	jg     80105655 <safestrcpy+0x17>
    return os;
80105650:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105653:	eb 35                	jmp    8010568a <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105655:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105659:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010565d:	7e 22                	jle    80105681 <safestrcpy+0x43>
8010565f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105662:	0f b6 10             	movzbl (%eax),%edx
80105665:	8b 45 08             	mov    0x8(%ebp),%eax
80105668:	88 10                	mov    %dl,(%eax)
8010566a:	8b 45 08             	mov    0x8(%ebp),%eax
8010566d:	0f b6 00             	movzbl (%eax),%eax
80105670:	84 c0                	test   %al,%al
80105672:	0f 95 c0             	setne  %al
80105675:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105679:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
8010567d:	84 c0                	test   %al,%al
8010567f:	75 d4                	jne    80105655 <safestrcpy+0x17>
    ;
  *s = 0;
80105681:	8b 45 08             	mov    0x8(%ebp),%eax
80105684:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105687:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010568a:	c9                   	leave  
8010568b:	c3                   	ret    

8010568c <strlen>:

int
strlen(const char *s)
{
8010568c:	55                   	push   %ebp
8010568d:	89 e5                	mov    %esp,%ebp
8010568f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105692:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105699:	eb 04                	jmp    8010569f <strlen+0x13>
8010569b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010569f:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056a2:	03 45 08             	add    0x8(%ebp),%eax
801056a5:	0f b6 00             	movzbl (%eax),%eax
801056a8:	84 c0                	test   %al,%al
801056aa:	75 ef                	jne    8010569b <strlen+0xf>
    ;
  return n;
801056ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801056af:	c9                   	leave  
801056b0:	c3                   	ret    
801056b1:	00 00                	add    %al,(%eax)
	...

801056b4 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801056b4:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801056b8:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801056bc:	55                   	push   %ebp
  pushl %ebx
801056bd:	53                   	push   %ebx
  pushl %esi
801056be:	56                   	push   %esi
  pushl %edi
801056bf:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801056c0:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801056c2:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801056c4:	5f                   	pop    %edi
  popl %esi
801056c5:	5e                   	pop    %esi
  popl %ebx
801056c6:	5b                   	pop    %ebx
  popl %ebp
801056c7:	5d                   	pop    %ebp
  ret
801056c8:	c3                   	ret    
801056c9:	00 00                	add    %al,(%eax)
	...

801056cc <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
801056cc:	55                   	push   %ebp
801056cd:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
801056cf:	8b 45 08             	mov    0x8(%ebp),%eax
801056d2:	8b 00                	mov    (%eax),%eax
801056d4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801056d7:	76 0f                	jbe    801056e8 <fetchint+0x1c>
801056d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801056dc:	8d 50 04             	lea    0x4(%eax),%edx
801056df:	8b 45 08             	mov    0x8(%ebp),%eax
801056e2:	8b 00                	mov    (%eax),%eax
801056e4:	39 c2                	cmp    %eax,%edx
801056e6:	76 07                	jbe    801056ef <fetchint+0x23>
    return -1;
801056e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056ed:	eb 0f                	jmp    801056fe <fetchint+0x32>
  *ip = *(int*)(addr);
801056ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801056f2:	8b 10                	mov    (%eax),%edx
801056f4:	8b 45 10             	mov    0x10(%ebp),%eax
801056f7:	89 10                	mov    %edx,(%eax)
  return 0;
801056f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056fe:	5d                   	pop    %ebp
801056ff:	c3                   	ret    

80105700 <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
80105700:	55                   	push   %ebp
80105701:	89 e5                	mov    %esp,%ebp
80105703:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= p->sz)
80105706:	8b 45 08             	mov    0x8(%ebp),%eax
80105709:	8b 00                	mov    (%eax),%eax
8010570b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010570e:	77 07                	ja     80105717 <fetchstr+0x17>
    return -1;
80105710:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105715:	eb 45                	jmp    8010575c <fetchstr+0x5c>
  *pp = (char*)addr;
80105717:	8b 55 0c             	mov    0xc(%ebp),%edx
8010571a:	8b 45 10             	mov    0x10(%ebp),%eax
8010571d:	89 10                	mov    %edx,(%eax)
  ep = (char*)p->sz;
8010571f:	8b 45 08             	mov    0x8(%ebp),%eax
80105722:	8b 00                	mov    (%eax),%eax
80105724:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105727:	8b 45 10             	mov    0x10(%ebp),%eax
8010572a:	8b 00                	mov    (%eax),%eax
8010572c:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010572f:	eb 1e                	jmp    8010574f <fetchstr+0x4f>
    if(*s == 0)
80105731:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105734:	0f b6 00             	movzbl (%eax),%eax
80105737:	84 c0                	test   %al,%al
80105739:	75 10                	jne    8010574b <fetchstr+0x4b>
      return s - *pp;
8010573b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010573e:	8b 45 10             	mov    0x10(%ebp),%eax
80105741:	8b 00                	mov    (%eax),%eax
80105743:	89 d1                	mov    %edx,%ecx
80105745:	29 c1                	sub    %eax,%ecx
80105747:	89 c8                	mov    %ecx,%eax
80105749:	eb 11                	jmp    8010575c <fetchstr+0x5c>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
8010574b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010574f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105752:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105755:	72 da                	jb     80105731 <fetchstr+0x31>
    if(*s == 0)
      return s - *pp;
  return -1;
80105757:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010575c:	c9                   	leave  
8010575d:	c3                   	ret    

8010575e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010575e:	55                   	push   %ebp
8010575f:	89 e5                	mov    %esp,%ebp
80105761:	83 ec 0c             	sub    $0xc,%esp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
80105764:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010576a:	8b 40 18             	mov    0x18(%eax),%eax
8010576d:	8b 50 44             	mov    0x44(%eax),%edx
80105770:	8b 45 08             	mov    0x8(%ebp),%eax
80105773:	c1 e0 02             	shl    $0x2,%eax
80105776:	01 d0                	add    %edx,%eax
80105778:	8d 48 04             	lea    0x4(%eax),%ecx
8010577b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105781:	8b 55 0c             	mov    0xc(%ebp),%edx
80105784:	89 54 24 08          	mov    %edx,0x8(%esp)
80105788:	89 4c 24 04          	mov    %ecx,0x4(%esp)
8010578c:	89 04 24             	mov    %eax,(%esp)
8010578f:	e8 38 ff ff ff       	call   801056cc <fetchint>
}
80105794:	c9                   	leave  
80105795:	c3                   	ret    

80105796 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105796:	55                   	push   %ebp
80105797:	89 e5                	mov    %esp,%ebp
80105799:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010579c:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010579f:	89 44 24 04          	mov    %eax,0x4(%esp)
801057a3:	8b 45 08             	mov    0x8(%ebp),%eax
801057a6:	89 04 24             	mov    %eax,(%esp)
801057a9:	e8 b0 ff ff ff       	call   8010575e <argint>
801057ae:	85 c0                	test   %eax,%eax
801057b0:	79 07                	jns    801057b9 <argptr+0x23>
    return -1;
801057b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057b7:	eb 3d                	jmp    801057f6 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801057b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057bc:	89 c2                	mov    %eax,%edx
801057be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057c4:	8b 00                	mov    (%eax),%eax
801057c6:	39 c2                	cmp    %eax,%edx
801057c8:	73 16                	jae    801057e0 <argptr+0x4a>
801057ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057cd:	89 c2                	mov    %eax,%edx
801057cf:	8b 45 10             	mov    0x10(%ebp),%eax
801057d2:	01 c2                	add    %eax,%edx
801057d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057da:	8b 00                	mov    (%eax),%eax
801057dc:	39 c2                	cmp    %eax,%edx
801057de:	76 07                	jbe    801057e7 <argptr+0x51>
    return -1;
801057e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057e5:	eb 0f                	jmp    801057f6 <argptr+0x60>
  *pp = (char*)i;
801057e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057ea:	89 c2                	mov    %eax,%edx
801057ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801057ef:	89 10                	mov    %edx,(%eax)
  return 0;
801057f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057f6:	c9                   	leave  
801057f7:	c3                   	ret    

801057f8 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801057f8:	55                   	push   %ebp
801057f9:	89 e5                	mov    %esp,%ebp
801057fb:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  if(argint(n, &addr) < 0)
801057fe:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105801:	89 44 24 04          	mov    %eax,0x4(%esp)
80105805:	8b 45 08             	mov    0x8(%ebp),%eax
80105808:	89 04 24             	mov    %eax,(%esp)
8010580b:	e8 4e ff ff ff       	call   8010575e <argint>
80105810:	85 c0                	test   %eax,%eax
80105812:	79 07                	jns    8010581b <argstr+0x23>
    return -1;
80105814:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105819:	eb 1e                	jmp    80105839 <argstr+0x41>
  return fetchstr(proc, addr, pp);
8010581b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010581e:	89 c2                	mov    %eax,%edx
80105820:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105826:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105829:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010582d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105831:	89 04 24             	mov    %eax,(%esp)
80105834:	e8 c7 fe ff ff       	call   80105700 <fetchstr>
}
80105839:	c9                   	leave  
8010583a:	c3                   	ret    

8010583b <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
8010583b:	55                   	push   %ebp
8010583c:	89 e5                	mov    %esp,%ebp
8010583e:	53                   	push   %ebx
8010583f:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105842:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105848:	8b 40 18             	mov    0x18(%eax),%eax
8010584b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010584e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num >= 0 && num < SYS_open && syscalls[num]) {
80105851:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105855:	78 2e                	js     80105885 <syscall+0x4a>
80105857:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
8010585b:	7f 28                	jg     80105885 <syscall+0x4a>
8010585d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105860:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105867:	85 c0                	test   %eax,%eax
80105869:	74 1a                	je     80105885 <syscall+0x4a>
    proc->tf->eax = syscalls[num]();
8010586b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105871:	8b 58 18             	mov    0x18(%eax),%ebx
80105874:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105877:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010587e:	ff d0                	call   *%eax
80105880:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105883:	eb 73                	jmp    801058f8 <syscall+0xbd>
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
80105885:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80105889:	7e 30                	jle    801058bb <syscall+0x80>
8010588b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588e:	83 f8 17             	cmp    $0x17,%eax
80105891:	77 28                	ja     801058bb <syscall+0x80>
80105893:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105896:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010589d:	85 c0                	test   %eax,%eax
8010589f:	74 1a                	je     801058bb <syscall+0x80>
    proc->tf->eax = syscalls[num]();
801058a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058a7:	8b 58 18             	mov    0x18(%eax),%ebx
801058aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ad:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801058b4:	ff d0                	call   *%eax
801058b6:	89 43 1c             	mov    %eax,0x1c(%ebx)
801058b9:	eb 3d                	jmp    801058f8 <syscall+0xbd>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801058bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058c1:	8d 48 6c             	lea    0x6c(%eax),%ecx
801058c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(num >= 0 && num < SYS_open && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801058ca:	8b 40 10             	mov    0x10(%eax),%eax
801058cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
801058d4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801058d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801058dc:	c7 04 24 47 8c 10 80 	movl   $0x80108c47,(%esp)
801058e3:	e8 b9 aa ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801058e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058ee:	8b 40 18             	mov    0x18(%eax),%eax
801058f1:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801058f8:	83 c4 24             	add    $0x24,%esp
801058fb:	5b                   	pop    %ebx
801058fc:	5d                   	pop    %ebp
801058fd:	c3                   	ret    
	...

80105900 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105900:	55                   	push   %ebp
80105901:	89 e5                	mov    %esp,%ebp
80105903:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105906:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105909:	89 44 24 04          	mov    %eax,0x4(%esp)
8010590d:	8b 45 08             	mov    0x8(%ebp),%eax
80105910:	89 04 24             	mov    %eax,(%esp)
80105913:	e8 46 fe ff ff       	call   8010575e <argint>
80105918:	85 c0                	test   %eax,%eax
8010591a:	79 07                	jns    80105923 <argfd+0x23>
    return -1;
8010591c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105921:	eb 50                	jmp    80105973 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105923:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105926:	85 c0                	test   %eax,%eax
80105928:	78 21                	js     8010594b <argfd+0x4b>
8010592a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010592d:	83 f8 0f             	cmp    $0xf,%eax
80105930:	7f 19                	jg     8010594b <argfd+0x4b>
80105932:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105938:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010593b:	83 c2 08             	add    $0x8,%edx
8010593e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105942:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105945:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105949:	75 07                	jne    80105952 <argfd+0x52>
    return -1;
8010594b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105950:	eb 21                	jmp    80105973 <argfd+0x73>
  if(pfd)
80105952:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105956:	74 08                	je     80105960 <argfd+0x60>
    *pfd = fd;
80105958:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010595b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010595e:	89 10                	mov    %edx,(%eax)
  if(pf)
80105960:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105964:	74 08                	je     8010596e <argfd+0x6e>
    *pf = f;
80105966:	8b 45 10             	mov    0x10(%ebp),%eax
80105969:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010596c:	89 10                	mov    %edx,(%eax)
  return 0;
8010596e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105973:	c9                   	leave  
80105974:	c3                   	ret    

80105975 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105975:	55                   	push   %ebp
80105976:	89 e5                	mov    %esp,%ebp
80105978:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010597b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105982:	eb 30                	jmp    801059b4 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105984:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010598a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010598d:	83 c2 08             	add    $0x8,%edx
80105990:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105994:	85 c0                	test   %eax,%eax
80105996:	75 18                	jne    801059b0 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105998:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010599e:	8b 55 fc             	mov    -0x4(%ebp),%edx
801059a1:	8d 4a 08             	lea    0x8(%edx),%ecx
801059a4:	8b 55 08             	mov    0x8(%ebp),%edx
801059a7:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801059ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059ae:	eb 0f                	jmp    801059bf <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801059b0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801059b4:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801059b8:	7e ca                	jle    80105984 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801059ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059bf:	c9                   	leave  
801059c0:	c3                   	ret    

801059c1 <sys_dup>:

int
sys_dup(void)
{
801059c1:	55                   	push   %ebp
801059c2:	89 e5                	mov    %esp,%ebp
801059c4:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801059c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059ca:	89 44 24 08          	mov    %eax,0x8(%esp)
801059ce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801059d5:	00 
801059d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059dd:	e8 1e ff ff ff       	call   80105900 <argfd>
801059e2:	85 c0                	test   %eax,%eax
801059e4:	79 07                	jns    801059ed <sys_dup+0x2c>
    return -1;
801059e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059eb:	eb 29                	jmp    80105a16 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801059ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f0:	89 04 24             	mov    %eax,(%esp)
801059f3:	e8 7d ff ff ff       	call   80105975 <fdalloc>
801059f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059ff:	79 07                	jns    80105a08 <sys_dup+0x47>
    return -1;
80105a01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a06:	eb 0e                	jmp    80105a16 <sys_dup+0x55>
  filedup(f);
80105a08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a0b:	89 04 24             	mov    %eax,(%esp)
80105a0e:	e8 91 b8 ff ff       	call   801012a4 <filedup>
  return fd;
80105a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105a16:	c9                   	leave  
80105a17:	c3                   	ret    

80105a18 <sys_read>:

int
sys_read(void)
{
80105a18:	55                   	push   %ebp
80105a19:	89 e5                	mov    %esp,%ebp
80105a1b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105a1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a21:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a25:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a2c:	00 
80105a2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a34:	e8 c7 fe ff ff       	call   80105900 <argfd>
80105a39:	85 c0                	test   %eax,%eax
80105a3b:	78 35                	js     80105a72 <sys_read+0x5a>
80105a3d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a40:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a44:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105a4b:	e8 0e fd ff ff       	call   8010575e <argint>
80105a50:	85 c0                	test   %eax,%eax
80105a52:	78 1e                	js     80105a72 <sys_read+0x5a>
80105a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a57:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a5b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a62:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a69:	e8 28 fd ff ff       	call   80105796 <argptr>
80105a6e:	85 c0                	test   %eax,%eax
80105a70:	79 07                	jns    80105a79 <sys_read+0x61>
    return -1;
80105a72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a77:	eb 19                	jmp    80105a92 <sys_read+0x7a>
  return fileread(f, p, n);
80105a79:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105a7c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a82:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105a86:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a8a:	89 04 24             	mov    %eax,(%esp)
80105a8d:	e8 7f b9 ff ff       	call   80101411 <fileread>
}
80105a92:	c9                   	leave  
80105a93:	c3                   	ret    

80105a94 <sys_write>:

int
sys_write(void)
{
80105a94:	55                   	push   %ebp
80105a95:	89 e5                	mov    %esp,%ebp
80105a97:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105a9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a9d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105aa1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105aa8:	00 
80105aa9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ab0:	e8 4b fe ff ff       	call   80105900 <argfd>
80105ab5:	85 c0                	test   %eax,%eax
80105ab7:	78 35                	js     80105aee <sys_write+0x5a>
80105ab9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105abc:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ac0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105ac7:	e8 92 fc ff ff       	call   8010575e <argint>
80105acc:	85 c0                	test   %eax,%eax
80105ace:	78 1e                	js     80105aee <sys_write+0x5a>
80105ad0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad3:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ad7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ada:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ade:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105ae5:	e8 ac fc ff ff       	call   80105796 <argptr>
80105aea:	85 c0                	test   %eax,%eax
80105aec:	79 07                	jns    80105af5 <sys_write+0x61>
    return -1;
80105aee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105af3:	eb 19                	jmp    80105b0e <sys_write+0x7a>
  return filewrite(f, p, n);
80105af5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105af8:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105afe:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105b02:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b06:	89 04 24             	mov    %eax,(%esp)
80105b09:	e8 bf b9 ff ff       	call   801014cd <filewrite>
}
80105b0e:	c9                   	leave  
80105b0f:	c3                   	ret    

80105b10 <sys_close>:

int
sys_close(void)
{
80105b10:	55                   	push   %ebp
80105b11:	89 e5                	mov    %esp,%ebp
80105b13:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105b16:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b19:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b20:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b2b:	e8 d0 fd ff ff       	call   80105900 <argfd>
80105b30:	85 c0                	test   %eax,%eax
80105b32:	79 07                	jns    80105b3b <sys_close+0x2b>
    return -1;
80105b34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b39:	eb 24                	jmp    80105b5f <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105b3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b41:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b44:	83 c2 08             	add    $0x8,%edx
80105b47:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105b4e:	00 
  fileclose(f);
80105b4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b52:	89 04 24             	mov    %eax,(%esp)
80105b55:	e8 92 b7 ff ff       	call   801012ec <fileclose>
  return 0;
80105b5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b5f:	c9                   	leave  
80105b60:	c3                   	ret    

80105b61 <sys_fstat>:

int
sys_fstat(void)
{
80105b61:	55                   	push   %ebp
80105b62:	89 e5                	mov    %esp,%ebp
80105b64:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105b67:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b6a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b6e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b75:	00 
80105b76:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b7d:	e8 7e fd ff ff       	call   80105900 <argfd>
80105b82:	85 c0                	test   %eax,%eax
80105b84:	78 1f                	js     80105ba5 <sys_fstat+0x44>
80105b86:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105b8d:	00 
80105b8e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b91:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b9c:	e8 f5 fb ff ff       	call   80105796 <argptr>
80105ba1:	85 c0                	test   %eax,%eax
80105ba3:	79 07                	jns    80105bac <sys_fstat+0x4b>
    return -1;
80105ba5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105baa:	eb 12                	jmp    80105bbe <sys_fstat+0x5d>
  return filestat(f, st);
80105bac:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb2:	89 54 24 04          	mov    %edx,0x4(%esp)
80105bb6:	89 04 24             	mov    %eax,(%esp)
80105bb9:	e8 04 b8 ff ff       	call   801013c2 <filestat>
}
80105bbe:	c9                   	leave  
80105bbf:	c3                   	ret    

80105bc0 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105bc0:	55                   	push   %ebp
80105bc1:	89 e5                	mov    %esp,%ebp
80105bc3:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105bc6:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105bc9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bcd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105bd4:	e8 1f fc ff ff       	call   801057f8 <argstr>
80105bd9:	85 c0                	test   %eax,%eax
80105bdb:	78 17                	js     80105bf4 <sys_link+0x34>
80105bdd:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105be0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105be4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105beb:	e8 08 fc ff ff       	call   801057f8 <argstr>
80105bf0:	85 c0                	test   %eax,%eax
80105bf2:	79 0a                	jns    80105bfe <sys_link+0x3e>
    return -1;
80105bf4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bf9:	e9 3c 01 00 00       	jmp    80105d3a <sys_link+0x17a>
  if((ip = namei(old)) == 0)
80105bfe:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105c01:	89 04 24             	mov    %eax,(%esp)
80105c04:	e8 29 cb ff ff       	call   80102732 <namei>
80105c09:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c10:	75 0a                	jne    80105c1c <sys_link+0x5c>
    return -1;
80105c12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c17:	e9 1e 01 00 00       	jmp    80105d3a <sys_link+0x17a>

  begin_trans();
80105c1c:	e8 24 d9 ff ff       	call   80103545 <begin_trans>

  ilock(ip);
80105c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c24:	89 04 24             	mov    %eax,(%esp)
80105c27:	e8 64 bf ff ff       	call   80101b90 <ilock>
  if(ip->type == T_DIR){
80105c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c2f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105c33:	66 83 f8 01          	cmp    $0x1,%ax
80105c37:	75 1a                	jne    80105c53 <sys_link+0x93>
    iunlockput(ip);
80105c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c3c:	89 04 24             	mov    %eax,(%esp)
80105c3f:	e8 d0 c1 ff ff       	call   80101e14 <iunlockput>
    commit_trans();
80105c44:	e8 45 d9 ff ff       	call   8010358e <commit_trans>
    return -1;
80105c49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c4e:	e9 e7 00 00 00       	jmp    80105d3a <sys_link+0x17a>
  }

  ip->nlink++;
80105c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c56:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c5a:	8d 50 01             	lea    0x1(%eax),%edx
80105c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c60:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c67:	89 04 24             	mov    %eax,(%esp)
80105c6a:	e8 65 bd ff ff       	call   801019d4 <iupdate>
  iunlock(ip);
80105c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c72:	89 04 24             	mov    %eax,(%esp)
80105c75:	e8 64 c0 ff ff       	call   80101cde <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105c7a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105c7d:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105c80:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c84:	89 04 24             	mov    %eax,(%esp)
80105c87:	e8 c8 ca ff ff       	call   80102754 <nameiparent>
80105c8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c8f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c93:	74 68                	je     80105cfd <sys_link+0x13d>
    goto bad;
  ilock(dp);
80105c95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c98:	89 04 24             	mov    %eax,(%esp)
80105c9b:	e8 f0 be ff ff       	call   80101b90 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105ca0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca3:	8b 10                	mov    (%eax),%edx
80105ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca8:	8b 00                	mov    (%eax),%eax
80105caa:	39 c2                	cmp    %eax,%edx
80105cac:	75 20                	jne    80105cce <sys_link+0x10e>
80105cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb1:	8b 40 04             	mov    0x4(%eax),%eax
80105cb4:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cb8:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105cbb:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc2:	89 04 24             	mov    %eax,(%esp)
80105cc5:	e8 a7 c7 ff ff       	call   80102471 <dirlink>
80105cca:	85 c0                	test   %eax,%eax
80105ccc:	79 0d                	jns    80105cdb <sys_link+0x11b>
    iunlockput(dp);
80105cce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd1:	89 04 24             	mov    %eax,(%esp)
80105cd4:	e8 3b c1 ff ff       	call   80101e14 <iunlockput>
    goto bad;
80105cd9:	eb 23                	jmp    80105cfe <sys_link+0x13e>
  }
  iunlockput(dp);
80105cdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cde:	89 04 24             	mov    %eax,(%esp)
80105ce1:	e8 2e c1 ff ff       	call   80101e14 <iunlockput>
  iput(ip);
80105ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce9:	89 04 24             	mov    %eax,(%esp)
80105cec:	e8 52 c0 ff ff       	call   80101d43 <iput>

  commit_trans();
80105cf1:	e8 98 d8 ff ff       	call   8010358e <commit_trans>

  return 0;
80105cf6:	b8 00 00 00 00       	mov    $0x0,%eax
80105cfb:	eb 3d                	jmp    80105d3a <sys_link+0x17a>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105cfd:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
80105cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d01:	89 04 24             	mov    %eax,(%esp)
80105d04:	e8 87 be ff ff       	call   80101b90 <ilock>
  ip->nlink--;
80105d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d0c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d10:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d16:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d1d:	89 04 24             	mov    %eax,(%esp)
80105d20:	e8 af bc ff ff       	call   801019d4 <iupdate>
  iunlockput(ip);
80105d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d28:	89 04 24             	mov    %eax,(%esp)
80105d2b:	e8 e4 c0 ff ff       	call   80101e14 <iunlockput>
  commit_trans();
80105d30:	e8 59 d8 ff ff       	call   8010358e <commit_trans>
  return -1;
80105d35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d3a:	c9                   	leave  
80105d3b:	c3                   	ret    

80105d3c <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105d3c:	55                   	push   %ebp
80105d3d:	89 e5                	mov    %esp,%ebp
80105d3f:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d42:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105d49:	eb 4b                	jmp    80105d96 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105d55:	00 
80105d56:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d5a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d61:	8b 45 08             	mov    0x8(%ebp),%eax
80105d64:	89 04 24             	mov    %eax,(%esp)
80105d67:	e8 1a c3 ff ff       	call   80102086 <readi>
80105d6c:	83 f8 10             	cmp    $0x10,%eax
80105d6f:	74 0c                	je     80105d7d <isdirempty+0x41>
      panic("isdirempty: readi");
80105d71:	c7 04 24 63 8c 10 80 	movl   $0x80108c63,(%esp)
80105d78:	e8 c0 a7 ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80105d7d:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105d81:	66 85 c0             	test   %ax,%ax
80105d84:	74 07                	je     80105d8d <isdirempty+0x51>
      return 0;
80105d86:	b8 00 00 00 00       	mov    $0x0,%eax
80105d8b:	eb 1b                	jmp    80105da8 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d90:	83 c0 10             	add    $0x10,%eax
80105d93:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d96:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d99:	8b 45 08             	mov    0x8(%ebp),%eax
80105d9c:	8b 40 18             	mov    0x18(%eax),%eax
80105d9f:	39 c2                	cmp    %eax,%edx
80105da1:	72 a8                	jb     80105d4b <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105da3:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105da8:	c9                   	leave  
80105da9:	c3                   	ret    

80105daa <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105daa:	55                   	push   %ebp
80105dab:	89 e5                	mov    %esp,%ebp
80105dad:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105db0:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105db3:	89 44 24 04          	mov    %eax,0x4(%esp)
80105db7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105dbe:	e8 35 fa ff ff       	call   801057f8 <argstr>
80105dc3:	85 c0                	test   %eax,%eax
80105dc5:	79 0a                	jns    80105dd1 <sys_unlink+0x27>
    return -1;
80105dc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dcc:	e9 aa 01 00 00       	jmp    80105f7b <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
80105dd1:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105dd4:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105dd7:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ddb:	89 04 24             	mov    %eax,(%esp)
80105dde:	e8 71 c9 ff ff       	call   80102754 <nameiparent>
80105de3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105de6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dea:	75 0a                	jne    80105df6 <sys_unlink+0x4c>
    return -1;
80105dec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105df1:	e9 85 01 00 00       	jmp    80105f7b <sys_unlink+0x1d1>

  begin_trans();
80105df6:	e8 4a d7 ff ff       	call   80103545 <begin_trans>

  ilock(dp);
80105dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dfe:	89 04 24             	mov    %eax,(%esp)
80105e01:	e8 8a bd ff ff       	call   80101b90 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105e06:	c7 44 24 04 75 8c 10 	movl   $0x80108c75,0x4(%esp)
80105e0d:	80 
80105e0e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e11:	89 04 24             	mov    %eax,(%esp)
80105e14:	e8 6e c5 ff ff       	call   80102387 <namecmp>
80105e19:	85 c0                	test   %eax,%eax
80105e1b:	0f 84 45 01 00 00    	je     80105f66 <sys_unlink+0x1bc>
80105e21:	c7 44 24 04 77 8c 10 	movl   $0x80108c77,0x4(%esp)
80105e28:	80 
80105e29:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e2c:	89 04 24             	mov    %eax,(%esp)
80105e2f:	e8 53 c5 ff ff       	call   80102387 <namecmp>
80105e34:	85 c0                	test   %eax,%eax
80105e36:	0f 84 2a 01 00 00    	je     80105f66 <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105e3c:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105e3f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e43:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e46:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4d:	89 04 24             	mov    %eax,(%esp)
80105e50:	e8 54 c5 ff ff       	call   801023a9 <dirlookup>
80105e55:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e58:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e5c:	0f 84 03 01 00 00    	je     80105f65 <sys_unlink+0x1bb>
    goto bad;
  ilock(ip);
80105e62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e65:	89 04 24             	mov    %eax,(%esp)
80105e68:	e8 23 bd ff ff       	call   80101b90 <ilock>

  if(ip->nlink < 1)
80105e6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e70:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e74:	66 85 c0             	test   %ax,%ax
80105e77:	7f 0c                	jg     80105e85 <sys_unlink+0xdb>
    panic("unlink: nlink < 1");
80105e79:	c7 04 24 7a 8c 10 80 	movl   $0x80108c7a,(%esp)
80105e80:	e8 b8 a6 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e88:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e8c:	66 83 f8 01          	cmp    $0x1,%ax
80105e90:	75 1f                	jne    80105eb1 <sys_unlink+0x107>
80105e92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e95:	89 04 24             	mov    %eax,(%esp)
80105e98:	e8 9f fe ff ff       	call   80105d3c <isdirempty>
80105e9d:	85 c0                	test   %eax,%eax
80105e9f:	75 10                	jne    80105eb1 <sys_unlink+0x107>
    iunlockput(ip);
80105ea1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea4:	89 04 24             	mov    %eax,(%esp)
80105ea7:	e8 68 bf ff ff       	call   80101e14 <iunlockput>
    goto bad;
80105eac:	e9 b5 00 00 00       	jmp    80105f66 <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
80105eb1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105eb8:	00 
80105eb9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ec0:	00 
80105ec1:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ec4:	89 04 24             	mov    %eax,(%esp)
80105ec7:	e8 42 f5 ff ff       	call   8010540e <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ecc:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105ecf:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105ed6:	00 
80105ed7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105edb:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ede:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee5:	89 04 24             	mov    %eax,(%esp)
80105ee8:	e8 04 c3 ff ff       	call   801021f1 <writei>
80105eed:	83 f8 10             	cmp    $0x10,%eax
80105ef0:	74 0c                	je     80105efe <sys_unlink+0x154>
    panic("unlink: writei");
80105ef2:	c7 04 24 8c 8c 10 80 	movl   $0x80108c8c,(%esp)
80105ef9:	e8 3f a6 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80105efe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f01:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105f05:	66 83 f8 01          	cmp    $0x1,%ax
80105f09:	75 1c                	jne    80105f27 <sys_unlink+0x17d>
    dp->nlink--;
80105f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f0e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f12:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f18:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1f:	89 04 24             	mov    %eax,(%esp)
80105f22:	e8 ad ba ff ff       	call   801019d4 <iupdate>
  }
  iunlockput(dp);
80105f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f2a:	89 04 24             	mov    %eax,(%esp)
80105f2d:	e8 e2 be ff ff       	call   80101e14 <iunlockput>

  ip->nlink--;
80105f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f35:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f39:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f3f:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105f43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f46:	89 04 24             	mov    %eax,(%esp)
80105f49:	e8 86 ba ff ff       	call   801019d4 <iupdate>
  iunlockput(ip);
80105f4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f51:	89 04 24             	mov    %eax,(%esp)
80105f54:	e8 bb be ff ff       	call   80101e14 <iunlockput>

  commit_trans();
80105f59:	e8 30 d6 ff ff       	call   8010358e <commit_trans>

  return 0;
80105f5e:	b8 00 00 00 00       	mov    $0x0,%eax
80105f63:	eb 16                	jmp    80105f7b <sys_unlink+0x1d1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105f65:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
80105f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f69:	89 04 24             	mov    %eax,(%esp)
80105f6c:	e8 a3 be ff ff       	call   80101e14 <iunlockput>
  commit_trans();
80105f71:	e8 18 d6 ff ff       	call   8010358e <commit_trans>
  return -1;
80105f76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f7b:	c9                   	leave  
80105f7c:	c3                   	ret    

80105f7d <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105f7d:	55                   	push   %ebp
80105f7e:	89 e5                	mov    %esp,%ebp
80105f80:	83 ec 48             	sub    $0x48,%esp
80105f83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105f86:	8b 55 10             	mov    0x10(%ebp),%edx
80105f89:	8b 45 14             	mov    0x14(%ebp),%eax
80105f8c:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105f90:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105f94:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105f98:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f9b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f9f:	8b 45 08             	mov    0x8(%ebp),%eax
80105fa2:	89 04 24             	mov    %eax,(%esp)
80105fa5:	e8 aa c7 ff ff       	call   80102754 <nameiparent>
80105faa:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fb1:	75 0a                	jne    80105fbd <create+0x40>
    return 0;
80105fb3:	b8 00 00 00 00       	mov    $0x0,%eax
80105fb8:	e9 7e 01 00 00       	jmp    8010613b <create+0x1be>
  ilock(dp);
80105fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc0:	89 04 24             	mov    %eax,(%esp)
80105fc3:	e8 c8 bb ff ff       	call   80101b90 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105fc8:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105fcb:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fcf:	8d 45 de             	lea    -0x22(%ebp),%eax
80105fd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd9:	89 04 24             	mov    %eax,(%esp)
80105fdc:	e8 c8 c3 ff ff       	call   801023a9 <dirlookup>
80105fe1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fe4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fe8:	74 47                	je     80106031 <create+0xb4>
    iunlockput(dp);
80105fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fed:	89 04 24             	mov    %eax,(%esp)
80105ff0:	e8 1f be ff ff       	call   80101e14 <iunlockput>
    ilock(ip);
80105ff5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ff8:	89 04 24             	mov    %eax,(%esp)
80105ffb:	e8 90 bb ff ff       	call   80101b90 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80106000:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106005:	75 15                	jne    8010601c <create+0x9f>
80106007:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010600a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010600e:	66 83 f8 02          	cmp    $0x2,%ax
80106012:	75 08                	jne    8010601c <create+0x9f>
      return ip;
80106014:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106017:	e9 1f 01 00 00       	jmp    8010613b <create+0x1be>
    iunlockput(ip);
8010601c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010601f:	89 04 24             	mov    %eax,(%esp)
80106022:	e8 ed bd ff ff       	call   80101e14 <iunlockput>
    return 0;
80106027:	b8 00 00 00 00       	mov    $0x0,%eax
8010602c:	e9 0a 01 00 00       	jmp    8010613b <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106031:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106038:	8b 00                	mov    (%eax),%eax
8010603a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010603e:	89 04 24             	mov    %eax,(%esp)
80106041:	e8 b1 b8 ff ff       	call   801018f7 <ialloc>
80106046:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106049:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010604d:	75 0c                	jne    8010605b <create+0xde>
    panic("create: ialloc");
8010604f:	c7 04 24 9b 8c 10 80 	movl   $0x80108c9b,(%esp)
80106056:	e8 e2 a4 ff ff       	call   8010053d <panic>

  ilock(ip);
8010605b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010605e:	89 04 24             	mov    %eax,(%esp)
80106061:	e8 2a bb ff ff       	call   80101b90 <ilock>
  ip->major = major;
80106066:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106069:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010606d:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106071:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106074:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106078:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
8010607c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010607f:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106085:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106088:	89 04 24             	mov    %eax,(%esp)
8010608b:	e8 44 b9 ff ff       	call   801019d4 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80106090:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106095:	75 6a                	jne    80106101 <create+0x184>
    dp->nlink++;  // for ".."
80106097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010609a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010609e:	8d 50 01             	lea    0x1(%eax),%edx
801060a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a4:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801060a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ab:	89 04 24             	mov    %eax,(%esp)
801060ae:	e8 21 b9 ff ff       	call   801019d4 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801060b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b6:	8b 40 04             	mov    0x4(%eax),%eax
801060b9:	89 44 24 08          	mov    %eax,0x8(%esp)
801060bd:	c7 44 24 04 75 8c 10 	movl   $0x80108c75,0x4(%esp)
801060c4:	80 
801060c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c8:	89 04 24             	mov    %eax,(%esp)
801060cb:	e8 a1 c3 ff ff       	call   80102471 <dirlink>
801060d0:	85 c0                	test   %eax,%eax
801060d2:	78 21                	js     801060f5 <create+0x178>
801060d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060d7:	8b 40 04             	mov    0x4(%eax),%eax
801060da:	89 44 24 08          	mov    %eax,0x8(%esp)
801060de:	c7 44 24 04 77 8c 10 	movl   $0x80108c77,0x4(%esp)
801060e5:	80 
801060e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e9:	89 04 24             	mov    %eax,(%esp)
801060ec:	e8 80 c3 ff ff       	call   80102471 <dirlink>
801060f1:	85 c0                	test   %eax,%eax
801060f3:	79 0c                	jns    80106101 <create+0x184>
      panic("create dots");
801060f5:	c7 04 24 aa 8c 10 80 	movl   $0x80108caa,(%esp)
801060fc:	e8 3c a4 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106101:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106104:	8b 40 04             	mov    0x4(%eax),%eax
80106107:	89 44 24 08          	mov    %eax,0x8(%esp)
8010610b:	8d 45 de             	lea    -0x22(%ebp),%eax
8010610e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106115:	89 04 24             	mov    %eax,(%esp)
80106118:	e8 54 c3 ff ff       	call   80102471 <dirlink>
8010611d:	85 c0                	test   %eax,%eax
8010611f:	79 0c                	jns    8010612d <create+0x1b0>
    panic("create: dirlink");
80106121:	c7 04 24 b6 8c 10 80 	movl   $0x80108cb6,(%esp)
80106128:	e8 10 a4 ff ff       	call   8010053d <panic>

  iunlockput(dp);
8010612d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106130:	89 04 24             	mov    %eax,(%esp)
80106133:	e8 dc bc ff ff       	call   80101e14 <iunlockput>

  return ip;
80106138:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010613b:	c9                   	leave  
8010613c:	c3                   	ret    

8010613d <sys_open>:

int
sys_open(void)
{
8010613d:	55                   	push   %ebp
8010613e:	89 e5                	mov    %esp,%ebp
80106140:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106143:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106146:	89 44 24 04          	mov    %eax,0x4(%esp)
8010614a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106151:	e8 a2 f6 ff ff       	call   801057f8 <argstr>
80106156:	85 c0                	test   %eax,%eax
80106158:	78 17                	js     80106171 <sys_open+0x34>
8010615a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010615d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106161:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106168:	e8 f1 f5 ff ff       	call   8010575e <argint>
8010616d:	85 c0                	test   %eax,%eax
8010616f:	79 0a                	jns    8010617b <sys_open+0x3e>
    return -1;
80106171:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106176:	e9 46 01 00 00       	jmp    801062c1 <sys_open+0x184>
  if(omode & O_CREATE){
8010617b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010617e:	25 00 02 00 00       	and    $0x200,%eax
80106183:	85 c0                	test   %eax,%eax
80106185:	74 40                	je     801061c7 <sys_open+0x8a>
    begin_trans();
80106187:	e8 b9 d3 ff ff       	call   80103545 <begin_trans>
    ip = create(path, T_FILE, 0, 0);
8010618c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010618f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106196:	00 
80106197:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010619e:	00 
8010619f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801061a6:	00 
801061a7:	89 04 24             	mov    %eax,(%esp)
801061aa:	e8 ce fd ff ff       	call   80105f7d <create>
801061af:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
801061b2:	e8 d7 d3 ff ff       	call   8010358e <commit_trans>
    if(ip == 0)
801061b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061bb:	75 5c                	jne    80106219 <sys_open+0xdc>
      return -1;
801061bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c2:	e9 fa 00 00 00       	jmp    801062c1 <sys_open+0x184>
  } else {
    if((ip = namei(path)) == 0)
801061c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061ca:	89 04 24             	mov    %eax,(%esp)
801061cd:	e8 60 c5 ff ff       	call   80102732 <namei>
801061d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061d9:	75 0a                	jne    801061e5 <sys_open+0xa8>
      return -1;
801061db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061e0:	e9 dc 00 00 00       	jmp    801062c1 <sys_open+0x184>
    ilock(ip);
801061e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e8:	89 04 24             	mov    %eax,(%esp)
801061eb:	e8 a0 b9 ff ff       	call   80101b90 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801061f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801061f7:	66 83 f8 01          	cmp    $0x1,%ax
801061fb:	75 1c                	jne    80106219 <sys_open+0xdc>
801061fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106200:	85 c0                	test   %eax,%eax
80106202:	74 15                	je     80106219 <sys_open+0xdc>
      iunlockput(ip);
80106204:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106207:	89 04 24             	mov    %eax,(%esp)
8010620a:	e8 05 bc ff ff       	call   80101e14 <iunlockput>
      return -1;
8010620f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106214:	e9 a8 00 00 00       	jmp    801062c1 <sys_open+0x184>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106219:	e8 26 b0 ff ff       	call   80101244 <filealloc>
8010621e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106221:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106225:	74 14                	je     8010623b <sys_open+0xfe>
80106227:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010622a:	89 04 24             	mov    %eax,(%esp)
8010622d:	e8 43 f7 ff ff       	call   80105975 <fdalloc>
80106232:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106235:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106239:	79 23                	jns    8010625e <sys_open+0x121>
    if(f)
8010623b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010623f:	74 0b                	je     8010624c <sys_open+0x10f>
      fileclose(f);
80106241:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106244:	89 04 24             	mov    %eax,(%esp)
80106247:	e8 a0 b0 ff ff       	call   801012ec <fileclose>
    iunlockput(ip);
8010624c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010624f:	89 04 24             	mov    %eax,(%esp)
80106252:	e8 bd bb ff ff       	call   80101e14 <iunlockput>
    return -1;
80106257:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010625c:	eb 63                	jmp    801062c1 <sys_open+0x184>
  }
  iunlock(ip);
8010625e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106261:	89 04 24             	mov    %eax,(%esp)
80106264:	e8 75 ba ff ff       	call   80101cde <iunlock>

  f->type = FD_INODE;
80106269:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010626c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106272:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106275:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106278:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010627b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010627e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106285:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106288:	83 e0 01             	and    $0x1,%eax
8010628b:	85 c0                	test   %eax,%eax
8010628d:	0f 94 c2             	sete   %dl
80106290:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106293:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106296:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106299:	83 e0 01             	and    $0x1,%eax
8010629c:	84 c0                	test   %al,%al
8010629e:	75 0a                	jne    801062aa <sys_open+0x16d>
801062a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062a3:	83 e0 02             	and    $0x2,%eax
801062a6:	85 c0                	test   %eax,%eax
801062a8:	74 07                	je     801062b1 <sys_open+0x174>
801062aa:	b8 01 00 00 00       	mov    $0x1,%eax
801062af:	eb 05                	jmp    801062b6 <sys_open+0x179>
801062b1:	b8 00 00 00 00       	mov    $0x0,%eax
801062b6:	89 c2                	mov    %eax,%edx
801062b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062bb:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801062be:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801062c1:	c9                   	leave  
801062c2:	c3                   	ret    

801062c3 <sys_mkdir>:

int
sys_mkdir(void)
{
801062c3:	55                   	push   %ebp
801062c4:	89 e5                	mov    %esp,%ebp
801062c6:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
801062c9:	e8 77 d2 ff ff       	call   80103545 <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801062ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062d1:	89 44 24 04          	mov    %eax,0x4(%esp)
801062d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062dc:	e8 17 f5 ff ff       	call   801057f8 <argstr>
801062e1:	85 c0                	test   %eax,%eax
801062e3:	78 2c                	js     80106311 <sys_mkdir+0x4e>
801062e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801062ef:	00 
801062f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801062f7:	00 
801062f8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801062ff:	00 
80106300:	89 04 24             	mov    %eax,(%esp)
80106303:	e8 75 fc ff ff       	call   80105f7d <create>
80106308:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010630b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010630f:	75 0c                	jne    8010631d <sys_mkdir+0x5a>
    commit_trans();
80106311:	e8 78 d2 ff ff       	call   8010358e <commit_trans>
    return -1;
80106316:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010631b:	eb 15                	jmp    80106332 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
8010631d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106320:	89 04 24             	mov    %eax,(%esp)
80106323:	e8 ec ba ff ff       	call   80101e14 <iunlockput>
  commit_trans();
80106328:	e8 61 d2 ff ff       	call   8010358e <commit_trans>
  return 0;
8010632d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106332:	c9                   	leave  
80106333:	c3                   	ret    

80106334 <sys_mknod>:

int
sys_mknod(void)
{
80106334:	55                   	push   %ebp
80106335:	89 e5                	mov    %esp,%ebp
80106337:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
8010633a:	e8 06 d2 ff ff       	call   80103545 <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
8010633f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106342:	89 44 24 04          	mov    %eax,0x4(%esp)
80106346:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010634d:	e8 a6 f4 ff ff       	call   801057f8 <argstr>
80106352:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106355:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106359:	78 5e                	js     801063b9 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
8010635b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010635e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106362:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106369:	e8 f0 f3 ff ff       	call   8010575e <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
8010636e:	85 c0                	test   %eax,%eax
80106370:	78 47                	js     801063b9 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106372:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106375:	89 44 24 04          	mov    %eax,0x4(%esp)
80106379:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106380:	e8 d9 f3 ff ff       	call   8010575e <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106385:	85 c0                	test   %eax,%eax
80106387:	78 30                	js     801063b9 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106389:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010638c:	0f bf c8             	movswl %ax,%ecx
8010638f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106392:	0f bf d0             	movswl %ax,%edx
80106395:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106398:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010639c:	89 54 24 08          	mov    %edx,0x8(%esp)
801063a0:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801063a7:	00 
801063a8:	89 04 24             	mov    %eax,(%esp)
801063ab:	e8 cd fb ff ff       	call   80105f7d <create>
801063b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063b7:	75 0c                	jne    801063c5 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
801063b9:	e8 d0 d1 ff ff       	call   8010358e <commit_trans>
    return -1;
801063be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063c3:	eb 15                	jmp    801063da <sys_mknod+0xa6>
  }
  iunlockput(ip);
801063c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c8:	89 04 24             	mov    %eax,(%esp)
801063cb:	e8 44 ba ff ff       	call   80101e14 <iunlockput>
  commit_trans();
801063d0:	e8 b9 d1 ff ff       	call   8010358e <commit_trans>
  return 0;
801063d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063da:	c9                   	leave  
801063db:	c3                   	ret    

801063dc <sys_chdir>:

int
sys_chdir(void)
{
801063dc:	55                   	push   %ebp
801063dd:	89 e5                	mov    %esp,%ebp
801063df:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
801063e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063e5:	89 44 24 04          	mov    %eax,0x4(%esp)
801063e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063f0:	e8 03 f4 ff ff       	call   801057f8 <argstr>
801063f5:	85 c0                	test   %eax,%eax
801063f7:	78 14                	js     8010640d <sys_chdir+0x31>
801063f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063fc:	89 04 24             	mov    %eax,(%esp)
801063ff:	e8 2e c3 ff ff       	call   80102732 <namei>
80106404:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106407:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010640b:	75 07                	jne    80106414 <sys_chdir+0x38>
    return -1;
8010640d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106412:	eb 57                	jmp    8010646b <sys_chdir+0x8f>
  ilock(ip);
80106414:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106417:	89 04 24             	mov    %eax,(%esp)
8010641a:	e8 71 b7 ff ff       	call   80101b90 <ilock>
  if(ip->type != T_DIR){
8010641f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106422:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106426:	66 83 f8 01          	cmp    $0x1,%ax
8010642a:	74 12                	je     8010643e <sys_chdir+0x62>
    iunlockput(ip);
8010642c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010642f:	89 04 24             	mov    %eax,(%esp)
80106432:	e8 dd b9 ff ff       	call   80101e14 <iunlockput>
    return -1;
80106437:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010643c:	eb 2d                	jmp    8010646b <sys_chdir+0x8f>
  }
  iunlock(ip);
8010643e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106441:	89 04 24             	mov    %eax,(%esp)
80106444:	e8 95 b8 ff ff       	call   80101cde <iunlock>
  iput(proc->cwd);
80106449:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010644f:	8b 40 68             	mov    0x68(%eax),%eax
80106452:	89 04 24             	mov    %eax,(%esp)
80106455:	e8 e9 b8 ff ff       	call   80101d43 <iput>
  proc->cwd = ip;
8010645a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106460:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106463:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106466:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010646b:	c9                   	leave  
8010646c:	c3                   	ret    

8010646d <sys_exec>:

int
sys_exec(void)
{
8010646d:	55                   	push   %ebp
8010646e:	89 e5                	mov    %esp,%ebp
80106470:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106476:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106479:	89 44 24 04          	mov    %eax,0x4(%esp)
8010647d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106484:	e8 6f f3 ff ff       	call   801057f8 <argstr>
80106489:	85 c0                	test   %eax,%eax
8010648b:	78 1a                	js     801064a7 <sys_exec+0x3a>
8010648d:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106493:	89 44 24 04          	mov    %eax,0x4(%esp)
80106497:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010649e:	e8 bb f2 ff ff       	call   8010575e <argint>
801064a3:	85 c0                	test   %eax,%eax
801064a5:	79 0a                	jns    801064b1 <sys_exec+0x44>
    return -1;
801064a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ac:	e9 e2 00 00 00       	jmp    80106593 <sys_exec+0x126>
  }
  memset(argv, 0, sizeof(argv));
801064b1:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801064b8:	00 
801064b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801064c0:	00 
801064c1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801064c7:	89 04 24             	mov    %eax,(%esp)
801064ca:	e8 3f ef ff ff       	call   8010540e <memset>
  for(i=0;; i++){
801064cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801064d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d9:	83 f8 1f             	cmp    $0x1f,%eax
801064dc:	76 0a                	jbe    801064e8 <sys_exec+0x7b>
      return -1;
801064de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e3:	e9 ab 00 00 00       	jmp    80106593 <sys_exec+0x126>
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
801064e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064eb:	c1 e0 02             	shl    $0x2,%eax
801064ee:	89 c2                	mov    %eax,%edx
801064f0:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801064f6:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
801064f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064ff:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
80106505:	89 54 24 08          	mov    %edx,0x8(%esp)
80106509:	89 4c 24 04          	mov    %ecx,0x4(%esp)
8010650d:	89 04 24             	mov    %eax,(%esp)
80106510:	e8 b7 f1 ff ff       	call   801056cc <fetchint>
80106515:	85 c0                	test   %eax,%eax
80106517:	79 07                	jns    80106520 <sys_exec+0xb3>
      return -1;
80106519:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010651e:	eb 73                	jmp    80106593 <sys_exec+0x126>
    if(uarg == 0){
80106520:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106526:	85 c0                	test   %eax,%eax
80106528:	75 26                	jne    80106550 <sys_exec+0xe3>
      argv[i] = 0;
8010652a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010652d:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106534:	00 00 00 00 
      break;
80106538:	90                   	nop
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106539:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010653c:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106542:	89 54 24 04          	mov    %edx,0x4(%esp)
80106546:	89 04 24             	mov    %eax,(%esp)
80106549:	e8 d6 a8 ff ff       	call   80100e24 <exec>
8010654e:	eb 43                	jmp    80106593 <sys_exec+0x126>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
80106550:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106553:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010655a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106560:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
80106563:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
80106569:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010656f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106573:	89 54 24 04          	mov    %edx,0x4(%esp)
80106577:	89 04 24             	mov    %eax,(%esp)
8010657a:	e8 81 f1 ff ff       	call   80105700 <fetchstr>
8010657f:	85 c0                	test   %eax,%eax
80106581:	79 07                	jns    8010658a <sys_exec+0x11d>
      return -1;
80106583:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106588:	eb 09                	jmp    80106593 <sys_exec+0x126>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010658a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
8010658e:	e9 43 ff ff ff       	jmp    801064d6 <sys_exec+0x69>
  return exec(path, argv);
}
80106593:	c9                   	leave  
80106594:	c3                   	ret    

80106595 <sys_pipe>:

int
sys_pipe(void)
{
80106595:	55                   	push   %ebp
80106596:	89 e5                	mov    %esp,%ebp
80106598:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010659b:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801065a2:	00 
801065a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801065a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801065aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065b1:	e8 e0 f1 ff ff       	call   80105796 <argptr>
801065b6:	85 c0                	test   %eax,%eax
801065b8:	79 0a                	jns    801065c4 <sys_pipe+0x2f>
    return -1;
801065ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065bf:	e9 9b 00 00 00       	jmp    8010665f <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801065c4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801065c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801065cb:	8d 45 e8             	lea    -0x18(%ebp),%eax
801065ce:	89 04 24             	mov    %eax,(%esp)
801065d1:	e8 8a d9 ff ff       	call   80103f60 <pipealloc>
801065d6:	85 c0                	test   %eax,%eax
801065d8:	79 07                	jns    801065e1 <sys_pipe+0x4c>
    return -1;
801065da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065df:	eb 7e                	jmp    8010665f <sys_pipe+0xca>
  fd0 = -1;
801065e1:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801065e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801065eb:	89 04 24             	mov    %eax,(%esp)
801065ee:	e8 82 f3 ff ff       	call   80105975 <fdalloc>
801065f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065fa:	78 14                	js     80106610 <sys_pipe+0x7b>
801065fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065ff:	89 04 24             	mov    %eax,(%esp)
80106602:	e8 6e f3 ff ff       	call   80105975 <fdalloc>
80106607:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010660a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010660e:	79 37                	jns    80106647 <sys_pipe+0xb2>
    if(fd0 >= 0)
80106610:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106614:	78 14                	js     8010662a <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80106616:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010661c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010661f:	83 c2 08             	add    $0x8,%edx
80106622:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106629:	00 
    fileclose(rf);
8010662a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010662d:	89 04 24             	mov    %eax,(%esp)
80106630:	e8 b7 ac ff ff       	call   801012ec <fileclose>
    fileclose(wf);
80106635:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106638:	89 04 24             	mov    %eax,(%esp)
8010663b:	e8 ac ac ff ff       	call   801012ec <fileclose>
    return -1;
80106640:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106645:	eb 18                	jmp    8010665f <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106647:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010664a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010664d:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010664f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106652:	8d 50 04             	lea    0x4(%eax),%edx
80106655:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106658:	89 02                	mov    %eax,(%edx)
  return 0;
8010665a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010665f:	c9                   	leave  
80106660:	c3                   	ret    
80106661:	00 00                	add    %al,(%eax)
	...

80106664 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106664:	55                   	push   %ebp
80106665:	89 e5                	mov    %esp,%ebp
80106667:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010666a:	e8 ae df ff ff       	call   8010461d <fork>
}
8010666f:	c9                   	leave  
80106670:	c3                   	ret    

80106671 <sys_exit>:

int
sys_exit(void)
{
80106671:	55                   	push   %ebp
80106672:	89 e5                	mov    %esp,%ebp
80106674:	83 ec 08             	sub    $0x8,%esp
  exit();
80106677:	e8 36 e1 ff ff       	call   801047b2 <exit>
  return 0;  // not reached
8010667c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106681:	c9                   	leave  
80106682:	c3                   	ret    

80106683 <sys_wait>:

int
sys_wait(void)
{
80106683:	55                   	push   %ebp
80106684:	89 e5                	mov    %esp,%ebp
80106686:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106689:	e8 79 e2 ff ff       	call   80104907 <wait>
}
8010668e:	c9                   	leave  
8010668f:	c3                   	ret    

80106690 <sys_wait2>:

int
sys_wait2(void)
{
80106690:	55                   	push   %ebp
80106691:	89 e5                	mov    %esp,%ebp
80106693:	83 ec 28             	sub    $0x28,%esp
  char *rtime=0;
80106696:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  char *wtime=0;
8010669d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  argptr(1,&rtime,sizeof(rtime));
801066a4:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801066ab:	00 
801066ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066af:	89 44 24 04          	mov    %eax,0x4(%esp)
801066b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801066ba:	e8 d7 f0 ff ff       	call   80105796 <argptr>
  argptr(0,&wtime,sizeof(wtime));
801066bf:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801066c6:	00 
801066c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801066ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066d5:	e8 bc f0 ff ff       	call   80105796 <argptr>
  return wait2((int*)wtime, (int*)rtime);
801066da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066e0:	89 54 24 04          	mov    %edx,0x4(%esp)
801066e4:	89 04 24             	mov    %eax,(%esp)
801066e7:	e8 2d e3 ff ff       	call   80104a19 <wait2>
}
801066ec:	c9                   	leave  
801066ed:	c3                   	ret    

801066ee <sys_nice>:

int
sys_nice(void)
{
801066ee:	55                   	push   %ebp
801066ef:	89 e5                	mov    %esp,%ebp
801066f1:	83 ec 08             	sub    $0x8,%esp
  return nice();
801066f4:	e8 db e9 ff ff       	call   801050d4 <nice>
}
801066f9:	c9                   	leave  
801066fa:	c3                   	ret    

801066fb <sys_kill>:
int
sys_kill(void)
{
801066fb:	55                   	push   %ebp
801066fc:	89 e5                	mov    %esp,%ebp
801066fe:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106701:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106704:	89 44 24 04          	mov    %eax,0x4(%esp)
80106708:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010670f:	e8 4a f0 ff ff       	call   8010575e <argint>
80106714:	85 c0                	test   %eax,%eax
80106716:	79 07                	jns    8010671f <sys_kill+0x24>
    return -1;
80106718:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010671d:	eb 0b                	jmp    8010672a <sys_kill+0x2f>
  return kill(pid);
8010671f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106722:	89 04 24             	mov    %eax,(%esp)
80106725:	e8 33 e8 ff ff       	call   80104f5d <kill>
}
8010672a:	c9                   	leave  
8010672b:	c3                   	ret    

8010672c <sys_getpid>:

int
sys_getpid(void)
{
8010672c:	55                   	push   %ebp
8010672d:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010672f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106735:	8b 40 10             	mov    0x10(%eax),%eax
}
80106738:	5d                   	pop    %ebp
80106739:	c3                   	ret    

8010673a <sys_sbrk>:

int
sys_sbrk(void)
{
8010673a:	55                   	push   %ebp
8010673b:	89 e5                	mov    %esp,%ebp
8010673d:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106740:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106743:	89 44 24 04          	mov    %eax,0x4(%esp)
80106747:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010674e:	e8 0b f0 ff ff       	call   8010575e <argint>
80106753:	85 c0                	test   %eax,%eax
80106755:	79 07                	jns    8010675e <sys_sbrk+0x24>
    return -1;
80106757:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010675c:	eb 24                	jmp    80106782 <sys_sbrk+0x48>
  addr = proc->sz;
8010675e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106764:	8b 00                	mov    (%eax),%eax
80106766:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106769:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010676c:	89 04 24             	mov    %eax,(%esp)
8010676f:	e8 04 de ff ff       	call   80104578 <growproc>
80106774:	85 c0                	test   %eax,%eax
80106776:	79 07                	jns    8010677f <sys_sbrk+0x45>
    return -1;
80106778:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010677d:	eb 03                	jmp    80106782 <sys_sbrk+0x48>
  return addr;
8010677f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106782:	c9                   	leave  
80106783:	c3                   	ret    

80106784 <sys_sleep>:

int
sys_sleep(void)
{
80106784:	55                   	push   %ebp
80106785:	89 e5                	mov    %esp,%ebp
80106787:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
8010678a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010678d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106791:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106798:	e8 c1 ef ff ff       	call   8010575e <argint>
8010679d:	85 c0                	test   %eax,%eax
8010679f:	79 07                	jns    801067a8 <sys_sleep+0x24>
    return -1;
801067a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067a6:	eb 6c                	jmp    80106814 <sys_sleep+0x90>
  acquire(&tickslock);
801067a8:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
801067af:	e8 0b ea ff ff       	call   801051bf <acquire>
  ticks0 = ticks;
801067b4:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
801067b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801067bc:	eb 34                	jmp    801067f2 <sys_sleep+0x6e>
    if(proc->killed){
801067be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067c4:	8b 40 24             	mov    0x24(%eax),%eax
801067c7:	85 c0                	test   %eax,%eax
801067c9:	74 13                	je     801067de <sys_sleep+0x5a>
      release(&tickslock);
801067cb:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
801067d2:	e8 4a ea ff ff       	call   80105221 <release>
      return -1;
801067d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067dc:	eb 36                	jmp    80106814 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
801067de:	c7 44 24 04 80 24 11 	movl   $0x80112480,0x4(%esp)
801067e5:	80 
801067e6:	c7 04 24 c0 2c 11 80 	movl   $0x80112cc0,(%esp)
801067ed:	e8 64 e6 ff ff       	call   80104e56 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801067f2:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
801067f7:	89 c2                	mov    %eax,%edx
801067f9:	2b 55 f4             	sub    -0xc(%ebp),%edx
801067fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067ff:	39 c2                	cmp    %eax,%edx
80106801:	72 bb                	jb     801067be <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106803:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
8010680a:	e8 12 ea ff ff       	call   80105221 <release>
  return 0;
8010680f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106814:	c9                   	leave  
80106815:	c3                   	ret    

80106816 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106816:	55                   	push   %ebp
80106817:	89 e5                	mov    %esp,%ebp
80106819:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
8010681c:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80106823:	e8 97 e9 ff ff       	call   801051bf <acquire>
  xticks = ticks;
80106828:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
8010682d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106830:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80106837:	e8 e5 e9 ff ff       	call   80105221 <release>
  return xticks;
8010683c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010683f:	c9                   	leave  
80106840:	c3                   	ret    
80106841:	00 00                	add    %al,(%eax)
	...

80106844 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106844:	55                   	push   %ebp
80106845:	89 e5                	mov    %esp,%ebp
80106847:	83 ec 08             	sub    $0x8,%esp
8010684a:	8b 55 08             	mov    0x8(%ebp),%edx
8010684d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106850:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106854:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106857:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010685b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010685f:	ee                   	out    %al,(%dx)
}
80106860:	c9                   	leave  
80106861:	c3                   	ret    

80106862 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106862:	55                   	push   %ebp
80106863:	89 e5                	mov    %esp,%ebp
80106865:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106868:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
8010686f:	00 
80106870:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106877:	e8 c8 ff ff ff       	call   80106844 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
8010687c:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106883:	00 
80106884:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010688b:	e8 b4 ff ff ff       	call   80106844 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106890:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106897:	00 
80106898:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010689f:	e8 a0 ff ff ff       	call   80106844 <outb>
  picenable(IRQ_TIMER);
801068a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068ab:	e8 39 d5 ff ff       	call   80103de9 <picenable>
}
801068b0:	c9                   	leave  
801068b1:	c3                   	ret    
	...

801068b4 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801068b4:	1e                   	push   %ds
  pushl %es
801068b5:	06                   	push   %es
  pushl %fs
801068b6:	0f a0                	push   %fs
  pushl %gs
801068b8:	0f a8                	push   %gs
  pushal
801068ba:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801068bb:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801068bf:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801068c1:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801068c3:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801068c7:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801068c9:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801068cb:	54                   	push   %esp
  call trap
801068cc:	e8 de 01 00 00       	call   80106aaf <trap>
  addl $4, %esp
801068d1:	83 c4 04             	add    $0x4,%esp

801068d4 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801068d4:	61                   	popa   
  popl %gs
801068d5:	0f a9                	pop    %gs
  popl %fs
801068d7:	0f a1                	pop    %fs
  popl %es
801068d9:	07                   	pop    %es
  popl %ds
801068da:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801068db:	83 c4 08             	add    $0x8,%esp
  iret
801068de:	cf                   	iret   
	...

801068e0 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801068e0:	55                   	push   %ebp
801068e1:	89 e5                	mov    %esp,%ebp
801068e3:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801068e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801068e9:	83 e8 01             	sub    $0x1,%eax
801068ec:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801068f0:	8b 45 08             	mov    0x8(%ebp),%eax
801068f3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801068f7:	8b 45 08             	mov    0x8(%ebp),%eax
801068fa:	c1 e8 10             	shr    $0x10,%eax
801068fd:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106901:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106904:	0f 01 18             	lidtl  (%eax)
}
80106907:	c9                   	leave  
80106908:	c3                   	ret    

80106909 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106909:	55                   	push   %ebp
8010690a:	89 e5                	mov    %esp,%ebp
8010690c:	53                   	push   %ebx
8010690d:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106910:	0f 20 d3             	mov    %cr2,%ebx
80106913:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
80106916:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80106919:	83 c4 10             	add    $0x10,%esp
8010691c:	5b                   	pop    %ebx
8010691d:	5d                   	pop    %ebp
8010691e:	c3                   	ret    

8010691f <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010691f:	55                   	push   %ebp
80106920:	89 e5                	mov    %esp,%ebp
80106922:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106925:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010692c:	e9 c3 00 00 00       	jmp    801069f4 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106934:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
8010693b:	89 c2                	mov    %eax,%edx
8010693d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106940:	66 89 14 c5 c0 24 11 	mov    %dx,-0x7feedb40(,%eax,8)
80106947:	80 
80106948:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010694b:	66 c7 04 c5 c2 24 11 	movw   $0x8,-0x7feedb3e(,%eax,8)
80106952:	80 08 00 
80106955:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106958:	0f b6 14 c5 c4 24 11 	movzbl -0x7feedb3c(,%eax,8),%edx
8010695f:	80 
80106960:	83 e2 e0             	and    $0xffffffe0,%edx
80106963:	88 14 c5 c4 24 11 80 	mov    %dl,-0x7feedb3c(,%eax,8)
8010696a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010696d:	0f b6 14 c5 c4 24 11 	movzbl -0x7feedb3c(,%eax,8),%edx
80106974:	80 
80106975:	83 e2 1f             	and    $0x1f,%edx
80106978:	88 14 c5 c4 24 11 80 	mov    %dl,-0x7feedb3c(,%eax,8)
8010697f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106982:	0f b6 14 c5 c5 24 11 	movzbl -0x7feedb3b(,%eax,8),%edx
80106989:	80 
8010698a:	83 e2 f0             	and    $0xfffffff0,%edx
8010698d:	83 ca 0e             	or     $0xe,%edx
80106990:	88 14 c5 c5 24 11 80 	mov    %dl,-0x7feedb3b(,%eax,8)
80106997:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010699a:	0f b6 14 c5 c5 24 11 	movzbl -0x7feedb3b(,%eax,8),%edx
801069a1:	80 
801069a2:	83 e2 ef             	and    $0xffffffef,%edx
801069a5:	88 14 c5 c5 24 11 80 	mov    %dl,-0x7feedb3b(,%eax,8)
801069ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069af:	0f b6 14 c5 c5 24 11 	movzbl -0x7feedb3b(,%eax,8),%edx
801069b6:	80 
801069b7:	83 e2 9f             	and    $0xffffff9f,%edx
801069ba:	88 14 c5 c5 24 11 80 	mov    %dl,-0x7feedb3b(,%eax,8)
801069c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069c4:	0f b6 14 c5 c5 24 11 	movzbl -0x7feedb3b(,%eax,8),%edx
801069cb:	80 
801069cc:	83 ca 80             	or     $0xffffff80,%edx
801069cf:	88 14 c5 c5 24 11 80 	mov    %dl,-0x7feedb3b(,%eax,8)
801069d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069d9:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
801069e0:	c1 e8 10             	shr    $0x10,%eax
801069e3:	89 c2                	mov    %eax,%edx
801069e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069e8:	66 89 14 c5 c6 24 11 	mov    %dx,-0x7feedb3a(,%eax,8)
801069ef:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801069f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801069f4:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801069fb:	0f 8e 30 ff ff ff    	jle    80106931 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106a01:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
80106a06:	66 a3 c0 26 11 80    	mov    %ax,0x801126c0
80106a0c:	66 c7 05 c2 26 11 80 	movw   $0x8,0x801126c2
80106a13:	08 00 
80106a15:	0f b6 05 c4 26 11 80 	movzbl 0x801126c4,%eax
80106a1c:	83 e0 e0             	and    $0xffffffe0,%eax
80106a1f:	a2 c4 26 11 80       	mov    %al,0x801126c4
80106a24:	0f b6 05 c4 26 11 80 	movzbl 0x801126c4,%eax
80106a2b:	83 e0 1f             	and    $0x1f,%eax
80106a2e:	a2 c4 26 11 80       	mov    %al,0x801126c4
80106a33:	0f b6 05 c5 26 11 80 	movzbl 0x801126c5,%eax
80106a3a:	83 c8 0f             	or     $0xf,%eax
80106a3d:	a2 c5 26 11 80       	mov    %al,0x801126c5
80106a42:	0f b6 05 c5 26 11 80 	movzbl 0x801126c5,%eax
80106a49:	83 e0 ef             	and    $0xffffffef,%eax
80106a4c:	a2 c5 26 11 80       	mov    %al,0x801126c5
80106a51:	0f b6 05 c5 26 11 80 	movzbl 0x801126c5,%eax
80106a58:	83 c8 60             	or     $0x60,%eax
80106a5b:	a2 c5 26 11 80       	mov    %al,0x801126c5
80106a60:	0f b6 05 c5 26 11 80 	movzbl 0x801126c5,%eax
80106a67:	83 c8 80             	or     $0xffffff80,%eax
80106a6a:	a2 c5 26 11 80       	mov    %al,0x801126c5
80106a6f:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
80106a74:	c1 e8 10             	shr    $0x10,%eax
80106a77:	66 a3 c6 26 11 80    	mov    %ax,0x801126c6
  
  initlock(&tickslock, "time");
80106a7d:	c7 44 24 04 c8 8c 10 	movl   $0x80108cc8,0x4(%esp)
80106a84:	80 
80106a85:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80106a8c:	e8 0d e7 ff ff       	call   8010519e <initlock>
}
80106a91:	c9                   	leave  
80106a92:	c3                   	ret    

80106a93 <idtinit>:

void
idtinit(void)
{
80106a93:	55                   	push   %ebp
80106a94:	89 e5                	mov    %esp,%ebp
80106a96:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106a99:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106aa0:	00 
80106aa1:	c7 04 24 c0 24 11 80 	movl   $0x801124c0,(%esp)
80106aa8:	e8 33 fe ff ff       	call   801068e0 <lidt>
}
80106aad:	c9                   	leave  
80106aae:	c3                   	ret    

80106aaf <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106aaf:	55                   	push   %ebp
80106ab0:	89 e5                	mov    %esp,%ebp
80106ab2:	57                   	push   %edi
80106ab3:	56                   	push   %esi
80106ab4:	53                   	push   %ebx
80106ab5:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106ab8:	8b 45 08             	mov    0x8(%ebp),%eax
80106abb:	8b 40 30             	mov    0x30(%eax),%eax
80106abe:	83 f8 40             	cmp    $0x40,%eax
80106ac1:	75 3e                	jne    80106b01 <trap+0x52>
    if(proc->killed)
80106ac3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ac9:	8b 40 24             	mov    0x24(%eax),%eax
80106acc:	85 c0                	test   %eax,%eax
80106ace:	74 05                	je     80106ad5 <trap+0x26>
      exit();
80106ad0:	e8 dd dc ff ff       	call   801047b2 <exit>
    proc->tf = tf;
80106ad5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106adb:	8b 55 08             	mov    0x8(%ebp),%edx
80106ade:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106ae1:	e8 55 ed ff ff       	call   8010583b <syscall>
    if(proc->killed)
80106ae6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106aec:	8b 40 24             	mov    0x24(%eax),%eax
80106aef:	85 c0                	test   %eax,%eax
80106af1:	0f 84 78 02 00 00    	je     80106d6f <trap+0x2c0>
      exit();
80106af7:	e8 b6 dc ff ff       	call   801047b2 <exit>
    return;
80106afc:	e9 6e 02 00 00       	jmp    80106d6f <trap+0x2c0>
  }

  switch(tf->trapno){
80106b01:	8b 45 08             	mov    0x8(%ebp),%eax
80106b04:	8b 40 30             	mov    0x30(%eax),%eax
80106b07:	83 e8 20             	sub    $0x20,%eax
80106b0a:	83 f8 1f             	cmp    $0x1f,%eax
80106b0d:	0f 87 f0 00 00 00    	ja     80106c03 <trap+0x154>
80106b13:	8b 04 85 70 8d 10 80 	mov    -0x7fef7290(,%eax,4),%eax
80106b1a:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106b1c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b22:	0f b6 00             	movzbl (%eax),%eax
80106b25:	84 c0                	test   %al,%al
80106b27:	75 65                	jne    80106b8e <trap+0xdf>
      acquire(&tickslock);
80106b29:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80106b30:	e8 8a e6 ff ff       	call   801051bf <acquire>
      ticks++;
80106b35:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
80106b3a:	83 c0 01             	add    $0x1,%eax
80106b3d:	a3 c0 2c 11 80       	mov    %eax,0x80112cc0
      if(proc)
80106b42:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b48:	85 c0                	test   %eax,%eax
80106b4a:	74 2a                	je     80106b76 <trap+0xc7>
      {
	proc->rtime++;
80106b4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b52:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80106b58:	83 c2 01             	add    $0x1,%edx
80106b5b:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
	proc->quanta--;
80106b61:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b67:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
80106b6d:	83 ea 01             	sub    $0x1,%edx
80106b70:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
      }
      wakeup(&ticks);
80106b76:	c7 04 24 c0 2c 11 80 	movl   $0x80112cc0,(%esp)
80106b7d:	e8 b0 e3 ff ff       	call   80104f32 <wakeup>
      release(&tickslock);
80106b82:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80106b89:	e8 93 e6 ff ff       	call   80105221 <release>
    }
    lapiceoi();
80106b8e:	e8 7e c6 ff ff       	call   80103211 <lapiceoi>
    break;
80106b93:	e9 41 01 00 00       	jmp    80106cd9 <trap+0x22a>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106b98:	e8 7c be ff ff       	call   80102a19 <ideintr>
    lapiceoi();
80106b9d:	e8 6f c6 ff ff       	call   80103211 <lapiceoi>
    break;
80106ba2:	e9 32 01 00 00       	jmp    80106cd9 <trap+0x22a>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106ba7:	e8 43 c4 ff ff       	call   80102fef <kbdintr>
    lapiceoi();
80106bac:	e8 60 c6 ff ff       	call   80103211 <lapiceoi>
    break;
80106bb1:	e9 23 01 00 00       	jmp    80106cd9 <trap+0x22a>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106bb6:	e8 b9 03 00 00       	call   80106f74 <uartintr>
    lapiceoi();
80106bbb:	e8 51 c6 ff ff       	call   80103211 <lapiceoi>
    break;
80106bc0:	e9 14 01 00 00       	jmp    80106cd9 <trap+0x22a>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106bc5:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bc8:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106bcb:	8b 45 08             	mov    0x8(%ebp),%eax
80106bce:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bd2:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106bd5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106bdb:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bde:	0f b6 c0             	movzbl %al,%eax
80106be1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106be5:	89 54 24 08          	mov    %edx,0x8(%esp)
80106be9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bed:	c7 04 24 d0 8c 10 80 	movl   $0x80108cd0,(%esp)
80106bf4:	e8 a8 97 ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106bf9:	e8 13 c6 ff ff       	call   80103211 <lapiceoi>
    break;
80106bfe:	e9 d6 00 00 00       	jmp    80106cd9 <trap+0x22a>
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106c03:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c09:	85 c0                	test   %eax,%eax
80106c0b:	74 11                	je     80106c1e <trap+0x16f>
80106c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80106c10:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c14:	0f b7 c0             	movzwl %ax,%eax
80106c17:	83 e0 03             	and    $0x3,%eax
80106c1a:	85 c0                	test   %eax,%eax
80106c1c:	75 46                	jne    80106c64 <trap+0x1b5>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c1e:	e8 e6 fc ff ff       	call   80106909 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c23:	8b 55 08             	mov    0x8(%ebp),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c26:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c29:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106c30:	0f b6 12             	movzbl (%edx),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c33:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c36:	8b 55 08             	mov    0x8(%ebp),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c39:	8b 52 30             	mov    0x30(%edx),%edx
80106c3c:	89 44 24 10          	mov    %eax,0x10(%esp)
80106c40:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106c44:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106c48:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c4c:	c7 04 24 f4 8c 10 80 	movl   $0x80108cf4,(%esp)
80106c53:	e8 49 97 ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106c58:	c7 04 24 26 8d 10 80 	movl   $0x80108d26,(%esp)
80106c5f:	e8 d9 98 ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c64:	e8 a0 fc ff ff       	call   80106909 <rcr2>
80106c69:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c6b:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c6e:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c71:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c77:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c7a:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c7d:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c80:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c83:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c86:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c89:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c8f:	83 c0 6c             	add    $0x6c,%eax
80106c92:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106c95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c9b:	8b 40 10             	mov    0x10(%eax),%eax
80106c9e:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106ca2:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106ca6:	89 74 24 14          	mov    %esi,0x14(%esp)
80106caa:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106cae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106cb2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106cb5:	89 54 24 08          	mov    %edx,0x8(%esp)
80106cb9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cbd:	c7 04 24 2c 8d 10 80 	movl   $0x80108d2c,(%esp)
80106cc4:	e8 d8 96 ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106cc9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ccf:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106cd6:	eb 01                	jmp    80106cd9 <trap+0x22a>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106cd8:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106cd9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cdf:	85 c0                	test   %eax,%eax
80106ce1:	74 24                	je     80106d07 <trap+0x258>
80106ce3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ce9:	8b 40 24             	mov    0x24(%eax),%eax
80106cec:	85 c0                	test   %eax,%eax
80106cee:	74 17                	je     80106d07 <trap+0x258>
80106cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80106cf3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106cf7:	0f b7 c0             	movzwl %ax,%eax
80106cfa:	83 e0 03             	and    $0x3,%eax
80106cfd:	83 f8 03             	cmp    $0x3,%eax
80106d00:	75 05                	jne    80106d07 <trap+0x258>
    exit();
80106d02:	e8 ab da ff ff       	call   801047b2 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER && proc->quanta <= 0)
80106d07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d0d:	85 c0                	test   %eax,%eax
80106d0f:	74 2e                	je     80106d3f <trap+0x290>
80106d11:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d17:	8b 40 0c             	mov    0xc(%eax),%eax
80106d1a:	83 f8 04             	cmp    $0x4,%eax
80106d1d:	75 20                	jne    80106d3f <trap+0x290>
80106d1f:	8b 45 08             	mov    0x8(%ebp),%eax
80106d22:	8b 40 30             	mov    0x30(%eax),%eax
80106d25:	83 f8 20             	cmp    $0x20,%eax
80106d28:	75 15                	jne    80106d3f <trap+0x290>
80106d2a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d30:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80106d36:	85 c0                	test   %eax,%eax
80106d38:	7f 05                	jg     80106d3f <trap+0x290>
    yield();
80106d3a:	e8 b9 e0 ff ff       	call   80104df8 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106d3f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d45:	85 c0                	test   %eax,%eax
80106d47:	74 27                	je     80106d70 <trap+0x2c1>
80106d49:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d4f:	8b 40 24             	mov    0x24(%eax),%eax
80106d52:	85 c0                	test   %eax,%eax
80106d54:	74 1a                	je     80106d70 <trap+0x2c1>
80106d56:	8b 45 08             	mov    0x8(%ebp),%eax
80106d59:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d5d:	0f b7 c0             	movzwl %ax,%eax
80106d60:	83 e0 03             	and    $0x3,%eax
80106d63:	83 f8 03             	cmp    $0x3,%eax
80106d66:	75 08                	jne    80106d70 <trap+0x2c1>
    exit();
80106d68:	e8 45 da ff ff       	call   801047b2 <exit>
80106d6d:	eb 01                	jmp    80106d70 <trap+0x2c1>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106d6f:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106d70:	83 c4 3c             	add    $0x3c,%esp
80106d73:	5b                   	pop    %ebx
80106d74:	5e                   	pop    %esi
80106d75:	5f                   	pop    %edi
80106d76:	5d                   	pop    %ebp
80106d77:	c3                   	ret    

80106d78 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106d78:	55                   	push   %ebp
80106d79:	89 e5                	mov    %esp,%ebp
80106d7b:	53                   	push   %ebx
80106d7c:	83 ec 14             	sub    $0x14,%esp
80106d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80106d82:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106d86:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80106d8a:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80106d8e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80106d92:	ec                   	in     (%dx),%al
80106d93:	89 c3                	mov    %eax,%ebx
80106d95:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80106d98:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80106d9c:	83 c4 14             	add    $0x14,%esp
80106d9f:	5b                   	pop    %ebx
80106da0:	5d                   	pop    %ebp
80106da1:	c3                   	ret    

80106da2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106da2:	55                   	push   %ebp
80106da3:	89 e5                	mov    %esp,%ebp
80106da5:	83 ec 08             	sub    $0x8,%esp
80106da8:	8b 55 08             	mov    0x8(%ebp),%edx
80106dab:	8b 45 0c             	mov    0xc(%ebp),%eax
80106dae:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106db2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106db5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106db9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106dbd:	ee                   	out    %al,(%dx)
}
80106dbe:	c9                   	leave  
80106dbf:	c3                   	ret    

80106dc0 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106dc0:	55                   	push   %ebp
80106dc1:	89 e5                	mov    %esp,%ebp
80106dc3:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106dc6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106dcd:	00 
80106dce:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106dd5:	e8 c8 ff ff ff       	call   80106da2 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106dda:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106de1:	00 
80106de2:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106de9:	e8 b4 ff ff ff       	call   80106da2 <outb>
  outb(COM1+0, 115200/9600);
80106dee:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106df5:	00 
80106df6:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106dfd:	e8 a0 ff ff ff       	call   80106da2 <outb>
  outb(COM1+1, 0);
80106e02:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e09:	00 
80106e0a:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106e11:	e8 8c ff ff ff       	call   80106da2 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106e16:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106e1d:	00 
80106e1e:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106e25:	e8 78 ff ff ff       	call   80106da2 <outb>
  outb(COM1+4, 0);
80106e2a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e31:	00 
80106e32:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106e39:	e8 64 ff ff ff       	call   80106da2 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106e3e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106e45:	00 
80106e46:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106e4d:	e8 50 ff ff ff       	call   80106da2 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106e52:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106e59:	e8 1a ff ff ff       	call   80106d78 <inb>
80106e5e:	3c ff                	cmp    $0xff,%al
80106e60:	74 6c                	je     80106ece <uartinit+0x10e>
    return;
  uart = 1;
80106e62:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106e69:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106e6c:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106e73:	e8 00 ff ff ff       	call   80106d78 <inb>
  inb(COM1+0);
80106e78:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e7f:	e8 f4 fe ff ff       	call   80106d78 <inb>
  picenable(IRQ_COM1);
80106e84:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106e8b:	e8 59 cf ff ff       	call   80103de9 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106e90:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e97:	00 
80106e98:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106e9f:	e8 fa bd ff ff       	call   80102c9e <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106ea4:	c7 45 f4 f0 8d 10 80 	movl   $0x80108df0,-0xc(%ebp)
80106eab:	eb 15                	jmp    80106ec2 <uartinit+0x102>
    uartputc(*p);
80106ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eb0:	0f b6 00             	movzbl (%eax),%eax
80106eb3:	0f be c0             	movsbl %al,%eax
80106eb6:	89 04 24             	mov    %eax,(%esp)
80106eb9:	e8 13 00 00 00       	call   80106ed1 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106ebe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ec5:	0f b6 00             	movzbl (%eax),%eax
80106ec8:	84 c0                	test   %al,%al
80106eca:	75 e1                	jne    80106ead <uartinit+0xed>
80106ecc:	eb 01                	jmp    80106ecf <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106ece:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106ecf:	c9                   	leave  
80106ed0:	c3                   	ret    

80106ed1 <uartputc>:

void
uartputc(int c)
{
80106ed1:	55                   	push   %ebp
80106ed2:	89 e5                	mov    %esp,%ebp
80106ed4:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106ed7:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106edc:	85 c0                	test   %eax,%eax
80106ede:	74 4d                	je     80106f2d <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ee0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106ee7:	eb 10                	jmp    80106ef9 <uartputc+0x28>
    microdelay(10);
80106ee9:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106ef0:	e8 41 c3 ff ff       	call   80103236 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ef5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ef9:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106efd:	7f 16                	jg     80106f15 <uartputc+0x44>
80106eff:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106f06:	e8 6d fe ff ff       	call   80106d78 <inb>
80106f0b:	0f b6 c0             	movzbl %al,%eax
80106f0e:	83 e0 20             	and    $0x20,%eax
80106f11:	85 c0                	test   %eax,%eax
80106f13:	74 d4                	je     80106ee9 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106f15:	8b 45 08             	mov    0x8(%ebp),%eax
80106f18:	0f b6 c0             	movzbl %al,%eax
80106f1b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f1f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106f26:	e8 77 fe ff ff       	call   80106da2 <outb>
80106f2b:	eb 01                	jmp    80106f2e <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106f2d:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106f2e:	c9                   	leave  
80106f2f:	c3                   	ret    

80106f30 <uartgetc>:

static int
uartgetc(void)
{
80106f30:	55                   	push   %ebp
80106f31:	89 e5                	mov    %esp,%ebp
80106f33:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106f36:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106f3b:	85 c0                	test   %eax,%eax
80106f3d:	75 07                	jne    80106f46 <uartgetc+0x16>
    return -1;
80106f3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f44:	eb 2c                	jmp    80106f72 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106f46:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106f4d:	e8 26 fe ff ff       	call   80106d78 <inb>
80106f52:	0f b6 c0             	movzbl %al,%eax
80106f55:	83 e0 01             	and    $0x1,%eax
80106f58:	85 c0                	test   %eax,%eax
80106f5a:	75 07                	jne    80106f63 <uartgetc+0x33>
    return -1;
80106f5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f61:	eb 0f                	jmp    80106f72 <uartgetc+0x42>
  return inb(COM1+0);
80106f63:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106f6a:	e8 09 fe ff ff       	call   80106d78 <inb>
80106f6f:	0f b6 c0             	movzbl %al,%eax
}
80106f72:	c9                   	leave  
80106f73:	c3                   	ret    

80106f74 <uartintr>:

void
uartintr(void)
{
80106f74:	55                   	push   %ebp
80106f75:	89 e5                	mov    %esp,%ebp
80106f77:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106f7a:	c7 04 24 30 6f 10 80 	movl   $0x80106f30,(%esp)
80106f81:	e8 e6 98 ff ff       	call   8010086c <consoleintr>
}
80106f86:	c9                   	leave  
80106f87:	c3                   	ret    

80106f88 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106f88:	6a 00                	push   $0x0
  pushl $0
80106f8a:	6a 00                	push   $0x0
  jmp alltraps
80106f8c:	e9 23 f9 ff ff       	jmp    801068b4 <alltraps>

80106f91 <vector1>:
.globl vector1
vector1:
  pushl $0
80106f91:	6a 00                	push   $0x0
  pushl $1
80106f93:	6a 01                	push   $0x1
  jmp alltraps
80106f95:	e9 1a f9 ff ff       	jmp    801068b4 <alltraps>

80106f9a <vector2>:
.globl vector2
vector2:
  pushl $0
80106f9a:	6a 00                	push   $0x0
  pushl $2
80106f9c:	6a 02                	push   $0x2
  jmp alltraps
80106f9e:	e9 11 f9 ff ff       	jmp    801068b4 <alltraps>

80106fa3 <vector3>:
.globl vector3
vector3:
  pushl $0
80106fa3:	6a 00                	push   $0x0
  pushl $3
80106fa5:	6a 03                	push   $0x3
  jmp alltraps
80106fa7:	e9 08 f9 ff ff       	jmp    801068b4 <alltraps>

80106fac <vector4>:
.globl vector4
vector4:
  pushl $0
80106fac:	6a 00                	push   $0x0
  pushl $4
80106fae:	6a 04                	push   $0x4
  jmp alltraps
80106fb0:	e9 ff f8 ff ff       	jmp    801068b4 <alltraps>

80106fb5 <vector5>:
.globl vector5
vector5:
  pushl $0
80106fb5:	6a 00                	push   $0x0
  pushl $5
80106fb7:	6a 05                	push   $0x5
  jmp alltraps
80106fb9:	e9 f6 f8 ff ff       	jmp    801068b4 <alltraps>

80106fbe <vector6>:
.globl vector6
vector6:
  pushl $0
80106fbe:	6a 00                	push   $0x0
  pushl $6
80106fc0:	6a 06                	push   $0x6
  jmp alltraps
80106fc2:	e9 ed f8 ff ff       	jmp    801068b4 <alltraps>

80106fc7 <vector7>:
.globl vector7
vector7:
  pushl $0
80106fc7:	6a 00                	push   $0x0
  pushl $7
80106fc9:	6a 07                	push   $0x7
  jmp alltraps
80106fcb:	e9 e4 f8 ff ff       	jmp    801068b4 <alltraps>

80106fd0 <vector8>:
.globl vector8
vector8:
  pushl $8
80106fd0:	6a 08                	push   $0x8
  jmp alltraps
80106fd2:	e9 dd f8 ff ff       	jmp    801068b4 <alltraps>

80106fd7 <vector9>:
.globl vector9
vector9:
  pushl $0
80106fd7:	6a 00                	push   $0x0
  pushl $9
80106fd9:	6a 09                	push   $0x9
  jmp alltraps
80106fdb:	e9 d4 f8 ff ff       	jmp    801068b4 <alltraps>

80106fe0 <vector10>:
.globl vector10
vector10:
  pushl $10
80106fe0:	6a 0a                	push   $0xa
  jmp alltraps
80106fe2:	e9 cd f8 ff ff       	jmp    801068b4 <alltraps>

80106fe7 <vector11>:
.globl vector11
vector11:
  pushl $11
80106fe7:	6a 0b                	push   $0xb
  jmp alltraps
80106fe9:	e9 c6 f8 ff ff       	jmp    801068b4 <alltraps>

80106fee <vector12>:
.globl vector12
vector12:
  pushl $12
80106fee:	6a 0c                	push   $0xc
  jmp alltraps
80106ff0:	e9 bf f8 ff ff       	jmp    801068b4 <alltraps>

80106ff5 <vector13>:
.globl vector13
vector13:
  pushl $13
80106ff5:	6a 0d                	push   $0xd
  jmp alltraps
80106ff7:	e9 b8 f8 ff ff       	jmp    801068b4 <alltraps>

80106ffc <vector14>:
.globl vector14
vector14:
  pushl $14
80106ffc:	6a 0e                	push   $0xe
  jmp alltraps
80106ffe:	e9 b1 f8 ff ff       	jmp    801068b4 <alltraps>

80107003 <vector15>:
.globl vector15
vector15:
  pushl $0
80107003:	6a 00                	push   $0x0
  pushl $15
80107005:	6a 0f                	push   $0xf
  jmp alltraps
80107007:	e9 a8 f8 ff ff       	jmp    801068b4 <alltraps>

8010700c <vector16>:
.globl vector16
vector16:
  pushl $0
8010700c:	6a 00                	push   $0x0
  pushl $16
8010700e:	6a 10                	push   $0x10
  jmp alltraps
80107010:	e9 9f f8 ff ff       	jmp    801068b4 <alltraps>

80107015 <vector17>:
.globl vector17
vector17:
  pushl $17
80107015:	6a 11                	push   $0x11
  jmp alltraps
80107017:	e9 98 f8 ff ff       	jmp    801068b4 <alltraps>

8010701c <vector18>:
.globl vector18
vector18:
  pushl $0
8010701c:	6a 00                	push   $0x0
  pushl $18
8010701e:	6a 12                	push   $0x12
  jmp alltraps
80107020:	e9 8f f8 ff ff       	jmp    801068b4 <alltraps>

80107025 <vector19>:
.globl vector19
vector19:
  pushl $0
80107025:	6a 00                	push   $0x0
  pushl $19
80107027:	6a 13                	push   $0x13
  jmp alltraps
80107029:	e9 86 f8 ff ff       	jmp    801068b4 <alltraps>

8010702e <vector20>:
.globl vector20
vector20:
  pushl $0
8010702e:	6a 00                	push   $0x0
  pushl $20
80107030:	6a 14                	push   $0x14
  jmp alltraps
80107032:	e9 7d f8 ff ff       	jmp    801068b4 <alltraps>

80107037 <vector21>:
.globl vector21
vector21:
  pushl $0
80107037:	6a 00                	push   $0x0
  pushl $21
80107039:	6a 15                	push   $0x15
  jmp alltraps
8010703b:	e9 74 f8 ff ff       	jmp    801068b4 <alltraps>

80107040 <vector22>:
.globl vector22
vector22:
  pushl $0
80107040:	6a 00                	push   $0x0
  pushl $22
80107042:	6a 16                	push   $0x16
  jmp alltraps
80107044:	e9 6b f8 ff ff       	jmp    801068b4 <alltraps>

80107049 <vector23>:
.globl vector23
vector23:
  pushl $0
80107049:	6a 00                	push   $0x0
  pushl $23
8010704b:	6a 17                	push   $0x17
  jmp alltraps
8010704d:	e9 62 f8 ff ff       	jmp    801068b4 <alltraps>

80107052 <vector24>:
.globl vector24
vector24:
  pushl $0
80107052:	6a 00                	push   $0x0
  pushl $24
80107054:	6a 18                	push   $0x18
  jmp alltraps
80107056:	e9 59 f8 ff ff       	jmp    801068b4 <alltraps>

8010705b <vector25>:
.globl vector25
vector25:
  pushl $0
8010705b:	6a 00                	push   $0x0
  pushl $25
8010705d:	6a 19                	push   $0x19
  jmp alltraps
8010705f:	e9 50 f8 ff ff       	jmp    801068b4 <alltraps>

80107064 <vector26>:
.globl vector26
vector26:
  pushl $0
80107064:	6a 00                	push   $0x0
  pushl $26
80107066:	6a 1a                	push   $0x1a
  jmp alltraps
80107068:	e9 47 f8 ff ff       	jmp    801068b4 <alltraps>

8010706d <vector27>:
.globl vector27
vector27:
  pushl $0
8010706d:	6a 00                	push   $0x0
  pushl $27
8010706f:	6a 1b                	push   $0x1b
  jmp alltraps
80107071:	e9 3e f8 ff ff       	jmp    801068b4 <alltraps>

80107076 <vector28>:
.globl vector28
vector28:
  pushl $0
80107076:	6a 00                	push   $0x0
  pushl $28
80107078:	6a 1c                	push   $0x1c
  jmp alltraps
8010707a:	e9 35 f8 ff ff       	jmp    801068b4 <alltraps>

8010707f <vector29>:
.globl vector29
vector29:
  pushl $0
8010707f:	6a 00                	push   $0x0
  pushl $29
80107081:	6a 1d                	push   $0x1d
  jmp alltraps
80107083:	e9 2c f8 ff ff       	jmp    801068b4 <alltraps>

80107088 <vector30>:
.globl vector30
vector30:
  pushl $0
80107088:	6a 00                	push   $0x0
  pushl $30
8010708a:	6a 1e                	push   $0x1e
  jmp alltraps
8010708c:	e9 23 f8 ff ff       	jmp    801068b4 <alltraps>

80107091 <vector31>:
.globl vector31
vector31:
  pushl $0
80107091:	6a 00                	push   $0x0
  pushl $31
80107093:	6a 1f                	push   $0x1f
  jmp alltraps
80107095:	e9 1a f8 ff ff       	jmp    801068b4 <alltraps>

8010709a <vector32>:
.globl vector32
vector32:
  pushl $0
8010709a:	6a 00                	push   $0x0
  pushl $32
8010709c:	6a 20                	push   $0x20
  jmp alltraps
8010709e:	e9 11 f8 ff ff       	jmp    801068b4 <alltraps>

801070a3 <vector33>:
.globl vector33
vector33:
  pushl $0
801070a3:	6a 00                	push   $0x0
  pushl $33
801070a5:	6a 21                	push   $0x21
  jmp alltraps
801070a7:	e9 08 f8 ff ff       	jmp    801068b4 <alltraps>

801070ac <vector34>:
.globl vector34
vector34:
  pushl $0
801070ac:	6a 00                	push   $0x0
  pushl $34
801070ae:	6a 22                	push   $0x22
  jmp alltraps
801070b0:	e9 ff f7 ff ff       	jmp    801068b4 <alltraps>

801070b5 <vector35>:
.globl vector35
vector35:
  pushl $0
801070b5:	6a 00                	push   $0x0
  pushl $35
801070b7:	6a 23                	push   $0x23
  jmp alltraps
801070b9:	e9 f6 f7 ff ff       	jmp    801068b4 <alltraps>

801070be <vector36>:
.globl vector36
vector36:
  pushl $0
801070be:	6a 00                	push   $0x0
  pushl $36
801070c0:	6a 24                	push   $0x24
  jmp alltraps
801070c2:	e9 ed f7 ff ff       	jmp    801068b4 <alltraps>

801070c7 <vector37>:
.globl vector37
vector37:
  pushl $0
801070c7:	6a 00                	push   $0x0
  pushl $37
801070c9:	6a 25                	push   $0x25
  jmp alltraps
801070cb:	e9 e4 f7 ff ff       	jmp    801068b4 <alltraps>

801070d0 <vector38>:
.globl vector38
vector38:
  pushl $0
801070d0:	6a 00                	push   $0x0
  pushl $38
801070d2:	6a 26                	push   $0x26
  jmp alltraps
801070d4:	e9 db f7 ff ff       	jmp    801068b4 <alltraps>

801070d9 <vector39>:
.globl vector39
vector39:
  pushl $0
801070d9:	6a 00                	push   $0x0
  pushl $39
801070db:	6a 27                	push   $0x27
  jmp alltraps
801070dd:	e9 d2 f7 ff ff       	jmp    801068b4 <alltraps>

801070e2 <vector40>:
.globl vector40
vector40:
  pushl $0
801070e2:	6a 00                	push   $0x0
  pushl $40
801070e4:	6a 28                	push   $0x28
  jmp alltraps
801070e6:	e9 c9 f7 ff ff       	jmp    801068b4 <alltraps>

801070eb <vector41>:
.globl vector41
vector41:
  pushl $0
801070eb:	6a 00                	push   $0x0
  pushl $41
801070ed:	6a 29                	push   $0x29
  jmp alltraps
801070ef:	e9 c0 f7 ff ff       	jmp    801068b4 <alltraps>

801070f4 <vector42>:
.globl vector42
vector42:
  pushl $0
801070f4:	6a 00                	push   $0x0
  pushl $42
801070f6:	6a 2a                	push   $0x2a
  jmp alltraps
801070f8:	e9 b7 f7 ff ff       	jmp    801068b4 <alltraps>

801070fd <vector43>:
.globl vector43
vector43:
  pushl $0
801070fd:	6a 00                	push   $0x0
  pushl $43
801070ff:	6a 2b                	push   $0x2b
  jmp alltraps
80107101:	e9 ae f7 ff ff       	jmp    801068b4 <alltraps>

80107106 <vector44>:
.globl vector44
vector44:
  pushl $0
80107106:	6a 00                	push   $0x0
  pushl $44
80107108:	6a 2c                	push   $0x2c
  jmp alltraps
8010710a:	e9 a5 f7 ff ff       	jmp    801068b4 <alltraps>

8010710f <vector45>:
.globl vector45
vector45:
  pushl $0
8010710f:	6a 00                	push   $0x0
  pushl $45
80107111:	6a 2d                	push   $0x2d
  jmp alltraps
80107113:	e9 9c f7 ff ff       	jmp    801068b4 <alltraps>

80107118 <vector46>:
.globl vector46
vector46:
  pushl $0
80107118:	6a 00                	push   $0x0
  pushl $46
8010711a:	6a 2e                	push   $0x2e
  jmp alltraps
8010711c:	e9 93 f7 ff ff       	jmp    801068b4 <alltraps>

80107121 <vector47>:
.globl vector47
vector47:
  pushl $0
80107121:	6a 00                	push   $0x0
  pushl $47
80107123:	6a 2f                	push   $0x2f
  jmp alltraps
80107125:	e9 8a f7 ff ff       	jmp    801068b4 <alltraps>

8010712a <vector48>:
.globl vector48
vector48:
  pushl $0
8010712a:	6a 00                	push   $0x0
  pushl $48
8010712c:	6a 30                	push   $0x30
  jmp alltraps
8010712e:	e9 81 f7 ff ff       	jmp    801068b4 <alltraps>

80107133 <vector49>:
.globl vector49
vector49:
  pushl $0
80107133:	6a 00                	push   $0x0
  pushl $49
80107135:	6a 31                	push   $0x31
  jmp alltraps
80107137:	e9 78 f7 ff ff       	jmp    801068b4 <alltraps>

8010713c <vector50>:
.globl vector50
vector50:
  pushl $0
8010713c:	6a 00                	push   $0x0
  pushl $50
8010713e:	6a 32                	push   $0x32
  jmp alltraps
80107140:	e9 6f f7 ff ff       	jmp    801068b4 <alltraps>

80107145 <vector51>:
.globl vector51
vector51:
  pushl $0
80107145:	6a 00                	push   $0x0
  pushl $51
80107147:	6a 33                	push   $0x33
  jmp alltraps
80107149:	e9 66 f7 ff ff       	jmp    801068b4 <alltraps>

8010714e <vector52>:
.globl vector52
vector52:
  pushl $0
8010714e:	6a 00                	push   $0x0
  pushl $52
80107150:	6a 34                	push   $0x34
  jmp alltraps
80107152:	e9 5d f7 ff ff       	jmp    801068b4 <alltraps>

80107157 <vector53>:
.globl vector53
vector53:
  pushl $0
80107157:	6a 00                	push   $0x0
  pushl $53
80107159:	6a 35                	push   $0x35
  jmp alltraps
8010715b:	e9 54 f7 ff ff       	jmp    801068b4 <alltraps>

80107160 <vector54>:
.globl vector54
vector54:
  pushl $0
80107160:	6a 00                	push   $0x0
  pushl $54
80107162:	6a 36                	push   $0x36
  jmp alltraps
80107164:	e9 4b f7 ff ff       	jmp    801068b4 <alltraps>

80107169 <vector55>:
.globl vector55
vector55:
  pushl $0
80107169:	6a 00                	push   $0x0
  pushl $55
8010716b:	6a 37                	push   $0x37
  jmp alltraps
8010716d:	e9 42 f7 ff ff       	jmp    801068b4 <alltraps>

80107172 <vector56>:
.globl vector56
vector56:
  pushl $0
80107172:	6a 00                	push   $0x0
  pushl $56
80107174:	6a 38                	push   $0x38
  jmp alltraps
80107176:	e9 39 f7 ff ff       	jmp    801068b4 <alltraps>

8010717b <vector57>:
.globl vector57
vector57:
  pushl $0
8010717b:	6a 00                	push   $0x0
  pushl $57
8010717d:	6a 39                	push   $0x39
  jmp alltraps
8010717f:	e9 30 f7 ff ff       	jmp    801068b4 <alltraps>

80107184 <vector58>:
.globl vector58
vector58:
  pushl $0
80107184:	6a 00                	push   $0x0
  pushl $58
80107186:	6a 3a                	push   $0x3a
  jmp alltraps
80107188:	e9 27 f7 ff ff       	jmp    801068b4 <alltraps>

8010718d <vector59>:
.globl vector59
vector59:
  pushl $0
8010718d:	6a 00                	push   $0x0
  pushl $59
8010718f:	6a 3b                	push   $0x3b
  jmp alltraps
80107191:	e9 1e f7 ff ff       	jmp    801068b4 <alltraps>

80107196 <vector60>:
.globl vector60
vector60:
  pushl $0
80107196:	6a 00                	push   $0x0
  pushl $60
80107198:	6a 3c                	push   $0x3c
  jmp alltraps
8010719a:	e9 15 f7 ff ff       	jmp    801068b4 <alltraps>

8010719f <vector61>:
.globl vector61
vector61:
  pushl $0
8010719f:	6a 00                	push   $0x0
  pushl $61
801071a1:	6a 3d                	push   $0x3d
  jmp alltraps
801071a3:	e9 0c f7 ff ff       	jmp    801068b4 <alltraps>

801071a8 <vector62>:
.globl vector62
vector62:
  pushl $0
801071a8:	6a 00                	push   $0x0
  pushl $62
801071aa:	6a 3e                	push   $0x3e
  jmp alltraps
801071ac:	e9 03 f7 ff ff       	jmp    801068b4 <alltraps>

801071b1 <vector63>:
.globl vector63
vector63:
  pushl $0
801071b1:	6a 00                	push   $0x0
  pushl $63
801071b3:	6a 3f                	push   $0x3f
  jmp alltraps
801071b5:	e9 fa f6 ff ff       	jmp    801068b4 <alltraps>

801071ba <vector64>:
.globl vector64
vector64:
  pushl $0
801071ba:	6a 00                	push   $0x0
  pushl $64
801071bc:	6a 40                	push   $0x40
  jmp alltraps
801071be:	e9 f1 f6 ff ff       	jmp    801068b4 <alltraps>

801071c3 <vector65>:
.globl vector65
vector65:
  pushl $0
801071c3:	6a 00                	push   $0x0
  pushl $65
801071c5:	6a 41                	push   $0x41
  jmp alltraps
801071c7:	e9 e8 f6 ff ff       	jmp    801068b4 <alltraps>

801071cc <vector66>:
.globl vector66
vector66:
  pushl $0
801071cc:	6a 00                	push   $0x0
  pushl $66
801071ce:	6a 42                	push   $0x42
  jmp alltraps
801071d0:	e9 df f6 ff ff       	jmp    801068b4 <alltraps>

801071d5 <vector67>:
.globl vector67
vector67:
  pushl $0
801071d5:	6a 00                	push   $0x0
  pushl $67
801071d7:	6a 43                	push   $0x43
  jmp alltraps
801071d9:	e9 d6 f6 ff ff       	jmp    801068b4 <alltraps>

801071de <vector68>:
.globl vector68
vector68:
  pushl $0
801071de:	6a 00                	push   $0x0
  pushl $68
801071e0:	6a 44                	push   $0x44
  jmp alltraps
801071e2:	e9 cd f6 ff ff       	jmp    801068b4 <alltraps>

801071e7 <vector69>:
.globl vector69
vector69:
  pushl $0
801071e7:	6a 00                	push   $0x0
  pushl $69
801071e9:	6a 45                	push   $0x45
  jmp alltraps
801071eb:	e9 c4 f6 ff ff       	jmp    801068b4 <alltraps>

801071f0 <vector70>:
.globl vector70
vector70:
  pushl $0
801071f0:	6a 00                	push   $0x0
  pushl $70
801071f2:	6a 46                	push   $0x46
  jmp alltraps
801071f4:	e9 bb f6 ff ff       	jmp    801068b4 <alltraps>

801071f9 <vector71>:
.globl vector71
vector71:
  pushl $0
801071f9:	6a 00                	push   $0x0
  pushl $71
801071fb:	6a 47                	push   $0x47
  jmp alltraps
801071fd:	e9 b2 f6 ff ff       	jmp    801068b4 <alltraps>

80107202 <vector72>:
.globl vector72
vector72:
  pushl $0
80107202:	6a 00                	push   $0x0
  pushl $72
80107204:	6a 48                	push   $0x48
  jmp alltraps
80107206:	e9 a9 f6 ff ff       	jmp    801068b4 <alltraps>

8010720b <vector73>:
.globl vector73
vector73:
  pushl $0
8010720b:	6a 00                	push   $0x0
  pushl $73
8010720d:	6a 49                	push   $0x49
  jmp alltraps
8010720f:	e9 a0 f6 ff ff       	jmp    801068b4 <alltraps>

80107214 <vector74>:
.globl vector74
vector74:
  pushl $0
80107214:	6a 00                	push   $0x0
  pushl $74
80107216:	6a 4a                	push   $0x4a
  jmp alltraps
80107218:	e9 97 f6 ff ff       	jmp    801068b4 <alltraps>

8010721d <vector75>:
.globl vector75
vector75:
  pushl $0
8010721d:	6a 00                	push   $0x0
  pushl $75
8010721f:	6a 4b                	push   $0x4b
  jmp alltraps
80107221:	e9 8e f6 ff ff       	jmp    801068b4 <alltraps>

80107226 <vector76>:
.globl vector76
vector76:
  pushl $0
80107226:	6a 00                	push   $0x0
  pushl $76
80107228:	6a 4c                	push   $0x4c
  jmp alltraps
8010722a:	e9 85 f6 ff ff       	jmp    801068b4 <alltraps>

8010722f <vector77>:
.globl vector77
vector77:
  pushl $0
8010722f:	6a 00                	push   $0x0
  pushl $77
80107231:	6a 4d                	push   $0x4d
  jmp alltraps
80107233:	e9 7c f6 ff ff       	jmp    801068b4 <alltraps>

80107238 <vector78>:
.globl vector78
vector78:
  pushl $0
80107238:	6a 00                	push   $0x0
  pushl $78
8010723a:	6a 4e                	push   $0x4e
  jmp alltraps
8010723c:	e9 73 f6 ff ff       	jmp    801068b4 <alltraps>

80107241 <vector79>:
.globl vector79
vector79:
  pushl $0
80107241:	6a 00                	push   $0x0
  pushl $79
80107243:	6a 4f                	push   $0x4f
  jmp alltraps
80107245:	e9 6a f6 ff ff       	jmp    801068b4 <alltraps>

8010724a <vector80>:
.globl vector80
vector80:
  pushl $0
8010724a:	6a 00                	push   $0x0
  pushl $80
8010724c:	6a 50                	push   $0x50
  jmp alltraps
8010724e:	e9 61 f6 ff ff       	jmp    801068b4 <alltraps>

80107253 <vector81>:
.globl vector81
vector81:
  pushl $0
80107253:	6a 00                	push   $0x0
  pushl $81
80107255:	6a 51                	push   $0x51
  jmp alltraps
80107257:	e9 58 f6 ff ff       	jmp    801068b4 <alltraps>

8010725c <vector82>:
.globl vector82
vector82:
  pushl $0
8010725c:	6a 00                	push   $0x0
  pushl $82
8010725e:	6a 52                	push   $0x52
  jmp alltraps
80107260:	e9 4f f6 ff ff       	jmp    801068b4 <alltraps>

80107265 <vector83>:
.globl vector83
vector83:
  pushl $0
80107265:	6a 00                	push   $0x0
  pushl $83
80107267:	6a 53                	push   $0x53
  jmp alltraps
80107269:	e9 46 f6 ff ff       	jmp    801068b4 <alltraps>

8010726e <vector84>:
.globl vector84
vector84:
  pushl $0
8010726e:	6a 00                	push   $0x0
  pushl $84
80107270:	6a 54                	push   $0x54
  jmp alltraps
80107272:	e9 3d f6 ff ff       	jmp    801068b4 <alltraps>

80107277 <vector85>:
.globl vector85
vector85:
  pushl $0
80107277:	6a 00                	push   $0x0
  pushl $85
80107279:	6a 55                	push   $0x55
  jmp alltraps
8010727b:	e9 34 f6 ff ff       	jmp    801068b4 <alltraps>

80107280 <vector86>:
.globl vector86
vector86:
  pushl $0
80107280:	6a 00                	push   $0x0
  pushl $86
80107282:	6a 56                	push   $0x56
  jmp alltraps
80107284:	e9 2b f6 ff ff       	jmp    801068b4 <alltraps>

80107289 <vector87>:
.globl vector87
vector87:
  pushl $0
80107289:	6a 00                	push   $0x0
  pushl $87
8010728b:	6a 57                	push   $0x57
  jmp alltraps
8010728d:	e9 22 f6 ff ff       	jmp    801068b4 <alltraps>

80107292 <vector88>:
.globl vector88
vector88:
  pushl $0
80107292:	6a 00                	push   $0x0
  pushl $88
80107294:	6a 58                	push   $0x58
  jmp alltraps
80107296:	e9 19 f6 ff ff       	jmp    801068b4 <alltraps>

8010729b <vector89>:
.globl vector89
vector89:
  pushl $0
8010729b:	6a 00                	push   $0x0
  pushl $89
8010729d:	6a 59                	push   $0x59
  jmp alltraps
8010729f:	e9 10 f6 ff ff       	jmp    801068b4 <alltraps>

801072a4 <vector90>:
.globl vector90
vector90:
  pushl $0
801072a4:	6a 00                	push   $0x0
  pushl $90
801072a6:	6a 5a                	push   $0x5a
  jmp alltraps
801072a8:	e9 07 f6 ff ff       	jmp    801068b4 <alltraps>

801072ad <vector91>:
.globl vector91
vector91:
  pushl $0
801072ad:	6a 00                	push   $0x0
  pushl $91
801072af:	6a 5b                	push   $0x5b
  jmp alltraps
801072b1:	e9 fe f5 ff ff       	jmp    801068b4 <alltraps>

801072b6 <vector92>:
.globl vector92
vector92:
  pushl $0
801072b6:	6a 00                	push   $0x0
  pushl $92
801072b8:	6a 5c                	push   $0x5c
  jmp alltraps
801072ba:	e9 f5 f5 ff ff       	jmp    801068b4 <alltraps>

801072bf <vector93>:
.globl vector93
vector93:
  pushl $0
801072bf:	6a 00                	push   $0x0
  pushl $93
801072c1:	6a 5d                	push   $0x5d
  jmp alltraps
801072c3:	e9 ec f5 ff ff       	jmp    801068b4 <alltraps>

801072c8 <vector94>:
.globl vector94
vector94:
  pushl $0
801072c8:	6a 00                	push   $0x0
  pushl $94
801072ca:	6a 5e                	push   $0x5e
  jmp alltraps
801072cc:	e9 e3 f5 ff ff       	jmp    801068b4 <alltraps>

801072d1 <vector95>:
.globl vector95
vector95:
  pushl $0
801072d1:	6a 00                	push   $0x0
  pushl $95
801072d3:	6a 5f                	push   $0x5f
  jmp alltraps
801072d5:	e9 da f5 ff ff       	jmp    801068b4 <alltraps>

801072da <vector96>:
.globl vector96
vector96:
  pushl $0
801072da:	6a 00                	push   $0x0
  pushl $96
801072dc:	6a 60                	push   $0x60
  jmp alltraps
801072de:	e9 d1 f5 ff ff       	jmp    801068b4 <alltraps>

801072e3 <vector97>:
.globl vector97
vector97:
  pushl $0
801072e3:	6a 00                	push   $0x0
  pushl $97
801072e5:	6a 61                	push   $0x61
  jmp alltraps
801072e7:	e9 c8 f5 ff ff       	jmp    801068b4 <alltraps>

801072ec <vector98>:
.globl vector98
vector98:
  pushl $0
801072ec:	6a 00                	push   $0x0
  pushl $98
801072ee:	6a 62                	push   $0x62
  jmp alltraps
801072f0:	e9 bf f5 ff ff       	jmp    801068b4 <alltraps>

801072f5 <vector99>:
.globl vector99
vector99:
  pushl $0
801072f5:	6a 00                	push   $0x0
  pushl $99
801072f7:	6a 63                	push   $0x63
  jmp alltraps
801072f9:	e9 b6 f5 ff ff       	jmp    801068b4 <alltraps>

801072fe <vector100>:
.globl vector100
vector100:
  pushl $0
801072fe:	6a 00                	push   $0x0
  pushl $100
80107300:	6a 64                	push   $0x64
  jmp alltraps
80107302:	e9 ad f5 ff ff       	jmp    801068b4 <alltraps>

80107307 <vector101>:
.globl vector101
vector101:
  pushl $0
80107307:	6a 00                	push   $0x0
  pushl $101
80107309:	6a 65                	push   $0x65
  jmp alltraps
8010730b:	e9 a4 f5 ff ff       	jmp    801068b4 <alltraps>

80107310 <vector102>:
.globl vector102
vector102:
  pushl $0
80107310:	6a 00                	push   $0x0
  pushl $102
80107312:	6a 66                	push   $0x66
  jmp alltraps
80107314:	e9 9b f5 ff ff       	jmp    801068b4 <alltraps>

80107319 <vector103>:
.globl vector103
vector103:
  pushl $0
80107319:	6a 00                	push   $0x0
  pushl $103
8010731b:	6a 67                	push   $0x67
  jmp alltraps
8010731d:	e9 92 f5 ff ff       	jmp    801068b4 <alltraps>

80107322 <vector104>:
.globl vector104
vector104:
  pushl $0
80107322:	6a 00                	push   $0x0
  pushl $104
80107324:	6a 68                	push   $0x68
  jmp alltraps
80107326:	e9 89 f5 ff ff       	jmp    801068b4 <alltraps>

8010732b <vector105>:
.globl vector105
vector105:
  pushl $0
8010732b:	6a 00                	push   $0x0
  pushl $105
8010732d:	6a 69                	push   $0x69
  jmp alltraps
8010732f:	e9 80 f5 ff ff       	jmp    801068b4 <alltraps>

80107334 <vector106>:
.globl vector106
vector106:
  pushl $0
80107334:	6a 00                	push   $0x0
  pushl $106
80107336:	6a 6a                	push   $0x6a
  jmp alltraps
80107338:	e9 77 f5 ff ff       	jmp    801068b4 <alltraps>

8010733d <vector107>:
.globl vector107
vector107:
  pushl $0
8010733d:	6a 00                	push   $0x0
  pushl $107
8010733f:	6a 6b                	push   $0x6b
  jmp alltraps
80107341:	e9 6e f5 ff ff       	jmp    801068b4 <alltraps>

80107346 <vector108>:
.globl vector108
vector108:
  pushl $0
80107346:	6a 00                	push   $0x0
  pushl $108
80107348:	6a 6c                	push   $0x6c
  jmp alltraps
8010734a:	e9 65 f5 ff ff       	jmp    801068b4 <alltraps>

8010734f <vector109>:
.globl vector109
vector109:
  pushl $0
8010734f:	6a 00                	push   $0x0
  pushl $109
80107351:	6a 6d                	push   $0x6d
  jmp alltraps
80107353:	e9 5c f5 ff ff       	jmp    801068b4 <alltraps>

80107358 <vector110>:
.globl vector110
vector110:
  pushl $0
80107358:	6a 00                	push   $0x0
  pushl $110
8010735a:	6a 6e                	push   $0x6e
  jmp alltraps
8010735c:	e9 53 f5 ff ff       	jmp    801068b4 <alltraps>

80107361 <vector111>:
.globl vector111
vector111:
  pushl $0
80107361:	6a 00                	push   $0x0
  pushl $111
80107363:	6a 6f                	push   $0x6f
  jmp alltraps
80107365:	e9 4a f5 ff ff       	jmp    801068b4 <alltraps>

8010736a <vector112>:
.globl vector112
vector112:
  pushl $0
8010736a:	6a 00                	push   $0x0
  pushl $112
8010736c:	6a 70                	push   $0x70
  jmp alltraps
8010736e:	e9 41 f5 ff ff       	jmp    801068b4 <alltraps>

80107373 <vector113>:
.globl vector113
vector113:
  pushl $0
80107373:	6a 00                	push   $0x0
  pushl $113
80107375:	6a 71                	push   $0x71
  jmp alltraps
80107377:	e9 38 f5 ff ff       	jmp    801068b4 <alltraps>

8010737c <vector114>:
.globl vector114
vector114:
  pushl $0
8010737c:	6a 00                	push   $0x0
  pushl $114
8010737e:	6a 72                	push   $0x72
  jmp alltraps
80107380:	e9 2f f5 ff ff       	jmp    801068b4 <alltraps>

80107385 <vector115>:
.globl vector115
vector115:
  pushl $0
80107385:	6a 00                	push   $0x0
  pushl $115
80107387:	6a 73                	push   $0x73
  jmp alltraps
80107389:	e9 26 f5 ff ff       	jmp    801068b4 <alltraps>

8010738e <vector116>:
.globl vector116
vector116:
  pushl $0
8010738e:	6a 00                	push   $0x0
  pushl $116
80107390:	6a 74                	push   $0x74
  jmp alltraps
80107392:	e9 1d f5 ff ff       	jmp    801068b4 <alltraps>

80107397 <vector117>:
.globl vector117
vector117:
  pushl $0
80107397:	6a 00                	push   $0x0
  pushl $117
80107399:	6a 75                	push   $0x75
  jmp alltraps
8010739b:	e9 14 f5 ff ff       	jmp    801068b4 <alltraps>

801073a0 <vector118>:
.globl vector118
vector118:
  pushl $0
801073a0:	6a 00                	push   $0x0
  pushl $118
801073a2:	6a 76                	push   $0x76
  jmp alltraps
801073a4:	e9 0b f5 ff ff       	jmp    801068b4 <alltraps>

801073a9 <vector119>:
.globl vector119
vector119:
  pushl $0
801073a9:	6a 00                	push   $0x0
  pushl $119
801073ab:	6a 77                	push   $0x77
  jmp alltraps
801073ad:	e9 02 f5 ff ff       	jmp    801068b4 <alltraps>

801073b2 <vector120>:
.globl vector120
vector120:
  pushl $0
801073b2:	6a 00                	push   $0x0
  pushl $120
801073b4:	6a 78                	push   $0x78
  jmp alltraps
801073b6:	e9 f9 f4 ff ff       	jmp    801068b4 <alltraps>

801073bb <vector121>:
.globl vector121
vector121:
  pushl $0
801073bb:	6a 00                	push   $0x0
  pushl $121
801073bd:	6a 79                	push   $0x79
  jmp alltraps
801073bf:	e9 f0 f4 ff ff       	jmp    801068b4 <alltraps>

801073c4 <vector122>:
.globl vector122
vector122:
  pushl $0
801073c4:	6a 00                	push   $0x0
  pushl $122
801073c6:	6a 7a                	push   $0x7a
  jmp alltraps
801073c8:	e9 e7 f4 ff ff       	jmp    801068b4 <alltraps>

801073cd <vector123>:
.globl vector123
vector123:
  pushl $0
801073cd:	6a 00                	push   $0x0
  pushl $123
801073cf:	6a 7b                	push   $0x7b
  jmp alltraps
801073d1:	e9 de f4 ff ff       	jmp    801068b4 <alltraps>

801073d6 <vector124>:
.globl vector124
vector124:
  pushl $0
801073d6:	6a 00                	push   $0x0
  pushl $124
801073d8:	6a 7c                	push   $0x7c
  jmp alltraps
801073da:	e9 d5 f4 ff ff       	jmp    801068b4 <alltraps>

801073df <vector125>:
.globl vector125
vector125:
  pushl $0
801073df:	6a 00                	push   $0x0
  pushl $125
801073e1:	6a 7d                	push   $0x7d
  jmp alltraps
801073e3:	e9 cc f4 ff ff       	jmp    801068b4 <alltraps>

801073e8 <vector126>:
.globl vector126
vector126:
  pushl $0
801073e8:	6a 00                	push   $0x0
  pushl $126
801073ea:	6a 7e                	push   $0x7e
  jmp alltraps
801073ec:	e9 c3 f4 ff ff       	jmp    801068b4 <alltraps>

801073f1 <vector127>:
.globl vector127
vector127:
  pushl $0
801073f1:	6a 00                	push   $0x0
  pushl $127
801073f3:	6a 7f                	push   $0x7f
  jmp alltraps
801073f5:	e9 ba f4 ff ff       	jmp    801068b4 <alltraps>

801073fa <vector128>:
.globl vector128
vector128:
  pushl $0
801073fa:	6a 00                	push   $0x0
  pushl $128
801073fc:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107401:	e9 ae f4 ff ff       	jmp    801068b4 <alltraps>

80107406 <vector129>:
.globl vector129
vector129:
  pushl $0
80107406:	6a 00                	push   $0x0
  pushl $129
80107408:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010740d:	e9 a2 f4 ff ff       	jmp    801068b4 <alltraps>

80107412 <vector130>:
.globl vector130
vector130:
  pushl $0
80107412:	6a 00                	push   $0x0
  pushl $130
80107414:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107419:	e9 96 f4 ff ff       	jmp    801068b4 <alltraps>

8010741e <vector131>:
.globl vector131
vector131:
  pushl $0
8010741e:	6a 00                	push   $0x0
  pushl $131
80107420:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107425:	e9 8a f4 ff ff       	jmp    801068b4 <alltraps>

8010742a <vector132>:
.globl vector132
vector132:
  pushl $0
8010742a:	6a 00                	push   $0x0
  pushl $132
8010742c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107431:	e9 7e f4 ff ff       	jmp    801068b4 <alltraps>

80107436 <vector133>:
.globl vector133
vector133:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $133
80107438:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010743d:	e9 72 f4 ff ff       	jmp    801068b4 <alltraps>

80107442 <vector134>:
.globl vector134
vector134:
  pushl $0
80107442:	6a 00                	push   $0x0
  pushl $134
80107444:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107449:	e9 66 f4 ff ff       	jmp    801068b4 <alltraps>

8010744e <vector135>:
.globl vector135
vector135:
  pushl $0
8010744e:	6a 00                	push   $0x0
  pushl $135
80107450:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107455:	e9 5a f4 ff ff       	jmp    801068b4 <alltraps>

8010745a <vector136>:
.globl vector136
vector136:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $136
8010745c:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107461:	e9 4e f4 ff ff       	jmp    801068b4 <alltraps>

80107466 <vector137>:
.globl vector137
vector137:
  pushl $0
80107466:	6a 00                	push   $0x0
  pushl $137
80107468:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010746d:	e9 42 f4 ff ff       	jmp    801068b4 <alltraps>

80107472 <vector138>:
.globl vector138
vector138:
  pushl $0
80107472:	6a 00                	push   $0x0
  pushl $138
80107474:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107479:	e9 36 f4 ff ff       	jmp    801068b4 <alltraps>

8010747e <vector139>:
.globl vector139
vector139:
  pushl $0
8010747e:	6a 00                	push   $0x0
  pushl $139
80107480:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107485:	e9 2a f4 ff ff       	jmp    801068b4 <alltraps>

8010748a <vector140>:
.globl vector140
vector140:
  pushl $0
8010748a:	6a 00                	push   $0x0
  pushl $140
8010748c:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107491:	e9 1e f4 ff ff       	jmp    801068b4 <alltraps>

80107496 <vector141>:
.globl vector141
vector141:
  pushl $0
80107496:	6a 00                	push   $0x0
  pushl $141
80107498:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010749d:	e9 12 f4 ff ff       	jmp    801068b4 <alltraps>

801074a2 <vector142>:
.globl vector142
vector142:
  pushl $0
801074a2:	6a 00                	push   $0x0
  pushl $142
801074a4:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801074a9:	e9 06 f4 ff ff       	jmp    801068b4 <alltraps>

801074ae <vector143>:
.globl vector143
vector143:
  pushl $0
801074ae:	6a 00                	push   $0x0
  pushl $143
801074b0:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801074b5:	e9 fa f3 ff ff       	jmp    801068b4 <alltraps>

801074ba <vector144>:
.globl vector144
vector144:
  pushl $0
801074ba:	6a 00                	push   $0x0
  pushl $144
801074bc:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801074c1:	e9 ee f3 ff ff       	jmp    801068b4 <alltraps>

801074c6 <vector145>:
.globl vector145
vector145:
  pushl $0
801074c6:	6a 00                	push   $0x0
  pushl $145
801074c8:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801074cd:	e9 e2 f3 ff ff       	jmp    801068b4 <alltraps>

801074d2 <vector146>:
.globl vector146
vector146:
  pushl $0
801074d2:	6a 00                	push   $0x0
  pushl $146
801074d4:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801074d9:	e9 d6 f3 ff ff       	jmp    801068b4 <alltraps>

801074de <vector147>:
.globl vector147
vector147:
  pushl $0
801074de:	6a 00                	push   $0x0
  pushl $147
801074e0:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801074e5:	e9 ca f3 ff ff       	jmp    801068b4 <alltraps>

801074ea <vector148>:
.globl vector148
vector148:
  pushl $0
801074ea:	6a 00                	push   $0x0
  pushl $148
801074ec:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801074f1:	e9 be f3 ff ff       	jmp    801068b4 <alltraps>

801074f6 <vector149>:
.globl vector149
vector149:
  pushl $0
801074f6:	6a 00                	push   $0x0
  pushl $149
801074f8:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801074fd:	e9 b2 f3 ff ff       	jmp    801068b4 <alltraps>

80107502 <vector150>:
.globl vector150
vector150:
  pushl $0
80107502:	6a 00                	push   $0x0
  pushl $150
80107504:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107509:	e9 a6 f3 ff ff       	jmp    801068b4 <alltraps>

8010750e <vector151>:
.globl vector151
vector151:
  pushl $0
8010750e:	6a 00                	push   $0x0
  pushl $151
80107510:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107515:	e9 9a f3 ff ff       	jmp    801068b4 <alltraps>

8010751a <vector152>:
.globl vector152
vector152:
  pushl $0
8010751a:	6a 00                	push   $0x0
  pushl $152
8010751c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107521:	e9 8e f3 ff ff       	jmp    801068b4 <alltraps>

80107526 <vector153>:
.globl vector153
vector153:
  pushl $0
80107526:	6a 00                	push   $0x0
  pushl $153
80107528:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010752d:	e9 82 f3 ff ff       	jmp    801068b4 <alltraps>

80107532 <vector154>:
.globl vector154
vector154:
  pushl $0
80107532:	6a 00                	push   $0x0
  pushl $154
80107534:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107539:	e9 76 f3 ff ff       	jmp    801068b4 <alltraps>

8010753e <vector155>:
.globl vector155
vector155:
  pushl $0
8010753e:	6a 00                	push   $0x0
  pushl $155
80107540:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107545:	e9 6a f3 ff ff       	jmp    801068b4 <alltraps>

8010754a <vector156>:
.globl vector156
vector156:
  pushl $0
8010754a:	6a 00                	push   $0x0
  pushl $156
8010754c:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107551:	e9 5e f3 ff ff       	jmp    801068b4 <alltraps>

80107556 <vector157>:
.globl vector157
vector157:
  pushl $0
80107556:	6a 00                	push   $0x0
  pushl $157
80107558:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010755d:	e9 52 f3 ff ff       	jmp    801068b4 <alltraps>

80107562 <vector158>:
.globl vector158
vector158:
  pushl $0
80107562:	6a 00                	push   $0x0
  pushl $158
80107564:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107569:	e9 46 f3 ff ff       	jmp    801068b4 <alltraps>

8010756e <vector159>:
.globl vector159
vector159:
  pushl $0
8010756e:	6a 00                	push   $0x0
  pushl $159
80107570:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107575:	e9 3a f3 ff ff       	jmp    801068b4 <alltraps>

8010757a <vector160>:
.globl vector160
vector160:
  pushl $0
8010757a:	6a 00                	push   $0x0
  pushl $160
8010757c:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107581:	e9 2e f3 ff ff       	jmp    801068b4 <alltraps>

80107586 <vector161>:
.globl vector161
vector161:
  pushl $0
80107586:	6a 00                	push   $0x0
  pushl $161
80107588:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010758d:	e9 22 f3 ff ff       	jmp    801068b4 <alltraps>

80107592 <vector162>:
.globl vector162
vector162:
  pushl $0
80107592:	6a 00                	push   $0x0
  pushl $162
80107594:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107599:	e9 16 f3 ff ff       	jmp    801068b4 <alltraps>

8010759e <vector163>:
.globl vector163
vector163:
  pushl $0
8010759e:	6a 00                	push   $0x0
  pushl $163
801075a0:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801075a5:	e9 0a f3 ff ff       	jmp    801068b4 <alltraps>

801075aa <vector164>:
.globl vector164
vector164:
  pushl $0
801075aa:	6a 00                	push   $0x0
  pushl $164
801075ac:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801075b1:	e9 fe f2 ff ff       	jmp    801068b4 <alltraps>

801075b6 <vector165>:
.globl vector165
vector165:
  pushl $0
801075b6:	6a 00                	push   $0x0
  pushl $165
801075b8:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801075bd:	e9 f2 f2 ff ff       	jmp    801068b4 <alltraps>

801075c2 <vector166>:
.globl vector166
vector166:
  pushl $0
801075c2:	6a 00                	push   $0x0
  pushl $166
801075c4:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801075c9:	e9 e6 f2 ff ff       	jmp    801068b4 <alltraps>

801075ce <vector167>:
.globl vector167
vector167:
  pushl $0
801075ce:	6a 00                	push   $0x0
  pushl $167
801075d0:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801075d5:	e9 da f2 ff ff       	jmp    801068b4 <alltraps>

801075da <vector168>:
.globl vector168
vector168:
  pushl $0
801075da:	6a 00                	push   $0x0
  pushl $168
801075dc:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801075e1:	e9 ce f2 ff ff       	jmp    801068b4 <alltraps>

801075e6 <vector169>:
.globl vector169
vector169:
  pushl $0
801075e6:	6a 00                	push   $0x0
  pushl $169
801075e8:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801075ed:	e9 c2 f2 ff ff       	jmp    801068b4 <alltraps>

801075f2 <vector170>:
.globl vector170
vector170:
  pushl $0
801075f2:	6a 00                	push   $0x0
  pushl $170
801075f4:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801075f9:	e9 b6 f2 ff ff       	jmp    801068b4 <alltraps>

801075fe <vector171>:
.globl vector171
vector171:
  pushl $0
801075fe:	6a 00                	push   $0x0
  pushl $171
80107600:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107605:	e9 aa f2 ff ff       	jmp    801068b4 <alltraps>

8010760a <vector172>:
.globl vector172
vector172:
  pushl $0
8010760a:	6a 00                	push   $0x0
  pushl $172
8010760c:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107611:	e9 9e f2 ff ff       	jmp    801068b4 <alltraps>

80107616 <vector173>:
.globl vector173
vector173:
  pushl $0
80107616:	6a 00                	push   $0x0
  pushl $173
80107618:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010761d:	e9 92 f2 ff ff       	jmp    801068b4 <alltraps>

80107622 <vector174>:
.globl vector174
vector174:
  pushl $0
80107622:	6a 00                	push   $0x0
  pushl $174
80107624:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107629:	e9 86 f2 ff ff       	jmp    801068b4 <alltraps>

8010762e <vector175>:
.globl vector175
vector175:
  pushl $0
8010762e:	6a 00                	push   $0x0
  pushl $175
80107630:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107635:	e9 7a f2 ff ff       	jmp    801068b4 <alltraps>

8010763a <vector176>:
.globl vector176
vector176:
  pushl $0
8010763a:	6a 00                	push   $0x0
  pushl $176
8010763c:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107641:	e9 6e f2 ff ff       	jmp    801068b4 <alltraps>

80107646 <vector177>:
.globl vector177
vector177:
  pushl $0
80107646:	6a 00                	push   $0x0
  pushl $177
80107648:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010764d:	e9 62 f2 ff ff       	jmp    801068b4 <alltraps>

80107652 <vector178>:
.globl vector178
vector178:
  pushl $0
80107652:	6a 00                	push   $0x0
  pushl $178
80107654:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107659:	e9 56 f2 ff ff       	jmp    801068b4 <alltraps>

8010765e <vector179>:
.globl vector179
vector179:
  pushl $0
8010765e:	6a 00                	push   $0x0
  pushl $179
80107660:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107665:	e9 4a f2 ff ff       	jmp    801068b4 <alltraps>

8010766a <vector180>:
.globl vector180
vector180:
  pushl $0
8010766a:	6a 00                	push   $0x0
  pushl $180
8010766c:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107671:	e9 3e f2 ff ff       	jmp    801068b4 <alltraps>

80107676 <vector181>:
.globl vector181
vector181:
  pushl $0
80107676:	6a 00                	push   $0x0
  pushl $181
80107678:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010767d:	e9 32 f2 ff ff       	jmp    801068b4 <alltraps>

80107682 <vector182>:
.globl vector182
vector182:
  pushl $0
80107682:	6a 00                	push   $0x0
  pushl $182
80107684:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107689:	e9 26 f2 ff ff       	jmp    801068b4 <alltraps>

8010768e <vector183>:
.globl vector183
vector183:
  pushl $0
8010768e:	6a 00                	push   $0x0
  pushl $183
80107690:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107695:	e9 1a f2 ff ff       	jmp    801068b4 <alltraps>

8010769a <vector184>:
.globl vector184
vector184:
  pushl $0
8010769a:	6a 00                	push   $0x0
  pushl $184
8010769c:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801076a1:	e9 0e f2 ff ff       	jmp    801068b4 <alltraps>

801076a6 <vector185>:
.globl vector185
vector185:
  pushl $0
801076a6:	6a 00                	push   $0x0
  pushl $185
801076a8:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801076ad:	e9 02 f2 ff ff       	jmp    801068b4 <alltraps>

801076b2 <vector186>:
.globl vector186
vector186:
  pushl $0
801076b2:	6a 00                	push   $0x0
  pushl $186
801076b4:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801076b9:	e9 f6 f1 ff ff       	jmp    801068b4 <alltraps>

801076be <vector187>:
.globl vector187
vector187:
  pushl $0
801076be:	6a 00                	push   $0x0
  pushl $187
801076c0:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801076c5:	e9 ea f1 ff ff       	jmp    801068b4 <alltraps>

801076ca <vector188>:
.globl vector188
vector188:
  pushl $0
801076ca:	6a 00                	push   $0x0
  pushl $188
801076cc:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801076d1:	e9 de f1 ff ff       	jmp    801068b4 <alltraps>

801076d6 <vector189>:
.globl vector189
vector189:
  pushl $0
801076d6:	6a 00                	push   $0x0
  pushl $189
801076d8:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801076dd:	e9 d2 f1 ff ff       	jmp    801068b4 <alltraps>

801076e2 <vector190>:
.globl vector190
vector190:
  pushl $0
801076e2:	6a 00                	push   $0x0
  pushl $190
801076e4:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801076e9:	e9 c6 f1 ff ff       	jmp    801068b4 <alltraps>

801076ee <vector191>:
.globl vector191
vector191:
  pushl $0
801076ee:	6a 00                	push   $0x0
  pushl $191
801076f0:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801076f5:	e9 ba f1 ff ff       	jmp    801068b4 <alltraps>

801076fa <vector192>:
.globl vector192
vector192:
  pushl $0
801076fa:	6a 00                	push   $0x0
  pushl $192
801076fc:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107701:	e9 ae f1 ff ff       	jmp    801068b4 <alltraps>

80107706 <vector193>:
.globl vector193
vector193:
  pushl $0
80107706:	6a 00                	push   $0x0
  pushl $193
80107708:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010770d:	e9 a2 f1 ff ff       	jmp    801068b4 <alltraps>

80107712 <vector194>:
.globl vector194
vector194:
  pushl $0
80107712:	6a 00                	push   $0x0
  pushl $194
80107714:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107719:	e9 96 f1 ff ff       	jmp    801068b4 <alltraps>

8010771e <vector195>:
.globl vector195
vector195:
  pushl $0
8010771e:	6a 00                	push   $0x0
  pushl $195
80107720:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107725:	e9 8a f1 ff ff       	jmp    801068b4 <alltraps>

8010772a <vector196>:
.globl vector196
vector196:
  pushl $0
8010772a:	6a 00                	push   $0x0
  pushl $196
8010772c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107731:	e9 7e f1 ff ff       	jmp    801068b4 <alltraps>

80107736 <vector197>:
.globl vector197
vector197:
  pushl $0
80107736:	6a 00                	push   $0x0
  pushl $197
80107738:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010773d:	e9 72 f1 ff ff       	jmp    801068b4 <alltraps>

80107742 <vector198>:
.globl vector198
vector198:
  pushl $0
80107742:	6a 00                	push   $0x0
  pushl $198
80107744:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107749:	e9 66 f1 ff ff       	jmp    801068b4 <alltraps>

8010774e <vector199>:
.globl vector199
vector199:
  pushl $0
8010774e:	6a 00                	push   $0x0
  pushl $199
80107750:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107755:	e9 5a f1 ff ff       	jmp    801068b4 <alltraps>

8010775a <vector200>:
.globl vector200
vector200:
  pushl $0
8010775a:	6a 00                	push   $0x0
  pushl $200
8010775c:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107761:	e9 4e f1 ff ff       	jmp    801068b4 <alltraps>

80107766 <vector201>:
.globl vector201
vector201:
  pushl $0
80107766:	6a 00                	push   $0x0
  pushl $201
80107768:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010776d:	e9 42 f1 ff ff       	jmp    801068b4 <alltraps>

80107772 <vector202>:
.globl vector202
vector202:
  pushl $0
80107772:	6a 00                	push   $0x0
  pushl $202
80107774:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107779:	e9 36 f1 ff ff       	jmp    801068b4 <alltraps>

8010777e <vector203>:
.globl vector203
vector203:
  pushl $0
8010777e:	6a 00                	push   $0x0
  pushl $203
80107780:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107785:	e9 2a f1 ff ff       	jmp    801068b4 <alltraps>

8010778a <vector204>:
.globl vector204
vector204:
  pushl $0
8010778a:	6a 00                	push   $0x0
  pushl $204
8010778c:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107791:	e9 1e f1 ff ff       	jmp    801068b4 <alltraps>

80107796 <vector205>:
.globl vector205
vector205:
  pushl $0
80107796:	6a 00                	push   $0x0
  pushl $205
80107798:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010779d:	e9 12 f1 ff ff       	jmp    801068b4 <alltraps>

801077a2 <vector206>:
.globl vector206
vector206:
  pushl $0
801077a2:	6a 00                	push   $0x0
  pushl $206
801077a4:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801077a9:	e9 06 f1 ff ff       	jmp    801068b4 <alltraps>

801077ae <vector207>:
.globl vector207
vector207:
  pushl $0
801077ae:	6a 00                	push   $0x0
  pushl $207
801077b0:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801077b5:	e9 fa f0 ff ff       	jmp    801068b4 <alltraps>

801077ba <vector208>:
.globl vector208
vector208:
  pushl $0
801077ba:	6a 00                	push   $0x0
  pushl $208
801077bc:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801077c1:	e9 ee f0 ff ff       	jmp    801068b4 <alltraps>

801077c6 <vector209>:
.globl vector209
vector209:
  pushl $0
801077c6:	6a 00                	push   $0x0
  pushl $209
801077c8:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801077cd:	e9 e2 f0 ff ff       	jmp    801068b4 <alltraps>

801077d2 <vector210>:
.globl vector210
vector210:
  pushl $0
801077d2:	6a 00                	push   $0x0
  pushl $210
801077d4:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801077d9:	e9 d6 f0 ff ff       	jmp    801068b4 <alltraps>

801077de <vector211>:
.globl vector211
vector211:
  pushl $0
801077de:	6a 00                	push   $0x0
  pushl $211
801077e0:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801077e5:	e9 ca f0 ff ff       	jmp    801068b4 <alltraps>

801077ea <vector212>:
.globl vector212
vector212:
  pushl $0
801077ea:	6a 00                	push   $0x0
  pushl $212
801077ec:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801077f1:	e9 be f0 ff ff       	jmp    801068b4 <alltraps>

801077f6 <vector213>:
.globl vector213
vector213:
  pushl $0
801077f6:	6a 00                	push   $0x0
  pushl $213
801077f8:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801077fd:	e9 b2 f0 ff ff       	jmp    801068b4 <alltraps>

80107802 <vector214>:
.globl vector214
vector214:
  pushl $0
80107802:	6a 00                	push   $0x0
  pushl $214
80107804:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107809:	e9 a6 f0 ff ff       	jmp    801068b4 <alltraps>

8010780e <vector215>:
.globl vector215
vector215:
  pushl $0
8010780e:	6a 00                	push   $0x0
  pushl $215
80107810:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107815:	e9 9a f0 ff ff       	jmp    801068b4 <alltraps>

8010781a <vector216>:
.globl vector216
vector216:
  pushl $0
8010781a:	6a 00                	push   $0x0
  pushl $216
8010781c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107821:	e9 8e f0 ff ff       	jmp    801068b4 <alltraps>

80107826 <vector217>:
.globl vector217
vector217:
  pushl $0
80107826:	6a 00                	push   $0x0
  pushl $217
80107828:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010782d:	e9 82 f0 ff ff       	jmp    801068b4 <alltraps>

80107832 <vector218>:
.globl vector218
vector218:
  pushl $0
80107832:	6a 00                	push   $0x0
  pushl $218
80107834:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107839:	e9 76 f0 ff ff       	jmp    801068b4 <alltraps>

8010783e <vector219>:
.globl vector219
vector219:
  pushl $0
8010783e:	6a 00                	push   $0x0
  pushl $219
80107840:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107845:	e9 6a f0 ff ff       	jmp    801068b4 <alltraps>

8010784a <vector220>:
.globl vector220
vector220:
  pushl $0
8010784a:	6a 00                	push   $0x0
  pushl $220
8010784c:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107851:	e9 5e f0 ff ff       	jmp    801068b4 <alltraps>

80107856 <vector221>:
.globl vector221
vector221:
  pushl $0
80107856:	6a 00                	push   $0x0
  pushl $221
80107858:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010785d:	e9 52 f0 ff ff       	jmp    801068b4 <alltraps>

80107862 <vector222>:
.globl vector222
vector222:
  pushl $0
80107862:	6a 00                	push   $0x0
  pushl $222
80107864:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107869:	e9 46 f0 ff ff       	jmp    801068b4 <alltraps>

8010786e <vector223>:
.globl vector223
vector223:
  pushl $0
8010786e:	6a 00                	push   $0x0
  pushl $223
80107870:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107875:	e9 3a f0 ff ff       	jmp    801068b4 <alltraps>

8010787a <vector224>:
.globl vector224
vector224:
  pushl $0
8010787a:	6a 00                	push   $0x0
  pushl $224
8010787c:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107881:	e9 2e f0 ff ff       	jmp    801068b4 <alltraps>

80107886 <vector225>:
.globl vector225
vector225:
  pushl $0
80107886:	6a 00                	push   $0x0
  pushl $225
80107888:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010788d:	e9 22 f0 ff ff       	jmp    801068b4 <alltraps>

80107892 <vector226>:
.globl vector226
vector226:
  pushl $0
80107892:	6a 00                	push   $0x0
  pushl $226
80107894:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107899:	e9 16 f0 ff ff       	jmp    801068b4 <alltraps>

8010789e <vector227>:
.globl vector227
vector227:
  pushl $0
8010789e:	6a 00                	push   $0x0
  pushl $227
801078a0:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801078a5:	e9 0a f0 ff ff       	jmp    801068b4 <alltraps>

801078aa <vector228>:
.globl vector228
vector228:
  pushl $0
801078aa:	6a 00                	push   $0x0
  pushl $228
801078ac:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801078b1:	e9 fe ef ff ff       	jmp    801068b4 <alltraps>

801078b6 <vector229>:
.globl vector229
vector229:
  pushl $0
801078b6:	6a 00                	push   $0x0
  pushl $229
801078b8:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801078bd:	e9 f2 ef ff ff       	jmp    801068b4 <alltraps>

801078c2 <vector230>:
.globl vector230
vector230:
  pushl $0
801078c2:	6a 00                	push   $0x0
  pushl $230
801078c4:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801078c9:	e9 e6 ef ff ff       	jmp    801068b4 <alltraps>

801078ce <vector231>:
.globl vector231
vector231:
  pushl $0
801078ce:	6a 00                	push   $0x0
  pushl $231
801078d0:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801078d5:	e9 da ef ff ff       	jmp    801068b4 <alltraps>

801078da <vector232>:
.globl vector232
vector232:
  pushl $0
801078da:	6a 00                	push   $0x0
  pushl $232
801078dc:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801078e1:	e9 ce ef ff ff       	jmp    801068b4 <alltraps>

801078e6 <vector233>:
.globl vector233
vector233:
  pushl $0
801078e6:	6a 00                	push   $0x0
  pushl $233
801078e8:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801078ed:	e9 c2 ef ff ff       	jmp    801068b4 <alltraps>

801078f2 <vector234>:
.globl vector234
vector234:
  pushl $0
801078f2:	6a 00                	push   $0x0
  pushl $234
801078f4:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801078f9:	e9 b6 ef ff ff       	jmp    801068b4 <alltraps>

801078fe <vector235>:
.globl vector235
vector235:
  pushl $0
801078fe:	6a 00                	push   $0x0
  pushl $235
80107900:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107905:	e9 aa ef ff ff       	jmp    801068b4 <alltraps>

8010790a <vector236>:
.globl vector236
vector236:
  pushl $0
8010790a:	6a 00                	push   $0x0
  pushl $236
8010790c:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107911:	e9 9e ef ff ff       	jmp    801068b4 <alltraps>

80107916 <vector237>:
.globl vector237
vector237:
  pushl $0
80107916:	6a 00                	push   $0x0
  pushl $237
80107918:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010791d:	e9 92 ef ff ff       	jmp    801068b4 <alltraps>

80107922 <vector238>:
.globl vector238
vector238:
  pushl $0
80107922:	6a 00                	push   $0x0
  pushl $238
80107924:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107929:	e9 86 ef ff ff       	jmp    801068b4 <alltraps>

8010792e <vector239>:
.globl vector239
vector239:
  pushl $0
8010792e:	6a 00                	push   $0x0
  pushl $239
80107930:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107935:	e9 7a ef ff ff       	jmp    801068b4 <alltraps>

8010793a <vector240>:
.globl vector240
vector240:
  pushl $0
8010793a:	6a 00                	push   $0x0
  pushl $240
8010793c:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107941:	e9 6e ef ff ff       	jmp    801068b4 <alltraps>

80107946 <vector241>:
.globl vector241
vector241:
  pushl $0
80107946:	6a 00                	push   $0x0
  pushl $241
80107948:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010794d:	e9 62 ef ff ff       	jmp    801068b4 <alltraps>

80107952 <vector242>:
.globl vector242
vector242:
  pushl $0
80107952:	6a 00                	push   $0x0
  pushl $242
80107954:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107959:	e9 56 ef ff ff       	jmp    801068b4 <alltraps>

8010795e <vector243>:
.globl vector243
vector243:
  pushl $0
8010795e:	6a 00                	push   $0x0
  pushl $243
80107960:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107965:	e9 4a ef ff ff       	jmp    801068b4 <alltraps>

8010796a <vector244>:
.globl vector244
vector244:
  pushl $0
8010796a:	6a 00                	push   $0x0
  pushl $244
8010796c:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107971:	e9 3e ef ff ff       	jmp    801068b4 <alltraps>

80107976 <vector245>:
.globl vector245
vector245:
  pushl $0
80107976:	6a 00                	push   $0x0
  pushl $245
80107978:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010797d:	e9 32 ef ff ff       	jmp    801068b4 <alltraps>

80107982 <vector246>:
.globl vector246
vector246:
  pushl $0
80107982:	6a 00                	push   $0x0
  pushl $246
80107984:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107989:	e9 26 ef ff ff       	jmp    801068b4 <alltraps>

8010798e <vector247>:
.globl vector247
vector247:
  pushl $0
8010798e:	6a 00                	push   $0x0
  pushl $247
80107990:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107995:	e9 1a ef ff ff       	jmp    801068b4 <alltraps>

8010799a <vector248>:
.globl vector248
vector248:
  pushl $0
8010799a:	6a 00                	push   $0x0
  pushl $248
8010799c:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801079a1:	e9 0e ef ff ff       	jmp    801068b4 <alltraps>

801079a6 <vector249>:
.globl vector249
vector249:
  pushl $0
801079a6:	6a 00                	push   $0x0
  pushl $249
801079a8:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801079ad:	e9 02 ef ff ff       	jmp    801068b4 <alltraps>

801079b2 <vector250>:
.globl vector250
vector250:
  pushl $0
801079b2:	6a 00                	push   $0x0
  pushl $250
801079b4:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801079b9:	e9 f6 ee ff ff       	jmp    801068b4 <alltraps>

801079be <vector251>:
.globl vector251
vector251:
  pushl $0
801079be:	6a 00                	push   $0x0
  pushl $251
801079c0:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801079c5:	e9 ea ee ff ff       	jmp    801068b4 <alltraps>

801079ca <vector252>:
.globl vector252
vector252:
  pushl $0
801079ca:	6a 00                	push   $0x0
  pushl $252
801079cc:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801079d1:	e9 de ee ff ff       	jmp    801068b4 <alltraps>

801079d6 <vector253>:
.globl vector253
vector253:
  pushl $0
801079d6:	6a 00                	push   $0x0
  pushl $253
801079d8:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801079dd:	e9 d2 ee ff ff       	jmp    801068b4 <alltraps>

801079e2 <vector254>:
.globl vector254
vector254:
  pushl $0
801079e2:	6a 00                	push   $0x0
  pushl $254
801079e4:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801079e9:	e9 c6 ee ff ff       	jmp    801068b4 <alltraps>

801079ee <vector255>:
.globl vector255
vector255:
  pushl $0
801079ee:	6a 00                	push   $0x0
  pushl $255
801079f0:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801079f5:	e9 ba ee ff ff       	jmp    801068b4 <alltraps>
	...

801079fc <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801079fc:	55                   	push   %ebp
801079fd:	89 e5                	mov    %esp,%ebp
801079ff:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107a02:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a05:	83 e8 01             	sub    $0x1,%eax
80107a08:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80107a0f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107a13:	8b 45 08             	mov    0x8(%ebp),%eax
80107a16:	c1 e8 10             	shr    $0x10,%eax
80107a19:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107a1d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107a20:	0f 01 10             	lgdtl  (%eax)
}
80107a23:	c9                   	leave  
80107a24:	c3                   	ret    

80107a25 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107a25:	55                   	push   %ebp
80107a26:	89 e5                	mov    %esp,%ebp
80107a28:	83 ec 04             	sub    $0x4,%esp
80107a2b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a2e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107a32:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a36:	0f 00 d8             	ltr    %ax
}
80107a39:	c9                   	leave  
80107a3a:	c3                   	ret    

80107a3b <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107a3b:	55                   	push   %ebp
80107a3c:	89 e5                	mov    %esp,%ebp
80107a3e:	83 ec 04             	sub    $0x4,%esp
80107a41:	8b 45 08             	mov    0x8(%ebp),%eax
80107a44:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107a48:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a4c:	8e e8                	mov    %eax,%gs
}
80107a4e:	c9                   	leave  
80107a4f:	c3                   	ret    

80107a50 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107a50:	55                   	push   %ebp
80107a51:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107a53:	8b 45 08             	mov    0x8(%ebp),%eax
80107a56:	0f 22 d8             	mov    %eax,%cr3
}
80107a59:	5d                   	pop    %ebp
80107a5a:	c3                   	ret    

80107a5b <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107a5b:	55                   	push   %ebp
80107a5c:	89 e5                	mov    %esp,%ebp
80107a5e:	8b 45 08             	mov    0x8(%ebp),%eax
80107a61:	05 00 00 00 80       	add    $0x80000000,%eax
80107a66:	5d                   	pop    %ebp
80107a67:	c3                   	ret    

80107a68 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107a68:	55                   	push   %ebp
80107a69:	89 e5                	mov    %esp,%ebp
80107a6b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a6e:	05 00 00 00 80       	add    $0x80000000,%eax
80107a73:	5d                   	pop    %ebp
80107a74:	c3                   	ret    

80107a75 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107a75:	55                   	push   %ebp
80107a76:	89 e5                	mov    %esp,%ebp
80107a78:	53                   	push   %ebx
80107a79:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107a7c:	e8 34 b7 ff ff       	call   801031b5 <cpunum>
80107a81:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107a87:	05 40 f9 10 80       	add    $0x8010f940,%eax
80107a8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a92:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9b:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa4:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aab:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107aaf:	83 e2 f0             	and    $0xfffffff0,%edx
80107ab2:	83 ca 0a             	or     $0xa,%edx
80107ab5:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abb:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107abf:	83 ca 10             	or     $0x10,%edx
80107ac2:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107acc:	83 e2 9f             	and    $0xffffff9f,%edx
80107acf:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad5:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107ad9:	83 ca 80             	or     $0xffffff80,%edx
80107adc:	88 50 7d             	mov    %dl,0x7d(%eax)
80107adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ae6:	83 ca 0f             	or     $0xf,%edx
80107ae9:	88 50 7e             	mov    %dl,0x7e(%eax)
80107aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aef:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107af3:	83 e2 ef             	and    $0xffffffef,%edx
80107af6:	88 50 7e             	mov    %dl,0x7e(%eax)
80107af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b00:	83 e2 df             	and    $0xffffffdf,%edx
80107b03:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b09:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b0d:	83 ca 40             	or     $0x40,%edx
80107b10:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b16:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b1a:	83 ca 80             	or     $0xffffff80,%edx
80107b1d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b23:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2a:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107b31:	ff ff 
80107b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b36:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107b3d:	00 00 
80107b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b42:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b53:	83 e2 f0             	and    $0xfffffff0,%edx
80107b56:	83 ca 02             	or     $0x2,%edx
80107b59:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b62:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b69:	83 ca 10             	or     $0x10,%edx
80107b6c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b75:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b7c:	83 e2 9f             	and    $0xffffff9f,%edx
80107b7f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b88:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b8f:	83 ca 80             	or     $0xffffff80,%edx
80107b92:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107ba2:	83 ca 0f             	or     $0xf,%edx
80107ba5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bae:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bb5:	83 e2 ef             	and    $0xffffffef,%edx
80107bb8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bc8:	83 e2 df             	and    $0xffffffdf,%edx
80107bcb:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bdb:	83 ca 40             	or     $0x40,%edx
80107bde:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bee:	83 ca 80             	or     $0xffffff80,%edx
80107bf1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfa:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c04:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107c0b:	ff ff 
80107c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c10:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107c17:	00 00 
80107c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1c:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c26:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c2d:	83 e2 f0             	and    $0xfffffff0,%edx
80107c30:	83 ca 0a             	or     $0xa,%edx
80107c33:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c43:	83 ca 10             	or     $0x10,%edx
80107c46:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c56:	83 ca 60             	or     $0x60,%edx
80107c59:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c62:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c69:	83 ca 80             	or     $0xffffff80,%edx
80107c6c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c75:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c7c:	83 ca 0f             	or     $0xf,%edx
80107c7f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c88:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c8f:	83 e2 ef             	and    $0xffffffef,%edx
80107c92:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ca2:	83 e2 df             	and    $0xffffffdf,%edx
80107ca5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cae:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cb5:	83 ca 40             	or     $0x40,%edx
80107cb8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cc8:	83 ca 80             	or     $0xffffff80,%edx
80107ccb:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd4:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cde:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107ce5:	ff ff 
80107ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cea:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107cf1:	00 00 
80107cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf6:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d00:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d07:	83 e2 f0             	and    $0xfffffff0,%edx
80107d0a:	83 ca 02             	or     $0x2,%edx
80107d0d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d16:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d1d:	83 ca 10             	or     $0x10,%edx
80107d20:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d29:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d30:	83 ca 60             	or     $0x60,%edx
80107d33:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d43:	83 ca 80             	or     $0xffffff80,%edx
80107d46:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d56:	83 ca 0f             	or     $0xf,%edx
80107d59:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d62:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d69:	83 e2 ef             	and    $0xffffffef,%edx
80107d6c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d75:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d7c:	83 e2 df             	and    $0xffffffdf,%edx
80107d7f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d88:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d8f:	83 ca 40             	or     $0x40,%edx
80107d92:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107da2:	83 ca 80             	or     $0xffffff80,%edx
80107da5:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dae:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db8:	05 b4 00 00 00       	add    $0xb4,%eax
80107dbd:	89 c3                	mov    %eax,%ebx
80107dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc2:	05 b4 00 00 00       	add    $0xb4,%eax
80107dc7:	c1 e8 10             	shr    $0x10,%eax
80107dca:	89 c1                	mov    %eax,%ecx
80107dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dcf:	05 b4 00 00 00       	add    $0xb4,%eax
80107dd4:	c1 e8 18             	shr    $0x18,%eax
80107dd7:	89 c2                	mov    %eax,%edx
80107dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddc:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107de3:	00 00 
80107de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de8:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107def:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df2:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfb:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e02:	83 e1 f0             	and    $0xfffffff0,%ecx
80107e05:	83 c9 02             	or     $0x2,%ecx
80107e08:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e11:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e18:	83 c9 10             	or     $0x10,%ecx
80107e1b:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e24:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e2b:	83 e1 9f             	and    $0xffffff9f,%ecx
80107e2e:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e37:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e3e:	83 c9 80             	or     $0xffffff80,%ecx
80107e41:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4a:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e51:	83 e1 f0             	and    $0xfffffff0,%ecx
80107e54:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5d:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e64:	83 e1 ef             	and    $0xffffffef,%ecx
80107e67:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e70:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e77:	83 e1 df             	and    $0xffffffdf,%ecx
80107e7a:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e83:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e8a:	83 c9 40             	or     $0x40,%ecx
80107e8d:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e96:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e9d:	83 c9 80             	or     $0xffffff80,%ecx
80107ea0:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea9:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb2:	83 c0 70             	add    $0x70,%eax
80107eb5:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107ebc:	00 
80107ebd:	89 04 24             	mov    %eax,(%esp)
80107ec0:	e8 37 fb ff ff       	call   801079fc <lgdt>
  loadgs(SEG_KCPU << 3);
80107ec5:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107ecc:	e8 6a fb ff ff       	call   80107a3b <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed4:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107eda:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107ee1:	00 00 00 00 
}
80107ee5:	83 c4 24             	add    $0x24,%esp
80107ee8:	5b                   	pop    %ebx
80107ee9:	5d                   	pop    %ebp
80107eea:	c3                   	ret    

80107eeb <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107eeb:	55                   	push   %ebp
80107eec:	89 e5                	mov    %esp,%ebp
80107eee:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107ef1:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ef4:	c1 e8 16             	shr    $0x16,%eax
80107ef7:	c1 e0 02             	shl    $0x2,%eax
80107efa:	03 45 08             	add    0x8(%ebp),%eax
80107efd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107f00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f03:	8b 00                	mov    (%eax),%eax
80107f05:	83 e0 01             	and    $0x1,%eax
80107f08:	84 c0                	test   %al,%al
80107f0a:	74 17                	je     80107f23 <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107f0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f0f:	8b 00                	mov    (%eax),%eax
80107f11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f16:	89 04 24             	mov    %eax,(%esp)
80107f19:	e8 4a fb ff ff       	call   80107a68 <p2v>
80107f1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f21:	eb 4b                	jmp    80107f6e <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107f23:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107f27:	74 0e                	je     80107f37 <walkpgdir+0x4c>
80107f29:	e8 f9 ae ff ff       	call   80102e27 <kalloc>
80107f2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f31:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f35:	75 07                	jne    80107f3e <walkpgdir+0x53>
      return 0;
80107f37:	b8 00 00 00 00       	mov    $0x0,%eax
80107f3c:	eb 41                	jmp    80107f7f <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107f3e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f45:	00 
80107f46:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f4d:	00 
80107f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f51:	89 04 24             	mov    %eax,(%esp)
80107f54:	e8 b5 d4 ff ff       	call   8010540e <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5c:	89 04 24             	mov    %eax,(%esp)
80107f5f:	e8 f7 fa ff ff       	call   80107a5b <v2p>
80107f64:	89 c2                	mov    %eax,%edx
80107f66:	83 ca 07             	or     $0x7,%edx
80107f69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f6c:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f71:	c1 e8 0c             	shr    $0xc,%eax
80107f74:	25 ff 03 00 00       	and    $0x3ff,%eax
80107f79:	c1 e0 02             	shl    $0x2,%eax
80107f7c:	03 45 f4             	add    -0xc(%ebp),%eax
}
80107f7f:	c9                   	leave  
80107f80:	c3                   	ret    

80107f81 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107f81:	55                   	push   %ebp
80107f82:	89 e5                	mov    %esp,%ebp
80107f84:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107f87:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f8a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107f92:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f95:	03 45 10             	add    0x10(%ebp),%eax
80107f98:	83 e8 01             	sub    $0x1,%eax
80107f9b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fa0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107fa3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107faa:	00 
80107fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fae:	89 44 24 04          	mov    %eax,0x4(%esp)
80107fb2:	8b 45 08             	mov    0x8(%ebp),%eax
80107fb5:	89 04 24             	mov    %eax,(%esp)
80107fb8:	e8 2e ff ff ff       	call   80107eeb <walkpgdir>
80107fbd:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107fc0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107fc4:	75 07                	jne    80107fcd <mappages+0x4c>
      return -1;
80107fc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fcb:	eb 46                	jmp    80108013 <mappages+0x92>
    if(*pte & PTE_P)
80107fcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fd0:	8b 00                	mov    (%eax),%eax
80107fd2:	83 e0 01             	and    $0x1,%eax
80107fd5:	84 c0                	test   %al,%al
80107fd7:	74 0c                	je     80107fe5 <mappages+0x64>
      panic("remap");
80107fd9:	c7 04 24 f8 8d 10 80 	movl   $0x80108df8,(%esp)
80107fe0:	e8 58 85 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80107fe5:	8b 45 18             	mov    0x18(%ebp),%eax
80107fe8:	0b 45 14             	or     0x14(%ebp),%eax
80107feb:	89 c2                	mov    %eax,%edx
80107fed:	83 ca 01             	or     $0x1,%edx
80107ff0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ff3:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107ffb:	74 10                	je     8010800d <mappages+0x8c>
      break;
    a += PGSIZE;
80107ffd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108004:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
8010800b:	eb 96                	jmp    80107fa3 <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
8010800d:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
8010800e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108013:	c9                   	leave  
80108014:	c3                   	ret    

80108015 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm()
{
80108015:	55                   	push   %ebp
80108016:	89 e5                	mov    %esp,%ebp
80108018:	53                   	push   %ebx
80108019:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
8010801c:	e8 06 ae ff ff       	call   80102e27 <kalloc>
80108021:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108024:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108028:	75 0a                	jne    80108034 <setupkvm+0x1f>
    return 0;
8010802a:	b8 00 00 00 00       	mov    $0x0,%eax
8010802f:	e9 98 00 00 00       	jmp    801080cc <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80108034:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010803b:	00 
8010803c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108043:	00 
80108044:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108047:	89 04 24             	mov    %eax,(%esp)
8010804a:	e8 bf d3 ff ff       	call   8010540e <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
8010804f:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80108056:	e8 0d fa ff ff       	call   80107a68 <p2v>
8010805b:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108060:	76 0c                	jbe    8010806e <setupkvm+0x59>
    panic("PHYSTOP too high");
80108062:	c7 04 24 fe 8d 10 80 	movl   $0x80108dfe,(%esp)
80108069:	e8 cf 84 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010806e:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80108075:	eb 49                	jmp    801080c0 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
80108077:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010807a:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
8010807d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108080:	8b 50 04             	mov    0x4(%eax),%edx
80108083:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108086:	8b 58 08             	mov    0x8(%eax),%ebx
80108089:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010808c:	8b 40 04             	mov    0x4(%eax),%eax
8010808f:	29 c3                	sub    %eax,%ebx
80108091:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108094:	8b 00                	mov    (%eax),%eax
80108096:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010809a:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010809e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801080a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801080a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080a9:	89 04 24             	mov    %eax,(%esp)
801080ac:	e8 d0 fe ff ff       	call   80107f81 <mappages>
801080b1:	85 c0                	test   %eax,%eax
801080b3:	79 07                	jns    801080bc <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
801080b5:	b8 00 00 00 00       	mov    $0x0,%eax
801080ba:	eb 10                	jmp    801080cc <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801080bc:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801080c0:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
801080c7:	72 ae                	jb     80108077 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801080c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801080cc:	83 c4 34             	add    $0x34,%esp
801080cf:	5b                   	pop    %ebx
801080d0:	5d                   	pop    %ebp
801080d1:	c3                   	ret    

801080d2 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801080d2:	55                   	push   %ebp
801080d3:	89 e5                	mov    %esp,%ebp
801080d5:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801080d8:	e8 38 ff ff ff       	call   80108015 <setupkvm>
801080dd:	a3 18 2d 11 80       	mov    %eax,0x80112d18
  switchkvm();
801080e2:	e8 02 00 00 00       	call   801080e9 <switchkvm>
}
801080e7:	c9                   	leave  
801080e8:	c3                   	ret    

801080e9 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801080e9:	55                   	push   %ebp
801080ea:	89 e5                	mov    %esp,%ebp
801080ec:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801080ef:	a1 18 2d 11 80       	mov    0x80112d18,%eax
801080f4:	89 04 24             	mov    %eax,(%esp)
801080f7:	e8 5f f9 ff ff       	call   80107a5b <v2p>
801080fc:	89 04 24             	mov    %eax,(%esp)
801080ff:	e8 4c f9 ff ff       	call   80107a50 <lcr3>
}
80108104:	c9                   	leave  
80108105:	c3                   	ret    

80108106 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108106:	55                   	push   %ebp
80108107:	89 e5                	mov    %esp,%ebp
80108109:	53                   	push   %ebx
8010810a:	83 ec 14             	sub    $0x14,%esp
  pushcli();
8010810d:	e8 f5 d1 ff ff       	call   80105307 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108112:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108118:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010811f:	83 c2 08             	add    $0x8,%edx
80108122:	89 d3                	mov    %edx,%ebx
80108124:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010812b:	83 c2 08             	add    $0x8,%edx
8010812e:	c1 ea 10             	shr    $0x10,%edx
80108131:	89 d1                	mov    %edx,%ecx
80108133:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010813a:	83 c2 08             	add    $0x8,%edx
8010813d:	c1 ea 18             	shr    $0x18,%edx
80108140:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108147:	67 00 
80108149:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80108150:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80108156:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010815d:	83 e1 f0             	and    $0xfffffff0,%ecx
80108160:	83 c9 09             	or     $0x9,%ecx
80108163:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108169:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108170:	83 c9 10             	or     $0x10,%ecx
80108173:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108179:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108180:	83 e1 9f             	and    $0xffffff9f,%ecx
80108183:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108189:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108190:	83 c9 80             	or     $0xffffff80,%ecx
80108193:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108199:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081a0:	83 e1 f0             	and    $0xfffffff0,%ecx
801081a3:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081a9:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081b0:	83 e1 ef             	and    $0xffffffef,%ecx
801081b3:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081b9:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081c0:	83 e1 df             	and    $0xffffffdf,%ecx
801081c3:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081c9:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081d0:	83 c9 40             	or     $0x40,%ecx
801081d3:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081d9:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081e0:	83 e1 7f             	and    $0x7f,%ecx
801081e3:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081e9:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801081ef:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081f5:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801081fc:	83 e2 ef             	and    $0xffffffef,%edx
801081ff:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108205:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010820b:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108211:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108217:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010821e:	8b 52 08             	mov    0x8(%edx),%edx
80108221:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108227:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
8010822a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80108231:	e8 ef f7 ff ff       	call   80107a25 <ltr>
  if(p->pgdir == 0)
80108236:	8b 45 08             	mov    0x8(%ebp),%eax
80108239:	8b 40 04             	mov    0x4(%eax),%eax
8010823c:	85 c0                	test   %eax,%eax
8010823e:	75 0c                	jne    8010824c <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80108240:	c7 04 24 0f 8e 10 80 	movl   $0x80108e0f,(%esp)
80108247:	e8 f1 82 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
8010824c:	8b 45 08             	mov    0x8(%ebp),%eax
8010824f:	8b 40 04             	mov    0x4(%eax),%eax
80108252:	89 04 24             	mov    %eax,(%esp)
80108255:	e8 01 f8 ff ff       	call   80107a5b <v2p>
8010825a:	89 04 24             	mov    %eax,(%esp)
8010825d:	e8 ee f7 ff ff       	call   80107a50 <lcr3>
  popcli();
80108262:	e8 e8 d0 ff ff       	call   8010534f <popcli>
}
80108267:	83 c4 14             	add    $0x14,%esp
8010826a:	5b                   	pop    %ebx
8010826b:	5d                   	pop    %ebp
8010826c:	c3                   	ret    

8010826d <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010826d:	55                   	push   %ebp
8010826e:	89 e5                	mov    %esp,%ebp
80108270:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108273:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010827a:	76 0c                	jbe    80108288 <inituvm+0x1b>
    panic("inituvm: more than a page");
8010827c:	c7 04 24 23 8e 10 80 	movl   $0x80108e23,(%esp)
80108283:	e8 b5 82 ff ff       	call   8010053d <panic>
  mem = kalloc();
80108288:	e8 9a ab ff ff       	call   80102e27 <kalloc>
8010828d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108290:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108297:	00 
80108298:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010829f:	00 
801082a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082a3:	89 04 24             	mov    %eax,(%esp)
801082a6:	e8 63 d1 ff ff       	call   8010540e <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
801082ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ae:	89 04 24             	mov    %eax,(%esp)
801082b1:	e8 a5 f7 ff ff       	call   80107a5b <v2p>
801082b6:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801082bd:	00 
801082be:	89 44 24 0c          	mov    %eax,0xc(%esp)
801082c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082c9:	00 
801082ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082d1:	00 
801082d2:	8b 45 08             	mov    0x8(%ebp),%eax
801082d5:	89 04 24             	mov    %eax,(%esp)
801082d8:	e8 a4 fc ff ff       	call   80107f81 <mappages>
  memmove(mem, init, sz);
801082dd:	8b 45 10             	mov    0x10(%ebp),%eax
801082e0:	89 44 24 08          	mov    %eax,0x8(%esp)
801082e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801082e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801082eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ee:	89 04 24             	mov    %eax,(%esp)
801082f1:	e8 eb d1 ff ff       	call   801054e1 <memmove>
}
801082f6:	c9                   	leave  
801082f7:	c3                   	ret    

801082f8 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801082f8:	55                   	push   %ebp
801082f9:	89 e5                	mov    %esp,%ebp
801082fb:	53                   	push   %ebx
801082fc:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801082ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80108302:	25 ff 0f 00 00       	and    $0xfff,%eax
80108307:	85 c0                	test   %eax,%eax
80108309:	74 0c                	je     80108317 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
8010830b:	c7 04 24 40 8e 10 80 	movl   $0x80108e40,(%esp)
80108312:	e8 26 82 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108317:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010831e:	e9 ad 00 00 00       	jmp    801083d0 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108323:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108326:	8b 55 0c             	mov    0xc(%ebp),%edx
80108329:	01 d0                	add    %edx,%eax
8010832b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108332:	00 
80108333:	89 44 24 04          	mov    %eax,0x4(%esp)
80108337:	8b 45 08             	mov    0x8(%ebp),%eax
8010833a:	89 04 24             	mov    %eax,(%esp)
8010833d:	e8 a9 fb ff ff       	call   80107eeb <walkpgdir>
80108342:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108345:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108349:	75 0c                	jne    80108357 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
8010834b:	c7 04 24 63 8e 10 80 	movl   $0x80108e63,(%esp)
80108352:	e8 e6 81 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80108357:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010835a:	8b 00                	mov    (%eax),%eax
8010835c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108361:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108367:	8b 55 18             	mov    0x18(%ebp),%edx
8010836a:	89 d1                	mov    %edx,%ecx
8010836c:	29 c1                	sub    %eax,%ecx
8010836e:	89 c8                	mov    %ecx,%eax
80108370:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108375:	77 11                	ja     80108388 <loaduvm+0x90>
      n = sz - i;
80108377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010837a:	8b 55 18             	mov    0x18(%ebp),%edx
8010837d:	89 d1                	mov    %edx,%ecx
8010837f:	29 c1                	sub    %eax,%ecx
80108381:	89 c8                	mov    %ecx,%eax
80108383:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108386:	eb 07                	jmp    8010838f <loaduvm+0x97>
    else
      n = PGSIZE;
80108388:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
8010838f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108392:	8b 55 14             	mov    0x14(%ebp),%edx
80108395:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108398:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010839b:	89 04 24             	mov    %eax,(%esp)
8010839e:	e8 c5 f6 ff ff       	call   80107a68 <p2v>
801083a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801083a6:	89 54 24 0c          	mov    %edx,0xc(%esp)
801083aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801083ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801083b2:	8b 45 10             	mov    0x10(%ebp),%eax
801083b5:	89 04 24             	mov    %eax,(%esp)
801083b8:	e8 c9 9c ff ff       	call   80102086 <readi>
801083bd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801083c0:	74 07                	je     801083c9 <loaduvm+0xd1>
      return -1;
801083c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801083c7:	eb 18                	jmp    801083e1 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801083c9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d3:	3b 45 18             	cmp    0x18(%ebp),%eax
801083d6:	0f 82 47 ff ff ff    	jb     80108323 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
801083dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801083e1:	83 c4 24             	add    $0x24,%esp
801083e4:	5b                   	pop    %ebx
801083e5:	5d                   	pop    %ebp
801083e6:	c3                   	ret    

801083e7 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801083e7:	55                   	push   %ebp
801083e8:	89 e5                	mov    %esp,%ebp
801083ea:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801083ed:	8b 45 10             	mov    0x10(%ebp),%eax
801083f0:	85 c0                	test   %eax,%eax
801083f2:	79 0a                	jns    801083fe <allocuvm+0x17>
    return 0;
801083f4:	b8 00 00 00 00       	mov    $0x0,%eax
801083f9:	e9 c1 00 00 00       	jmp    801084bf <allocuvm+0xd8>
  if(newsz < oldsz)
801083fe:	8b 45 10             	mov    0x10(%ebp),%eax
80108401:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108404:	73 08                	jae    8010840e <allocuvm+0x27>
    return oldsz;
80108406:	8b 45 0c             	mov    0xc(%ebp),%eax
80108409:	e9 b1 00 00 00       	jmp    801084bf <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
8010840e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108411:	05 ff 0f 00 00       	add    $0xfff,%eax
80108416:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010841b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010841e:	e9 8d 00 00 00       	jmp    801084b0 <allocuvm+0xc9>
    mem = kalloc();
80108423:	e8 ff a9 ff ff       	call   80102e27 <kalloc>
80108428:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010842b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010842f:	75 2c                	jne    8010845d <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108431:	c7 04 24 81 8e 10 80 	movl   $0x80108e81,(%esp)
80108438:	e8 64 7f ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010843d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108440:	89 44 24 08          	mov    %eax,0x8(%esp)
80108444:	8b 45 10             	mov    0x10(%ebp),%eax
80108447:	89 44 24 04          	mov    %eax,0x4(%esp)
8010844b:	8b 45 08             	mov    0x8(%ebp),%eax
8010844e:	89 04 24             	mov    %eax,(%esp)
80108451:	e8 6b 00 00 00       	call   801084c1 <deallocuvm>
      return 0;
80108456:	b8 00 00 00 00       	mov    $0x0,%eax
8010845b:	eb 62                	jmp    801084bf <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
8010845d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108464:	00 
80108465:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010846c:	00 
8010846d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108470:	89 04 24             	mov    %eax,(%esp)
80108473:	e8 96 cf ff ff       	call   8010540e <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108478:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010847b:	89 04 24             	mov    %eax,(%esp)
8010847e:	e8 d8 f5 ff ff       	call   80107a5b <v2p>
80108483:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108486:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010848d:	00 
8010848e:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108492:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108499:	00 
8010849a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010849e:	8b 45 08             	mov    0x8(%ebp),%eax
801084a1:	89 04 24             	mov    %eax,(%esp)
801084a4:	e8 d8 fa ff ff       	call   80107f81 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801084a9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b3:	3b 45 10             	cmp    0x10(%ebp),%eax
801084b6:	0f 82 67 ff ff ff    	jb     80108423 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801084bc:	8b 45 10             	mov    0x10(%ebp),%eax
}
801084bf:	c9                   	leave  
801084c0:	c3                   	ret    

801084c1 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801084c1:	55                   	push   %ebp
801084c2:	89 e5                	mov    %esp,%ebp
801084c4:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801084c7:	8b 45 10             	mov    0x10(%ebp),%eax
801084ca:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084cd:	72 08                	jb     801084d7 <deallocuvm+0x16>
    return oldsz;
801084cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801084d2:	e9 a4 00 00 00       	jmp    8010857b <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
801084d7:	8b 45 10             	mov    0x10(%ebp),%eax
801084da:	05 ff 0f 00 00       	add    $0xfff,%eax
801084df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801084e7:	e9 80 00 00 00       	jmp    8010856c <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
801084ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801084f6:	00 
801084f7:	89 44 24 04          	mov    %eax,0x4(%esp)
801084fb:	8b 45 08             	mov    0x8(%ebp),%eax
801084fe:	89 04 24             	mov    %eax,(%esp)
80108501:	e8 e5 f9 ff ff       	call   80107eeb <walkpgdir>
80108506:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108509:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010850d:	75 09                	jne    80108518 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
8010850f:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108516:	eb 4d                	jmp    80108565 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108518:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010851b:	8b 00                	mov    (%eax),%eax
8010851d:	83 e0 01             	and    $0x1,%eax
80108520:	84 c0                	test   %al,%al
80108522:	74 41                	je     80108565 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108524:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108527:	8b 00                	mov    (%eax),%eax
80108529:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010852e:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108531:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108535:	75 0c                	jne    80108543 <deallocuvm+0x82>
        panic("kfree");
80108537:	c7 04 24 99 8e 10 80 	movl   $0x80108e99,(%esp)
8010853e:	e8 fa 7f ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
80108543:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108546:	89 04 24             	mov    %eax,(%esp)
80108549:	e8 1a f5 ff ff       	call   80107a68 <p2v>
8010854e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108551:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108554:	89 04 24             	mov    %eax,(%esp)
80108557:	e8 32 a8 ff ff       	call   80102d8e <kfree>
      *pte = 0;
8010855c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010855f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108565:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010856c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010856f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108572:	0f 82 74 ff ff ff    	jb     801084ec <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108578:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010857b:	c9                   	leave  
8010857c:	c3                   	ret    

8010857d <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010857d:	55                   	push   %ebp
8010857e:	89 e5                	mov    %esp,%ebp
80108580:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108583:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108587:	75 0c                	jne    80108595 <freevm+0x18>
    panic("freevm: no pgdir");
80108589:	c7 04 24 9f 8e 10 80 	movl   $0x80108e9f,(%esp)
80108590:	e8 a8 7f ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108595:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010859c:	00 
8010859d:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801085a4:	80 
801085a5:	8b 45 08             	mov    0x8(%ebp),%eax
801085a8:	89 04 24             	mov    %eax,(%esp)
801085ab:	e8 11 ff ff ff       	call   801084c1 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801085b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085b7:	eb 3c                	jmp    801085f5 <freevm+0x78>
    if(pgdir[i] & PTE_P){
801085b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085bc:	c1 e0 02             	shl    $0x2,%eax
801085bf:	03 45 08             	add    0x8(%ebp),%eax
801085c2:	8b 00                	mov    (%eax),%eax
801085c4:	83 e0 01             	and    $0x1,%eax
801085c7:	84 c0                	test   %al,%al
801085c9:	74 26                	je     801085f1 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801085cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ce:	c1 e0 02             	shl    $0x2,%eax
801085d1:	03 45 08             	add    0x8(%ebp),%eax
801085d4:	8b 00                	mov    (%eax),%eax
801085d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085db:	89 04 24             	mov    %eax,(%esp)
801085de:	e8 85 f4 ff ff       	call   80107a68 <p2v>
801085e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801085e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085e9:	89 04 24             	mov    %eax,(%esp)
801085ec:	e8 9d a7 ff ff       	call   80102d8e <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801085f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085f5:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801085fc:	76 bb                	jbe    801085b9 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801085fe:	8b 45 08             	mov    0x8(%ebp),%eax
80108601:	89 04 24             	mov    %eax,(%esp)
80108604:	e8 85 a7 ff ff       	call   80102d8e <kfree>
}
80108609:	c9                   	leave  
8010860a:	c3                   	ret    

8010860b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010860b:	55                   	push   %ebp
8010860c:	89 e5                	mov    %esp,%ebp
8010860e:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108611:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108618:	00 
80108619:	8b 45 0c             	mov    0xc(%ebp),%eax
8010861c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108620:	8b 45 08             	mov    0x8(%ebp),%eax
80108623:	89 04 24             	mov    %eax,(%esp)
80108626:	e8 c0 f8 ff ff       	call   80107eeb <walkpgdir>
8010862b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010862e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108632:	75 0c                	jne    80108640 <clearpteu+0x35>
    panic("clearpteu");
80108634:	c7 04 24 b0 8e 10 80 	movl   $0x80108eb0,(%esp)
8010863b:	e8 fd 7e ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
80108640:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108643:	8b 00                	mov    (%eax),%eax
80108645:	89 c2                	mov    %eax,%edx
80108647:	83 e2 fb             	and    $0xfffffffb,%edx
8010864a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010864d:	89 10                	mov    %edx,(%eax)
}
8010864f:	c9                   	leave  
80108650:	c3                   	ret    

80108651 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108651:	55                   	push   %ebp
80108652:	89 e5                	mov    %esp,%ebp
80108654:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
80108657:	e8 b9 f9 ff ff       	call   80108015 <setupkvm>
8010865c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010865f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108663:	75 0a                	jne    8010866f <copyuvm+0x1e>
    return 0;
80108665:	b8 00 00 00 00       	mov    $0x0,%eax
8010866a:	e9 f1 00 00 00       	jmp    80108760 <copyuvm+0x10f>
  for(i = 0; i < sz; i += PGSIZE){
8010866f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108676:	e9 c0 00 00 00       	jmp    8010873b <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010867b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108685:	00 
80108686:	89 44 24 04          	mov    %eax,0x4(%esp)
8010868a:	8b 45 08             	mov    0x8(%ebp),%eax
8010868d:	89 04 24             	mov    %eax,(%esp)
80108690:	e8 56 f8 ff ff       	call   80107eeb <walkpgdir>
80108695:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108698:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010869c:	75 0c                	jne    801086aa <copyuvm+0x59>
      panic("copyuvm: pte should exist");
8010869e:	c7 04 24 ba 8e 10 80 	movl   $0x80108eba,(%esp)
801086a5:	e8 93 7e ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
801086aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086ad:	8b 00                	mov    (%eax),%eax
801086af:	83 e0 01             	and    $0x1,%eax
801086b2:	85 c0                	test   %eax,%eax
801086b4:	75 0c                	jne    801086c2 <copyuvm+0x71>
      panic("copyuvm: page not present");
801086b6:	c7 04 24 d4 8e 10 80 	movl   $0x80108ed4,(%esp)
801086bd:	e8 7b 7e ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
801086c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086c5:	8b 00                	mov    (%eax),%eax
801086c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((mem = kalloc()) == 0)
801086cf:	e8 53 a7 ff ff       	call   80102e27 <kalloc>
801086d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801086d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801086db:	74 6f                	je     8010874c <copyuvm+0xfb>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
801086dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801086e0:	89 04 24             	mov    %eax,(%esp)
801086e3:	e8 80 f3 ff ff       	call   80107a68 <p2v>
801086e8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801086ef:	00 
801086f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801086f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801086f7:	89 04 24             	mov    %eax,(%esp)
801086fa:	e8 e2 cd ff ff       	call   801054e1 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
801086ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108702:	89 04 24             	mov    %eax,(%esp)
80108705:	e8 51 f3 ff ff       	call   80107a5b <v2p>
8010870a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010870d:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108714:	00 
80108715:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108719:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108720:	00 
80108721:	89 54 24 04          	mov    %edx,0x4(%esp)
80108725:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108728:	89 04 24             	mov    %eax,(%esp)
8010872b:	e8 51 f8 ff ff       	call   80107f81 <mappages>
80108730:	85 c0                	test   %eax,%eax
80108732:	78 1b                	js     8010874f <copyuvm+0xfe>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108734:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010873b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108741:	0f 82 34 ff ff ff    	jb     8010867b <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
  }
  return d;
80108747:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010874a:	eb 14                	jmp    80108760 <copyuvm+0x10f>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010874c:	90                   	nop
8010874d:	eb 01                	jmp    80108750 <copyuvm+0xff>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
8010874f:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108750:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108753:	89 04 24             	mov    %eax,(%esp)
80108756:	e8 22 fe ff ff       	call   8010857d <freevm>
  return 0;
8010875b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108760:	c9                   	leave  
80108761:	c3                   	ret    

80108762 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108762:	55                   	push   %ebp
80108763:	89 e5                	mov    %esp,%ebp
80108765:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108768:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010876f:	00 
80108770:	8b 45 0c             	mov    0xc(%ebp),%eax
80108773:	89 44 24 04          	mov    %eax,0x4(%esp)
80108777:	8b 45 08             	mov    0x8(%ebp),%eax
8010877a:	89 04 24             	mov    %eax,(%esp)
8010877d:	e8 69 f7 ff ff       	call   80107eeb <walkpgdir>
80108782:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108785:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108788:	8b 00                	mov    (%eax),%eax
8010878a:	83 e0 01             	and    $0x1,%eax
8010878d:	85 c0                	test   %eax,%eax
8010878f:	75 07                	jne    80108798 <uva2ka+0x36>
    return 0;
80108791:	b8 00 00 00 00       	mov    $0x0,%eax
80108796:	eb 25                	jmp    801087bd <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108798:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010879b:	8b 00                	mov    (%eax),%eax
8010879d:	83 e0 04             	and    $0x4,%eax
801087a0:	85 c0                	test   %eax,%eax
801087a2:	75 07                	jne    801087ab <uva2ka+0x49>
    return 0;
801087a4:	b8 00 00 00 00       	mov    $0x0,%eax
801087a9:	eb 12                	jmp    801087bd <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
801087ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ae:	8b 00                	mov    (%eax),%eax
801087b0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087b5:	89 04 24             	mov    %eax,(%esp)
801087b8:	e8 ab f2 ff ff       	call   80107a68 <p2v>
}
801087bd:	c9                   	leave  
801087be:	c3                   	ret    

801087bf <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801087bf:	55                   	push   %ebp
801087c0:	89 e5                	mov    %esp,%ebp
801087c2:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801087c5:	8b 45 10             	mov    0x10(%ebp),%eax
801087c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801087cb:	e9 8b 00 00 00       	jmp    8010885b <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
801087d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801087d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801087db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087de:	89 44 24 04          	mov    %eax,0x4(%esp)
801087e2:	8b 45 08             	mov    0x8(%ebp),%eax
801087e5:	89 04 24             	mov    %eax,(%esp)
801087e8:	e8 75 ff ff ff       	call   80108762 <uva2ka>
801087ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801087f0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801087f4:	75 07                	jne    801087fd <copyout+0x3e>
      return -1;
801087f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801087fb:	eb 6d                	jmp    8010886a <copyout+0xab>
    n = PGSIZE - (va - va0);
801087fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80108800:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108803:	89 d1                	mov    %edx,%ecx
80108805:	29 c1                	sub    %eax,%ecx
80108807:	89 c8                	mov    %ecx,%eax
80108809:	05 00 10 00 00       	add    $0x1000,%eax
8010880e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108811:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108814:	3b 45 14             	cmp    0x14(%ebp),%eax
80108817:	76 06                	jbe    8010881f <copyout+0x60>
      n = len;
80108819:	8b 45 14             	mov    0x14(%ebp),%eax
8010881c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010881f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108822:	8b 55 0c             	mov    0xc(%ebp),%edx
80108825:	89 d1                	mov    %edx,%ecx
80108827:	29 c1                	sub    %eax,%ecx
80108829:	89 c8                	mov    %ecx,%eax
8010882b:	03 45 e8             	add    -0x18(%ebp),%eax
8010882e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108831:	89 54 24 08          	mov    %edx,0x8(%esp)
80108835:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108838:	89 54 24 04          	mov    %edx,0x4(%esp)
8010883c:	89 04 24             	mov    %eax,(%esp)
8010883f:	e8 9d cc ff ff       	call   801054e1 <memmove>
    len -= n;
80108844:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108847:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010884a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010884d:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108850:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108853:	05 00 10 00 00       	add    $0x1000,%eax
80108858:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010885b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010885f:	0f 85 6b ff ff ff    	jne    801087d0 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108865:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010886a:	c9                   	leave  
8010886b:	c3                   	ret    

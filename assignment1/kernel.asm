
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
8010002d:	b8 5b 37 10 80       	mov    $0x8010375b,%eax
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
8010003a:	c7 44 24 04 28 87 10 	movl   $0x80108728,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 40 50 00 00       	call   8010508e <initlock>

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
801000bd:	e8 ed 4f 00 00       	call   801050af <acquire>

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
80100104:	e8 08 50 00 00       	call   80105111 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 a5 4c 00 00       	call   80104dc9 <sleep>
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
8010017c:	e8 90 4f 00 00       	call   80105111 <release>
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
80100198:	c7 04 24 2f 87 10 80 	movl   $0x8010872f,(%esp)
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
801001d3:	e8 30 29 00 00       	call   80102b08 <iderw>
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
801001ef:	c7 04 24 40 87 10 80 	movl   $0x80108740,(%esp)
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
80100210:	e8 f3 28 00 00       	call   80102b08 <iderw>
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
80100229:	c7 04 24 47 87 10 80 	movl   $0x80108747,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 6e 4e 00 00       	call   801050af <acquire>

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
8010029d:	e8 03 4c 00 00       	call   80104ea5 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 63 4e 00 00       	call   80105111 <release>
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
80100390:	e8 46 04 00 00       	call   801007db <consputc>
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
801003bc:	e8 ee 4c 00 00       	call   801050af <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 4e 87 10 80 	movl   $0x8010874e,(%esp)
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
801003f2:	e8 e4 03 00 00       	call   801007db <consputc>
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
801004af:	c7 45 ec 57 87 10 80 	movl   $0x80108757,-0x14(%ebp)
      for(; *s; s++)
801004b6:	eb 17                	jmp    801004cf <cprintf+0x12e>
        consputc(*s);
801004b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004bb:	0f b6 00             	movzbl (%eax),%eax
801004be:	0f be c0             	movsbl %al,%eax
801004c1:	89 04 24             	mov    %eax,(%esp)
801004c4:	e8 12 03 00 00       	call   801007db <consputc>
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
801004e3:	e8 f3 02 00 00       	call   801007db <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x161>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 e5 02 00 00       	call   801007db <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 da 02 00 00       	call   801007db <consputc>
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
80100536:	e8 d6 4b 00 00       	call   80105111 <release>
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
80100562:	c7 04 24 5e 87 10 80 	movl   $0x8010875e,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 6d 87 10 80 	movl   $0x8010876d,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 c9 4b 00 00       	call   80105160 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 6f 87 10 80 	movl   $0x8010876f,(%esp)
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
80100626:	75 33                	jne    8010065b <cgaputc+0x8e>
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
80100656:	e9 a8 00 00 00       	jmp    80100703 <cgaputc+0x136>
  else if(c == BACKSPACE){
8010065b:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100662:	75 13                	jne    80100677 <cgaputc+0xaa>
    if(pos > 0) --pos;
80100664:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100668:	0f 8e 95 00 00 00    	jle    80100703 <cgaputc+0x136>
8010066e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100672:	e9 8c 00 00 00       	jmp    80100703 <cgaputc+0x136>
  }
  else if(c == KEY_LF){
80100677:	81 7d 08 e4 00 00 00 	cmpl   $0xe4,0x8(%ebp)
8010067e:	75 2e                	jne    801006ae <cgaputc+0xe1>
    if(pos%80 > 0) --pos;
80100680:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100683:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100688:	89 c8                	mov    %ecx,%eax
8010068a:	f7 ea                	imul   %edx
8010068c:	c1 fa 05             	sar    $0x5,%edx
8010068f:	89 c8                	mov    %ecx,%eax
80100691:	c1 f8 1f             	sar    $0x1f,%eax
80100694:	29 c2                	sub    %eax,%edx
80100696:	89 d0                	mov    %edx,%eax
80100698:	c1 e0 02             	shl    $0x2,%eax
8010069b:	01 d0                	add    %edx,%eax
8010069d:	c1 e0 04             	shl    $0x4,%eax
801006a0:	89 ca                	mov    %ecx,%edx
801006a2:	29 c2                	sub    %eax,%edx
801006a4:	85 d2                	test   %edx,%edx
801006a6:	7e 5b                	jle    80100703 <cgaputc+0x136>
801006a8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801006ac:	eb 55                	jmp    80100703 <cgaputc+0x136>
  }
  else if(c == KEY_RT){
801006ae:	81 7d 08 e5 00 00 00 	cmpl   $0xe5,0x8(%ebp)
801006b5:	75 2f                	jne    801006e6 <cgaputc+0x119>
    if(pos%80 < 79) ++pos;
801006b7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006ba:	ba 67 66 66 66       	mov    $0x66666667,%edx
801006bf:	89 c8                	mov    %ecx,%eax
801006c1:	f7 ea                	imul   %edx
801006c3:	c1 fa 05             	sar    $0x5,%edx
801006c6:	89 c8                	mov    %ecx,%eax
801006c8:	c1 f8 1f             	sar    $0x1f,%eax
801006cb:	29 c2                	sub    %eax,%edx
801006cd:	89 d0                	mov    %edx,%eax
801006cf:	c1 e0 02             	shl    $0x2,%eax
801006d2:	01 d0                	add    %edx,%eax
801006d4:	c1 e0 04             	shl    $0x4,%eax
801006d7:	89 ca                	mov    %ecx,%edx
801006d9:	29 c2                	sub    %eax,%edx
801006db:	83 fa 4e             	cmp    $0x4e,%edx
801006de:	7f 23                	jg     80100703 <cgaputc+0x136>
801006e0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801006e4:	eb 1d                	jmp    80100703 <cgaputc+0x136>
  }
  else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801006e6:	a1 00 90 10 80       	mov    0x80109000,%eax
801006eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801006ee:	01 d2                	add    %edx,%edx
801006f0:	01 c2                	add    %eax,%edx
801006f2:	8b 45 08             	mov    0x8(%ebp),%eax
801006f5:	66 25 ff 00          	and    $0xff,%ax
801006f9:	80 cc 07             	or     $0x7,%ah
801006fc:	66 89 02             	mov    %ax,(%edx)
801006ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  if((pos/80) >= 24){  // Scroll up.
80100703:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
8010070a:	7e 53                	jle    8010075f <cgaputc+0x192>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010070c:	a1 00 90 10 80       	mov    0x80109000,%eax
80100711:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100717:	a1 00 90 10 80       	mov    0x80109000,%eax
8010071c:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
80100723:	00 
80100724:	89 54 24 04          	mov    %edx,0x4(%esp)
80100728:	89 04 24             	mov    %eax,(%esp)
8010072b:	e8 a1 4c 00 00       	call   801053d1 <memmove>
    pos -= 80;
80100730:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100734:	b8 80 07 00 00       	mov    $0x780,%eax
80100739:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010073c:	01 c0                	add    %eax,%eax
8010073e:	8b 15 00 90 10 80    	mov    0x80109000,%edx
80100744:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100747:	01 c9                	add    %ecx,%ecx
80100749:	01 ca                	add    %ecx,%edx
8010074b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010074f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100756:	00 
80100757:	89 14 24             	mov    %edx,(%esp)
8010075a:	e8 9f 4b 00 00       	call   801052fe <memset>
  }
  
  outb(CRTPORT, 14);
8010075f:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100766:	00 
80100767:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010076e:	e8 67 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos>>8);
80100773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100776:	c1 f8 08             	sar    $0x8,%eax
80100779:	0f b6 c0             	movzbl %al,%eax
8010077c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100780:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100787:	e8 4e fb ff ff       	call   801002da <outb>
  outb(CRTPORT, 15);
8010078c:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100793:	00 
80100794:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010079b:	e8 3a fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos);
801007a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007a3:	0f b6 c0             	movzbl %al,%eax
801007a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801007aa:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801007b1:	e8 24 fb ff ff       	call   801002da <outb>
  if(c != KEY_LF && c != KEY_RT)
801007b6:	81 7d 08 e4 00 00 00 	cmpl   $0xe4,0x8(%ebp)
801007bd:	74 1a                	je     801007d9 <cgaputc+0x20c>
801007bf:	81 7d 08 e5 00 00 00 	cmpl   $0xe5,0x8(%ebp)
801007c6:	74 11                	je     801007d9 <cgaputc+0x20c>
    crt[pos] = ' ' | 0x0700;
801007c8:	a1 00 90 10 80       	mov    0x80109000,%eax
801007cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801007d0:	01 d2                	add    %edx,%edx
801007d2:	01 d0                	add    %edx,%eax
801007d4:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801007d9:	c9                   	leave  
801007da:	c3                   	ret    

801007db <consputc>:

void
consputc(int c)
{
801007db:	55                   	push   %ebp
801007dc:	89 e5                	mov    %esp,%ebp
801007de:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
801007e1:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
801007e6:	85 c0                	test   %eax,%eax
801007e8:	74 07                	je     801007f1 <consputc+0x16>
    cli();
801007ea:	e8 09 fb ff ff       	call   801002f8 <cli>
    for(;;)
      ;
801007ef:	eb fe                	jmp    801007ef <consputc+0x14>
  }

  if(c == BACKSPACE){
801007f1:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007f8:	75 26                	jne    80100820 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007fa:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100801:	e8 87 65 00 00       	call   80106d8d <uartputc>
80100806:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010080d:	e8 7b 65 00 00       	call   80106d8d <uartputc>
80100812:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100819:	e8 6f 65 00 00       	call   80106d8d <uartputc>
8010081e:	eb 0b                	jmp    8010082b <consputc+0x50>
  }
  else if (c == KEY_RT){
    uartputc(0x601);
  }*/
  else
    uartputc(c);
80100820:	8b 45 08             	mov    0x8(%ebp),%eax
80100823:	89 04 24             	mov    %eax,(%esp)
80100826:	e8 62 65 00 00       	call   80106d8d <uartputc>
  cgaputc(c);
8010082b:	8b 45 08             	mov    0x8(%ebp),%eax
8010082e:	89 04 24             	mov    %eax,(%esp)
80100831:	e8 97 fd ff ff       	call   801005cd <cgaputc>
}
80100836:	c9                   	leave  
80100837:	c3                   	ret    

80100838 <shiftRightBuf>:

#define C(x)  ((x)-'@')  // Control-x

void
shiftRightBuf(int e, int k)
{
80100838:	55                   	push   %ebp
80100839:	89 e5                	mov    %esp,%ebp
8010083b:	83 ec 10             	sub    $0x10,%esp
  int i = e+1;
8010083e:	8b 45 08             	mov    0x8(%ebp),%eax
80100841:	83 c0 01             	add    $0x1,%eax
80100844:	89 45 fc             	mov    %eax,-0x4(%ebp)
  int j=0;
80100847:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(;j < k ;i--,j++){
8010084e:	eb 21                	jmp    80100871 <shiftRightBuf+0x39>
    input.buf[i] = input.buf[i-1];
80100850:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100853:	83 e8 01             	sub    $0x1,%eax
80100856:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
8010085d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80100860:	81 c2 d0 dd 10 80    	add    $0x8010ddd0,%edx
80100866:	88 42 04             	mov    %al,0x4(%edx)
void
shiftRightBuf(int e, int k)
{
  int i = e+1;
  int j=0;
  for(;j < k ;i--,j++){
80100869:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010086d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80100871:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100874:	3b 45 0c             	cmp    0xc(%ebp),%eax
80100877:	7c d7                	jl     80100850 <shiftRightBuf+0x18>
    input.buf[i] = input.buf[i-1];
  }
}
80100879:	c9                   	leave  
8010087a:	c3                   	ret    

8010087b <shiftLeftBuf>:

void
shiftLeftBuf(int e, int k)
{
8010087b:	55                   	push   %ebp
8010087c:	89 e5                	mov    %esp,%ebp
8010087e:	83 ec 10             	sub    $0x10,%esp
  int i = e+k;
80100881:	8b 45 0c             	mov    0xc(%ebp),%eax
80100884:	8b 55 08             	mov    0x8(%ebp),%edx
80100887:	01 d0                	add    %edx,%eax
80100889:	89 45 fc             	mov    %eax,-0x4(%ebp)
  int j=0;
8010088c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(;j < (-1)*k ;i++,j++){
80100893:	eb 21                	jmp    801008b6 <shiftLeftBuf+0x3b>
    input.buf[i] = input.buf[i+1];
80100895:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100898:	83 c0 01             	add    $0x1,%eax
8010089b:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
801008a2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801008a5:	81 c2 d0 dd 10 80    	add    $0x8010ddd0,%edx
801008ab:	88 42 04             	mov    %al,0x4(%edx)
void
shiftLeftBuf(int e, int k)
{
  int i = e+k;
  int j=0;
  for(;j < (-1)*k ;i++,j++){
801008ae:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801008b2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801008b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801008b9:	f7 d8                	neg    %eax
801008bb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801008be:	7f d5                	jg     80100895 <shiftLeftBuf+0x1a>
    input.buf[i] = input.buf[i+1];
  }
  input.buf[e] = ' ';
801008c0:	8b 45 08             	mov    0x8(%ebp),%eax
801008c3:	05 d0 dd 10 80       	add    $0x8010ddd0,%eax
801008c8:	c6 40 04 20          	movb   $0x20,0x4(%eax)
}
801008cc:	c9                   	leave  
801008cd:	c3                   	ret    

801008ce <consoleintr>:

void
consoleintr(int (*getc)(void))
{
801008ce:	55                   	push   %ebp
801008cf:	89 e5                	mov    %esp,%ebp
801008d1:	83 ec 38             	sub    $0x38,%esp
  int c;

  acquire(&input.lock);
801008d4:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
801008db:	e8 cf 47 00 00       	call   801050af <acquire>
  while((c = getc()) >= 0){
801008e0:	e9 74 03 00 00       	jmp    80100c59 <consoleintr+0x38b>
    switch(c){
801008e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801008e8:	83 f8 15             	cmp    $0x15,%eax
801008eb:	74 59                	je     80100946 <consoleintr+0x78>
801008ed:	83 f8 15             	cmp    $0x15,%eax
801008f0:	7f 0f                	jg     80100901 <consoleintr+0x33>
801008f2:	83 f8 08             	cmp    $0x8,%eax
801008f5:	74 7e                	je     80100975 <consoleintr+0xa7>
801008f7:	83 f8 10             	cmp    $0x10,%eax
801008fa:	74 25                	je     80100921 <consoleintr+0x53>
801008fc:	e9 b5 01 00 00       	jmp    80100ab6 <consoleintr+0x1e8>
80100901:	3d e4 00 00 00       	cmp    $0xe4,%eax
80100906:	0f 84 40 01 00 00    	je     80100a4c <consoleintr+0x17e>
8010090c:	3d e5 00 00 00       	cmp    $0xe5,%eax
80100911:	0f 84 63 01 00 00    	je     80100a7a <consoleintr+0x1ac>
80100917:	83 f8 7f             	cmp    $0x7f,%eax
8010091a:	74 59                	je     80100975 <consoleintr+0xa7>
8010091c:	e9 95 01 00 00       	jmp    80100ab6 <consoleintr+0x1e8>
    case C('P'):  // Process listing.
      procdump();
80100921:	e8 25 46 00 00       	call   80104f4b <procdump>
      break;
80100926:	e9 2e 03 00 00       	jmp    80100c59 <consoleintr+0x38b>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010092b:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100930:	83 e8 01             	sub    $0x1,%eax
80100933:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(BACKSPACE);
80100938:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010093f:	e8 97 fe ff ff       	call   801007db <consputc>
80100944:	eb 01                	jmp    80100947 <consoleintr+0x79>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100946:	90                   	nop
80100947:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
8010094d:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100952:	39 c2                	cmp    %eax,%edx
80100954:	0f 84 f2 02 00 00    	je     80100c4c <consoleintr+0x37e>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010095a:	a1 5c de 10 80       	mov    0x8010de5c,%eax
8010095f:	83 e8 01             	sub    $0x1,%eax
80100962:	83 e0 7f             	and    $0x7f,%eax
80100965:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010096c:	3c 0a                	cmp    $0xa,%al
8010096e:	75 bb                	jne    8010092b <consoleintr+0x5d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100970:	e9 d7 02 00 00       	jmp    80100c4c <consoleintr+0x37e>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100975:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
8010097b:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100980:	39 c2                	cmp    %eax,%edx
80100982:	0f 84 c7 02 00 00    	je     80100c4f <consoleintr+0x381>
	if(input.a<0)
80100988:	a1 60 de 10 80       	mov    0x8010de60,%eax
8010098d:	85 c0                	test   %eax,%eax
8010098f:	0f 89 99 00 00 00    	jns    80100a2e <consoleintr+0x160>
	{
	    shiftLeftBuf((input.e-1) % INPUT_BUF,input.a);
80100995:	a1 60 de 10 80       	mov    0x8010de60,%eax
8010099a:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
801009a0:	83 ea 01             	sub    $0x1,%edx
801009a3:	83 e2 7f             	and    $0x7f,%edx
801009a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801009aa:	89 14 24             	mov    %edx,(%esp)
801009ad:	e8 c9 fe ff ff       	call   8010087b <shiftLeftBuf>
	    int i = input.e+input.a-1;
801009b2:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
801009b8:	a1 60 de 10 80       	mov    0x8010de60,%eax
801009bd:	01 d0                	add    %edx,%eax
801009bf:	83 e8 01             	sub    $0x1,%eax
801009c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    consputc(KEY_LF);
801009c5:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
801009cc:	e8 0a fe ff ff       	call   801007db <consputc>
	    for(;i<input.e;i++){
801009d1:	eb 1b                	jmp    801009ee <consoleintr+0x120>
	      consputc(input.buf[i]);
801009d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801009d6:	05 d0 dd 10 80       	add    $0x8010ddd0,%eax
801009db:	0f b6 40 04          	movzbl 0x4(%eax),%eax
801009df:	0f be c0             	movsbl %al,%eax
801009e2:	89 04 24             	mov    %eax,(%esp)
801009e5:	e8 f1 fd ff ff       	call   801007db <consputc>
	if(input.a<0)
	{
	    shiftLeftBuf((input.e-1) % INPUT_BUF,input.a);
	    int i = input.e+input.a-1;
	    consputc(KEY_LF);
	    for(;i<input.e;i++){
801009ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801009ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801009f1:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801009f6:	39 c2                	cmp    %eax,%edx
801009f8:	72 d9                	jb     801009d3 <consoleintr+0x105>
	      consputc(input.buf[i]);
	    }
	    i = input.e+input.a;
801009fa:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100a00:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a05:	01 d0                	add    %edx,%eax
80100a07:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    for(;i<input.e+1;i++){
80100a0a:	eb 10                	jmp    80100a1c <consoleintr+0x14e>
	      consputc(KEY_LF);
80100a0c:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100a13:	e8 c3 fd ff ff       	call   801007db <consputc>
	    consputc(KEY_LF);
	    for(;i<input.e;i++){
	      consputc(input.buf[i]);
	    }
	    i = input.e+input.a;
	    for(;i<input.e+1;i++){
80100a18:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a1f:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100a25:	83 c2 01             	add    $0x1,%edx
80100a28:	39 d0                	cmp    %edx,%eax
80100a2a:	72 e0                	jb     80100a0c <consoleintr+0x13e>
80100a2c:	eb 0c                	jmp    80100a3a <consoleintr+0x16c>
	      consputc(KEY_LF);
	    }
	}
	else
	{
	  consputc(BACKSPACE);
80100a2e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100a35:	e8 a1 fd ff ff       	call   801007db <consputc>
	}
	input.e--;
80100a3a:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100a3f:	83 e8 01             	sub    $0x1,%eax
80100a42:	a3 5c de 10 80       	mov    %eax,0x8010de5c
      }
      break;
80100a47:	e9 03 02 00 00       	jmp    80100c4f <consoleintr+0x381>
    case KEY_LF: //LEFT KEY
     if(input.e % INPUT_BUF > 0)
80100a4c:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100a51:	83 e0 7f             	and    $0x7f,%eax
80100a54:	85 c0                	test   %eax,%eax
80100a56:	0f 84 f6 01 00 00    	je     80100c52 <consoleintr+0x384>
      {
        input.a--;
80100a5c:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a61:	83 e8 01             	sub    $0x1,%eax
80100a64:	a3 60 de 10 80       	mov    %eax,0x8010de60
        consputc(KEY_LF);
80100a69:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100a70:	e8 66 fd ff ff       	call   801007db <consputc>
      }
      break;
80100a75:	e9 d8 01 00 00       	jmp    80100c52 <consoleintr+0x384>
    case KEY_RT: //RIGHT KEY
      if(input.a < 0 && input.e % INPUT_BUF < INPUT_BUF-1)
80100a7a:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a7f:	85 c0                	test   %eax,%eax
80100a81:	0f 89 ce 01 00 00    	jns    80100c55 <consoleintr+0x387>
80100a87:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100a8c:	83 e0 7f             	and    $0x7f,%eax
80100a8f:	83 f8 7e             	cmp    $0x7e,%eax
80100a92:	0f 87 bd 01 00 00    	ja     80100c55 <consoleintr+0x387>
      {
        input.a++;
80100a98:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a9d:	83 c0 01             	add    $0x1,%eax
80100aa0:	a3 60 de 10 80       	mov    %eax,0x8010de60
        consputc(KEY_RT);
80100aa5:	c7 04 24 e5 00 00 00 	movl   $0xe5,(%esp)
80100aac:	e8 2a fd ff ff       	call   801007db <consputc>
      }
      break;
80100ab1:	e9 9f 01 00 00       	jmp    80100c55 <consoleintr+0x387>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF)
80100ab6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100aba:	0f 84 98 01 00 00    	je     80100c58 <consoleintr+0x38a>
80100ac0:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100ac6:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100acb:	89 d1                	mov    %edx,%ecx
80100acd:	29 c1                	sub    %eax,%ecx
80100acf:	89 c8                	mov    %ecx,%eax
80100ad1:	83 f8 7f             	cmp    $0x7f,%eax
80100ad4:	0f 87 7e 01 00 00    	ja     80100c58 <consoleintr+0x38a>
      {
	c = (c == '\r') ? '\n' : c;
80100ada:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
80100ade:	74 05                	je     80100ae5 <consoleintr+0x217>
80100ae0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100ae3:	eb 05                	jmp    80100aea <consoleintr+0x21c>
80100ae5:	b8 0a 00 00 00       	mov    $0xa,%eax
80100aea:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(c != '\n' && input.a < 0)
80100aed:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100af1:	0f 84 ef 00 00 00    	je     80100be6 <consoleintr+0x318>
80100af7:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100afc:	85 c0                	test   %eax,%eax
80100afe:	0f 89 e2 00 00 00    	jns    80100be6 <consoleintr+0x318>
	{
	    int j = (INPUT_BUF-(input.e-input.w));
80100b04:	8b 15 58 de 10 80    	mov    0x8010de58,%edx
80100b0a:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b0f:	89 d1                	mov    %edx,%ecx
80100b11:	29 c1                	sub    %eax,%ecx
80100b13:	89 c8                	mov    %ecx,%eax
80100b15:	83 e8 80             	sub    $0xffffff80,%eax
80100b18:	89 45 e8             	mov    %eax,-0x18(%ebp)
	    int k = ((-1)*input.a > j) ? j : (-1)*input.a;
80100b1b:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100b20:	89 c2                	mov    %eax,%edx
80100b22:	f7 da                	neg    %edx
80100b24:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100b27:	39 c2                	cmp    %eax,%edx
80100b29:	0f 4e c2             	cmovle %edx,%eax
80100b2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	    shiftRightBuf((input.e-1) % INPUT_BUF,k);
80100b2f:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b34:	83 e8 01             	sub    $0x1,%eax
80100b37:	89 c2                	mov    %eax,%edx
80100b39:	83 e2 7f             	and    $0x7f,%edx
80100b3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b43:	89 14 24             	mov    %edx,(%esp)
80100b46:	e8 ed fc ff ff       	call   80100838 <shiftRightBuf>
	    input.buf[(input.e-k) % INPUT_BUF] = c;
80100b4b:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100b51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100b54:	89 d1                	mov    %edx,%ecx
80100b56:	29 c1                	sub    %eax,%ecx
80100b58:	89 c8                	mov    %ecx,%eax
80100b5a:	89 c2                	mov    %eax,%edx
80100b5c:	83 e2 7f             	and    $0x7f,%edx
80100b5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100b62:	88 82 d4 dd 10 80    	mov    %al,-0x7fef222c(%edx)
	    int i = input.e-k;
80100b68:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100b6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100b71:	89 d1                	mov    %edx,%ecx
80100b73:	29 c1                	sub    %eax,%ecx
80100b75:	89 c8                	mov    %ecx,%eax
80100b77:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    
	    for(;i<input.e+1;i++){
80100b7a:	eb 1b                	jmp    80100b97 <consoleintr+0x2c9>
	      consputc(input.buf[i]);
80100b7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100b7f:	05 d0 dd 10 80       	add    $0x8010ddd0,%eax
80100b84:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80100b88:	0f be c0             	movsbl %al,%eax
80100b8b:	89 04 24             	mov    %eax,(%esp)
80100b8e:	e8 48 fc ff ff       	call   801007db <consputc>
	    int k = ((-1)*input.a > j) ? j : (-1)*input.a;
	    shiftRightBuf((input.e-1) % INPUT_BUF,k);
	    input.buf[(input.e-k) % INPUT_BUF] = c;
	    int i = input.e-k;
	    
	    for(;i<input.e+1;i++){
80100b93:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100b97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100b9a:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100ba0:	83 c2 01             	add    $0x1,%edx
80100ba3:	39 d0                	cmp    %edx,%eax
80100ba5:	72 d5                	jb     80100b7c <consoleintr+0x2ae>
	      consputc(input.buf[i]);
	    }
	    i = input.e-k;
80100ba7:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100bad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100bb0:	89 d1                	mov    %edx,%ecx
80100bb2:	29 c1                	sub    %eax,%ecx
80100bb4:	89 c8                	mov    %ecx,%eax
80100bb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    for(;i<input.e;i++){
80100bb9:	eb 10                	jmp    80100bcb <consoleintr+0x2fd>
	      consputc(KEY_LF);
80100bbb:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100bc2:	e8 14 fc ff ff       	call   801007db <consputc>
	    
	    for(;i<input.e+1;i++){
	      consputc(input.buf[i]);
	    }
	    i = input.e-k;
	    for(;i<input.e;i++){
80100bc7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100bcb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100bce:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100bd3:	39 c2                	cmp    %eax,%edx
80100bd5:	72 e4                	jb     80100bbb <consoleintr+0x2ed>
	      consputc(KEY_LF);
	    }
	    input.e++;
80100bd7:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100bdc:	83 c0 01             	add    $0x1,%eax
80100bdf:	a3 5c de 10 80       	mov    %eax,0x8010de5c
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF)
      {
	c = (c == '\r') ? '\n' : c;
	if(c != '\n' && input.a < 0)
	{
80100be4:	eb 26                	jmp    80100c0c <consoleintr+0x33e>
	      consputc(KEY_LF);
	    }
	    input.e++;
	}
	else {
	  input.buf[input.e++ % INPUT_BUF] = c;
80100be6:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100beb:	89 c1                	mov    %eax,%ecx
80100bed:	83 e1 7f             	and    $0x7f,%ecx
80100bf0:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100bf3:	88 91 d4 dd 10 80    	mov    %dl,-0x7fef222c(%ecx)
80100bf9:	83 c0 01             	add    $0x1,%eax
80100bfc:	a3 5c de 10 80       	mov    %eax,0x8010de5c
          consputc(c);
80100c01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100c04:	89 04 24             	mov    %eax,(%esp)
80100c07:	e8 cf fb ff ff       	call   801007db <consputc>
	}
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100c0c:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100c10:	74 18                	je     80100c2a <consoleintr+0x35c>
80100c12:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80100c16:	74 12                	je     80100c2a <consoleintr+0x35c>
80100c18:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100c1d:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
80100c23:	83 ea 80             	sub    $0xffffff80,%edx
80100c26:	39 d0                	cmp    %edx,%eax
80100c28:	75 2e                	jne    80100c58 <consoleintr+0x38a>
          input.a = 0;
80100c2a:	c7 05 60 de 10 80 00 	movl   $0x0,0x8010de60
80100c31:	00 00 00 
	  input.w = input.e;
80100c34:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100c39:	a3 58 de 10 80       	mov    %eax,0x8010de58
          wakeup(&input.r);
80100c3e:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100c45:	e8 5b 42 00 00       	call   80104ea5 <wakeup>
        }
      }
      break;
80100c4a:	eb 0c                	jmp    80100c58 <consoleintr+0x38a>
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100c4c:	90                   	nop
80100c4d:	eb 0a                	jmp    80100c59 <consoleintr+0x38b>
	{
	  consputc(BACKSPACE);
	}
	input.e--;
      }
      break;
80100c4f:	90                   	nop
80100c50:	eb 07                	jmp    80100c59 <consoleintr+0x38b>
     if(input.e % INPUT_BUF > 0)
      {
        input.a--;
        consputc(KEY_LF);
      }
      break;
80100c52:	90                   	nop
80100c53:	eb 04                	jmp    80100c59 <consoleintr+0x38b>
      if(input.a < 0 && input.e % INPUT_BUF < INPUT_BUF-1)
      {
        input.a++;
        consputc(KEY_RT);
      }
      break;
80100c55:	90                   	nop
80100c56:	eb 01                	jmp    80100c59 <consoleintr+0x38b>
          input.a = 0;
	  input.w = input.e;
          wakeup(&input.r);
        }
      }
      break;
80100c58:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100c59:	8b 45 08             	mov    0x8(%ebp),%eax
80100c5c:	ff d0                	call   *%eax
80100c5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100c61:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100c65:	0f 89 7a fc ff ff    	jns    801008e5 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100c6b:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100c72:	e8 9a 44 00 00       	call   80105111 <release>
}
80100c77:	c9                   	leave  
80100c78:	c3                   	ret    

80100c79 <consoleread>:


int
consoleread(struct inode *ip, char *dst, int n)
{
80100c79:	55                   	push   %ebp
80100c7a:	89 e5                	mov    %esp,%ebp
80100c7c:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100c7f:	8b 45 08             	mov    0x8(%ebp),%eax
80100c82:	89 04 24             	mov    %eax,(%esp)
80100c85:	e8 80 10 00 00       	call   80101d0a <iunlock>
  target = n;
80100c8a:	8b 45 10             	mov    0x10(%ebp),%eax
80100c8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100c90:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100c97:	e8 13 44 00 00       	call   801050af <acquire>
  while(n > 0){
80100c9c:	e9 a8 00 00 00       	jmp    80100d49 <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
80100ca1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ca7:	8b 40 24             	mov    0x24(%eax),%eax
80100caa:	85 c0                	test   %eax,%eax
80100cac:	74 21                	je     80100ccf <consoleread+0x56>
        release(&input.lock);
80100cae:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100cb5:	e8 57 44 00 00       	call   80105111 <release>
        ilock(ip);
80100cba:	8b 45 08             	mov    0x8(%ebp),%eax
80100cbd:	89 04 24             	mov    %eax,(%esp)
80100cc0:	e8 f7 0e 00 00       	call   80101bbc <ilock>
        return -1;
80100cc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100cca:	e9 a9 00 00 00       	jmp    80100d78 <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
80100ccf:	c7 44 24 04 a0 dd 10 	movl   $0x8010dda0,0x4(%esp)
80100cd6:	80 
80100cd7:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100cde:	e8 e6 40 00 00       	call   80104dc9 <sleep>
80100ce3:	eb 01                	jmp    80100ce6 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100ce5:	90                   	nop
80100ce6:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
80100cec:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100cf1:	39 c2                	cmp    %eax,%edx
80100cf3:	74 ac                	je     80100ca1 <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100cf5:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100cfa:	89 c2                	mov    %eax,%edx
80100cfc:	83 e2 7f             	and    $0x7f,%edx
80100cff:	0f b6 92 d4 dd 10 80 	movzbl -0x7fef222c(%edx),%edx
80100d06:	0f be d2             	movsbl %dl,%edx
80100d09:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100d0c:	83 c0 01             	add    $0x1,%eax
80100d0f:	a3 54 de 10 80       	mov    %eax,0x8010de54
    if(c == C('D')){  // EOF
80100d14:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100d18:	75 17                	jne    80100d31 <consoleread+0xb8>
      if(n < target){
80100d1a:	8b 45 10             	mov    0x10(%ebp),%eax
80100d1d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100d20:	73 2f                	jae    80100d51 <consoleread+0xd8>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100d22:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100d27:	83 e8 01             	sub    $0x1,%eax
80100d2a:	a3 54 de 10 80       	mov    %eax,0x8010de54
      }
      break;
80100d2f:	eb 20                	jmp    80100d51 <consoleread+0xd8>
    }
    *dst++ = c;
80100d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100d34:	89 c2                	mov    %eax,%edx
80100d36:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d39:	88 10                	mov    %dl,(%eax)
80100d3b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    --n;
80100d3f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100d43:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100d47:	74 0b                	je     80100d54 <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100d49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100d4d:	7f 96                	jg     80100ce5 <consoleread+0x6c>
80100d4f:	eb 04                	jmp    80100d55 <consoleread+0xdc>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100d51:	90                   	nop
80100d52:	eb 01                	jmp    80100d55 <consoleread+0xdc>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100d54:	90                   	nop
  }
  release(&input.lock);
80100d55:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100d5c:	e8 b0 43 00 00       	call   80105111 <release>
  ilock(ip);
80100d61:	8b 45 08             	mov    0x8(%ebp),%eax
80100d64:	89 04 24             	mov    %eax,(%esp)
80100d67:	e8 50 0e 00 00       	call   80101bbc <ilock>

  return target - n;
80100d6c:	8b 45 10             	mov    0x10(%ebp),%eax
80100d6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100d72:	89 d1                	mov    %edx,%ecx
80100d74:	29 c1                	sub    %eax,%ecx
80100d76:	89 c8                	mov    %ecx,%eax
}
80100d78:	c9                   	leave  
80100d79:	c3                   	ret    

80100d7a <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100d7a:	55                   	push   %ebp
80100d7b:	89 e5                	mov    %esp,%ebp
80100d7d:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100d80:	8b 45 08             	mov    0x8(%ebp),%eax
80100d83:	89 04 24             	mov    %eax,(%esp)
80100d86:	e8 7f 0f 00 00       	call   80101d0a <iunlock>
  acquire(&cons.lock);
80100d8b:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100d92:	e8 18 43 00 00       	call   801050af <acquire>
  for(i = 0; i < n; i++)
80100d97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100d9e:	eb 1d                	jmp    80100dbd <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100da3:	03 45 0c             	add    0xc(%ebp),%eax
80100da6:	0f b6 00             	movzbl (%eax),%eax
80100da9:	0f be c0             	movsbl %al,%eax
80100dac:	25 ff 00 00 00       	and    $0xff,%eax
80100db1:	89 04 24             	mov    %eax,(%esp)
80100db4:	e8 22 fa ff ff       	call   801007db <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100db9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100dc0:	3b 45 10             	cmp    0x10(%ebp),%eax
80100dc3:	7c db                	jl     80100da0 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100dc5:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100dcc:	e8 40 43 00 00       	call   80105111 <release>
  ilock(ip);
80100dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80100dd4:	89 04 24             	mov    %eax,(%esp)
80100dd7:	e8 e0 0d 00 00       	call   80101bbc <ilock>

  return n;
80100ddc:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100ddf:	c9                   	leave  
80100de0:	c3                   	ret    

80100de1 <consoleinit>:

void
consoleinit(void)
{
80100de1:	55                   	push   %ebp
80100de2:	89 e5                	mov    %esp,%ebp
80100de4:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100de7:	c7 44 24 04 73 87 10 	movl   $0x80108773,0x4(%esp)
80100dee:	80 
80100def:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100df6:	e8 93 42 00 00       	call   8010508e <initlock>
  initlock(&input.lock, "input");
80100dfb:	c7 44 24 04 7b 87 10 	movl   $0x8010877b,0x4(%esp)
80100e02:	80 
80100e03:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100e0a:	e8 7f 42 00 00       	call   8010508e <initlock>

  devsw[CONSOLE].write = consolewrite;
80100e0f:	c7 05 2c e8 10 80 7a 	movl   $0x80100d7a,0x8010e82c
80100e16:	0d 10 80 
  devsw[CONSOLE].read = consoleread;
80100e19:	c7 05 28 e8 10 80 79 	movl   $0x80100c79,0x8010e828
80100e20:	0c 10 80 
  cons.locking = 1;
80100e23:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100e2a:	00 00 00 

  picenable(IRQ_KBD);
80100e2d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100e34:	e8 dc 2f 00 00       	call   80103e15 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100e39:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100e40:	00 
80100e41:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100e48:	e8 7d 1e 00 00       	call   80102cca <ioapicenable>
}
80100e4d:	c9                   	leave  
80100e4e:	c3                   	ret    
	...

80100e50 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100e50:	55                   	push   %ebp
80100e51:	89 e5                	mov    %esp,%ebp
80100e53:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100e59:	8b 45 08             	mov    0x8(%ebp),%eax
80100e5c:	89 04 24             	mov    %eax,(%esp)
80100e5f:	e8 fa 18 00 00       	call   8010275e <namei>
80100e64:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100e67:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100e6b:	75 0a                	jne    80100e77 <exec+0x27>
    return -1;
80100e6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100e72:	e9 da 03 00 00       	jmp    80101251 <exec+0x401>
  ilock(ip);
80100e77:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e7a:	89 04 24             	mov    %eax,(%esp)
80100e7d:	e8 3a 0d 00 00       	call   80101bbc <ilock>
  pgdir = 0;
80100e82:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100e89:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100e90:	00 
80100e91:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100e98:	00 
80100e99:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100e9f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ea3:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ea6:	89 04 24             	mov    %eax,(%esp)
80100ea9:	e8 04 12 00 00       	call   801020b2 <readi>
80100eae:	83 f8 33             	cmp    $0x33,%eax
80100eb1:	0f 86 54 03 00 00    	jbe    8010120b <exec+0x3bb>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100eb7:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100ebd:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100ec2:	0f 85 46 03 00 00    	jne    8010120e <exec+0x3be>
    goto bad;

  if((pgdir = setupkvm(kalloc)) == 0)
80100ec8:	c7 04 24 53 2e 10 80 	movl   $0x80102e53,(%esp)
80100ecf:	e8 fd 6f 00 00       	call   80107ed1 <setupkvm>
80100ed4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100ed7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100edb:	0f 84 30 03 00 00    	je     80101211 <exec+0x3c1>
    goto bad;

  // Load program into memory.
  sz = 0;
80100ee1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ee8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100eef:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100ef5:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ef8:	e9 c5 00 00 00       	jmp    80100fc2 <exec+0x172>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100efd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100f00:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100f07:	00 
80100f08:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f0c:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100f12:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f16:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f19:	89 04 24             	mov    %eax,(%esp)
80100f1c:	e8 91 11 00 00       	call   801020b2 <readi>
80100f21:	83 f8 20             	cmp    $0x20,%eax
80100f24:	0f 85 ea 02 00 00    	jne    80101214 <exec+0x3c4>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100f2a:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100f30:	83 f8 01             	cmp    $0x1,%eax
80100f33:	75 7f                	jne    80100fb4 <exec+0x164>
      continue;
    if(ph.memsz < ph.filesz)
80100f35:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100f3b:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100f41:	39 c2                	cmp    %eax,%edx
80100f43:	0f 82 ce 02 00 00    	jb     80101217 <exec+0x3c7>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100f49:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100f4f:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100f55:	01 d0                	add    %edx,%eax
80100f57:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f5e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f62:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f65:	89 04 24             	mov    %eax,(%esp)
80100f68:	e8 36 73 00 00       	call   801082a3 <allocuvm>
80100f6d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100f70:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100f74:	0f 84 a0 02 00 00    	je     8010121a <exec+0x3ca>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100f7a:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100f80:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100f86:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100f8c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100f90:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100f94:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100f97:	89 54 24 08          	mov    %edx,0x8(%esp)
80100f9b:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f9f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100fa2:	89 04 24             	mov    %eax,(%esp)
80100fa5:	e8 0a 72 00 00       	call   801081b4 <loaduvm>
80100faa:	85 c0                	test   %eax,%eax
80100fac:	0f 88 6b 02 00 00    	js     8010121d <exec+0x3cd>
80100fb2:	eb 01                	jmp    80100fb5 <exec+0x165>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100fb4:	90                   	nop
  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100fb5:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100fb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100fbc:	83 c0 20             	add    $0x20,%eax
80100fbf:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100fc2:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100fc9:	0f b7 c0             	movzwl %ax,%eax
80100fcc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100fcf:	0f 8f 28 ff ff ff    	jg     80100efd <exec+0xad>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100fd5:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100fd8:	89 04 24             	mov    %eax,(%esp)
80100fdb:	e8 60 0e 00 00       	call   80101e40 <iunlockput>
  ip = 0;
80100fe0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100fe7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fea:	05 ff 0f 00 00       	add    $0xfff,%eax
80100fef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ff4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100ff7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ffa:	05 00 20 00 00       	add    $0x2000,%eax
80100fff:	89 44 24 08          	mov    %eax,0x8(%esp)
80101003:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101006:	89 44 24 04          	mov    %eax,0x4(%esp)
8010100a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010100d:	89 04 24             	mov    %eax,(%esp)
80101010:	e8 8e 72 00 00       	call   801082a3 <allocuvm>
80101015:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101018:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010101c:	0f 84 fe 01 00 00    	je     80101220 <exec+0x3d0>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80101022:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101025:	2d 00 20 00 00       	sub    $0x2000,%eax
8010102a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010102e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101031:	89 04 24             	mov    %eax,(%esp)
80101034:	e8 8e 74 00 00       	call   801084c7 <clearpteu>
  sp = sz;
80101039:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010103c:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
8010103f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101046:	e9 81 00 00 00       	jmp    801010cc <exec+0x27c>
    if(argc >= MAXARG)
8010104b:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
8010104f:	0f 87 ce 01 00 00    	ja     80101223 <exec+0x3d3>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80101055:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101058:	c1 e0 02             	shl    $0x2,%eax
8010105b:	03 45 0c             	add    0xc(%ebp),%eax
8010105e:	8b 00                	mov    (%eax),%eax
80101060:	89 04 24             	mov    %eax,(%esp)
80101063:	e8 14 45 00 00       	call   8010557c <strlen>
80101068:	f7 d0                	not    %eax
8010106a:	03 45 dc             	add    -0x24(%ebp),%eax
8010106d:	83 e0 fc             	and    $0xfffffffc,%eax
80101070:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80101073:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101076:	c1 e0 02             	shl    $0x2,%eax
80101079:	03 45 0c             	add    0xc(%ebp),%eax
8010107c:	8b 00                	mov    (%eax),%eax
8010107e:	89 04 24             	mov    %eax,(%esp)
80101081:	e8 f6 44 00 00       	call   8010557c <strlen>
80101086:	83 c0 01             	add    $0x1,%eax
80101089:	89 c2                	mov    %eax,%edx
8010108b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010108e:	c1 e0 02             	shl    $0x2,%eax
80101091:	03 45 0c             	add    0xc(%ebp),%eax
80101094:	8b 00                	mov    (%eax),%eax
80101096:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010109a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010109e:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010a1:	89 44 24 04          	mov    %eax,0x4(%esp)
801010a5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801010a8:	89 04 24             	mov    %eax,(%esp)
801010ab:	e8 cb 75 00 00       	call   8010867b <copyout>
801010b0:	85 c0                	test   %eax,%eax
801010b2:	0f 88 6e 01 00 00    	js     80101226 <exec+0x3d6>
      goto bad;
    ustack[3+argc] = sp;
801010b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010bb:	8d 50 03             	lea    0x3(%eax),%edx
801010be:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010c1:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
801010c8:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801010cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010cf:	c1 e0 02             	shl    $0x2,%eax
801010d2:	03 45 0c             	add    0xc(%ebp),%eax
801010d5:	8b 00                	mov    (%eax),%eax
801010d7:	85 c0                	test   %eax,%eax
801010d9:	0f 85 6c ff ff ff    	jne    8010104b <exec+0x1fb>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
801010df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010e2:	83 c0 03             	add    $0x3,%eax
801010e5:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
801010ec:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
801010f0:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
801010f7:	ff ff ff 
  ustack[1] = argc;
801010fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010fd:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80101103:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101106:	83 c0 01             	add    $0x1,%eax
80101109:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101110:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101113:	29 d0                	sub    %edx,%eax
80101115:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
8010111b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010111e:	83 c0 04             	add    $0x4,%eax
80101121:	c1 e0 02             	shl    $0x2,%eax
80101124:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80101127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010112a:	83 c0 04             	add    $0x4,%eax
8010112d:	c1 e0 02             	shl    $0x2,%eax
80101130:	89 44 24 0c          	mov    %eax,0xc(%esp)
80101134:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
8010113a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010113e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101141:	89 44 24 04          	mov    %eax,0x4(%esp)
80101145:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101148:	89 04 24             	mov    %eax,(%esp)
8010114b:	e8 2b 75 00 00       	call   8010867b <copyout>
80101150:	85 c0                	test   %eax,%eax
80101152:	0f 88 d1 00 00 00    	js     80101229 <exec+0x3d9>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101158:	8b 45 08             	mov    0x8(%ebp),%eax
8010115b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010115e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101161:	89 45 f0             	mov    %eax,-0x10(%ebp)
80101164:	eb 17                	jmp    8010117d <exec+0x32d>
    if(*s == '/')
80101166:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101169:	0f b6 00             	movzbl (%eax),%eax
8010116c:	3c 2f                	cmp    $0x2f,%al
8010116e:	75 09                	jne    80101179 <exec+0x329>
      last = s+1;
80101170:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101173:	83 c0 01             	add    $0x1,%eax
80101176:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101179:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010117d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101180:	0f b6 00             	movzbl (%eax),%eax
80101183:	84 c0                	test   %al,%al
80101185:	75 df                	jne    80101166 <exec+0x316>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80101187:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010118d:	8d 50 6c             	lea    0x6c(%eax),%edx
80101190:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101197:	00 
80101198:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010119b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010119f:	89 14 24             	mov    %edx,(%esp)
801011a2:	e8 87 43 00 00       	call   8010552e <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
801011a7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011ad:	8b 40 04             	mov    0x4(%eax),%eax
801011b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
801011b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011b9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801011bc:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
801011bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011c5:	8b 55 e0             	mov    -0x20(%ebp),%edx
801011c8:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
801011ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011d0:	8b 40 18             	mov    0x18(%eax),%eax
801011d3:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
801011d9:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
801011dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011e2:	8b 40 18             	mov    0x18(%eax),%eax
801011e5:	8b 55 dc             	mov    -0x24(%ebp),%edx
801011e8:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
801011eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011f1:	89 04 24             	mov    %eax,(%esp)
801011f4:	e8 c9 6d 00 00       	call   80107fc2 <switchuvm>
  freevm(oldpgdir);
801011f9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801011fc:	89 04 24             	mov    %eax,(%esp)
801011ff:	e8 35 72 00 00       	call   80108439 <freevm>
  return 0;
80101204:	b8 00 00 00 00       	mov    $0x0,%eax
80101209:	eb 46                	jmp    80101251 <exec+0x401>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
8010120b:	90                   	nop
8010120c:	eb 1c                	jmp    8010122a <exec+0x3da>
  if(elf.magic != ELF_MAGIC)
    goto bad;
8010120e:	90                   	nop
8010120f:	eb 19                	jmp    8010122a <exec+0x3da>

  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;
80101211:	90                   	nop
80101212:	eb 16                	jmp    8010122a <exec+0x3da>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80101214:	90                   	nop
80101215:	eb 13                	jmp    8010122a <exec+0x3da>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80101217:	90                   	nop
80101218:	eb 10                	jmp    8010122a <exec+0x3da>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
8010121a:	90                   	nop
8010121b:	eb 0d                	jmp    8010122a <exec+0x3da>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
8010121d:	90                   	nop
8010121e:	eb 0a                	jmp    8010122a <exec+0x3da>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80101220:	90                   	nop
80101221:	eb 07                	jmp    8010122a <exec+0x3da>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80101223:	90                   	nop
80101224:	eb 04                	jmp    8010122a <exec+0x3da>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80101226:	90                   	nop
80101227:	eb 01                	jmp    8010122a <exec+0x3da>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80101229:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
8010122a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010122e:	74 0b                	je     8010123b <exec+0x3eb>
    freevm(pgdir);
80101230:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101233:	89 04 24             	mov    %eax,(%esp)
80101236:	e8 fe 71 00 00       	call   80108439 <freevm>
  if(ip)
8010123b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010123f:	74 0b                	je     8010124c <exec+0x3fc>
    iunlockput(ip);
80101241:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101244:	89 04 24             	mov    %eax,(%esp)
80101247:	e8 f4 0b 00 00       	call   80101e40 <iunlockput>
  return -1;
8010124c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101251:	c9                   	leave  
80101252:	c3                   	ret    
	...

80101254 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101254:	55                   	push   %ebp
80101255:	89 e5                	mov    %esp,%ebp
80101257:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
8010125a:	c7 44 24 04 81 87 10 	movl   $0x80108781,0x4(%esp)
80101261:	80 
80101262:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101269:	e8 20 3e 00 00       	call   8010508e <initlock>
}
8010126e:	c9                   	leave  
8010126f:	c3                   	ret    

80101270 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101270:	55                   	push   %ebp
80101271:	89 e5                	mov    %esp,%ebp
80101273:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80101276:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
8010127d:	e8 2d 3e 00 00       	call   801050af <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101282:	c7 45 f4 b4 de 10 80 	movl   $0x8010deb4,-0xc(%ebp)
80101289:	eb 29                	jmp    801012b4 <filealloc+0x44>
    if(f->ref == 0){
8010128b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010128e:	8b 40 04             	mov    0x4(%eax),%eax
80101291:	85 c0                	test   %eax,%eax
80101293:	75 1b                	jne    801012b0 <filealloc+0x40>
      f->ref = 1;
80101295:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101298:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010129f:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012a6:	e8 66 3e 00 00       	call   80105111 <release>
      return f;
801012ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ae:	eb 1e                	jmp    801012ce <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801012b0:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801012b4:	81 7d f4 14 e8 10 80 	cmpl   $0x8010e814,-0xc(%ebp)
801012bb:	72 ce                	jb     8010128b <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
801012bd:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012c4:	e8 48 3e 00 00       	call   80105111 <release>
  return 0;
801012c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801012ce:	c9                   	leave  
801012cf:	c3                   	ret    

801012d0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801012d0:	55                   	push   %ebp
801012d1:	89 e5                	mov    %esp,%ebp
801012d3:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
801012d6:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012dd:	e8 cd 3d 00 00       	call   801050af <acquire>
  if(f->ref < 1)
801012e2:	8b 45 08             	mov    0x8(%ebp),%eax
801012e5:	8b 40 04             	mov    0x4(%eax),%eax
801012e8:	85 c0                	test   %eax,%eax
801012ea:	7f 0c                	jg     801012f8 <filedup+0x28>
    panic("filedup");
801012ec:	c7 04 24 88 87 10 80 	movl   $0x80108788,(%esp)
801012f3:	e8 45 f2 ff ff       	call   8010053d <panic>
  f->ref++;
801012f8:	8b 45 08             	mov    0x8(%ebp),%eax
801012fb:	8b 40 04             	mov    0x4(%eax),%eax
801012fe:	8d 50 01             	lea    0x1(%eax),%edx
80101301:	8b 45 08             	mov    0x8(%ebp),%eax
80101304:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101307:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
8010130e:	e8 fe 3d 00 00       	call   80105111 <release>
  return f;
80101313:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101316:	c9                   	leave  
80101317:	c3                   	ret    

80101318 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101318:	55                   	push   %ebp
80101319:	89 e5                	mov    %esp,%ebp
8010131b:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
8010131e:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101325:	e8 85 3d 00 00       	call   801050af <acquire>
  if(f->ref < 1)
8010132a:	8b 45 08             	mov    0x8(%ebp),%eax
8010132d:	8b 40 04             	mov    0x4(%eax),%eax
80101330:	85 c0                	test   %eax,%eax
80101332:	7f 0c                	jg     80101340 <fileclose+0x28>
    panic("fileclose");
80101334:	c7 04 24 90 87 10 80 	movl   $0x80108790,(%esp)
8010133b:	e8 fd f1 ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
80101340:	8b 45 08             	mov    0x8(%ebp),%eax
80101343:	8b 40 04             	mov    0x4(%eax),%eax
80101346:	8d 50 ff             	lea    -0x1(%eax),%edx
80101349:	8b 45 08             	mov    0x8(%ebp),%eax
8010134c:	89 50 04             	mov    %edx,0x4(%eax)
8010134f:	8b 45 08             	mov    0x8(%ebp),%eax
80101352:	8b 40 04             	mov    0x4(%eax),%eax
80101355:	85 c0                	test   %eax,%eax
80101357:	7e 11                	jle    8010136a <fileclose+0x52>
    release(&ftable.lock);
80101359:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101360:	e8 ac 3d 00 00       	call   80105111 <release>
    return;
80101365:	e9 82 00 00 00       	jmp    801013ec <fileclose+0xd4>
  }
  ff = *f;
8010136a:	8b 45 08             	mov    0x8(%ebp),%eax
8010136d:	8b 10                	mov    (%eax),%edx
8010136f:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101372:	8b 50 04             	mov    0x4(%eax),%edx
80101375:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101378:	8b 50 08             	mov    0x8(%eax),%edx
8010137b:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010137e:	8b 50 0c             	mov    0xc(%eax),%edx
80101381:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101384:	8b 50 10             	mov    0x10(%eax),%edx
80101387:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010138a:	8b 40 14             	mov    0x14(%eax),%eax
8010138d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101390:	8b 45 08             	mov    0x8(%ebp),%eax
80101393:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010139a:	8b 45 08             	mov    0x8(%ebp),%eax
8010139d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801013a3:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801013aa:	e8 62 3d 00 00       	call   80105111 <release>
  
  if(ff.type == FD_PIPE)
801013af:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013b2:	83 f8 01             	cmp    $0x1,%eax
801013b5:	75 18                	jne    801013cf <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
801013b7:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801013bb:	0f be d0             	movsbl %al,%edx
801013be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013c1:	89 54 24 04          	mov    %edx,0x4(%esp)
801013c5:	89 04 24             	mov    %eax,(%esp)
801013c8:	e8 02 2d 00 00       	call   801040cf <pipeclose>
801013cd:	eb 1d                	jmp    801013ec <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801013cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013d2:	83 f8 02             	cmp    $0x2,%eax
801013d5:	75 15                	jne    801013ec <fileclose+0xd4>
    begin_trans();
801013d7:	e8 95 21 00 00       	call   80103571 <begin_trans>
    iput(ff.ip);
801013dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013df:	89 04 24             	mov    %eax,(%esp)
801013e2:	e8 88 09 00 00       	call   80101d6f <iput>
    commit_trans();
801013e7:	e8 ce 21 00 00       	call   801035ba <commit_trans>
  }
}
801013ec:	c9                   	leave  
801013ed:	c3                   	ret    

801013ee <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801013ee:	55                   	push   %ebp
801013ef:	89 e5                	mov    %esp,%ebp
801013f1:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801013f4:	8b 45 08             	mov    0x8(%ebp),%eax
801013f7:	8b 00                	mov    (%eax),%eax
801013f9:	83 f8 02             	cmp    $0x2,%eax
801013fc:	75 38                	jne    80101436 <filestat+0x48>
    ilock(f->ip);
801013fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101401:	8b 40 10             	mov    0x10(%eax),%eax
80101404:	89 04 24             	mov    %eax,(%esp)
80101407:	e8 b0 07 00 00       	call   80101bbc <ilock>
    stati(f->ip, st);
8010140c:	8b 45 08             	mov    0x8(%ebp),%eax
8010140f:	8b 40 10             	mov    0x10(%eax),%eax
80101412:	8b 55 0c             	mov    0xc(%ebp),%edx
80101415:	89 54 24 04          	mov    %edx,0x4(%esp)
80101419:	89 04 24             	mov    %eax,(%esp)
8010141c:	e8 4c 0c 00 00       	call   8010206d <stati>
    iunlock(f->ip);
80101421:	8b 45 08             	mov    0x8(%ebp),%eax
80101424:	8b 40 10             	mov    0x10(%eax),%eax
80101427:	89 04 24             	mov    %eax,(%esp)
8010142a:	e8 db 08 00 00       	call   80101d0a <iunlock>
    return 0;
8010142f:	b8 00 00 00 00       	mov    $0x0,%eax
80101434:	eb 05                	jmp    8010143b <filestat+0x4d>
  }
  return -1;
80101436:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010143b:	c9                   	leave  
8010143c:	c3                   	ret    

8010143d <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010143d:	55                   	push   %ebp
8010143e:	89 e5                	mov    %esp,%ebp
80101440:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101443:	8b 45 08             	mov    0x8(%ebp),%eax
80101446:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010144a:	84 c0                	test   %al,%al
8010144c:	75 0a                	jne    80101458 <fileread+0x1b>
    return -1;
8010144e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101453:	e9 9f 00 00 00       	jmp    801014f7 <fileread+0xba>
  if(f->type == FD_PIPE)
80101458:	8b 45 08             	mov    0x8(%ebp),%eax
8010145b:	8b 00                	mov    (%eax),%eax
8010145d:	83 f8 01             	cmp    $0x1,%eax
80101460:	75 1e                	jne    80101480 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101462:	8b 45 08             	mov    0x8(%ebp),%eax
80101465:	8b 40 0c             	mov    0xc(%eax),%eax
80101468:	8b 55 10             	mov    0x10(%ebp),%edx
8010146b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010146f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101472:	89 54 24 04          	mov    %edx,0x4(%esp)
80101476:	89 04 24             	mov    %eax,(%esp)
80101479:	e8 d3 2d 00 00       	call   80104251 <piperead>
8010147e:	eb 77                	jmp    801014f7 <fileread+0xba>
  if(f->type == FD_INODE){
80101480:	8b 45 08             	mov    0x8(%ebp),%eax
80101483:	8b 00                	mov    (%eax),%eax
80101485:	83 f8 02             	cmp    $0x2,%eax
80101488:	75 61                	jne    801014eb <fileread+0xae>
    ilock(f->ip);
8010148a:	8b 45 08             	mov    0x8(%ebp),%eax
8010148d:	8b 40 10             	mov    0x10(%eax),%eax
80101490:	89 04 24             	mov    %eax,(%esp)
80101493:	e8 24 07 00 00       	call   80101bbc <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101498:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010149b:	8b 45 08             	mov    0x8(%ebp),%eax
8010149e:	8b 50 14             	mov    0x14(%eax),%edx
801014a1:	8b 45 08             	mov    0x8(%ebp),%eax
801014a4:	8b 40 10             	mov    0x10(%eax),%eax
801014a7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801014ab:	89 54 24 08          	mov    %edx,0x8(%esp)
801014af:	8b 55 0c             	mov    0xc(%ebp),%edx
801014b2:	89 54 24 04          	mov    %edx,0x4(%esp)
801014b6:	89 04 24             	mov    %eax,(%esp)
801014b9:	e8 f4 0b 00 00       	call   801020b2 <readi>
801014be:	89 45 f4             	mov    %eax,-0xc(%ebp)
801014c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801014c5:	7e 11                	jle    801014d8 <fileread+0x9b>
      f->off += r;
801014c7:	8b 45 08             	mov    0x8(%ebp),%eax
801014ca:	8b 50 14             	mov    0x14(%eax),%edx
801014cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014d0:	01 c2                	add    %eax,%edx
801014d2:	8b 45 08             	mov    0x8(%ebp),%eax
801014d5:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801014d8:	8b 45 08             	mov    0x8(%ebp),%eax
801014db:	8b 40 10             	mov    0x10(%eax),%eax
801014de:	89 04 24             	mov    %eax,(%esp)
801014e1:	e8 24 08 00 00       	call   80101d0a <iunlock>
    return r;
801014e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014e9:	eb 0c                	jmp    801014f7 <fileread+0xba>
  }
  panic("fileread");
801014eb:	c7 04 24 9a 87 10 80 	movl   $0x8010879a,(%esp)
801014f2:	e8 46 f0 ff ff       	call   8010053d <panic>
}
801014f7:	c9                   	leave  
801014f8:	c3                   	ret    

801014f9 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801014f9:	55                   	push   %ebp
801014fa:	89 e5                	mov    %esp,%ebp
801014fc:	53                   	push   %ebx
801014fd:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
80101500:	8b 45 08             	mov    0x8(%ebp),%eax
80101503:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101507:	84 c0                	test   %al,%al
80101509:	75 0a                	jne    80101515 <filewrite+0x1c>
    return -1;
8010150b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101510:	e9 23 01 00 00       	jmp    80101638 <filewrite+0x13f>
  if(f->type == FD_PIPE)
80101515:	8b 45 08             	mov    0x8(%ebp),%eax
80101518:	8b 00                	mov    (%eax),%eax
8010151a:	83 f8 01             	cmp    $0x1,%eax
8010151d:	75 21                	jne    80101540 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
8010151f:	8b 45 08             	mov    0x8(%ebp),%eax
80101522:	8b 40 0c             	mov    0xc(%eax),%eax
80101525:	8b 55 10             	mov    0x10(%ebp),%edx
80101528:	89 54 24 08          	mov    %edx,0x8(%esp)
8010152c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010152f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101533:	89 04 24             	mov    %eax,(%esp)
80101536:	e8 26 2c 00 00       	call   80104161 <pipewrite>
8010153b:	e9 f8 00 00 00       	jmp    80101638 <filewrite+0x13f>
  if(f->type == FD_INODE){
80101540:	8b 45 08             	mov    0x8(%ebp),%eax
80101543:	8b 00                	mov    (%eax),%eax
80101545:	83 f8 02             	cmp    $0x2,%eax
80101548:	0f 85 de 00 00 00    	jne    8010162c <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010154e:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101555:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010155c:	e9 a8 00 00 00       	jmp    80101609 <filewrite+0x110>
      int n1 = n - i;
80101561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101564:	8b 55 10             	mov    0x10(%ebp),%edx
80101567:	89 d1                	mov    %edx,%ecx
80101569:	29 c1                	sub    %eax,%ecx
8010156b:	89 c8                	mov    %ecx,%eax
8010156d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101570:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101573:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101576:	7e 06                	jle    8010157e <filewrite+0x85>
        n1 = max;
80101578:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010157b:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
8010157e:	e8 ee 1f 00 00       	call   80103571 <begin_trans>
      ilock(f->ip);
80101583:	8b 45 08             	mov    0x8(%ebp),%eax
80101586:	8b 40 10             	mov    0x10(%eax),%eax
80101589:	89 04 24             	mov    %eax,(%esp)
8010158c:	e8 2b 06 00 00       	call   80101bbc <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101591:	8b 5d f0             	mov    -0x10(%ebp),%ebx
80101594:	8b 45 08             	mov    0x8(%ebp),%eax
80101597:	8b 48 14             	mov    0x14(%eax),%ecx
8010159a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159d:	89 c2                	mov    %eax,%edx
8010159f:	03 55 0c             	add    0xc(%ebp),%edx
801015a2:	8b 45 08             	mov    0x8(%ebp),%eax
801015a5:	8b 40 10             	mov    0x10(%eax),%eax
801015a8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
801015ac:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801015b0:	89 54 24 04          	mov    %edx,0x4(%esp)
801015b4:	89 04 24             	mov    %eax,(%esp)
801015b7:	e8 61 0c 00 00       	call   8010221d <writei>
801015bc:	89 45 e8             	mov    %eax,-0x18(%ebp)
801015bf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801015c3:	7e 11                	jle    801015d6 <filewrite+0xdd>
        f->off += r;
801015c5:	8b 45 08             	mov    0x8(%ebp),%eax
801015c8:	8b 50 14             	mov    0x14(%eax),%edx
801015cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801015ce:	01 c2                	add    %eax,%edx
801015d0:	8b 45 08             	mov    0x8(%ebp),%eax
801015d3:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801015d6:	8b 45 08             	mov    0x8(%ebp),%eax
801015d9:	8b 40 10             	mov    0x10(%eax),%eax
801015dc:	89 04 24             	mov    %eax,(%esp)
801015df:	e8 26 07 00 00       	call   80101d0a <iunlock>
      commit_trans();
801015e4:	e8 d1 1f 00 00       	call   801035ba <commit_trans>

      if(r < 0)
801015e9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801015ed:	78 28                	js     80101617 <filewrite+0x11e>
        break;
      if(r != n1)
801015ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
801015f2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801015f5:	74 0c                	je     80101603 <filewrite+0x10a>
        panic("short filewrite");
801015f7:	c7 04 24 a3 87 10 80 	movl   $0x801087a3,(%esp)
801015fe:	e8 3a ef ff ff       	call   8010053d <panic>
      i += r;
80101603:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101606:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010160c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010160f:	0f 8c 4c ff ff ff    	jl     80101561 <filewrite+0x68>
80101615:	eb 01                	jmp    80101618 <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
80101617:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010161b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010161e:	75 05                	jne    80101625 <filewrite+0x12c>
80101620:	8b 45 10             	mov    0x10(%ebp),%eax
80101623:	eb 05                	jmp    8010162a <filewrite+0x131>
80101625:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010162a:	eb 0c                	jmp    80101638 <filewrite+0x13f>
  }
  panic("filewrite");
8010162c:	c7 04 24 b3 87 10 80 	movl   $0x801087b3,(%esp)
80101633:	e8 05 ef ff ff       	call   8010053d <panic>
}
80101638:	83 c4 24             	add    $0x24,%esp
8010163b:	5b                   	pop    %ebx
8010163c:	5d                   	pop    %ebp
8010163d:	c3                   	ret    
	...

80101640 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101640:	55                   	push   %ebp
80101641:	89 e5                	mov    %esp,%ebp
80101643:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101646:	8b 45 08             	mov    0x8(%ebp),%eax
80101649:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101650:	00 
80101651:	89 04 24             	mov    %eax,(%esp)
80101654:	e8 4d eb ff ff       	call   801001a6 <bread>
80101659:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010165c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010165f:	83 c0 18             	add    $0x18,%eax
80101662:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101669:	00 
8010166a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010166e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101671:	89 04 24             	mov    %eax,(%esp)
80101674:	e8 58 3d 00 00       	call   801053d1 <memmove>
  brelse(bp);
80101679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010167c:	89 04 24             	mov    %eax,(%esp)
8010167f:	e8 93 eb ff ff       	call   80100217 <brelse>
}
80101684:	c9                   	leave  
80101685:	c3                   	ret    

80101686 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101686:	55                   	push   %ebp
80101687:	89 e5                	mov    %esp,%ebp
80101689:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
8010168c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010168f:	8b 45 08             	mov    0x8(%ebp),%eax
80101692:	89 54 24 04          	mov    %edx,0x4(%esp)
80101696:	89 04 24             	mov    %eax,(%esp)
80101699:	e8 08 eb ff ff       	call   801001a6 <bread>
8010169e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801016a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016a4:	83 c0 18             	add    $0x18,%eax
801016a7:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801016ae:	00 
801016af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801016b6:	00 
801016b7:	89 04 24             	mov    %eax,(%esp)
801016ba:	e8 3f 3c 00 00       	call   801052fe <memset>
  log_write(bp);
801016bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016c2:	89 04 24             	mov    %eax,(%esp)
801016c5:	e8 48 1f 00 00       	call   80103612 <log_write>
  brelse(bp);
801016ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016cd:	89 04 24             	mov    %eax,(%esp)
801016d0:	e8 42 eb ff ff       	call   80100217 <brelse>
}
801016d5:	c9                   	leave  
801016d6:	c3                   	ret    

801016d7 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801016d7:	55                   	push   %ebp
801016d8:	89 e5                	mov    %esp,%ebp
801016da:	53                   	push   %ebx
801016db:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
801016de:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
801016e5:	8b 45 08             	mov    0x8(%ebp),%eax
801016e8:	8d 55 d8             	lea    -0x28(%ebp),%edx
801016eb:	89 54 24 04          	mov    %edx,0x4(%esp)
801016ef:	89 04 24             	mov    %eax,(%esp)
801016f2:	e8 49 ff ff ff       	call   80101640 <readsb>
  for(b = 0; b < sb.size; b += BPB){
801016f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801016fe:	e9 11 01 00 00       	jmp    80101814 <balloc+0x13d>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
80101703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101706:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010170c:	85 c0                	test   %eax,%eax
8010170e:	0f 48 c2             	cmovs  %edx,%eax
80101711:	c1 f8 0c             	sar    $0xc,%eax
80101714:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101717:	c1 ea 03             	shr    $0x3,%edx
8010171a:	01 d0                	add    %edx,%eax
8010171c:	83 c0 03             	add    $0x3,%eax
8010171f:	89 44 24 04          	mov    %eax,0x4(%esp)
80101723:	8b 45 08             	mov    0x8(%ebp),%eax
80101726:	89 04 24             	mov    %eax,(%esp)
80101729:	e8 78 ea ff ff       	call   801001a6 <bread>
8010172e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101731:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101738:	e9 a7 00 00 00       	jmp    801017e4 <balloc+0x10d>
      m = 1 << (bi % 8);
8010173d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101740:	89 c2                	mov    %eax,%edx
80101742:	c1 fa 1f             	sar    $0x1f,%edx
80101745:	c1 ea 1d             	shr    $0x1d,%edx
80101748:	01 d0                	add    %edx,%eax
8010174a:	83 e0 07             	and    $0x7,%eax
8010174d:	29 d0                	sub    %edx,%eax
8010174f:	ba 01 00 00 00       	mov    $0x1,%edx
80101754:	89 d3                	mov    %edx,%ebx
80101756:	89 c1                	mov    %eax,%ecx
80101758:	d3 e3                	shl    %cl,%ebx
8010175a:	89 d8                	mov    %ebx,%eax
8010175c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010175f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101762:	8d 50 07             	lea    0x7(%eax),%edx
80101765:	85 c0                	test   %eax,%eax
80101767:	0f 48 c2             	cmovs  %edx,%eax
8010176a:	c1 f8 03             	sar    $0x3,%eax
8010176d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101770:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101775:	0f b6 c0             	movzbl %al,%eax
80101778:	23 45 e8             	and    -0x18(%ebp),%eax
8010177b:	85 c0                	test   %eax,%eax
8010177d:	75 61                	jne    801017e0 <balloc+0x109>
        bp->data[bi/8] |= m;  // Mark block in use.
8010177f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101782:	8d 50 07             	lea    0x7(%eax),%edx
80101785:	85 c0                	test   %eax,%eax
80101787:	0f 48 c2             	cmovs  %edx,%eax
8010178a:	c1 f8 03             	sar    $0x3,%eax
8010178d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101790:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101795:	89 d1                	mov    %edx,%ecx
80101797:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010179a:	09 ca                	or     %ecx,%edx
8010179c:	89 d1                	mov    %edx,%ecx
8010179e:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017a1:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801017a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a8:	89 04 24             	mov    %eax,(%esp)
801017ab:	e8 62 1e 00 00       	call   80103612 <log_write>
        brelse(bp);
801017b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017b3:	89 04 24             	mov    %eax,(%esp)
801017b6:	e8 5c ea ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
801017bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017be:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017c1:	01 c2                	add    %eax,%edx
801017c3:	8b 45 08             	mov    0x8(%ebp),%eax
801017c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801017ca:	89 04 24             	mov    %eax,(%esp)
801017cd:	e8 b4 fe ff ff       	call   80101686 <bzero>
        return b + bi;
801017d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017d8:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
801017da:	83 c4 34             	add    $0x34,%esp
801017dd:	5b                   	pop    %ebx
801017de:	5d                   	pop    %ebp
801017df:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801017e0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801017e4:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801017eb:	7f 15                	jg     80101802 <balloc+0x12b>
801017ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017f3:	01 d0                	add    %edx,%eax
801017f5:	89 c2                	mov    %eax,%edx
801017f7:	8b 45 d8             	mov    -0x28(%ebp),%eax
801017fa:	39 c2                	cmp    %eax,%edx
801017fc:	0f 82 3b ff ff ff    	jb     8010173d <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101802:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101805:	89 04 24             	mov    %eax,(%esp)
80101808:	e8 0a ea ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
8010180d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101814:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101817:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010181a:	39 c2                	cmp    %eax,%edx
8010181c:	0f 82 e1 fe ff ff    	jb     80101703 <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101822:	c7 04 24 bd 87 10 80 	movl   $0x801087bd,(%esp)
80101829:	e8 0f ed ff ff       	call   8010053d <panic>

8010182e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010182e:	55                   	push   %ebp
8010182f:	89 e5                	mov    %esp,%ebp
80101831:	53                   	push   %ebx
80101832:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
80101835:	8d 45 dc             	lea    -0x24(%ebp),%eax
80101838:	89 44 24 04          	mov    %eax,0x4(%esp)
8010183c:	8b 45 08             	mov    0x8(%ebp),%eax
8010183f:	89 04 24             	mov    %eax,(%esp)
80101842:	e8 f9 fd ff ff       	call   80101640 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
80101847:	8b 45 0c             	mov    0xc(%ebp),%eax
8010184a:	89 c2                	mov    %eax,%edx
8010184c:	c1 ea 0c             	shr    $0xc,%edx
8010184f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101852:	c1 e8 03             	shr    $0x3,%eax
80101855:	01 d0                	add    %edx,%eax
80101857:	8d 50 03             	lea    0x3(%eax),%edx
8010185a:	8b 45 08             	mov    0x8(%ebp),%eax
8010185d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101861:	89 04 24             	mov    %eax,(%esp)
80101864:	e8 3d e9 ff ff       	call   801001a6 <bread>
80101869:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010186c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010186f:	25 ff 0f 00 00       	and    $0xfff,%eax
80101874:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101877:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010187a:	89 c2                	mov    %eax,%edx
8010187c:	c1 fa 1f             	sar    $0x1f,%edx
8010187f:	c1 ea 1d             	shr    $0x1d,%edx
80101882:	01 d0                	add    %edx,%eax
80101884:	83 e0 07             	and    $0x7,%eax
80101887:	29 d0                	sub    %edx,%eax
80101889:	ba 01 00 00 00       	mov    $0x1,%edx
8010188e:	89 d3                	mov    %edx,%ebx
80101890:	89 c1                	mov    %eax,%ecx
80101892:	d3 e3                	shl    %cl,%ebx
80101894:	89 d8                	mov    %ebx,%eax
80101896:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101899:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189c:	8d 50 07             	lea    0x7(%eax),%edx
8010189f:	85 c0                	test   %eax,%eax
801018a1:	0f 48 c2             	cmovs  %edx,%eax
801018a4:	c1 f8 03             	sar    $0x3,%eax
801018a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018aa:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
801018af:	0f b6 c0             	movzbl %al,%eax
801018b2:	23 45 ec             	and    -0x14(%ebp),%eax
801018b5:	85 c0                	test   %eax,%eax
801018b7:	75 0c                	jne    801018c5 <bfree+0x97>
    panic("freeing free block");
801018b9:	c7 04 24 d3 87 10 80 	movl   $0x801087d3,(%esp)
801018c0:	e8 78 ec ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
801018c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018c8:	8d 50 07             	lea    0x7(%eax),%edx
801018cb:	85 c0                	test   %eax,%eax
801018cd:	0f 48 c2             	cmovs  %edx,%eax
801018d0:	c1 f8 03             	sar    $0x3,%eax
801018d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018d6:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801018db:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801018de:	f7 d1                	not    %ecx
801018e0:	21 ca                	and    %ecx,%edx
801018e2:	89 d1                	mov    %edx,%ecx
801018e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018e7:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801018eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ee:	89 04 24             	mov    %eax,(%esp)
801018f1:	e8 1c 1d 00 00       	call   80103612 <log_write>
  brelse(bp);
801018f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f9:	89 04 24             	mov    %eax,(%esp)
801018fc:	e8 16 e9 ff ff       	call   80100217 <brelse>
}
80101901:	83 c4 34             	add    $0x34,%esp
80101904:	5b                   	pop    %ebx
80101905:	5d                   	pop    %ebp
80101906:	c3                   	ret    

80101907 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
80101907:	55                   	push   %ebp
80101908:	89 e5                	mov    %esp,%ebp
8010190a:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
8010190d:	c7 44 24 04 e6 87 10 	movl   $0x801087e6,0x4(%esp)
80101914:	80 
80101915:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
8010191c:	e8 6d 37 00 00       	call   8010508e <initlock>
}
80101921:	c9                   	leave  
80101922:	c3                   	ret    

80101923 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101923:	55                   	push   %ebp
80101924:	89 e5                	mov    %esp,%ebp
80101926:	83 ec 48             	sub    $0x48,%esp
80101929:	8b 45 0c             	mov    0xc(%ebp),%eax
8010192c:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
80101930:	8b 45 08             	mov    0x8(%ebp),%eax
80101933:	8d 55 dc             	lea    -0x24(%ebp),%edx
80101936:	89 54 24 04          	mov    %edx,0x4(%esp)
8010193a:	89 04 24             	mov    %eax,(%esp)
8010193d:	e8 fe fc ff ff       	call   80101640 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
80101942:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101949:	e9 98 00 00 00       	jmp    801019e6 <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
8010194e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101951:	c1 e8 03             	shr    $0x3,%eax
80101954:	83 c0 02             	add    $0x2,%eax
80101957:	89 44 24 04          	mov    %eax,0x4(%esp)
8010195b:	8b 45 08             	mov    0x8(%ebp),%eax
8010195e:	89 04 24             	mov    %eax,(%esp)
80101961:	e8 40 e8 ff ff       	call   801001a6 <bread>
80101966:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101969:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010196c:	8d 50 18             	lea    0x18(%eax),%edx
8010196f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101972:	83 e0 07             	and    $0x7,%eax
80101975:	c1 e0 06             	shl    $0x6,%eax
80101978:	01 d0                	add    %edx,%eax
8010197a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010197d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101980:	0f b7 00             	movzwl (%eax),%eax
80101983:	66 85 c0             	test   %ax,%ax
80101986:	75 4f                	jne    801019d7 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101988:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010198f:	00 
80101990:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101997:	00 
80101998:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010199b:	89 04 24             	mov    %eax,(%esp)
8010199e:	e8 5b 39 00 00       	call   801052fe <memset>
      dip->type = type;
801019a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801019a6:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
801019aa:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801019ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b0:	89 04 24             	mov    %eax,(%esp)
801019b3:	e8 5a 1c 00 00       	call   80103612 <log_write>
      brelse(bp);
801019b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019bb:	89 04 24             	mov    %eax,(%esp)
801019be:	e8 54 e8 ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
801019c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801019ca:	8b 45 08             	mov    0x8(%ebp),%eax
801019cd:	89 04 24             	mov    %eax,(%esp)
801019d0:	e8 e3 00 00 00       	call   80101ab8 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
801019d5:	c9                   	leave  
801019d6:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
801019d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019da:	89 04 24             	mov    %eax,(%esp)
801019dd:	e8 35 e8 ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
801019e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801019e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801019e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801019ec:	39 c2                	cmp    %eax,%edx
801019ee:	0f 82 5a ff ff ff    	jb     8010194e <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801019f4:	c7 04 24 ed 87 10 80 	movl   $0x801087ed,(%esp)
801019fb:	e8 3d eb ff ff       	call   8010053d <panic>

80101a00 <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101a00:	55                   	push   %ebp
80101a01:	89 e5                	mov    %esp,%ebp
80101a03:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
80101a06:	8b 45 08             	mov    0x8(%ebp),%eax
80101a09:	8b 40 04             	mov    0x4(%eax),%eax
80101a0c:	c1 e8 03             	shr    $0x3,%eax
80101a0f:	8d 50 02             	lea    0x2(%eax),%edx
80101a12:	8b 45 08             	mov    0x8(%ebp),%eax
80101a15:	8b 00                	mov    (%eax),%eax
80101a17:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a1b:	89 04 24             	mov    %eax,(%esp)
80101a1e:	e8 83 e7 ff ff       	call   801001a6 <bread>
80101a23:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a29:	8d 50 18             	lea    0x18(%eax),%edx
80101a2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2f:	8b 40 04             	mov    0x4(%eax),%eax
80101a32:	83 e0 07             	and    $0x7,%eax
80101a35:	c1 e0 06             	shl    $0x6,%eax
80101a38:	01 d0                	add    %edx,%eax
80101a3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101a3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a40:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101a44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a47:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101a4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4d:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101a51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a54:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101a58:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5b:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a62:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101a66:	8b 45 08             	mov    0x8(%ebp),%eax
80101a69:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a70:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101a74:	8b 45 08             	mov    0x8(%ebp),%eax
80101a77:	8b 50 18             	mov    0x18(%eax),%edx
80101a7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7d:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101a80:	8b 45 08             	mov    0x8(%ebp),%eax
80101a83:	8d 50 1c             	lea    0x1c(%eax),%edx
80101a86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a89:	83 c0 0c             	add    $0xc,%eax
80101a8c:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101a93:	00 
80101a94:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a98:	89 04 24             	mov    %eax,(%esp)
80101a9b:	e8 31 39 00 00       	call   801053d1 <memmove>
  log_write(bp);
80101aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aa3:	89 04 24             	mov    %eax,(%esp)
80101aa6:	e8 67 1b 00 00       	call   80103612 <log_write>
  brelse(bp);
80101aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aae:	89 04 24             	mov    %eax,(%esp)
80101ab1:	e8 61 e7 ff ff       	call   80100217 <brelse>
}
80101ab6:	c9                   	leave  
80101ab7:	c3                   	ret    

80101ab8 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101ab8:	55                   	push   %ebp
80101ab9:	89 e5                	mov    %esp,%ebp
80101abb:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101abe:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101ac5:	e8 e5 35 00 00       	call   801050af <acquire>

  // Is the inode already cached?
  empty = 0;
80101aca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101ad1:	c7 45 f4 b4 e8 10 80 	movl   $0x8010e8b4,-0xc(%ebp)
80101ad8:	eb 59                	jmp    80101b33 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101add:	8b 40 08             	mov    0x8(%eax),%eax
80101ae0:	85 c0                	test   %eax,%eax
80101ae2:	7e 35                	jle    80101b19 <iget+0x61>
80101ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ae7:	8b 00                	mov    (%eax),%eax
80101ae9:	3b 45 08             	cmp    0x8(%ebp),%eax
80101aec:	75 2b                	jne    80101b19 <iget+0x61>
80101aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101af1:	8b 40 04             	mov    0x4(%eax),%eax
80101af4:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101af7:	75 20                	jne    80101b19 <iget+0x61>
      ip->ref++;
80101af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101afc:	8b 40 08             	mov    0x8(%eax),%eax
80101aff:	8d 50 01             	lea    0x1(%eax),%edx
80101b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b05:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101b08:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b0f:	e8 fd 35 00 00       	call   80105111 <release>
      return ip;
80101b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b17:	eb 6f                	jmp    80101b88 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101b19:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101b1d:	75 10                	jne    80101b2f <iget+0x77>
80101b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	75 06                	jne    80101b2f <iget+0x77>
      empty = ip;
80101b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b2c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101b2f:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101b33:	81 7d f4 54 f8 10 80 	cmpl   $0x8010f854,-0xc(%ebp)
80101b3a:	72 9e                	jb     80101ada <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101b3c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101b40:	75 0c                	jne    80101b4e <iget+0x96>
    panic("iget: no inodes");
80101b42:	c7 04 24 ff 87 10 80 	movl   $0x801087ff,(%esp)
80101b49:	e8 ef e9 ff ff       	call   8010053d <panic>

  ip = empty;
80101b4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b51:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b57:	8b 55 08             	mov    0x8(%ebp),%edx
80101b5a:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b5f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b62:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b68:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b72:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101b79:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b80:	e8 8c 35 00 00       	call   80105111 <release>

  return ip;
80101b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101b88:	c9                   	leave  
80101b89:	c3                   	ret    

80101b8a <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101b8a:	55                   	push   %ebp
80101b8b:	89 e5                	mov    %esp,%ebp
80101b8d:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101b90:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b97:	e8 13 35 00 00       	call   801050af <acquire>
  ip->ref++;
80101b9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9f:	8b 40 08             	mov    0x8(%eax),%eax
80101ba2:	8d 50 01             	lea    0x1(%eax),%edx
80101ba5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba8:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bab:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101bb2:	e8 5a 35 00 00       	call   80105111 <release>
  return ip;
80101bb7:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101bba:	c9                   	leave  
80101bbb:	c3                   	ret    

80101bbc <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101bbc:	55                   	push   %ebp
80101bbd:	89 e5                	mov    %esp,%ebp
80101bbf:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101bc2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101bc6:	74 0a                	je     80101bd2 <ilock+0x16>
80101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcb:	8b 40 08             	mov    0x8(%eax),%eax
80101bce:	85 c0                	test   %eax,%eax
80101bd0:	7f 0c                	jg     80101bde <ilock+0x22>
    panic("ilock");
80101bd2:	c7 04 24 0f 88 10 80 	movl   $0x8010880f,(%esp)
80101bd9:	e8 5f e9 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101bde:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101be5:	e8 c5 34 00 00       	call   801050af <acquire>
  while(ip->flags & I_BUSY)
80101bea:	eb 13                	jmp    80101bff <ilock+0x43>
    sleep(ip, &icache.lock);
80101bec:	c7 44 24 04 80 e8 10 	movl   $0x8010e880,0x4(%esp)
80101bf3:	80 
80101bf4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf7:	89 04 24             	mov    %eax,(%esp)
80101bfa:	e8 ca 31 00 00       	call   80104dc9 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101bff:	8b 45 08             	mov    0x8(%ebp),%eax
80101c02:	8b 40 0c             	mov    0xc(%eax),%eax
80101c05:	83 e0 01             	and    $0x1,%eax
80101c08:	84 c0                	test   %al,%al
80101c0a:	75 e0                	jne    80101bec <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101c0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0f:	8b 40 0c             	mov    0xc(%eax),%eax
80101c12:	89 c2                	mov    %eax,%edx
80101c14:	83 ca 01             	or     $0x1,%edx
80101c17:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1a:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101c1d:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101c24:	e8 e8 34 00 00       	call   80105111 <release>

  if(!(ip->flags & I_VALID)){
80101c29:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2c:	8b 40 0c             	mov    0xc(%eax),%eax
80101c2f:	83 e0 02             	and    $0x2,%eax
80101c32:	85 c0                	test   %eax,%eax
80101c34:	0f 85 ce 00 00 00    	jne    80101d08 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
80101c3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3d:	8b 40 04             	mov    0x4(%eax),%eax
80101c40:	c1 e8 03             	shr    $0x3,%eax
80101c43:	8d 50 02             	lea    0x2(%eax),%edx
80101c46:	8b 45 08             	mov    0x8(%ebp),%eax
80101c49:	8b 00                	mov    (%eax),%eax
80101c4b:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c4f:	89 04 24             	mov    %eax,(%esp)
80101c52:	e8 4f e5 ff ff       	call   801001a6 <bread>
80101c57:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c5d:	8d 50 18             	lea    0x18(%eax),%edx
80101c60:	8b 45 08             	mov    0x8(%ebp),%eax
80101c63:	8b 40 04             	mov    0x4(%eax),%eax
80101c66:	83 e0 07             	and    $0x7,%eax
80101c69:	c1 e0 06             	shl    $0x6,%eax
80101c6c:	01 d0                	add    %edx,%eax
80101c6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c74:	0f b7 10             	movzwl (%eax),%edx
80101c77:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7a:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101c7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c81:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101c85:	8b 45 08             	mov    0x8(%ebp),%eax
80101c88:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101c8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c8f:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101c93:	8b 45 08             	mov    0x8(%ebp),%eax
80101c96:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101c9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c9d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101ca1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca4:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101ca8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cab:	8b 50 08             	mov    0x8(%eax),%edx
80101cae:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb1:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101cb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cb7:	8d 50 0c             	lea    0xc(%eax),%edx
80101cba:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbd:	83 c0 1c             	add    $0x1c,%eax
80101cc0:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101cc7:	00 
80101cc8:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ccc:	89 04 24             	mov    %eax,(%esp)
80101ccf:	e8 fd 36 00 00       	call   801053d1 <memmove>
    brelse(bp);
80101cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cd7:	89 04 24             	mov    %eax,(%esp)
80101cda:	e8 38 e5 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce2:	8b 40 0c             	mov    0xc(%eax),%eax
80101ce5:	89 c2                	mov    %eax,%edx
80101ce7:	83 ca 02             	or     $0x2,%edx
80101cea:	8b 45 08             	mov    0x8(%ebp),%eax
80101ced:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101cf7:	66 85 c0             	test   %ax,%ax
80101cfa:	75 0c                	jne    80101d08 <ilock+0x14c>
      panic("ilock: no type");
80101cfc:	c7 04 24 15 88 10 80 	movl   $0x80108815,(%esp)
80101d03:	e8 35 e8 ff ff       	call   8010053d <panic>
  }
}
80101d08:	c9                   	leave  
80101d09:	c3                   	ret    

80101d0a <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101d0a:	55                   	push   %ebp
80101d0b:	89 e5                	mov    %esp,%ebp
80101d0d:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101d10:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101d14:	74 17                	je     80101d2d <iunlock+0x23>
80101d16:	8b 45 08             	mov    0x8(%ebp),%eax
80101d19:	8b 40 0c             	mov    0xc(%eax),%eax
80101d1c:	83 e0 01             	and    $0x1,%eax
80101d1f:	85 c0                	test   %eax,%eax
80101d21:	74 0a                	je     80101d2d <iunlock+0x23>
80101d23:	8b 45 08             	mov    0x8(%ebp),%eax
80101d26:	8b 40 08             	mov    0x8(%eax),%eax
80101d29:	85 c0                	test   %eax,%eax
80101d2b:	7f 0c                	jg     80101d39 <iunlock+0x2f>
    panic("iunlock");
80101d2d:	c7 04 24 24 88 10 80 	movl   $0x80108824,(%esp)
80101d34:	e8 04 e8 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101d39:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d40:	e8 6a 33 00 00       	call   801050af <acquire>
  ip->flags &= ~I_BUSY;
80101d45:	8b 45 08             	mov    0x8(%ebp),%eax
80101d48:	8b 40 0c             	mov    0xc(%eax),%eax
80101d4b:	89 c2                	mov    %eax,%edx
80101d4d:	83 e2 fe             	and    $0xfffffffe,%edx
80101d50:	8b 45 08             	mov    0x8(%ebp),%eax
80101d53:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101d56:	8b 45 08             	mov    0x8(%ebp),%eax
80101d59:	89 04 24             	mov    %eax,(%esp)
80101d5c:	e8 44 31 00 00       	call   80104ea5 <wakeup>
  release(&icache.lock);
80101d61:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d68:	e8 a4 33 00 00       	call   80105111 <release>
}
80101d6d:	c9                   	leave  
80101d6e:	c3                   	ret    

80101d6f <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101d6f:	55                   	push   %ebp
80101d70:	89 e5                	mov    %esp,%ebp
80101d72:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101d75:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d7c:	e8 2e 33 00 00       	call   801050af <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101d81:	8b 45 08             	mov    0x8(%ebp),%eax
80101d84:	8b 40 08             	mov    0x8(%eax),%eax
80101d87:	83 f8 01             	cmp    $0x1,%eax
80101d8a:	0f 85 93 00 00 00    	jne    80101e23 <iput+0xb4>
80101d90:	8b 45 08             	mov    0x8(%ebp),%eax
80101d93:	8b 40 0c             	mov    0xc(%eax),%eax
80101d96:	83 e0 02             	and    $0x2,%eax
80101d99:	85 c0                	test   %eax,%eax
80101d9b:	0f 84 82 00 00 00    	je     80101e23 <iput+0xb4>
80101da1:	8b 45 08             	mov    0x8(%ebp),%eax
80101da4:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101da8:	66 85 c0             	test   %ax,%ax
80101dab:	75 76                	jne    80101e23 <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101dad:	8b 45 08             	mov    0x8(%ebp),%eax
80101db0:	8b 40 0c             	mov    0xc(%eax),%eax
80101db3:	83 e0 01             	and    $0x1,%eax
80101db6:	84 c0                	test   %al,%al
80101db8:	74 0c                	je     80101dc6 <iput+0x57>
      panic("iput busy");
80101dba:	c7 04 24 2c 88 10 80 	movl   $0x8010882c,(%esp)
80101dc1:	e8 77 e7 ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80101dc6:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc9:	8b 40 0c             	mov    0xc(%eax),%eax
80101dcc:	89 c2                	mov    %eax,%edx
80101dce:	83 ca 01             	or     $0x1,%edx
80101dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd4:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101dd7:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101dde:	e8 2e 33 00 00       	call   80105111 <release>
    itrunc(ip);
80101de3:	8b 45 08             	mov    0x8(%ebp),%eax
80101de6:	89 04 24             	mov    %eax,(%esp)
80101de9:	e8 72 01 00 00       	call   80101f60 <itrunc>
    ip->type = 0;
80101dee:	8b 45 08             	mov    0x8(%ebp),%eax
80101df1:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101df7:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfa:	89 04 24             	mov    %eax,(%esp)
80101dfd:	e8 fe fb ff ff       	call   80101a00 <iupdate>
    acquire(&icache.lock);
80101e02:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101e09:	e8 a1 32 00 00       	call   801050af <acquire>
    ip->flags = 0;
80101e0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e11:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101e18:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1b:	89 04 24             	mov    %eax,(%esp)
80101e1e:	e8 82 30 00 00       	call   80104ea5 <wakeup>
  }
  ip->ref--;
80101e23:	8b 45 08             	mov    0x8(%ebp),%eax
80101e26:	8b 40 08             	mov    0x8(%eax),%eax
80101e29:	8d 50 ff             	lea    -0x1(%eax),%edx
80101e2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2f:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101e32:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101e39:	e8 d3 32 00 00       	call   80105111 <release>
}
80101e3e:	c9                   	leave  
80101e3f:	c3                   	ret    

80101e40 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101e40:	55                   	push   %ebp
80101e41:	89 e5                	mov    %esp,%ebp
80101e43:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101e46:	8b 45 08             	mov    0x8(%ebp),%eax
80101e49:	89 04 24             	mov    %eax,(%esp)
80101e4c:	e8 b9 fe ff ff       	call   80101d0a <iunlock>
  iput(ip);
80101e51:	8b 45 08             	mov    0x8(%ebp),%eax
80101e54:	89 04 24             	mov    %eax,(%esp)
80101e57:	e8 13 ff ff ff       	call   80101d6f <iput>
}
80101e5c:	c9                   	leave  
80101e5d:	c3                   	ret    

80101e5e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101e5e:	55                   	push   %ebp
80101e5f:	89 e5                	mov    %esp,%ebp
80101e61:	53                   	push   %ebx
80101e62:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101e65:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101e69:	77 3e                	ja     80101ea9 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101e6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e71:	83 c2 04             	add    $0x4,%edx
80101e74:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e78:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e7f:	75 20                	jne    80101ea1 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101e81:	8b 45 08             	mov    0x8(%ebp),%eax
80101e84:	8b 00                	mov    (%eax),%eax
80101e86:	89 04 24             	mov    %eax,(%esp)
80101e89:	e8 49 f8 ff ff       	call   801016d7 <balloc>
80101e8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e91:	8b 45 08             	mov    0x8(%ebp),%eax
80101e94:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e97:	8d 4a 04             	lea    0x4(%edx),%ecx
80101e9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e9d:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ea4:	e9 b1 00 00 00       	jmp    80101f5a <bmap+0xfc>
  }
  bn -= NDIRECT;
80101ea9:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101ead:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101eb1:	0f 87 97 00 00 00    	ja     80101f4e <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101eb7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eba:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ebd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ec0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ec4:	75 19                	jne    80101edf <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec9:	8b 00                	mov    (%eax),%eax
80101ecb:	89 04 24             	mov    %eax,(%esp)
80101ece:	e8 04 f8 ff ff       	call   801016d7 <balloc>
80101ed3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ed6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101edc:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101edf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee2:	8b 00                	mov    (%eax),%eax
80101ee4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ee7:	89 54 24 04          	mov    %edx,0x4(%esp)
80101eeb:	89 04 24             	mov    %eax,(%esp)
80101eee:	e8 b3 e2 ff ff       	call   801001a6 <bread>
80101ef3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ef6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ef9:	83 c0 18             	add    $0x18,%eax
80101efc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101eff:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f02:	c1 e0 02             	shl    $0x2,%eax
80101f05:	03 45 ec             	add    -0x14(%ebp),%eax
80101f08:	8b 00                	mov    (%eax),%eax
80101f0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f0d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101f11:	75 2b                	jne    80101f3e <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80101f13:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f16:	c1 e0 02             	shl    $0x2,%eax
80101f19:	89 c3                	mov    %eax,%ebx
80101f1b:	03 5d ec             	add    -0x14(%ebp),%ebx
80101f1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f21:	8b 00                	mov    (%eax),%eax
80101f23:	89 04 24             	mov    %eax,(%esp)
80101f26:	e8 ac f7 ff ff       	call   801016d7 <balloc>
80101f2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f31:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101f33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f36:	89 04 24             	mov    %eax,(%esp)
80101f39:	e8 d4 16 00 00       	call   80103612 <log_write>
    }
    brelse(bp);
80101f3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f41:	89 04 24             	mov    %eax,(%esp)
80101f44:	e8 ce e2 ff ff       	call   80100217 <brelse>
    return addr;
80101f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f4c:	eb 0c                	jmp    80101f5a <bmap+0xfc>
  }

  panic("bmap: out of range");
80101f4e:	c7 04 24 36 88 10 80 	movl   $0x80108836,(%esp)
80101f55:	e8 e3 e5 ff ff       	call   8010053d <panic>
}
80101f5a:	83 c4 24             	add    $0x24,%esp
80101f5d:	5b                   	pop    %ebx
80101f5e:	5d                   	pop    %ebp
80101f5f:	c3                   	ret    

80101f60 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101f60:	55                   	push   %ebp
80101f61:	89 e5                	mov    %esp,%ebp
80101f63:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f6d:	eb 44                	jmp    80101fb3 <itrunc+0x53>
    if(ip->addrs[i]){
80101f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f75:	83 c2 04             	add    $0x4,%edx
80101f78:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f7c:	85 c0                	test   %eax,%eax
80101f7e:	74 2f                	je     80101faf <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101f80:	8b 45 08             	mov    0x8(%ebp),%eax
80101f83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f86:	83 c2 04             	add    $0x4,%edx
80101f89:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101f8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f90:	8b 00                	mov    (%eax),%eax
80101f92:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f96:	89 04 24             	mov    %eax,(%esp)
80101f99:	e8 90 f8 ff ff       	call   8010182e <bfree>
      ip->addrs[i] = 0;
80101f9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101fa4:	83 c2 04             	add    $0x4,%edx
80101fa7:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101fae:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101faf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101fb3:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101fb7:	7e b6                	jle    80101f6f <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fbc:	8b 40 4c             	mov    0x4c(%eax),%eax
80101fbf:	85 c0                	test   %eax,%eax
80101fc1:	0f 84 8f 00 00 00    	je     80102056 <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101fc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101fca:	8b 50 4c             	mov    0x4c(%eax),%edx
80101fcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd0:	8b 00                	mov    (%eax),%eax
80101fd2:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fd6:	89 04 24             	mov    %eax,(%esp)
80101fd9:	e8 c8 e1 ff ff       	call   801001a6 <bread>
80101fde:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101fe1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fe4:	83 c0 18             	add    $0x18,%eax
80101fe7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101fea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ff1:	eb 2f                	jmp    80102022 <itrunc+0xc2>
      if(a[j])
80101ff3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ff6:	c1 e0 02             	shl    $0x2,%eax
80101ff9:	03 45 e8             	add    -0x18(%ebp),%eax
80101ffc:	8b 00                	mov    (%eax),%eax
80101ffe:	85 c0                	test   %eax,%eax
80102000:	74 1c                	je     8010201e <itrunc+0xbe>
        bfree(ip->dev, a[j]);
80102002:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102005:	c1 e0 02             	shl    $0x2,%eax
80102008:	03 45 e8             	add    -0x18(%ebp),%eax
8010200b:	8b 10                	mov    (%eax),%edx
8010200d:	8b 45 08             	mov    0x8(%ebp),%eax
80102010:	8b 00                	mov    (%eax),%eax
80102012:	89 54 24 04          	mov    %edx,0x4(%esp)
80102016:	89 04 24             	mov    %eax,(%esp)
80102019:	e8 10 f8 ff ff       	call   8010182e <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
8010201e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80102022:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102025:	83 f8 7f             	cmp    $0x7f,%eax
80102028:	76 c9                	jbe    80101ff3 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
8010202a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010202d:	89 04 24             	mov    %eax,(%esp)
80102030:	e8 e2 e1 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80102035:	8b 45 08             	mov    0x8(%ebp),%eax
80102038:	8b 50 4c             	mov    0x4c(%eax),%edx
8010203b:	8b 45 08             	mov    0x8(%ebp),%eax
8010203e:	8b 00                	mov    (%eax),%eax
80102040:	89 54 24 04          	mov    %edx,0x4(%esp)
80102044:	89 04 24             	mov    %eax,(%esp)
80102047:	e8 e2 f7 ff ff       	call   8010182e <bfree>
    ip->addrs[NDIRECT] = 0;
8010204c:	8b 45 08             	mov    0x8(%ebp),%eax
8010204f:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80102056:	8b 45 08             	mov    0x8(%ebp),%eax
80102059:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80102060:	8b 45 08             	mov    0x8(%ebp),%eax
80102063:	89 04 24             	mov    %eax,(%esp)
80102066:	e8 95 f9 ff ff       	call   80101a00 <iupdate>
}
8010206b:	c9                   	leave  
8010206c:	c3                   	ret    

8010206d <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
8010206d:	55                   	push   %ebp
8010206e:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80102070:	8b 45 08             	mov    0x8(%ebp),%eax
80102073:	8b 00                	mov    (%eax),%eax
80102075:	89 c2                	mov    %eax,%edx
80102077:	8b 45 0c             	mov    0xc(%ebp),%eax
8010207a:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
8010207d:	8b 45 08             	mov    0x8(%ebp),%eax
80102080:	8b 50 04             	mov    0x4(%eax),%edx
80102083:	8b 45 0c             	mov    0xc(%ebp),%eax
80102086:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102089:	8b 45 08             	mov    0x8(%ebp),%eax
8010208c:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80102090:	8b 45 0c             	mov    0xc(%ebp),%eax
80102093:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80102096:	8b 45 08             	mov    0x8(%ebp),%eax
80102099:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010209d:	8b 45 0c             	mov    0xc(%ebp),%eax
801020a0:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
801020a4:	8b 45 08             	mov    0x8(%ebp),%eax
801020a7:	8b 50 18             	mov    0x18(%eax),%edx
801020aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801020ad:	89 50 10             	mov    %edx,0x10(%eax)
}
801020b0:	5d                   	pop    %ebp
801020b1:	c3                   	ret    

801020b2 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
801020b2:	55                   	push   %ebp
801020b3:	89 e5                	mov    %esp,%ebp
801020b5:	53                   	push   %ebx
801020b6:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020b9:	8b 45 08             	mov    0x8(%ebp),%eax
801020bc:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020c0:	66 83 f8 03          	cmp    $0x3,%ax
801020c4:	75 60                	jne    80102126 <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801020c6:	8b 45 08             	mov    0x8(%ebp),%eax
801020c9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020cd:	66 85 c0             	test   %ax,%ax
801020d0:	78 20                	js     801020f2 <readi+0x40>
801020d2:	8b 45 08             	mov    0x8(%ebp),%eax
801020d5:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020d9:	66 83 f8 09          	cmp    $0x9,%ax
801020dd:	7f 13                	jg     801020f2 <readi+0x40>
801020df:	8b 45 08             	mov    0x8(%ebp),%eax
801020e2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020e6:	98                   	cwtl   
801020e7:	8b 04 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%eax
801020ee:	85 c0                	test   %eax,%eax
801020f0:	75 0a                	jne    801020fc <readi+0x4a>
      return -1;
801020f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020f7:	e9 1b 01 00 00       	jmp    80102217 <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
801020fc:	8b 45 08             	mov    0x8(%ebp),%eax
801020ff:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102103:	98                   	cwtl   
80102104:	8b 14 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%edx
8010210b:	8b 45 14             	mov    0x14(%ebp),%eax
8010210e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102112:	8b 45 0c             	mov    0xc(%ebp),%eax
80102115:	89 44 24 04          	mov    %eax,0x4(%esp)
80102119:	8b 45 08             	mov    0x8(%ebp),%eax
8010211c:	89 04 24             	mov    %eax,(%esp)
8010211f:	ff d2                	call   *%edx
80102121:	e9 f1 00 00 00       	jmp    80102217 <readi+0x165>
  }

  if(off > ip->size || off + n < off)
80102126:	8b 45 08             	mov    0x8(%ebp),%eax
80102129:	8b 40 18             	mov    0x18(%eax),%eax
8010212c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010212f:	72 0d                	jb     8010213e <readi+0x8c>
80102131:	8b 45 14             	mov    0x14(%ebp),%eax
80102134:	8b 55 10             	mov    0x10(%ebp),%edx
80102137:	01 d0                	add    %edx,%eax
80102139:	3b 45 10             	cmp    0x10(%ebp),%eax
8010213c:	73 0a                	jae    80102148 <readi+0x96>
    return -1;
8010213e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102143:	e9 cf 00 00 00       	jmp    80102217 <readi+0x165>
  if(off + n > ip->size)
80102148:	8b 45 14             	mov    0x14(%ebp),%eax
8010214b:	8b 55 10             	mov    0x10(%ebp),%edx
8010214e:	01 c2                	add    %eax,%edx
80102150:	8b 45 08             	mov    0x8(%ebp),%eax
80102153:	8b 40 18             	mov    0x18(%eax),%eax
80102156:	39 c2                	cmp    %eax,%edx
80102158:	76 0c                	jbe    80102166 <readi+0xb4>
    n = ip->size - off;
8010215a:	8b 45 08             	mov    0x8(%ebp),%eax
8010215d:	8b 40 18             	mov    0x18(%eax),%eax
80102160:	2b 45 10             	sub    0x10(%ebp),%eax
80102163:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102166:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010216d:	e9 96 00 00 00       	jmp    80102208 <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102172:	8b 45 10             	mov    0x10(%ebp),%eax
80102175:	c1 e8 09             	shr    $0x9,%eax
80102178:	89 44 24 04          	mov    %eax,0x4(%esp)
8010217c:	8b 45 08             	mov    0x8(%ebp),%eax
8010217f:	89 04 24             	mov    %eax,(%esp)
80102182:	e8 d7 fc ff ff       	call   80101e5e <bmap>
80102187:	8b 55 08             	mov    0x8(%ebp),%edx
8010218a:	8b 12                	mov    (%edx),%edx
8010218c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102190:	89 14 24             	mov    %edx,(%esp)
80102193:	e8 0e e0 ff ff       	call   801001a6 <bread>
80102198:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010219b:	8b 45 10             	mov    0x10(%ebp),%eax
8010219e:	89 c2                	mov    %eax,%edx
801021a0:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801021a6:	b8 00 02 00 00       	mov    $0x200,%eax
801021ab:	89 c1                	mov    %eax,%ecx
801021ad:	29 d1                	sub    %edx,%ecx
801021af:	89 ca                	mov    %ecx,%edx
801021b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021b4:	8b 4d 14             	mov    0x14(%ebp),%ecx
801021b7:	89 cb                	mov    %ecx,%ebx
801021b9:	29 c3                	sub    %eax,%ebx
801021bb:	89 d8                	mov    %ebx,%eax
801021bd:	39 c2                	cmp    %eax,%edx
801021bf:	0f 46 c2             	cmovbe %edx,%eax
801021c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801021c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021c8:	8d 50 18             	lea    0x18(%eax),%edx
801021cb:	8b 45 10             	mov    0x10(%ebp),%eax
801021ce:	25 ff 01 00 00       	and    $0x1ff,%eax
801021d3:	01 c2                	add    %eax,%edx
801021d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021d8:	89 44 24 08          	mov    %eax,0x8(%esp)
801021dc:	89 54 24 04          	mov    %edx,0x4(%esp)
801021e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801021e3:	89 04 24             	mov    %eax,(%esp)
801021e6:	e8 e6 31 00 00       	call   801053d1 <memmove>
    brelse(bp);
801021eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021ee:	89 04 24             	mov    %eax,(%esp)
801021f1:	e8 21 e0 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801021f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021f9:	01 45 f4             	add    %eax,-0xc(%ebp)
801021fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021ff:	01 45 10             	add    %eax,0x10(%ebp)
80102202:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102205:	01 45 0c             	add    %eax,0xc(%ebp)
80102208:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010220b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010220e:	0f 82 5e ff ff ff    	jb     80102172 <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102214:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102217:	83 c4 24             	add    $0x24,%esp
8010221a:	5b                   	pop    %ebx
8010221b:	5d                   	pop    %ebp
8010221c:	c3                   	ret    

8010221d <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010221d:	55                   	push   %ebp
8010221e:	89 e5                	mov    %esp,%ebp
80102220:	53                   	push   %ebx
80102221:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102224:	8b 45 08             	mov    0x8(%ebp),%eax
80102227:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010222b:	66 83 f8 03          	cmp    $0x3,%ax
8010222f:	75 60                	jne    80102291 <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102231:	8b 45 08             	mov    0x8(%ebp),%eax
80102234:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102238:	66 85 c0             	test   %ax,%ax
8010223b:	78 20                	js     8010225d <writei+0x40>
8010223d:	8b 45 08             	mov    0x8(%ebp),%eax
80102240:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102244:	66 83 f8 09          	cmp    $0x9,%ax
80102248:	7f 13                	jg     8010225d <writei+0x40>
8010224a:	8b 45 08             	mov    0x8(%ebp),%eax
8010224d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102251:	98                   	cwtl   
80102252:	8b 04 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%eax
80102259:	85 c0                	test   %eax,%eax
8010225b:	75 0a                	jne    80102267 <writei+0x4a>
      return -1;
8010225d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102262:	e9 46 01 00 00       	jmp    801023ad <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
80102267:	8b 45 08             	mov    0x8(%ebp),%eax
8010226a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010226e:	98                   	cwtl   
8010226f:	8b 14 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%edx
80102276:	8b 45 14             	mov    0x14(%ebp),%eax
80102279:	89 44 24 08          	mov    %eax,0x8(%esp)
8010227d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102280:	89 44 24 04          	mov    %eax,0x4(%esp)
80102284:	8b 45 08             	mov    0x8(%ebp),%eax
80102287:	89 04 24             	mov    %eax,(%esp)
8010228a:	ff d2                	call   *%edx
8010228c:	e9 1c 01 00 00       	jmp    801023ad <writei+0x190>
  }

  if(off > ip->size || off + n < off)
80102291:	8b 45 08             	mov    0x8(%ebp),%eax
80102294:	8b 40 18             	mov    0x18(%eax),%eax
80102297:	3b 45 10             	cmp    0x10(%ebp),%eax
8010229a:	72 0d                	jb     801022a9 <writei+0x8c>
8010229c:	8b 45 14             	mov    0x14(%ebp),%eax
8010229f:	8b 55 10             	mov    0x10(%ebp),%edx
801022a2:	01 d0                	add    %edx,%eax
801022a4:	3b 45 10             	cmp    0x10(%ebp),%eax
801022a7:	73 0a                	jae    801022b3 <writei+0x96>
    return -1;
801022a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022ae:	e9 fa 00 00 00       	jmp    801023ad <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
801022b3:	8b 45 14             	mov    0x14(%ebp),%eax
801022b6:	8b 55 10             	mov    0x10(%ebp),%edx
801022b9:	01 d0                	add    %edx,%eax
801022bb:	3d 00 18 01 00       	cmp    $0x11800,%eax
801022c0:	76 0a                	jbe    801022cc <writei+0xaf>
    return -1;
801022c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022c7:	e9 e1 00 00 00       	jmp    801023ad <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022d3:	e9 a1 00 00 00       	jmp    80102379 <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801022d8:	8b 45 10             	mov    0x10(%ebp),%eax
801022db:	c1 e8 09             	shr    $0x9,%eax
801022de:	89 44 24 04          	mov    %eax,0x4(%esp)
801022e2:	8b 45 08             	mov    0x8(%ebp),%eax
801022e5:	89 04 24             	mov    %eax,(%esp)
801022e8:	e8 71 fb ff ff       	call   80101e5e <bmap>
801022ed:	8b 55 08             	mov    0x8(%ebp),%edx
801022f0:	8b 12                	mov    (%edx),%edx
801022f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801022f6:	89 14 24             	mov    %edx,(%esp)
801022f9:	e8 a8 de ff ff       	call   801001a6 <bread>
801022fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102301:	8b 45 10             	mov    0x10(%ebp),%eax
80102304:	89 c2                	mov    %eax,%edx
80102306:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
8010230c:	b8 00 02 00 00       	mov    $0x200,%eax
80102311:	89 c1                	mov    %eax,%ecx
80102313:	29 d1                	sub    %edx,%ecx
80102315:	89 ca                	mov    %ecx,%edx
80102317:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010231a:	8b 4d 14             	mov    0x14(%ebp),%ecx
8010231d:	89 cb                	mov    %ecx,%ebx
8010231f:	29 c3                	sub    %eax,%ebx
80102321:	89 d8                	mov    %ebx,%eax
80102323:	39 c2                	cmp    %eax,%edx
80102325:	0f 46 c2             	cmovbe %edx,%eax
80102328:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010232b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010232e:	8d 50 18             	lea    0x18(%eax),%edx
80102331:	8b 45 10             	mov    0x10(%ebp),%eax
80102334:	25 ff 01 00 00       	and    $0x1ff,%eax
80102339:	01 c2                	add    %eax,%edx
8010233b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010233e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102342:	8b 45 0c             	mov    0xc(%ebp),%eax
80102345:	89 44 24 04          	mov    %eax,0x4(%esp)
80102349:	89 14 24             	mov    %edx,(%esp)
8010234c:	e8 80 30 00 00       	call   801053d1 <memmove>
    log_write(bp);
80102351:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102354:	89 04 24             	mov    %eax,(%esp)
80102357:	e8 b6 12 00 00       	call   80103612 <log_write>
    brelse(bp);
8010235c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010235f:	89 04 24             	mov    %eax,(%esp)
80102362:	e8 b0 de ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102367:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010236a:	01 45 f4             	add    %eax,-0xc(%ebp)
8010236d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102370:	01 45 10             	add    %eax,0x10(%ebp)
80102373:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102376:	01 45 0c             	add    %eax,0xc(%ebp)
80102379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010237c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010237f:	0f 82 53 ff ff ff    	jb     801022d8 <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102385:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102389:	74 1f                	je     801023aa <writei+0x18d>
8010238b:	8b 45 08             	mov    0x8(%ebp),%eax
8010238e:	8b 40 18             	mov    0x18(%eax),%eax
80102391:	3b 45 10             	cmp    0x10(%ebp),%eax
80102394:	73 14                	jae    801023aa <writei+0x18d>
    ip->size = off;
80102396:	8b 45 08             	mov    0x8(%ebp),%eax
80102399:	8b 55 10             	mov    0x10(%ebp),%edx
8010239c:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010239f:	8b 45 08             	mov    0x8(%ebp),%eax
801023a2:	89 04 24             	mov    %eax,(%esp)
801023a5:	e8 56 f6 ff ff       	call   80101a00 <iupdate>
  }
  return n;
801023aa:	8b 45 14             	mov    0x14(%ebp),%eax
}
801023ad:	83 c4 24             	add    $0x24,%esp
801023b0:	5b                   	pop    %ebx
801023b1:	5d                   	pop    %ebp
801023b2:	c3                   	ret    

801023b3 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801023b3:	55                   	push   %ebp
801023b4:	89 e5                	mov    %esp,%ebp
801023b6:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801023b9:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801023c0:	00 
801023c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801023c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801023c8:	8b 45 08             	mov    0x8(%ebp),%eax
801023cb:	89 04 24             	mov    %eax,(%esp)
801023ce:	e8 a2 30 00 00       	call   80105475 <strncmp>
}
801023d3:	c9                   	leave  
801023d4:	c3                   	ret    

801023d5 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801023d5:	55                   	push   %ebp
801023d6:	89 e5                	mov    %esp,%ebp
801023d8:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801023db:	8b 45 08             	mov    0x8(%ebp),%eax
801023de:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023e2:	66 83 f8 01          	cmp    $0x1,%ax
801023e6:	74 0c                	je     801023f4 <dirlookup+0x1f>
    panic("dirlookup not DIR");
801023e8:	c7 04 24 49 88 10 80 	movl   $0x80108849,(%esp)
801023ef:	e8 49 e1 ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801023f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023fb:	e9 87 00 00 00       	jmp    80102487 <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102400:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102407:	00 
80102408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010240b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010240f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102412:	89 44 24 04          	mov    %eax,0x4(%esp)
80102416:	8b 45 08             	mov    0x8(%ebp),%eax
80102419:	89 04 24             	mov    %eax,(%esp)
8010241c:	e8 91 fc ff ff       	call   801020b2 <readi>
80102421:	83 f8 10             	cmp    $0x10,%eax
80102424:	74 0c                	je     80102432 <dirlookup+0x5d>
      panic("dirlink read");
80102426:	c7 04 24 5b 88 10 80 	movl   $0x8010885b,(%esp)
8010242d:	e8 0b e1 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
80102432:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102436:	66 85 c0             	test   %ax,%ax
80102439:	74 47                	je     80102482 <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
8010243b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010243e:	83 c0 02             	add    $0x2,%eax
80102441:	89 44 24 04          	mov    %eax,0x4(%esp)
80102445:	8b 45 0c             	mov    0xc(%ebp),%eax
80102448:	89 04 24             	mov    %eax,(%esp)
8010244b:	e8 63 ff ff ff       	call   801023b3 <namecmp>
80102450:	85 c0                	test   %eax,%eax
80102452:	75 2f                	jne    80102483 <dirlookup+0xae>
      // entry matches path element
      if(poff)
80102454:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102458:	74 08                	je     80102462 <dirlookup+0x8d>
        *poff = off;
8010245a:	8b 45 10             	mov    0x10(%ebp),%eax
8010245d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102460:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102462:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102466:	0f b7 c0             	movzwl %ax,%eax
80102469:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010246c:	8b 45 08             	mov    0x8(%ebp),%eax
8010246f:	8b 00                	mov    (%eax),%eax
80102471:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102474:	89 54 24 04          	mov    %edx,0x4(%esp)
80102478:	89 04 24             	mov    %eax,(%esp)
8010247b:	e8 38 f6 ff ff       	call   80101ab8 <iget>
80102480:	eb 19                	jmp    8010249b <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102482:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102483:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102487:	8b 45 08             	mov    0x8(%ebp),%eax
8010248a:	8b 40 18             	mov    0x18(%eax),%eax
8010248d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102490:	0f 87 6a ff ff ff    	ja     80102400 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102496:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010249b:	c9                   	leave  
8010249c:	c3                   	ret    

8010249d <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010249d:	55                   	push   %ebp
8010249e:	89 e5                	mov    %esp,%ebp
801024a0:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801024a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801024aa:	00 
801024ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801024ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801024b2:	8b 45 08             	mov    0x8(%ebp),%eax
801024b5:	89 04 24             	mov    %eax,(%esp)
801024b8:	e8 18 ff ff ff       	call   801023d5 <dirlookup>
801024bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024c4:	74 15                	je     801024db <dirlink+0x3e>
    iput(ip);
801024c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024c9:	89 04 24             	mov    %eax,(%esp)
801024cc:	e8 9e f8 ff ff       	call   80101d6f <iput>
    return -1;
801024d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801024d6:	e9 b8 00 00 00       	jmp    80102593 <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801024db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801024e2:	eb 44                	jmp    80102528 <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024e7:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801024ee:	00 
801024ef:	89 44 24 08          	mov    %eax,0x8(%esp)
801024f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801024fa:	8b 45 08             	mov    0x8(%ebp),%eax
801024fd:	89 04 24             	mov    %eax,(%esp)
80102500:	e8 ad fb ff ff       	call   801020b2 <readi>
80102505:	83 f8 10             	cmp    $0x10,%eax
80102508:	74 0c                	je     80102516 <dirlink+0x79>
      panic("dirlink read");
8010250a:	c7 04 24 5b 88 10 80 	movl   $0x8010885b,(%esp)
80102511:	e8 27 e0 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
80102516:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010251a:	66 85 c0             	test   %ax,%ax
8010251d:	74 18                	je     80102537 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010251f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102522:	83 c0 10             	add    $0x10,%eax
80102525:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102528:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010252b:	8b 45 08             	mov    0x8(%ebp),%eax
8010252e:	8b 40 18             	mov    0x18(%eax),%eax
80102531:	39 c2                	cmp    %eax,%edx
80102533:	72 af                	jb     801024e4 <dirlink+0x47>
80102535:	eb 01                	jmp    80102538 <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102537:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102538:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010253f:	00 
80102540:	8b 45 0c             	mov    0xc(%ebp),%eax
80102543:	89 44 24 04          	mov    %eax,0x4(%esp)
80102547:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010254a:	83 c0 02             	add    $0x2,%eax
8010254d:	89 04 24             	mov    %eax,(%esp)
80102550:	e8 78 2f 00 00       	call   801054cd <strncpy>
  de.inum = inum;
80102555:	8b 45 10             	mov    0x10(%ebp),%eax
80102558:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010255c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010255f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102566:	00 
80102567:	89 44 24 08          	mov    %eax,0x8(%esp)
8010256b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010256e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102572:	8b 45 08             	mov    0x8(%ebp),%eax
80102575:	89 04 24             	mov    %eax,(%esp)
80102578:	e8 a0 fc ff ff       	call   8010221d <writei>
8010257d:	83 f8 10             	cmp    $0x10,%eax
80102580:	74 0c                	je     8010258e <dirlink+0xf1>
    panic("dirlink");
80102582:	c7 04 24 68 88 10 80 	movl   $0x80108868,(%esp)
80102589:	e8 af df ff ff       	call   8010053d <panic>
  
  return 0;
8010258e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102593:	c9                   	leave  
80102594:	c3                   	ret    

80102595 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102595:	55                   	push   %ebp
80102596:	89 e5                	mov    %esp,%ebp
80102598:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010259b:	eb 04                	jmp    801025a1 <skipelem+0xc>
    path++;
8010259d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801025a1:	8b 45 08             	mov    0x8(%ebp),%eax
801025a4:	0f b6 00             	movzbl (%eax),%eax
801025a7:	3c 2f                	cmp    $0x2f,%al
801025a9:	74 f2                	je     8010259d <skipelem+0x8>
    path++;
  if(*path == 0)
801025ab:	8b 45 08             	mov    0x8(%ebp),%eax
801025ae:	0f b6 00             	movzbl (%eax),%eax
801025b1:	84 c0                	test   %al,%al
801025b3:	75 0a                	jne    801025bf <skipelem+0x2a>
    return 0;
801025b5:	b8 00 00 00 00       	mov    $0x0,%eax
801025ba:	e9 86 00 00 00       	jmp    80102645 <skipelem+0xb0>
  s = path;
801025bf:	8b 45 08             	mov    0x8(%ebp),%eax
801025c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801025c5:	eb 04                	jmp    801025cb <skipelem+0x36>
    path++;
801025c7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801025cb:	8b 45 08             	mov    0x8(%ebp),%eax
801025ce:	0f b6 00             	movzbl (%eax),%eax
801025d1:	3c 2f                	cmp    $0x2f,%al
801025d3:	74 0a                	je     801025df <skipelem+0x4a>
801025d5:	8b 45 08             	mov    0x8(%ebp),%eax
801025d8:	0f b6 00             	movzbl (%eax),%eax
801025db:	84 c0                	test   %al,%al
801025dd:	75 e8                	jne    801025c7 <skipelem+0x32>
    path++;
  len = path - s;
801025df:	8b 55 08             	mov    0x8(%ebp),%edx
801025e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e5:	89 d1                	mov    %edx,%ecx
801025e7:	29 c1                	sub    %eax,%ecx
801025e9:	89 c8                	mov    %ecx,%eax
801025eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801025ee:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801025f2:	7e 1c                	jle    80102610 <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
801025f4:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801025fb:	00 
801025fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80102603:	8b 45 0c             	mov    0xc(%ebp),%eax
80102606:	89 04 24             	mov    %eax,(%esp)
80102609:	e8 c3 2d 00 00       	call   801053d1 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010260e:	eb 28                	jmp    80102638 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102610:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102613:	89 44 24 08          	mov    %eax,0x8(%esp)
80102617:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010261a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010261e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102621:	89 04 24             	mov    %eax,(%esp)
80102624:	e8 a8 2d 00 00       	call   801053d1 <memmove>
    name[len] = 0;
80102629:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010262c:	03 45 0c             	add    0xc(%ebp),%eax
8010262f:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102632:	eb 04                	jmp    80102638 <skipelem+0xa3>
    path++;
80102634:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102638:	8b 45 08             	mov    0x8(%ebp),%eax
8010263b:	0f b6 00             	movzbl (%eax),%eax
8010263e:	3c 2f                	cmp    $0x2f,%al
80102640:	74 f2                	je     80102634 <skipelem+0x9f>
    path++;
  return path;
80102642:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102645:	c9                   	leave  
80102646:	c3                   	ret    

80102647 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102647:	55                   	push   %ebp
80102648:	89 e5                	mov    %esp,%ebp
8010264a:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010264d:	8b 45 08             	mov    0x8(%ebp),%eax
80102650:	0f b6 00             	movzbl (%eax),%eax
80102653:	3c 2f                	cmp    $0x2f,%al
80102655:	75 1c                	jne    80102673 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
80102657:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010265e:	00 
8010265f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102666:	e8 4d f4 ff ff       	call   80101ab8 <iget>
8010266b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
8010266e:	e9 af 00 00 00       	jmp    80102722 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102673:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102679:	8b 40 68             	mov    0x68(%eax),%eax
8010267c:	89 04 24             	mov    %eax,(%esp)
8010267f:	e8 06 f5 ff ff       	call   80101b8a <idup>
80102684:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102687:	e9 96 00 00 00       	jmp    80102722 <namex+0xdb>
    ilock(ip);
8010268c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010268f:	89 04 24             	mov    %eax,(%esp)
80102692:	e8 25 f5 ff ff       	call   80101bbc <ilock>
    if(ip->type != T_DIR){
80102697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010269a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010269e:	66 83 f8 01          	cmp    $0x1,%ax
801026a2:	74 15                	je     801026b9 <namex+0x72>
      iunlockput(ip);
801026a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026a7:	89 04 24             	mov    %eax,(%esp)
801026aa:	e8 91 f7 ff ff       	call   80101e40 <iunlockput>
      return 0;
801026af:	b8 00 00 00 00       	mov    $0x0,%eax
801026b4:	e9 a3 00 00 00       	jmp    8010275c <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
801026b9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801026bd:	74 1d                	je     801026dc <namex+0x95>
801026bf:	8b 45 08             	mov    0x8(%ebp),%eax
801026c2:	0f b6 00             	movzbl (%eax),%eax
801026c5:	84 c0                	test   %al,%al
801026c7:	75 13                	jne    801026dc <namex+0x95>
      // Stop one level early.
      iunlock(ip);
801026c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026cc:	89 04 24             	mov    %eax,(%esp)
801026cf:	e8 36 f6 ff ff       	call   80101d0a <iunlock>
      return ip;
801026d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d7:	e9 80 00 00 00       	jmp    8010275c <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801026dc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801026e3:	00 
801026e4:	8b 45 10             	mov    0x10(%ebp),%eax
801026e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801026eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026ee:	89 04 24             	mov    %eax,(%esp)
801026f1:	e8 df fc ff ff       	call   801023d5 <dirlookup>
801026f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801026f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801026fd:	75 12                	jne    80102711 <namex+0xca>
      iunlockput(ip);
801026ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102702:	89 04 24             	mov    %eax,(%esp)
80102705:	e8 36 f7 ff ff       	call   80101e40 <iunlockput>
      return 0;
8010270a:	b8 00 00 00 00       	mov    $0x0,%eax
8010270f:	eb 4b                	jmp    8010275c <namex+0x115>
    }
    iunlockput(ip);
80102711:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102714:	89 04 24             	mov    %eax,(%esp)
80102717:	e8 24 f7 ff ff       	call   80101e40 <iunlockput>
    ip = next;
8010271c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010271f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102722:	8b 45 10             	mov    0x10(%ebp),%eax
80102725:	89 44 24 04          	mov    %eax,0x4(%esp)
80102729:	8b 45 08             	mov    0x8(%ebp),%eax
8010272c:	89 04 24             	mov    %eax,(%esp)
8010272f:	e8 61 fe ff ff       	call   80102595 <skipelem>
80102734:	89 45 08             	mov    %eax,0x8(%ebp)
80102737:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010273b:	0f 85 4b ff ff ff    	jne    8010268c <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102741:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102745:	74 12                	je     80102759 <namex+0x112>
    iput(ip);
80102747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010274a:	89 04 24             	mov    %eax,(%esp)
8010274d:	e8 1d f6 ff ff       	call   80101d6f <iput>
    return 0;
80102752:	b8 00 00 00 00       	mov    $0x0,%eax
80102757:	eb 03                	jmp    8010275c <namex+0x115>
  }
  return ip;
80102759:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010275c:	c9                   	leave  
8010275d:	c3                   	ret    

8010275e <namei>:

struct inode*
namei(char *path)
{
8010275e:	55                   	push   %ebp
8010275f:	89 e5                	mov    %esp,%ebp
80102761:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102764:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102767:	89 44 24 08          	mov    %eax,0x8(%esp)
8010276b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102772:	00 
80102773:	8b 45 08             	mov    0x8(%ebp),%eax
80102776:	89 04 24             	mov    %eax,(%esp)
80102779:	e8 c9 fe ff ff       	call   80102647 <namex>
}
8010277e:	c9                   	leave  
8010277f:	c3                   	ret    

80102780 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102780:	55                   	push   %ebp
80102781:	89 e5                	mov    %esp,%ebp
80102783:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102786:	8b 45 0c             	mov    0xc(%ebp),%eax
80102789:	89 44 24 08          	mov    %eax,0x8(%esp)
8010278d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102794:	00 
80102795:	8b 45 08             	mov    0x8(%ebp),%eax
80102798:	89 04 24             	mov    %eax,(%esp)
8010279b:	e8 a7 fe ff ff       	call   80102647 <namex>
}
801027a0:	c9                   	leave  
801027a1:	c3                   	ret    
	...

801027a4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801027a4:	55                   	push   %ebp
801027a5:	89 e5                	mov    %esp,%ebp
801027a7:	53                   	push   %ebx
801027a8:	83 ec 14             	sub    $0x14,%esp
801027ab:	8b 45 08             	mov    0x8(%ebp),%eax
801027ae:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801027b2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801027b6:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801027ba:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801027be:	ec                   	in     (%dx),%al
801027bf:	89 c3                	mov    %eax,%ebx
801027c1:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801027c4:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801027c8:	83 c4 14             	add    $0x14,%esp
801027cb:	5b                   	pop    %ebx
801027cc:	5d                   	pop    %ebp
801027cd:	c3                   	ret    

801027ce <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801027ce:	55                   	push   %ebp
801027cf:	89 e5                	mov    %esp,%ebp
801027d1:	57                   	push   %edi
801027d2:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801027d3:	8b 55 08             	mov    0x8(%ebp),%edx
801027d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801027d9:	8b 45 10             	mov    0x10(%ebp),%eax
801027dc:	89 cb                	mov    %ecx,%ebx
801027de:	89 df                	mov    %ebx,%edi
801027e0:	89 c1                	mov    %eax,%ecx
801027e2:	fc                   	cld    
801027e3:	f3 6d                	rep insl (%dx),%es:(%edi)
801027e5:	89 c8                	mov    %ecx,%eax
801027e7:	89 fb                	mov    %edi,%ebx
801027e9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801027ec:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801027ef:	5b                   	pop    %ebx
801027f0:	5f                   	pop    %edi
801027f1:	5d                   	pop    %ebp
801027f2:	c3                   	ret    

801027f3 <outb>:

static inline void
outb(ushort port, uchar data)
{
801027f3:	55                   	push   %ebp
801027f4:	89 e5                	mov    %esp,%ebp
801027f6:	83 ec 08             	sub    $0x8,%esp
801027f9:	8b 55 08             	mov    0x8(%ebp),%edx
801027fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801027ff:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102803:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102806:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010280a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010280e:	ee                   	out    %al,(%dx)
}
8010280f:	c9                   	leave  
80102810:	c3                   	ret    

80102811 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102811:	55                   	push   %ebp
80102812:	89 e5                	mov    %esp,%ebp
80102814:	56                   	push   %esi
80102815:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102816:	8b 55 08             	mov    0x8(%ebp),%edx
80102819:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010281c:	8b 45 10             	mov    0x10(%ebp),%eax
8010281f:	89 cb                	mov    %ecx,%ebx
80102821:	89 de                	mov    %ebx,%esi
80102823:	89 c1                	mov    %eax,%ecx
80102825:	fc                   	cld    
80102826:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102828:	89 c8                	mov    %ecx,%eax
8010282a:	89 f3                	mov    %esi,%ebx
8010282c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010282f:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102832:	5b                   	pop    %ebx
80102833:	5e                   	pop    %esi
80102834:	5d                   	pop    %ebp
80102835:	c3                   	ret    

80102836 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102836:	55                   	push   %ebp
80102837:	89 e5                	mov    %esp,%ebp
80102839:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
8010283c:	90                   	nop
8010283d:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102844:	e8 5b ff ff ff       	call   801027a4 <inb>
80102849:	0f b6 c0             	movzbl %al,%eax
8010284c:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010284f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102852:	25 c0 00 00 00       	and    $0xc0,%eax
80102857:	83 f8 40             	cmp    $0x40,%eax
8010285a:	75 e1                	jne    8010283d <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010285c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102860:	74 11                	je     80102873 <idewait+0x3d>
80102862:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102865:	83 e0 21             	and    $0x21,%eax
80102868:	85 c0                	test   %eax,%eax
8010286a:	74 07                	je     80102873 <idewait+0x3d>
    return -1;
8010286c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102871:	eb 05                	jmp    80102878 <idewait+0x42>
  return 0;
80102873:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102878:	c9                   	leave  
80102879:	c3                   	ret    

8010287a <ideinit>:

void
ideinit(void)
{
8010287a:	55                   	push   %ebp
8010287b:	89 e5                	mov    %esp,%ebp
8010287d:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102880:	c7 44 24 04 70 88 10 	movl   $0x80108870,0x4(%esp)
80102887:	80 
80102888:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010288f:	e8 fa 27 00 00       	call   8010508e <initlock>
  picenable(IRQ_IDE);
80102894:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010289b:	e8 75 15 00 00       	call   80103e15 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
801028a0:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
801028a5:	83 e8 01             	sub    $0x1,%eax
801028a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801028ac:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801028b3:	e8 12 04 00 00       	call   80102cca <ioapicenable>
  idewait(0);
801028b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028bf:	e8 72 ff ff ff       	call   80102836 <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801028c4:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801028cb:	00 
801028cc:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028d3:	e8 1b ff ff ff       	call   801027f3 <outb>
  for(i=0; i<1000; i++){
801028d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801028df:	eb 20                	jmp    80102901 <ideinit+0x87>
    if(inb(0x1f7) != 0){
801028e1:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801028e8:	e8 b7 fe ff ff       	call   801027a4 <inb>
801028ed:	84 c0                	test   %al,%al
801028ef:	74 0c                	je     801028fd <ideinit+0x83>
      havedisk1 = 1;
801028f1:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
801028f8:	00 00 00 
      break;
801028fb:	eb 0d                	jmp    8010290a <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801028fd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102901:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102908:	7e d7                	jle    801028e1 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010290a:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102911:	00 
80102912:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102919:	e8 d5 fe ff ff       	call   801027f3 <outb>
}
8010291e:	c9                   	leave  
8010291f:	c3                   	ret    

80102920 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102920:	55                   	push   %ebp
80102921:	89 e5                	mov    %esp,%ebp
80102923:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102926:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010292a:	75 0c                	jne    80102938 <idestart+0x18>
    panic("idestart");
8010292c:	c7 04 24 74 88 10 80 	movl   $0x80108874,(%esp)
80102933:	e8 05 dc ff ff       	call   8010053d <panic>

  idewait(0);
80102938:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010293f:	e8 f2 fe ff ff       	call   80102836 <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102944:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010294b:	00 
8010294c:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102953:	e8 9b fe ff ff       	call   801027f3 <outb>
  outb(0x1f2, 1);  // number of sectors
80102958:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010295f:	00 
80102960:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102967:	e8 87 fe ff ff       	call   801027f3 <outb>
  outb(0x1f3, b->sector & 0xff);
8010296c:	8b 45 08             	mov    0x8(%ebp),%eax
8010296f:	8b 40 08             	mov    0x8(%eax),%eax
80102972:	0f b6 c0             	movzbl %al,%eax
80102975:	89 44 24 04          	mov    %eax,0x4(%esp)
80102979:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102980:	e8 6e fe ff ff       	call   801027f3 <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
80102985:	8b 45 08             	mov    0x8(%ebp),%eax
80102988:	8b 40 08             	mov    0x8(%eax),%eax
8010298b:	c1 e8 08             	shr    $0x8,%eax
8010298e:	0f b6 c0             	movzbl %al,%eax
80102991:	89 44 24 04          	mov    %eax,0x4(%esp)
80102995:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
8010299c:	e8 52 fe ff ff       	call   801027f3 <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
801029a1:	8b 45 08             	mov    0x8(%ebp),%eax
801029a4:	8b 40 08             	mov    0x8(%eax),%eax
801029a7:	c1 e8 10             	shr    $0x10,%eax
801029aa:	0f b6 c0             	movzbl %al,%eax
801029ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801029b1:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801029b8:	e8 36 fe ff ff       	call   801027f3 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
801029bd:	8b 45 08             	mov    0x8(%ebp),%eax
801029c0:	8b 40 04             	mov    0x4(%eax),%eax
801029c3:	83 e0 01             	and    $0x1,%eax
801029c6:	89 c2                	mov    %eax,%edx
801029c8:	c1 e2 04             	shl    $0x4,%edx
801029cb:	8b 45 08             	mov    0x8(%ebp),%eax
801029ce:	8b 40 08             	mov    0x8(%eax),%eax
801029d1:	c1 e8 18             	shr    $0x18,%eax
801029d4:	83 e0 0f             	and    $0xf,%eax
801029d7:	09 d0                	or     %edx,%eax
801029d9:	83 c8 e0             	or     $0xffffffe0,%eax
801029dc:	0f b6 c0             	movzbl %al,%eax
801029df:	89 44 24 04          	mov    %eax,0x4(%esp)
801029e3:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801029ea:	e8 04 fe ff ff       	call   801027f3 <outb>
  if(b->flags & B_DIRTY){
801029ef:	8b 45 08             	mov    0x8(%ebp),%eax
801029f2:	8b 00                	mov    (%eax),%eax
801029f4:	83 e0 04             	and    $0x4,%eax
801029f7:	85 c0                	test   %eax,%eax
801029f9:	74 34                	je     80102a2f <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
801029fb:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102a02:	00 
80102a03:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a0a:	e8 e4 fd ff ff       	call   801027f3 <outb>
    outsl(0x1f0, b->data, 512/4);
80102a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a12:	83 c0 18             	add    $0x18,%eax
80102a15:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102a1c:	00 
80102a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a21:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102a28:	e8 e4 fd ff ff       	call   80102811 <outsl>
80102a2d:	eb 14                	jmp    80102a43 <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102a2f:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102a36:	00 
80102a37:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a3e:	e8 b0 fd ff ff       	call   801027f3 <outb>
  }
}
80102a43:	c9                   	leave  
80102a44:	c3                   	ret    

80102a45 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102a45:	55                   	push   %ebp
80102a46:	89 e5                	mov    %esp,%ebp
80102a48:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a4b:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102a52:	e8 58 26 00 00       	call   801050af <acquire>
  if((b = idequeue) == 0){
80102a57:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102a5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a63:	75 11                	jne    80102a76 <ideintr+0x31>
    release(&idelock);
80102a65:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102a6c:	e8 a0 26 00 00       	call   80105111 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102a71:	e9 90 00 00 00       	jmp    80102b06 <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a79:	8b 40 14             	mov    0x14(%eax),%eax
80102a7c:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a84:	8b 00                	mov    (%eax),%eax
80102a86:	83 e0 04             	and    $0x4,%eax
80102a89:	85 c0                	test   %eax,%eax
80102a8b:	75 2e                	jne    80102abb <ideintr+0x76>
80102a8d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102a94:	e8 9d fd ff ff       	call   80102836 <idewait>
80102a99:	85 c0                	test   %eax,%eax
80102a9b:	78 1e                	js     80102abb <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa0:	83 c0 18             	add    $0x18,%eax
80102aa3:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102aaa:	00 
80102aab:	89 44 24 04          	mov    %eax,0x4(%esp)
80102aaf:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102ab6:	e8 13 fd ff ff       	call   801027ce <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102abe:	8b 00                	mov    (%eax),%eax
80102ac0:	89 c2                	mov    %eax,%edx
80102ac2:	83 ca 02             	or     $0x2,%edx
80102ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac8:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102acd:	8b 00                	mov    (%eax),%eax
80102acf:	89 c2                	mov    %eax,%edx
80102ad1:	83 e2 fb             	and    $0xfffffffb,%edx
80102ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad7:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102adc:	89 04 24             	mov    %eax,(%esp)
80102adf:	e8 c1 23 00 00       	call   80104ea5 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102ae4:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102ae9:	85 c0                	test   %eax,%eax
80102aeb:	74 0d                	je     80102afa <ideintr+0xb5>
    idestart(idequeue);
80102aed:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102af2:	89 04 24             	mov    %eax,(%esp)
80102af5:	e8 26 fe ff ff       	call   80102920 <idestart>

  release(&idelock);
80102afa:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102b01:	e8 0b 26 00 00       	call   80105111 <release>
}
80102b06:	c9                   	leave  
80102b07:	c3                   	ret    

80102b08 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102b08:	55                   	push   %ebp
80102b09:	89 e5                	mov    %esp,%ebp
80102b0b:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102b0e:	8b 45 08             	mov    0x8(%ebp),%eax
80102b11:	8b 00                	mov    (%eax),%eax
80102b13:	83 e0 01             	and    $0x1,%eax
80102b16:	85 c0                	test   %eax,%eax
80102b18:	75 0c                	jne    80102b26 <iderw+0x1e>
    panic("iderw: buf not busy");
80102b1a:	c7 04 24 7d 88 10 80 	movl   $0x8010887d,(%esp)
80102b21:	e8 17 da ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102b26:	8b 45 08             	mov    0x8(%ebp),%eax
80102b29:	8b 00                	mov    (%eax),%eax
80102b2b:	83 e0 06             	and    $0x6,%eax
80102b2e:	83 f8 02             	cmp    $0x2,%eax
80102b31:	75 0c                	jne    80102b3f <iderw+0x37>
    panic("iderw: nothing to do");
80102b33:	c7 04 24 91 88 10 80 	movl   $0x80108891,(%esp)
80102b3a:	e8 fe d9 ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
80102b3f:	8b 45 08             	mov    0x8(%ebp),%eax
80102b42:	8b 40 04             	mov    0x4(%eax),%eax
80102b45:	85 c0                	test   %eax,%eax
80102b47:	74 15                	je     80102b5e <iderw+0x56>
80102b49:	a1 38 b6 10 80       	mov    0x8010b638,%eax
80102b4e:	85 c0                	test   %eax,%eax
80102b50:	75 0c                	jne    80102b5e <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80102b52:	c7 04 24 a6 88 10 80 	movl   $0x801088a6,(%esp)
80102b59:	e8 df d9 ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC: acquire-lock
80102b5e:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102b65:	e8 45 25 00 00       	call   801050af <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102b6a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b6d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC: insert-queue
80102b74:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102b7b:	eb 0b                	jmp    80102b88 <iderw+0x80>
80102b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b80:	8b 00                	mov    (%eax),%eax
80102b82:	83 c0 14             	add    $0x14,%eax
80102b85:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b8b:	8b 00                	mov    (%eax),%eax
80102b8d:	85 c0                	test   %eax,%eax
80102b8f:	75 ec                	jne    80102b7d <iderw+0x75>
    ;
  *pp = b;
80102b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b94:	8b 55 08             	mov    0x8(%ebp),%edx
80102b97:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102b99:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102b9e:	3b 45 08             	cmp    0x8(%ebp),%eax
80102ba1:	75 22                	jne    80102bc5 <iderw+0xbd>
    idestart(b);
80102ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ba6:	89 04 24             	mov    %eax,(%esp)
80102ba9:	e8 72 fd ff ff       	call   80102920 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bae:	eb 15                	jmp    80102bc5 <iderw+0xbd>
    sleep(b, &idelock);
80102bb0:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
80102bb7:	80 
80102bb8:	8b 45 08             	mov    0x8(%ebp),%eax
80102bbb:	89 04 24             	mov    %eax,(%esp)
80102bbe:	e8 06 22 00 00       	call   80104dc9 <sleep>
80102bc3:	eb 01                	jmp    80102bc6 <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bc5:	90                   	nop
80102bc6:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc9:	8b 00                	mov    (%eax),%eax
80102bcb:	83 e0 06             	and    $0x6,%eax
80102bce:	83 f8 02             	cmp    $0x2,%eax
80102bd1:	75 dd                	jne    80102bb0 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
80102bd3:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102bda:	e8 32 25 00 00       	call   80105111 <release>
}
80102bdf:	c9                   	leave  
80102be0:	c3                   	ret    
80102be1:	00 00                	add    %al,(%eax)
	...

80102be4 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102be4:	55                   	push   %ebp
80102be5:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102be7:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102bec:	8b 55 08             	mov    0x8(%ebp),%edx
80102bef:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102bf1:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102bf6:	8b 40 10             	mov    0x10(%eax),%eax
}
80102bf9:	5d                   	pop    %ebp
80102bfa:	c3                   	ret    

80102bfb <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102bfb:	55                   	push   %ebp
80102bfc:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bfe:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102c03:	8b 55 08             	mov    0x8(%ebp),%edx
80102c06:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102c08:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102c0d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102c10:	89 50 10             	mov    %edx,0x10(%eax)
}
80102c13:	5d                   	pop    %ebp
80102c14:	c3                   	ret    

80102c15 <ioapicinit>:

void
ioapicinit(void)
{
80102c15:	55                   	push   %ebp
80102c16:	89 e5                	mov    %esp,%ebp
80102c18:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102c1b:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102c20:	85 c0                	test   %eax,%eax
80102c22:	0f 84 9f 00 00 00    	je     80102cc7 <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102c28:	c7 05 54 f8 10 80 00 	movl   $0xfec00000,0x8010f854
80102c2f:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c32:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102c39:	e8 a6 ff ff ff       	call   80102be4 <ioapicread>
80102c3e:	c1 e8 10             	shr    $0x10,%eax
80102c41:	25 ff 00 00 00       	and    $0xff,%eax
80102c46:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102c50:	e8 8f ff ff ff       	call   80102be4 <ioapicread>
80102c55:	c1 e8 18             	shr    $0x18,%eax
80102c58:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c5b:	0f b6 05 20 f9 10 80 	movzbl 0x8010f920,%eax
80102c62:	0f b6 c0             	movzbl %al,%eax
80102c65:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102c68:	74 0c                	je     80102c76 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c6a:	c7 04 24 c4 88 10 80 	movl   $0x801088c4,(%esp)
80102c71:	e8 2b d7 ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c7d:	eb 3e                	jmp    80102cbd <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c82:	83 c0 20             	add    $0x20,%eax
80102c85:	0d 00 00 01 00       	or     $0x10000,%eax
80102c8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102c8d:	83 c2 08             	add    $0x8,%edx
80102c90:	01 d2                	add    %edx,%edx
80102c92:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c96:	89 14 24             	mov    %edx,(%esp)
80102c99:	e8 5d ff ff ff       	call   80102bfb <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ca1:	83 c0 08             	add    $0x8,%eax
80102ca4:	01 c0                	add    %eax,%eax
80102ca6:	83 c0 01             	add    $0x1,%eax
80102ca9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102cb0:	00 
80102cb1:	89 04 24             	mov    %eax,(%esp)
80102cb4:	e8 42 ff ff ff       	call   80102bfb <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102cb9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102cc3:	7e ba                	jle    80102c7f <ioapicinit+0x6a>
80102cc5:	eb 01                	jmp    80102cc8 <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102cc7:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102cc8:	c9                   	leave  
80102cc9:	c3                   	ret    

80102cca <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102cca:	55                   	push   %ebp
80102ccb:	89 e5                	mov    %esp,%ebp
80102ccd:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102cd0:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102cd5:	85 c0                	test   %eax,%eax
80102cd7:	74 39                	je     80102d12 <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102cd9:	8b 45 08             	mov    0x8(%ebp),%eax
80102cdc:	83 c0 20             	add    $0x20,%eax
80102cdf:	8b 55 08             	mov    0x8(%ebp),%edx
80102ce2:	83 c2 08             	add    $0x8,%edx
80102ce5:	01 d2                	add    %edx,%edx
80102ce7:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ceb:	89 14 24             	mov    %edx,(%esp)
80102cee:	e8 08 ff ff ff       	call   80102bfb <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cf6:	c1 e0 18             	shl    $0x18,%eax
80102cf9:	8b 55 08             	mov    0x8(%ebp),%edx
80102cfc:	83 c2 08             	add    $0x8,%edx
80102cff:	01 d2                	add    %edx,%edx
80102d01:	83 c2 01             	add    $0x1,%edx
80102d04:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d08:	89 14 24             	mov    %edx,(%esp)
80102d0b:	e8 eb fe ff ff       	call   80102bfb <ioapicwrite>
80102d10:	eb 01                	jmp    80102d13 <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102d12:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102d13:	c9                   	leave  
80102d14:	c3                   	ret    
80102d15:	00 00                	add    %al,(%eax)
	...

80102d18 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102d18:	55                   	push   %ebp
80102d19:	89 e5                	mov    %esp,%ebp
80102d1b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d1e:	05 00 00 00 80       	add    $0x80000000,%eax
80102d23:	5d                   	pop    %ebp
80102d24:	c3                   	ret    

80102d25 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102d25:	55                   	push   %ebp
80102d26:	89 e5                	mov    %esp,%ebp
80102d28:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102d2b:	c7 44 24 04 f6 88 10 	movl   $0x801088f6,0x4(%esp)
80102d32:	80 
80102d33:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102d3a:	e8 4f 23 00 00       	call   8010508e <initlock>
  kmem.use_lock = 0;
80102d3f:	c7 05 94 f8 10 80 00 	movl   $0x0,0x8010f894
80102d46:	00 00 00 
  freerange(vstart, vend);
80102d49:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d4c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d50:	8b 45 08             	mov    0x8(%ebp),%eax
80102d53:	89 04 24             	mov    %eax,(%esp)
80102d56:	e8 26 00 00 00       	call   80102d81 <freerange>
}
80102d5b:	c9                   	leave  
80102d5c:	c3                   	ret    

80102d5d <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d5d:	55                   	push   %ebp
80102d5e:	89 e5                	mov    %esp,%ebp
80102d60:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102d63:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d66:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80102d6d:	89 04 24             	mov    %eax,(%esp)
80102d70:	e8 0c 00 00 00       	call   80102d81 <freerange>
  kmem.use_lock = 1;
80102d75:	c7 05 94 f8 10 80 01 	movl   $0x1,0x8010f894
80102d7c:	00 00 00 
}
80102d7f:	c9                   	leave  
80102d80:	c3                   	ret    

80102d81 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d81:	55                   	push   %ebp
80102d82:	89 e5                	mov    %esp,%ebp
80102d84:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d87:	8b 45 08             	mov    0x8(%ebp),%eax
80102d8a:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d8f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d94:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d97:	eb 12                	jmp    80102dab <freerange+0x2a>
    kfree(p);
80102d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d9c:	89 04 24             	mov    %eax,(%esp)
80102d9f:	e8 16 00 00 00       	call   80102dba <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102da4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dae:	05 00 10 00 00       	add    $0x1000,%eax
80102db3:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102db6:	76 e1                	jbe    80102d99 <freerange+0x18>
    kfree(p);
}
80102db8:	c9                   	leave  
80102db9:	c3                   	ret    

80102dba <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102dba:	55                   	push   %ebp
80102dbb:	89 e5                	mov    %esp,%ebp
80102dbd:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102dc0:	8b 45 08             	mov    0x8(%ebp),%eax
80102dc3:	25 ff 0f 00 00       	and    $0xfff,%eax
80102dc8:	85 c0                	test   %eax,%eax
80102dca:	75 1b                	jne    80102de7 <kfree+0x2d>
80102dcc:	81 7d 08 1c 2a 11 80 	cmpl   $0x80112a1c,0x8(%ebp)
80102dd3:	72 12                	jb     80102de7 <kfree+0x2d>
80102dd5:	8b 45 08             	mov    0x8(%ebp),%eax
80102dd8:	89 04 24             	mov    %eax,(%esp)
80102ddb:	e8 38 ff ff ff       	call   80102d18 <v2p>
80102de0:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102de5:	76 0c                	jbe    80102df3 <kfree+0x39>
    panic("kfree");
80102de7:	c7 04 24 fb 88 10 80 	movl   $0x801088fb,(%esp)
80102dee:	e8 4a d7 ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102df3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102dfa:	00 
80102dfb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102e02:	00 
80102e03:	8b 45 08             	mov    0x8(%ebp),%eax
80102e06:	89 04 24             	mov    %eax,(%esp)
80102e09:	e8 f0 24 00 00       	call   801052fe <memset>

  if(kmem.use_lock)
80102e0e:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e13:	85 c0                	test   %eax,%eax
80102e15:	74 0c                	je     80102e23 <kfree+0x69>
    acquire(&kmem.lock);
80102e17:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e1e:	e8 8c 22 00 00       	call   801050af <acquire>
  r = (struct run*)v;
80102e23:	8b 45 08             	mov    0x8(%ebp),%eax
80102e26:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102e29:	8b 15 98 f8 10 80    	mov    0x8010f898,%edx
80102e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e32:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e37:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102e3c:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e41:	85 c0                	test   %eax,%eax
80102e43:	74 0c                	je     80102e51 <kfree+0x97>
    release(&kmem.lock);
80102e45:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e4c:	e8 c0 22 00 00       	call   80105111 <release>
}
80102e51:	c9                   	leave  
80102e52:	c3                   	ret    

80102e53 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e53:	55                   	push   %ebp
80102e54:	89 e5                	mov    %esp,%ebp
80102e56:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102e59:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e5e:	85 c0                	test   %eax,%eax
80102e60:	74 0c                	je     80102e6e <kalloc+0x1b>
    acquire(&kmem.lock);
80102e62:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e69:	e8 41 22 00 00       	call   801050af <acquire>
  r = kmem.freelist;
80102e6e:	a1 98 f8 10 80       	mov    0x8010f898,%eax
80102e73:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e76:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e7a:	74 0a                	je     80102e86 <kalloc+0x33>
    kmem.freelist = r->next;
80102e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e7f:	8b 00                	mov    (%eax),%eax
80102e81:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102e86:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e8b:	85 c0                	test   %eax,%eax
80102e8d:	74 0c                	je     80102e9b <kalloc+0x48>
    release(&kmem.lock);
80102e8f:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e96:	e8 76 22 00 00       	call   80105111 <release>
  return (char*)r;
80102e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102e9e:	c9                   	leave  
80102e9f:	c3                   	ret    

80102ea0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102ea0:	55                   	push   %ebp
80102ea1:	89 e5                	mov    %esp,%ebp
80102ea3:	53                   	push   %ebx
80102ea4:	83 ec 14             	sub    $0x14,%esp
80102ea7:	8b 45 08             	mov    0x8(%ebp),%eax
80102eaa:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102eae:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102eb2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102eb6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102eba:	ec                   	in     (%dx),%al
80102ebb:	89 c3                	mov    %eax,%ebx
80102ebd:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102ec0:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102ec4:	83 c4 14             	add    $0x14,%esp
80102ec7:	5b                   	pop    %ebx
80102ec8:	5d                   	pop    %ebp
80102ec9:	c3                   	ret    

80102eca <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102eca:	55                   	push   %ebp
80102ecb:	89 e5                	mov    %esp,%ebp
80102ecd:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102ed0:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102ed7:	e8 c4 ff ff ff       	call   80102ea0 <inb>
80102edc:	0f b6 c0             	movzbl %al,%eax
80102edf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ee5:	83 e0 01             	and    $0x1,%eax
80102ee8:	85 c0                	test   %eax,%eax
80102eea:	75 0a                	jne    80102ef6 <kbdgetc+0x2c>
    return -1;
80102eec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ef1:	e9 23 01 00 00       	jmp    80103019 <kbdgetc+0x14f>
  data = inb(KBDATAP);
80102ef6:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102efd:	e8 9e ff ff ff       	call   80102ea0 <inb>
80102f02:	0f b6 c0             	movzbl %al,%eax
80102f05:	89 45 fc             	mov    %eax,-0x4(%ebp)
    
  if(data == 0xE0){
80102f08:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102f0f:	75 17                	jne    80102f28 <kbdgetc+0x5e>
    shift |= E0ESC;
80102f11:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f16:	83 c8 40             	or     $0x40,%eax
80102f19:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102f1e:	b8 00 00 00 00       	mov    $0x0,%eax
80102f23:	e9 f1 00 00 00       	jmp    80103019 <kbdgetc+0x14f>
  } else if(data & 0x80){
80102f28:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f2b:	25 80 00 00 00       	and    $0x80,%eax
80102f30:	85 c0                	test   %eax,%eax
80102f32:	74 45                	je     80102f79 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102f34:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f39:	83 e0 40             	and    $0x40,%eax
80102f3c:	85 c0                	test   %eax,%eax
80102f3e:	75 08                	jne    80102f48 <kbdgetc+0x7e>
80102f40:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f43:	83 e0 7f             	and    $0x7f,%eax
80102f46:	eb 03                	jmp    80102f4b <kbdgetc+0x81>
80102f48:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f4b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f51:	05 20 90 10 80       	add    $0x80109020,%eax
80102f56:	0f b6 00             	movzbl (%eax),%eax
80102f59:	83 c8 40             	or     $0x40,%eax
80102f5c:	0f b6 c0             	movzbl %al,%eax
80102f5f:	f7 d0                	not    %eax
80102f61:	89 c2                	mov    %eax,%edx
80102f63:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f68:	21 d0                	and    %edx,%eax
80102f6a:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102f6f:	b8 00 00 00 00       	mov    $0x0,%eax
80102f74:	e9 a0 00 00 00       	jmp    80103019 <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80102f79:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f7e:	83 e0 40             	and    $0x40,%eax
80102f81:	85 c0                	test   %eax,%eax
80102f83:	74 14                	je     80102f99 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f85:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f8c:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f91:	83 e0 bf             	and    $0xffffffbf,%eax
80102f94:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102f99:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f9c:	05 20 90 10 80       	add    $0x80109020,%eax
80102fa1:	0f b6 00             	movzbl (%eax),%eax
80102fa4:	0f b6 d0             	movzbl %al,%edx
80102fa7:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fac:	09 d0                	or     %edx,%eax
80102fae:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102fb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fb6:	05 20 91 10 80       	add    $0x80109120,%eax
80102fbb:	0f b6 00             	movzbl (%eax),%eax
80102fbe:	0f b6 d0             	movzbl %al,%edx
80102fc1:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fc6:	31 d0                	xor    %edx,%eax
80102fc8:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102fcd:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fd2:	83 e0 03             	and    $0x3,%eax
80102fd5:	8b 04 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%eax
80102fdc:	03 45 fc             	add    -0x4(%ebp),%eax
80102fdf:	0f b6 00             	movzbl (%eax),%eax
80102fe2:	0f b6 c0             	movzbl %al,%eax
80102fe5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102fe8:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fed:	83 e0 08             	and    $0x8,%eax
80102ff0:	85 c0                	test   %eax,%eax
80102ff2:	74 22                	je     80103016 <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
80102ff4:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102ff8:	76 0c                	jbe    80103006 <kbdgetc+0x13c>
80102ffa:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102ffe:	77 06                	ja     80103006 <kbdgetc+0x13c>
      c += 'A' - 'a';
80103000:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103004:	eb 10                	jmp    80103016 <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
80103006:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010300a:	76 0a                	jbe    80103016 <kbdgetc+0x14c>
8010300c:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103010:	77 04                	ja     80103016 <kbdgetc+0x14c>
      c += 'a' - 'A';
80103012:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103016:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103019:	c9                   	leave  
8010301a:	c3                   	ret    

8010301b <kbdintr>:

void
kbdintr(void)
{
8010301b:	55                   	push   %ebp
8010301c:	89 e5                	mov    %esp,%ebp
8010301e:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80103021:	c7 04 24 ca 2e 10 80 	movl   $0x80102eca,(%esp)
80103028:	e8 a1 d8 ff ff       	call   801008ce <consoleintr>
}
8010302d:	c9                   	leave  
8010302e:	c3                   	ret    
	...

80103030 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103030:	55                   	push   %ebp
80103031:	89 e5                	mov    %esp,%ebp
80103033:	83 ec 08             	sub    $0x8,%esp
80103036:	8b 55 08             	mov    0x8(%ebp),%edx
80103039:	8b 45 0c             	mov    0xc(%ebp),%eax
8010303c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103040:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103043:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103047:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010304b:	ee                   	out    %al,(%dx)
}
8010304c:	c9                   	leave  
8010304d:	c3                   	ret    

8010304e <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010304e:	55                   	push   %ebp
8010304f:	89 e5                	mov    %esp,%ebp
80103051:	53                   	push   %ebx
80103052:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103055:	9c                   	pushf  
80103056:	5b                   	pop    %ebx
80103057:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
8010305a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010305d:	83 c4 10             	add    $0x10,%esp
80103060:	5b                   	pop    %ebx
80103061:	5d                   	pop    %ebp
80103062:	c3                   	ret    

80103063 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103063:	55                   	push   %ebp
80103064:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103066:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
8010306b:	8b 55 08             	mov    0x8(%ebp),%edx
8010306e:	c1 e2 02             	shl    $0x2,%edx
80103071:	01 c2                	add    %eax,%edx
80103073:	8b 45 0c             	mov    0xc(%ebp),%eax
80103076:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103078:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
8010307d:	83 c0 20             	add    $0x20,%eax
80103080:	8b 00                	mov    (%eax),%eax
}
80103082:	5d                   	pop    %ebp
80103083:	c3                   	ret    

80103084 <lapicinit>:
//PAGEBREAK!

void
lapicinit(int c)
{
80103084:	55                   	push   %ebp
80103085:	89 e5                	mov    %esp,%ebp
80103087:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
8010308a:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
8010308f:	85 c0                	test   %eax,%eax
80103091:	0f 84 47 01 00 00    	je     801031de <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103097:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
8010309e:	00 
8010309f:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
801030a6:	e8 b8 ff ff ff       	call   80103063 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801030ab:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
801030b2:	00 
801030b3:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
801030ba:	e8 a4 ff ff ff       	call   80103063 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801030bf:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
801030c6:	00 
801030c7:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030ce:	e8 90 ff ff ff       	call   80103063 <lapicw>
  lapicw(TICR, 10000000); 
801030d3:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
801030da:	00 
801030db:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
801030e2:	e8 7c ff ff ff       	call   80103063 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801030e7:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801030ee:	00 
801030ef:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
801030f6:	e8 68 ff ff ff       	call   80103063 <lapicw>
  lapicw(LINT1, MASKED);
801030fb:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103102:	00 
80103103:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
8010310a:	e8 54 ff ff ff       	call   80103063 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010310f:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103114:	83 c0 30             	add    $0x30,%eax
80103117:	8b 00                	mov    (%eax),%eax
80103119:	c1 e8 10             	shr    $0x10,%eax
8010311c:	25 ff 00 00 00       	and    $0xff,%eax
80103121:	83 f8 03             	cmp    $0x3,%eax
80103124:	76 14                	jbe    8010313a <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
80103126:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010312d:	00 
8010312e:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80103135:	e8 29 ff ff ff       	call   80103063 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010313a:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80103141:	00 
80103142:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80103149:	e8 15 ff ff ff       	call   80103063 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010314e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103155:	00 
80103156:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010315d:	e8 01 ff ff ff       	call   80103063 <lapicw>
  lapicw(ESR, 0);
80103162:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103169:	00 
8010316a:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103171:	e8 ed fe ff ff       	call   80103063 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103176:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010317d:	00 
8010317e:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103185:	e8 d9 fe ff ff       	call   80103063 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010318a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103191:	00 
80103192:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103199:	e8 c5 fe ff ff       	call   80103063 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010319e:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
801031a5:	00 
801031a6:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801031ad:	e8 b1 fe ff ff       	call   80103063 <lapicw>
  while(lapic[ICRLO] & DELIVS)
801031b2:	90                   	nop
801031b3:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
801031b8:	05 00 03 00 00       	add    $0x300,%eax
801031bd:	8b 00                	mov    (%eax),%eax
801031bf:	25 00 10 00 00       	and    $0x1000,%eax
801031c4:	85 c0                	test   %eax,%eax
801031c6:	75 eb                	jne    801031b3 <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801031c8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031cf:	00 
801031d0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801031d7:	e8 87 fe ff ff       	call   80103063 <lapicw>
801031dc:	eb 01                	jmp    801031df <lapicinit+0x15b>

void
lapicinit(int c)
{
  if(!lapic) 
    return;
801031de:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801031df:	c9                   	leave  
801031e0:	c3                   	ret    

801031e1 <cpunum>:

int
cpunum(void)
{
801031e1:	55                   	push   %ebp
801031e2:	89 e5                	mov    %esp,%ebp
801031e4:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801031e7:	e8 62 fe ff ff       	call   8010304e <readeflags>
801031ec:	25 00 02 00 00       	and    $0x200,%eax
801031f1:	85 c0                	test   %eax,%eax
801031f3:	74 29                	je     8010321e <cpunum+0x3d>
    static int n;
    if(n++ == 0)
801031f5:	a1 40 b6 10 80       	mov    0x8010b640,%eax
801031fa:	85 c0                	test   %eax,%eax
801031fc:	0f 94 c2             	sete   %dl
801031ff:	83 c0 01             	add    $0x1,%eax
80103202:	a3 40 b6 10 80       	mov    %eax,0x8010b640
80103207:	84 d2                	test   %dl,%dl
80103209:	74 13                	je     8010321e <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
8010320b:	8b 45 04             	mov    0x4(%ebp),%eax
8010320e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103212:	c7 04 24 04 89 10 80 	movl   $0x80108904,(%esp)
80103219:	e8 83 d1 ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
8010321e:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103223:	85 c0                	test   %eax,%eax
80103225:	74 0f                	je     80103236 <cpunum+0x55>
    return lapic[ID]>>24;
80103227:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
8010322c:	83 c0 20             	add    $0x20,%eax
8010322f:	8b 00                	mov    (%eax),%eax
80103231:	c1 e8 18             	shr    $0x18,%eax
80103234:	eb 05                	jmp    8010323b <cpunum+0x5a>
  return 0;
80103236:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010323b:	c9                   	leave  
8010323c:	c3                   	ret    

8010323d <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010323d:	55                   	push   %ebp
8010323e:	89 e5                	mov    %esp,%ebp
80103240:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103243:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103248:	85 c0                	test   %eax,%eax
8010324a:	74 14                	je     80103260 <lapiceoi+0x23>
    lapicw(EOI, 0);
8010324c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103253:	00 
80103254:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
8010325b:	e8 03 fe ff ff       	call   80103063 <lapicw>
}
80103260:	c9                   	leave  
80103261:	c3                   	ret    

80103262 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103262:	55                   	push   %ebp
80103263:	89 e5                	mov    %esp,%ebp
}
80103265:	5d                   	pop    %ebp
80103266:	c3                   	ret    

80103267 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103267:	55                   	push   %ebp
80103268:	89 e5                	mov    %esp,%ebp
8010326a:	83 ec 1c             	sub    $0x1c,%esp
8010326d:	8b 45 08             	mov    0x8(%ebp),%eax
80103270:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
80103273:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010327a:	00 
8010327b:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103282:	e8 a9 fd ff ff       	call   80103030 <outb>
  outb(IO_RTC+1, 0x0A);
80103287:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010328e:	00 
8010328f:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103296:	e8 95 fd ff ff       	call   80103030 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010329b:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801032a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801032a5:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801032aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
801032ad:	8d 50 02             	lea    0x2(%eax),%edx
801032b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801032b3:	c1 e8 04             	shr    $0x4,%eax
801032b6:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801032b9:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801032bd:	c1 e0 18             	shl    $0x18,%eax
801032c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801032c4:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801032cb:	e8 93 fd ff ff       	call   80103063 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801032d0:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801032d7:	00 
801032d8:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801032df:	e8 7f fd ff ff       	call   80103063 <lapicw>
  microdelay(200);
801032e4:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801032eb:	e8 72 ff ff ff       	call   80103262 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
801032f0:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801032f7:	00 
801032f8:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801032ff:	e8 5f fd ff ff       	call   80103063 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103304:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
8010330b:	e8 52 ff ff ff       	call   80103262 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103310:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103317:	eb 40                	jmp    80103359 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80103319:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010331d:	c1 e0 18             	shl    $0x18,%eax
80103320:	89 44 24 04          	mov    %eax,0x4(%esp)
80103324:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010332b:	e8 33 fd ff ff       	call   80103063 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103330:	8b 45 0c             	mov    0xc(%ebp),%eax
80103333:	c1 e8 0c             	shr    $0xc,%eax
80103336:	80 cc 06             	or     $0x6,%ah
80103339:	89 44 24 04          	mov    %eax,0x4(%esp)
8010333d:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103344:	e8 1a fd ff ff       	call   80103063 <lapicw>
    microdelay(200);
80103349:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103350:	e8 0d ff ff ff       	call   80103262 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103355:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103359:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010335d:	7e ba                	jle    80103319 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010335f:	c9                   	leave  
80103360:	c3                   	ret    
80103361:	00 00                	add    %al,(%eax)
	...

80103364 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103364:	55                   	push   %ebp
80103365:	89 e5                	mov    %esp,%ebp
80103367:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010336a:	c7 44 24 04 30 89 10 	movl   $0x80108930,0x4(%esp)
80103371:	80 
80103372:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103379:	e8 10 1d 00 00       	call   8010508e <initlock>
  readsb(ROOTDEV, &sb);
8010337e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103381:	89 44 24 04          	mov    %eax,0x4(%esp)
80103385:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010338c:	e8 af e2 ff ff       	call   80101640 <readsb>
  log.start = sb.size - sb.nlog;
80103391:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103397:	89 d1                	mov    %edx,%ecx
80103399:	29 c1                	sub    %eax,%ecx
8010339b:	89 c8                	mov    %ecx,%eax
8010339d:	a3 d4 f8 10 80       	mov    %eax,0x8010f8d4
  log.size = sb.nlog;
801033a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033a5:	a3 d8 f8 10 80       	mov    %eax,0x8010f8d8
  log.dev = ROOTDEV;
801033aa:	c7 05 e0 f8 10 80 01 	movl   $0x1,0x8010f8e0
801033b1:	00 00 00 
  recover_from_log();
801033b4:	e8 97 01 00 00       	call   80103550 <recover_from_log>
}
801033b9:	c9                   	leave  
801033ba:	c3                   	ret    

801033bb <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801033bb:	55                   	push   %ebp
801033bc:	89 e5                	mov    %esp,%ebp
801033be:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033c8:	e9 89 00 00 00       	jmp    80103456 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801033cd:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
801033d2:	03 45 f4             	add    -0xc(%ebp),%eax
801033d5:	83 c0 01             	add    $0x1,%eax
801033d8:	89 c2                	mov    %eax,%edx
801033da:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801033df:	89 54 24 04          	mov    %edx,0x4(%esp)
801033e3:	89 04 24             	mov    %eax,(%esp)
801033e6:	e8 bb cd ff ff       	call   801001a6 <bread>
801033eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801033ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033f1:	83 c0 10             	add    $0x10,%eax
801033f4:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
801033fb:	89 c2                	mov    %eax,%edx
801033fd:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
80103402:	89 54 24 04          	mov    %edx,0x4(%esp)
80103406:	89 04 24             	mov    %eax,(%esp)
80103409:	e8 98 cd ff ff       	call   801001a6 <bread>
8010340e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103411:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103414:	8d 50 18             	lea    0x18(%eax),%edx
80103417:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010341a:	83 c0 18             	add    $0x18,%eax
8010341d:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103424:	00 
80103425:	89 54 24 04          	mov    %edx,0x4(%esp)
80103429:	89 04 24             	mov    %eax,(%esp)
8010342c:	e8 a0 1f 00 00       	call   801053d1 <memmove>
    bwrite(dbuf);  // write dst to disk
80103431:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103434:	89 04 24             	mov    %eax,(%esp)
80103437:	e8 a1 cd ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
8010343c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010343f:	89 04 24             	mov    %eax,(%esp)
80103442:	e8 d0 cd ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103447:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010344a:	89 04 24             	mov    %eax,(%esp)
8010344d:	e8 c5 cd ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103452:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103456:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010345b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010345e:	0f 8f 69 ff ff ff    	jg     801033cd <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103464:	c9                   	leave  
80103465:	c3                   	ret    

80103466 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103466:	55                   	push   %ebp
80103467:	89 e5                	mov    %esp,%ebp
80103469:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010346c:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
80103471:	89 c2                	mov    %eax,%edx
80103473:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
80103478:	89 54 24 04          	mov    %edx,0x4(%esp)
8010347c:	89 04 24             	mov    %eax,(%esp)
8010347f:	e8 22 cd ff ff       	call   801001a6 <bread>
80103484:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103487:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010348a:	83 c0 18             	add    $0x18,%eax
8010348d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103490:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103493:	8b 00                	mov    (%eax),%eax
80103495:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  for (i = 0; i < log.lh.n; i++) {
8010349a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034a1:	eb 1b                	jmp    801034be <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
801034a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034a9:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801034ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034b0:	83 c2 10             	add    $0x10,%edx
801034b3:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801034ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034be:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801034c3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034c6:	7f db                	jg     801034a3 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
801034c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034cb:	89 04 24             	mov    %eax,(%esp)
801034ce:	e8 44 cd ff ff       	call   80100217 <brelse>
}
801034d3:	c9                   	leave  
801034d4:	c3                   	ret    

801034d5 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034d5:	55                   	push   %ebp
801034d6:	89 e5                	mov    %esp,%ebp
801034d8:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801034db:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
801034e0:	89 c2                	mov    %eax,%edx
801034e2:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801034e7:	89 54 24 04          	mov    %edx,0x4(%esp)
801034eb:	89 04 24             	mov    %eax,(%esp)
801034ee:	e8 b3 cc ff ff       	call   801001a6 <bread>
801034f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034f9:	83 c0 18             	add    $0x18,%eax
801034fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034ff:	8b 15 e4 f8 10 80    	mov    0x8010f8e4,%edx
80103505:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103508:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010350a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103511:	eb 1b                	jmp    8010352e <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
80103513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103516:	83 c0 10             	add    $0x10,%eax
80103519:	8b 0c 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%ecx
80103520:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103523:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103526:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010352a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010352e:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103533:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103536:	7f db                	jg     80103513 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
80103538:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010353b:	89 04 24             	mov    %eax,(%esp)
8010353e:	e8 9a cc ff ff       	call   801001dd <bwrite>
  brelse(buf);
80103543:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103546:	89 04 24             	mov    %eax,(%esp)
80103549:	e8 c9 cc ff ff       	call   80100217 <brelse>
}
8010354e:	c9                   	leave  
8010354f:	c3                   	ret    

80103550 <recover_from_log>:

static void
recover_from_log(void)
{
80103550:	55                   	push   %ebp
80103551:	89 e5                	mov    %esp,%ebp
80103553:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103556:	e8 0b ff ff ff       	call   80103466 <read_head>
  install_trans(); // if committed, copy from log to disk
8010355b:	e8 5b fe ff ff       	call   801033bb <install_trans>
  log.lh.n = 0;
80103560:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
80103567:	00 00 00 
  write_head(); // clear the log
8010356a:	e8 66 ff ff ff       	call   801034d5 <write_head>
}
8010356f:	c9                   	leave  
80103570:	c3                   	ret    

80103571 <begin_trans>:

void
begin_trans(void)
{
80103571:	55                   	push   %ebp
80103572:	89 e5                	mov    %esp,%ebp
80103574:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103577:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010357e:	e8 2c 1b 00 00       	call   801050af <acquire>
  while (log.busy) {
80103583:	eb 14                	jmp    80103599 <begin_trans+0x28>
    sleep(&log, &log.lock);
80103585:	c7 44 24 04 a0 f8 10 	movl   $0x8010f8a0,0x4(%esp)
8010358c:	80 
8010358d:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103594:	e8 30 18 00 00       	call   80104dc9 <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
80103599:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
8010359e:	85 c0                	test   %eax,%eax
801035a0:	75 e3                	jne    80103585 <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
801035a2:	c7 05 dc f8 10 80 01 	movl   $0x1,0x8010f8dc
801035a9:	00 00 00 
  release(&log.lock);
801035ac:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801035b3:	e8 59 1b 00 00       	call   80105111 <release>
}
801035b8:	c9                   	leave  
801035b9:	c3                   	ret    

801035ba <commit_trans>:

void
commit_trans(void)
{
801035ba:	55                   	push   %ebp
801035bb:	89 e5                	mov    %esp,%ebp
801035bd:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
801035c0:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801035c5:	85 c0                	test   %eax,%eax
801035c7:	7e 19                	jle    801035e2 <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
801035c9:	e8 07 ff ff ff       	call   801034d5 <write_head>
    install_trans(); // Now install writes to home locations
801035ce:	e8 e8 fd ff ff       	call   801033bb <install_trans>
    log.lh.n = 0; 
801035d3:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
801035da:	00 00 00 
    write_head();    // Erase the transaction from the log
801035dd:	e8 f3 fe ff ff       	call   801034d5 <write_head>
  }
  
  acquire(&log.lock);
801035e2:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801035e9:	e8 c1 1a 00 00       	call   801050af <acquire>
  log.busy = 0;
801035ee:	c7 05 dc f8 10 80 00 	movl   $0x0,0x8010f8dc
801035f5:	00 00 00 
  wakeup(&log);
801035f8:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801035ff:	e8 a1 18 00 00       	call   80104ea5 <wakeup>
  release(&log.lock);
80103604:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010360b:	e8 01 1b 00 00       	call   80105111 <release>
}
80103610:	c9                   	leave  
80103611:	c3                   	ret    

80103612 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103612:	55                   	push   %ebp
80103613:	89 e5                	mov    %esp,%ebp
80103615:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103618:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010361d:	83 f8 09             	cmp    $0x9,%eax
80103620:	7f 12                	jg     80103634 <log_write+0x22>
80103622:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103627:	8b 15 d8 f8 10 80    	mov    0x8010f8d8,%edx
8010362d:	83 ea 01             	sub    $0x1,%edx
80103630:	39 d0                	cmp    %edx,%eax
80103632:	7c 0c                	jl     80103640 <log_write+0x2e>
    panic("too big a transaction");
80103634:	c7 04 24 34 89 10 80 	movl   $0x80108934,(%esp)
8010363b:	e8 fd ce ff ff       	call   8010053d <panic>
  if (!log.busy)
80103640:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
80103645:	85 c0                	test   %eax,%eax
80103647:	75 0c                	jne    80103655 <log_write+0x43>
    panic("write outside of trans");
80103649:	c7 04 24 4a 89 10 80 	movl   $0x8010894a,(%esp)
80103650:	e8 e8 ce ff ff       	call   8010053d <panic>

  for (i = 0; i < log.lh.n; i++) {
80103655:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010365c:	eb 1d                	jmp    8010367b <log_write+0x69>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
8010365e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103661:	83 c0 10             	add    $0x10,%eax
80103664:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
8010366b:	89 c2                	mov    %eax,%edx
8010366d:	8b 45 08             	mov    0x8(%ebp),%eax
80103670:	8b 40 08             	mov    0x8(%eax),%eax
80103673:	39 c2                	cmp    %eax,%edx
80103675:	74 10                	je     80103687 <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
80103677:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010367b:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103680:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103683:	7f d9                	jg     8010365e <log_write+0x4c>
80103685:	eb 01                	jmp    80103688 <log_write+0x76>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
80103687:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
80103688:	8b 45 08             	mov    0x8(%ebp),%eax
8010368b:	8b 40 08             	mov    0x8(%eax),%eax
8010368e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103691:	83 c2 10             	add    $0x10,%edx
80103694:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
8010369b:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
801036a0:	03 45 f4             	add    -0xc(%ebp),%eax
801036a3:	83 c0 01             	add    $0x1,%eax
801036a6:	89 c2                	mov    %eax,%edx
801036a8:	8b 45 08             	mov    0x8(%ebp),%eax
801036ab:	8b 40 04             	mov    0x4(%eax),%eax
801036ae:	89 54 24 04          	mov    %edx,0x4(%esp)
801036b2:	89 04 24             	mov    %eax,(%esp)
801036b5:	e8 ec ca ff ff       	call   801001a6 <bread>
801036ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
801036bd:	8b 45 08             	mov    0x8(%ebp),%eax
801036c0:	8d 50 18             	lea    0x18(%eax),%edx
801036c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036c6:	83 c0 18             	add    $0x18,%eax
801036c9:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801036d0:	00 
801036d1:	89 54 24 04          	mov    %edx,0x4(%esp)
801036d5:	89 04 24             	mov    %eax,(%esp)
801036d8:	e8 f4 1c 00 00       	call   801053d1 <memmove>
  bwrite(lbuf);
801036dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036e0:	89 04 24             	mov    %eax,(%esp)
801036e3:	e8 f5 ca ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
801036e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036eb:	89 04 24             	mov    %eax,(%esp)
801036ee:	e8 24 cb ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
801036f3:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801036f8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036fb:	75 0d                	jne    8010370a <log_write+0xf8>
    log.lh.n++;
801036fd:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103702:	83 c0 01             	add    $0x1,%eax
80103705:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  b->flags |= B_DIRTY; // XXX prevent eviction
8010370a:	8b 45 08             	mov    0x8(%ebp),%eax
8010370d:	8b 00                	mov    (%eax),%eax
8010370f:	89 c2                	mov    %eax,%edx
80103711:	83 ca 04             	or     $0x4,%edx
80103714:	8b 45 08             	mov    0x8(%ebp),%eax
80103717:	89 10                	mov    %edx,(%eax)
}
80103719:	c9                   	leave  
8010371a:	c3                   	ret    
	...

8010371c <v2p>:
8010371c:	55                   	push   %ebp
8010371d:	89 e5                	mov    %esp,%ebp
8010371f:	8b 45 08             	mov    0x8(%ebp),%eax
80103722:	05 00 00 00 80       	add    $0x80000000,%eax
80103727:	5d                   	pop    %ebp
80103728:	c3                   	ret    

80103729 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103729:	55                   	push   %ebp
8010372a:	89 e5                	mov    %esp,%ebp
8010372c:	8b 45 08             	mov    0x8(%ebp),%eax
8010372f:	05 00 00 00 80       	add    $0x80000000,%eax
80103734:	5d                   	pop    %ebp
80103735:	c3                   	ret    

80103736 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103736:	55                   	push   %ebp
80103737:	89 e5                	mov    %esp,%ebp
80103739:	53                   	push   %ebx
8010373a:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
8010373d:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103740:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80103743:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103746:	89 c3                	mov    %eax,%ebx
80103748:	89 d8                	mov    %ebx,%eax
8010374a:	f0 87 02             	lock xchg %eax,(%edx)
8010374d:	89 c3                	mov    %eax,%ebx
8010374f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103752:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103755:	83 c4 10             	add    $0x10,%esp
80103758:	5b                   	pop    %ebx
80103759:	5d                   	pop    %ebp
8010375a:	c3                   	ret    

8010375b <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010375b:	55                   	push   %ebp
8010375c:	89 e5                	mov    %esp,%ebp
8010375e:	83 e4 f0             	and    $0xfffffff0,%esp
80103761:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103764:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
8010376b:	80 
8010376c:	c7 04 24 1c 2a 11 80 	movl   $0x80112a1c,(%esp)
80103773:	e8 ad f5 ff ff       	call   80102d25 <kinit1>
  kvmalloc();      // kernel page table
80103778:	e8 11 48 00 00       	call   80107f8e <kvmalloc>
  mpinit();        // collect info about this machine
8010377d:	e8 63 04 00 00       	call   80103be5 <mpinit>
  lapicinit(mpbcpu());
80103782:	e8 2e 02 00 00       	call   801039b5 <mpbcpu>
80103787:	89 04 24             	mov    %eax,(%esp)
8010378a:	e8 f5 f8 ff ff       	call   80103084 <lapicinit>
  seginit();       // set up segments
8010378f:	e8 9d 41 00 00       	call   80107931 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103794:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010379a:	0f b6 00             	movzbl (%eax),%eax
8010379d:	0f b6 c0             	movzbl %al,%eax
801037a0:	89 44 24 04          	mov    %eax,0x4(%esp)
801037a4:	c7 04 24 61 89 10 80 	movl   $0x80108961,(%esp)
801037ab:	e8 f1 cb ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
801037b0:	e8 95 06 00 00       	call   80103e4a <picinit>
  ioapicinit();    // another interrupt controller
801037b5:	e8 5b f4 ff ff       	call   80102c15 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801037ba:	e8 22 d6 ff ff       	call   80100de1 <consoleinit>
  uartinit();      // serial port
801037bf:	e8 b8 34 00 00       	call   80106c7c <uartinit>
  pinit();         // process table
801037c4:	e8 96 0b 00 00       	call   8010435f <pinit>
  tvinit();        // trap vectors
801037c9:	e8 31 30 00 00       	call   801067ff <tvinit>
  binit();         // buffer cache
801037ce:	e8 61 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801037d3:	e8 7c da ff ff       	call   80101254 <fileinit>
  iinit();         // inode cache
801037d8:	e8 2a e1 ff ff       	call   80101907 <iinit>
  ideinit();       // disk
801037dd:	e8 98 f0 ff ff       	call   8010287a <ideinit>
  if(!ismp)
801037e2:	a1 24 f9 10 80       	mov    0x8010f924,%eax
801037e7:	85 c0                	test   %eax,%eax
801037e9:	75 05                	jne    801037f0 <main+0x95>
    timerinit();   // uniprocessor timer
801037eb:	e8 52 2f 00 00       	call   80106742 <timerinit>
  startothers();   // start other processors
801037f0:	e8 87 00 00 00       	call   8010387c <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037f5:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801037fc:	8e 
801037fd:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103804:	e8 54 f5 ff ff       	call   80102d5d <kinit2>
  userinit();      // first user process
80103809:	e8 6f 0c 00 00       	call   8010447d <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
8010380e:	e8 22 00 00 00       	call   80103835 <mpmain>

80103813 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103813:	55                   	push   %ebp
80103814:	89 e5                	mov    %esp,%ebp
80103816:	83 ec 18             	sub    $0x18,%esp
  switchkvm(); 
80103819:	e8 87 47 00 00       	call   80107fa5 <switchkvm>
  seginit();
8010381e:	e8 0e 41 00 00       	call   80107931 <seginit>
  lapicinit(cpunum());
80103823:	e8 b9 f9 ff ff       	call   801031e1 <cpunum>
80103828:	89 04 24             	mov    %eax,(%esp)
8010382b:	e8 54 f8 ff ff       	call   80103084 <lapicinit>
  mpmain();
80103830:	e8 00 00 00 00       	call   80103835 <mpmain>

80103835 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103835:	55                   	push   %ebp
80103836:	89 e5                	mov    %esp,%ebp
80103838:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010383b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103841:	0f b6 00             	movzbl (%eax),%eax
80103844:	0f b6 c0             	movzbl %al,%eax
80103847:	89 44 24 04          	mov    %eax,0x4(%esp)
8010384b:	c7 04 24 78 89 10 80 	movl   $0x80108978,(%esp)
80103852:	e8 4a cb ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
80103857:	e8 17 31 00 00       	call   80106973 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
8010385c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103862:	05 a8 00 00 00       	add    $0xa8,%eax
80103867:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010386e:	00 
8010386f:	89 04 24             	mov    %eax,(%esp)
80103872:	e8 bf fe ff ff       	call   80103736 <xchg>
  scheduler();     // start running processes
80103877:	e8 a1 13 00 00       	call   80104c1d <scheduler>

8010387c <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010387c:	55                   	push   %ebp
8010387d:	89 e5                	mov    %esp,%ebp
8010387f:	53                   	push   %ebx
80103880:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103883:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
8010388a:	e8 9a fe ff ff       	call   80103729 <p2v>
8010388f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103892:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103897:	89 44 24 08          	mov    %eax,0x8(%esp)
8010389b:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
801038a2:	80 
801038a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038a6:	89 04 24             	mov    %eax,(%esp)
801038a9:	e8 23 1b 00 00       	call   801053d1 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801038ae:	c7 45 f4 40 f9 10 80 	movl   $0x8010f940,-0xc(%ebp)
801038b5:	e9 86 00 00 00       	jmp    80103940 <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
801038ba:	e8 22 f9 ff ff       	call   801031e1 <cpunum>
801038bf:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801038c5:	05 40 f9 10 80       	add    $0x8010f940,%eax
801038ca:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038cd:	74 69                	je     80103938 <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801038cf:	e8 7f f5 ff ff       	call   80102e53 <kalloc>
801038d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801038d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038da:	83 e8 04             	sub    $0x4,%eax
801038dd:	8b 55 ec             	mov    -0x14(%ebp),%edx
801038e0:	81 c2 00 10 00 00    	add    $0x1000,%edx
801038e6:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801038e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038eb:	83 e8 08             	sub    $0x8,%eax
801038ee:	c7 00 13 38 10 80    	movl   $0x80103813,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801038f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038f7:	8d 58 f4             	lea    -0xc(%eax),%ebx
801038fa:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
80103901:	e8 16 fe ff ff       	call   8010371c <v2p>
80103906:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103908:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010390b:	89 04 24             	mov    %eax,(%esp)
8010390e:	e8 09 fe ff ff       	call   8010371c <v2p>
80103913:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103916:	0f b6 12             	movzbl (%edx),%edx
80103919:	0f b6 d2             	movzbl %dl,%edx
8010391c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103920:	89 14 24             	mov    %edx,(%esp)
80103923:	e8 3f f9 ff ff       	call   80103267 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103928:	90                   	nop
80103929:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010392c:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103932:	85 c0                	test   %eax,%eax
80103934:	74 f3                	je     80103929 <startothers+0xad>
80103936:	eb 01                	jmp    80103939 <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103938:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103939:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103940:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103945:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010394b:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103950:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103953:	0f 87 61 ff ff ff    	ja     801038ba <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103959:	83 c4 24             	add    $0x24,%esp
8010395c:	5b                   	pop    %ebx
8010395d:	5d                   	pop    %ebp
8010395e:	c3                   	ret    
	...

80103960 <p2v>:
80103960:	55                   	push   %ebp
80103961:	89 e5                	mov    %esp,%ebp
80103963:	8b 45 08             	mov    0x8(%ebp),%eax
80103966:	05 00 00 00 80       	add    $0x80000000,%eax
8010396b:	5d                   	pop    %ebp
8010396c:	c3                   	ret    

8010396d <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010396d:	55                   	push   %ebp
8010396e:	89 e5                	mov    %esp,%ebp
80103970:	53                   	push   %ebx
80103971:	83 ec 14             	sub    $0x14,%esp
80103974:	8b 45 08             	mov    0x8(%ebp),%eax
80103977:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010397b:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010397f:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80103983:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80103987:	ec                   	in     (%dx),%al
80103988:	89 c3                	mov    %eax,%ebx
8010398a:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
8010398d:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80103991:	83 c4 14             	add    $0x14,%esp
80103994:	5b                   	pop    %ebx
80103995:	5d                   	pop    %ebp
80103996:	c3                   	ret    

80103997 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103997:	55                   	push   %ebp
80103998:	89 e5                	mov    %esp,%ebp
8010399a:	83 ec 08             	sub    $0x8,%esp
8010399d:	8b 55 08             	mov    0x8(%ebp),%edx
801039a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801039a3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801039a7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801039aa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801039ae:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801039b2:	ee                   	out    %al,(%dx)
}
801039b3:	c9                   	leave  
801039b4:	c3                   	ret    

801039b5 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801039b5:	55                   	push   %ebp
801039b6:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801039b8:	a1 44 b6 10 80       	mov    0x8010b644,%eax
801039bd:	89 c2                	mov    %eax,%edx
801039bf:	b8 40 f9 10 80       	mov    $0x8010f940,%eax
801039c4:	89 d1                	mov    %edx,%ecx
801039c6:	29 c1                	sub    %eax,%ecx
801039c8:	89 c8                	mov    %ecx,%eax
801039ca:	c1 f8 02             	sar    $0x2,%eax
801039cd:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801039d3:	5d                   	pop    %ebp
801039d4:	c3                   	ret    

801039d5 <sum>:

static uchar
sum(uchar *addr, int len)
{
801039d5:	55                   	push   %ebp
801039d6:	89 e5                	mov    %esp,%ebp
801039d8:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801039db:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801039e2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801039e9:	eb 13                	jmp    801039fe <sum+0x29>
    sum += addr[i];
801039eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801039ee:	03 45 08             	add    0x8(%ebp),%eax
801039f1:	0f b6 00             	movzbl (%eax),%eax
801039f4:	0f b6 c0             	movzbl %al,%eax
801039f7:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
801039fa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801039fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a01:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a04:	7c e5                	jl     801039eb <sum+0x16>
    sum += addr[i];
  return sum;
80103a06:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a09:	c9                   	leave  
80103a0a:	c3                   	ret    

80103a0b <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a0b:	55                   	push   %ebp
80103a0c:	89 e5                	mov    %esp,%ebp
80103a0e:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103a11:	8b 45 08             	mov    0x8(%ebp),%eax
80103a14:	89 04 24             	mov    %eax,(%esp)
80103a17:	e8 44 ff ff ff       	call   80103960 <p2v>
80103a1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a22:	03 45 f0             	add    -0x10(%ebp),%eax
80103a25:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a2e:	eb 3f                	jmp    80103a6f <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a30:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a37:	00 
80103a38:	c7 44 24 04 8c 89 10 	movl   $0x8010898c,0x4(%esp)
80103a3f:	80 
80103a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a43:	89 04 24             	mov    %eax,(%esp)
80103a46:	e8 2a 19 00 00       	call   80105375 <memcmp>
80103a4b:	85 c0                	test   %eax,%eax
80103a4d:	75 1c                	jne    80103a6b <mpsearch1+0x60>
80103a4f:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a56:	00 
80103a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a5a:	89 04 24             	mov    %eax,(%esp)
80103a5d:	e8 73 ff ff ff       	call   801039d5 <sum>
80103a62:	84 c0                	test   %al,%al
80103a64:	75 05                	jne    80103a6b <mpsearch1+0x60>
      return (struct mp*)p;
80103a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a69:	eb 11                	jmp    80103a7c <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a6b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a72:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a75:	72 b9                	jb     80103a30 <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a77:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a7c:	c9                   	leave  
80103a7d:	c3                   	ret    

80103a7e <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a7e:	55                   	push   %ebp
80103a7f:	89 e5                	mov    %esp,%ebp
80103a81:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a84:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a8e:	83 c0 0f             	add    $0xf,%eax
80103a91:	0f b6 00             	movzbl (%eax),%eax
80103a94:	0f b6 c0             	movzbl %al,%eax
80103a97:	89 c2                	mov    %eax,%edx
80103a99:	c1 e2 08             	shl    $0x8,%edx
80103a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a9f:	83 c0 0e             	add    $0xe,%eax
80103aa2:	0f b6 00             	movzbl (%eax),%eax
80103aa5:	0f b6 c0             	movzbl %al,%eax
80103aa8:	09 d0                	or     %edx,%eax
80103aaa:	c1 e0 04             	shl    $0x4,%eax
80103aad:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103ab0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103ab4:	74 21                	je     80103ad7 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103ab6:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103abd:	00 
80103abe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ac1:	89 04 24             	mov    %eax,(%esp)
80103ac4:	e8 42 ff ff ff       	call   80103a0b <mpsearch1>
80103ac9:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103acc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ad0:	74 50                	je     80103b22 <mpsearch+0xa4>
      return mp;
80103ad2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ad5:	eb 5f                	jmp    80103b36 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ada:	83 c0 14             	add    $0x14,%eax
80103add:	0f b6 00             	movzbl (%eax),%eax
80103ae0:	0f b6 c0             	movzbl %al,%eax
80103ae3:	89 c2                	mov    %eax,%edx
80103ae5:	c1 e2 08             	shl    $0x8,%edx
80103ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aeb:	83 c0 13             	add    $0x13,%eax
80103aee:	0f b6 00             	movzbl (%eax),%eax
80103af1:	0f b6 c0             	movzbl %al,%eax
80103af4:	09 d0                	or     %edx,%eax
80103af6:	c1 e0 0a             	shl    $0xa,%eax
80103af9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103afc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aff:	2d 00 04 00 00       	sub    $0x400,%eax
80103b04:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b0b:	00 
80103b0c:	89 04 24             	mov    %eax,(%esp)
80103b0f:	e8 f7 fe ff ff       	call   80103a0b <mpsearch1>
80103b14:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b17:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b1b:	74 05                	je     80103b22 <mpsearch+0xa4>
      return mp;
80103b1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b20:	eb 14                	jmp    80103b36 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b22:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b29:	00 
80103b2a:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b31:	e8 d5 fe ff ff       	call   80103a0b <mpsearch1>
}
80103b36:	c9                   	leave  
80103b37:	c3                   	ret    

80103b38 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b38:	55                   	push   %ebp
80103b39:	89 e5                	mov    %esp,%ebp
80103b3b:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b3e:	e8 3b ff ff ff       	call   80103a7e <mpsearch>
80103b43:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b46:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b4a:	74 0a                	je     80103b56 <mpconfig+0x1e>
80103b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4f:	8b 40 04             	mov    0x4(%eax),%eax
80103b52:	85 c0                	test   %eax,%eax
80103b54:	75 0a                	jne    80103b60 <mpconfig+0x28>
    return 0;
80103b56:	b8 00 00 00 00       	mov    $0x0,%eax
80103b5b:	e9 83 00 00 00       	jmp    80103be3 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b63:	8b 40 04             	mov    0x4(%eax),%eax
80103b66:	89 04 24             	mov    %eax,(%esp)
80103b69:	e8 f2 fd ff ff       	call   80103960 <p2v>
80103b6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b71:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b78:	00 
80103b79:	c7 44 24 04 91 89 10 	movl   $0x80108991,0x4(%esp)
80103b80:	80 
80103b81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b84:	89 04 24             	mov    %eax,(%esp)
80103b87:	e8 e9 17 00 00       	call   80105375 <memcmp>
80103b8c:	85 c0                	test   %eax,%eax
80103b8e:	74 07                	je     80103b97 <mpconfig+0x5f>
    return 0;
80103b90:	b8 00 00 00 00       	mov    $0x0,%eax
80103b95:	eb 4c                	jmp    80103be3 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103b97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b9a:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b9e:	3c 01                	cmp    $0x1,%al
80103ba0:	74 12                	je     80103bb4 <mpconfig+0x7c>
80103ba2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba5:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103ba9:	3c 04                	cmp    $0x4,%al
80103bab:	74 07                	je     80103bb4 <mpconfig+0x7c>
    return 0;
80103bad:	b8 00 00 00 00       	mov    $0x0,%eax
80103bb2:	eb 2f                	jmp    80103be3 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103bb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bb7:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103bbb:	0f b7 c0             	movzwl %ax,%eax
80103bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
80103bc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc5:	89 04 24             	mov    %eax,(%esp)
80103bc8:	e8 08 fe ff ff       	call   801039d5 <sum>
80103bcd:	84 c0                	test   %al,%al
80103bcf:	74 07                	je     80103bd8 <mpconfig+0xa0>
    return 0;
80103bd1:	b8 00 00 00 00       	mov    $0x0,%eax
80103bd6:	eb 0b                	jmp    80103be3 <mpconfig+0xab>
  *pmp = mp;
80103bd8:	8b 45 08             	mov    0x8(%ebp),%eax
80103bdb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bde:	89 10                	mov    %edx,(%eax)
  return conf;
80103be0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103be3:	c9                   	leave  
80103be4:	c3                   	ret    

80103be5 <mpinit>:

void
mpinit(void)
{
80103be5:	55                   	push   %ebp
80103be6:	89 e5                	mov    %esp,%ebp
80103be8:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103beb:	c7 05 44 b6 10 80 40 	movl   $0x8010f940,0x8010b644
80103bf2:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
80103bf5:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103bf8:	89 04 24             	mov    %eax,(%esp)
80103bfb:	e8 38 ff ff ff       	call   80103b38 <mpconfig>
80103c00:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c03:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c07:	0f 84 9c 01 00 00    	je     80103da9 <mpinit+0x1c4>
    return;
  ismp = 1;
80103c0d:	c7 05 24 f9 10 80 01 	movl   $0x1,0x8010f924
80103c14:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c1a:	8b 40 24             	mov    0x24(%eax),%eax
80103c1d:	a3 9c f8 10 80       	mov    %eax,0x8010f89c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c25:	83 c0 2c             	add    $0x2c,%eax
80103c28:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c2e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c32:	0f b7 c0             	movzwl %ax,%eax
80103c35:	03 45 f0             	add    -0x10(%ebp),%eax
80103c38:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c3b:	e9 f4 00 00 00       	jmp    80103d34 <mpinit+0x14f>
    switch(*p){
80103c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c43:	0f b6 00             	movzbl (%eax),%eax
80103c46:	0f b6 c0             	movzbl %al,%eax
80103c49:	83 f8 04             	cmp    $0x4,%eax
80103c4c:	0f 87 bf 00 00 00    	ja     80103d11 <mpinit+0x12c>
80103c52:	8b 04 85 d4 89 10 80 	mov    -0x7fef762c(,%eax,4),%eax
80103c59:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c61:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c64:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c68:	0f b6 d0             	movzbl %al,%edx
80103c6b:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c70:	39 c2                	cmp    %eax,%edx
80103c72:	74 2d                	je     80103ca1 <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c74:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c77:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c7b:	0f b6 d0             	movzbl %al,%edx
80103c7e:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c83:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c87:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c8b:	c7 04 24 96 89 10 80 	movl   $0x80108996,(%esp)
80103c92:	e8 0a c7 ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80103c97:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103c9e:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103ca1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ca4:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103ca8:	0f b6 c0             	movzbl %al,%eax
80103cab:	83 e0 02             	and    $0x2,%eax
80103cae:	85 c0                	test   %eax,%eax
80103cb0:	74 15                	je     80103cc7 <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80103cb2:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103cb7:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103cbd:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103cc2:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103cc7:	8b 15 20 ff 10 80    	mov    0x8010ff20,%edx
80103ccd:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103cd2:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103cd8:	81 c2 40 f9 10 80    	add    $0x8010f940,%edx
80103cde:	88 02                	mov    %al,(%edx)
      ncpu++;
80103ce0:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103ce5:	83 c0 01             	add    $0x1,%eax
80103ce8:	a3 20 ff 10 80       	mov    %eax,0x8010ff20
      p += sizeof(struct mpproc);
80103ced:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103cf1:	eb 41                	jmp    80103d34 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103cf9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103cfc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d00:	a2 20 f9 10 80       	mov    %al,0x8010f920
      p += sizeof(struct mpioapic);
80103d05:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d09:	eb 29                	jmp    80103d34 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d0b:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d0f:	eb 23                	jmp    80103d34 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d14:	0f b6 00             	movzbl (%eax),%eax
80103d17:	0f b6 c0             	movzbl %al,%eax
80103d1a:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d1e:	c7 04 24 b4 89 10 80 	movl   $0x801089b4,(%esp)
80103d25:	e8 77 c6 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
80103d2a:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103d31:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d37:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d3a:	0f 82 00 ff ff ff    	jb     80103c40 <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103d40:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80103d45:	85 c0                	test   %eax,%eax
80103d47:	75 1d                	jne    80103d66 <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103d49:	c7 05 20 ff 10 80 01 	movl   $0x1,0x8010ff20
80103d50:	00 00 00 
    lapic = 0;
80103d53:	c7 05 9c f8 10 80 00 	movl   $0x0,0x8010f89c
80103d5a:	00 00 00 
    ioapicid = 0;
80103d5d:	c6 05 20 f9 10 80 00 	movb   $0x0,0x8010f920
    return;
80103d64:	eb 44                	jmp    80103daa <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103d66:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d69:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d6d:	84 c0                	test   %al,%al
80103d6f:	74 39                	je     80103daa <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d71:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d78:	00 
80103d79:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d80:	e8 12 fc ff ff       	call   80103997 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d85:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d8c:	e8 dc fb ff ff       	call   8010396d <inb>
80103d91:	83 c8 01             	or     $0x1,%eax
80103d94:	0f b6 c0             	movzbl %al,%eax
80103d97:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d9b:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103da2:	e8 f0 fb ff ff       	call   80103997 <outb>
80103da7:	eb 01                	jmp    80103daa <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103da9:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103daa:	c9                   	leave  
80103dab:	c3                   	ret    

80103dac <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103dac:	55                   	push   %ebp
80103dad:	89 e5                	mov    %esp,%ebp
80103daf:	83 ec 08             	sub    $0x8,%esp
80103db2:	8b 55 08             	mov    0x8(%ebp),%edx
80103db5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103db8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103dbc:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103dbf:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103dc3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103dc7:	ee                   	out    %al,(%dx)
}
80103dc8:	c9                   	leave  
80103dc9:	c3                   	ret    

80103dca <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103dca:	55                   	push   %ebp
80103dcb:	89 e5                	mov    %esp,%ebp
80103dcd:	83 ec 0c             	sub    $0xc,%esp
80103dd0:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103dd7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103ddb:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103de1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103de5:	0f b6 c0             	movzbl %al,%eax
80103de8:	89 44 24 04          	mov    %eax,0x4(%esp)
80103dec:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103df3:	e8 b4 ff ff ff       	call   80103dac <outb>
  outb(IO_PIC2+1, mask >> 8);
80103df8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103dfc:	66 c1 e8 08          	shr    $0x8,%ax
80103e00:	0f b6 c0             	movzbl %al,%eax
80103e03:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e07:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e0e:	e8 99 ff ff ff       	call   80103dac <outb>
}
80103e13:	c9                   	leave  
80103e14:	c3                   	ret    

80103e15 <picenable>:

void
picenable(int irq)
{
80103e15:	55                   	push   %ebp
80103e16:	89 e5                	mov    %esp,%ebp
80103e18:	53                   	push   %ebx
80103e19:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103e1c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e1f:	ba 01 00 00 00       	mov    $0x1,%edx
80103e24:	89 d3                	mov    %edx,%ebx
80103e26:	89 c1                	mov    %eax,%ecx
80103e28:	d3 e3                	shl    %cl,%ebx
80103e2a:	89 d8                	mov    %ebx,%eax
80103e2c:	89 c2                	mov    %eax,%edx
80103e2e:	f7 d2                	not    %edx
80103e30:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103e37:	21 d0                	and    %edx,%eax
80103e39:	0f b7 c0             	movzwl %ax,%eax
80103e3c:	89 04 24             	mov    %eax,(%esp)
80103e3f:	e8 86 ff ff ff       	call   80103dca <picsetmask>
}
80103e44:	83 c4 04             	add    $0x4,%esp
80103e47:	5b                   	pop    %ebx
80103e48:	5d                   	pop    %ebp
80103e49:	c3                   	ret    

80103e4a <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e4a:	55                   	push   %ebp
80103e4b:	89 e5                	mov    %esp,%ebp
80103e4d:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e50:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e57:	00 
80103e58:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e5f:	e8 48 ff ff ff       	call   80103dac <outb>
  outb(IO_PIC2+1, 0xFF);
80103e64:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e6b:	00 
80103e6c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e73:	e8 34 ff ff ff       	call   80103dac <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e78:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e7f:	00 
80103e80:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e87:	e8 20 ff ff ff       	call   80103dac <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103e8c:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103e93:	00 
80103e94:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e9b:	e8 0c ff ff ff       	call   80103dac <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103ea0:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103ea7:	00 
80103ea8:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103eaf:	e8 f8 fe ff ff       	call   80103dac <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103eb4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103ebb:	00 
80103ebc:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ec3:	e8 e4 fe ff ff       	call   80103dac <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103ec8:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103ecf:	00 
80103ed0:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103ed7:	e8 d0 fe ff ff       	call   80103dac <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103edc:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103ee3:	00 
80103ee4:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103eeb:	e8 bc fe ff ff       	call   80103dac <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103ef0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103ef7:	00 
80103ef8:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103eff:	e8 a8 fe ff ff       	call   80103dac <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103f04:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103f0b:	00 
80103f0c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f13:	e8 94 fe ff ff       	call   80103dac <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103f18:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f1f:	00 
80103f20:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f27:	e8 80 fe ff ff       	call   80103dac <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f2c:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f33:	00 
80103f34:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f3b:	e8 6c fe ff ff       	call   80103dac <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103f40:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f47:	00 
80103f48:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f4f:	e8 58 fe ff ff       	call   80103dac <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103f54:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f5b:	00 
80103f5c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f63:	e8 44 fe ff ff       	call   80103dac <outb>

  if(irqmask != 0xFFFF)
80103f68:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f6f:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f73:	74 12                	je     80103f87 <picinit+0x13d>
    picsetmask(irqmask);
80103f75:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f7c:	0f b7 c0             	movzwl %ax,%eax
80103f7f:	89 04 24             	mov    %eax,(%esp)
80103f82:	e8 43 fe ff ff       	call   80103dca <picsetmask>
}
80103f87:	c9                   	leave  
80103f88:	c3                   	ret    
80103f89:	00 00                	add    %al,(%eax)
	...

80103f8c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103f8c:	55                   	push   %ebp
80103f8d:	89 e5                	mov    %esp,%ebp
80103f8f:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103f92:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f99:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f9c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fa2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fa5:	8b 10                	mov    (%eax),%edx
80103fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80103faa:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fac:	e8 bf d2 ff ff       	call   80101270 <filealloc>
80103fb1:	8b 55 08             	mov    0x8(%ebp),%edx
80103fb4:	89 02                	mov    %eax,(%edx)
80103fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb9:	8b 00                	mov    (%eax),%eax
80103fbb:	85 c0                	test   %eax,%eax
80103fbd:	0f 84 c8 00 00 00    	je     8010408b <pipealloc+0xff>
80103fc3:	e8 a8 d2 ff ff       	call   80101270 <filealloc>
80103fc8:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fcb:	89 02                	mov    %eax,(%edx)
80103fcd:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd0:	8b 00                	mov    (%eax),%eax
80103fd2:	85 c0                	test   %eax,%eax
80103fd4:	0f 84 b1 00 00 00    	je     8010408b <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103fda:	e8 74 ee ff ff       	call   80102e53 <kalloc>
80103fdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103fe2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103fe6:	0f 84 9e 00 00 00    	je     8010408a <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80103fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fef:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103ff6:	00 00 00 
  p->writeopen = 1;
80103ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ffc:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104003:	00 00 00 
  p->nwrite = 0;
80104006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104009:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104010:	00 00 00 
  p->nread = 0;
80104013:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104016:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010401d:	00 00 00 
  initlock(&p->lock, "pipe");
80104020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104023:	c7 44 24 04 e8 89 10 	movl   $0x801089e8,0x4(%esp)
8010402a:	80 
8010402b:	89 04 24             	mov    %eax,(%esp)
8010402e:	e8 5b 10 00 00       	call   8010508e <initlock>
  (*f0)->type = FD_PIPE;
80104033:	8b 45 08             	mov    0x8(%ebp),%eax
80104036:	8b 00                	mov    (%eax),%eax
80104038:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010403e:	8b 45 08             	mov    0x8(%ebp),%eax
80104041:	8b 00                	mov    (%eax),%eax
80104043:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104047:	8b 45 08             	mov    0x8(%ebp),%eax
8010404a:	8b 00                	mov    (%eax),%eax
8010404c:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104050:	8b 45 08             	mov    0x8(%ebp),%eax
80104053:	8b 00                	mov    (%eax),%eax
80104055:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104058:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010405b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010405e:	8b 00                	mov    (%eax),%eax
80104060:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104066:	8b 45 0c             	mov    0xc(%ebp),%eax
80104069:	8b 00                	mov    (%eax),%eax
8010406b:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010406f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104072:	8b 00                	mov    (%eax),%eax
80104074:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104078:	8b 45 0c             	mov    0xc(%ebp),%eax
8010407b:	8b 00                	mov    (%eax),%eax
8010407d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104080:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104083:	b8 00 00 00 00       	mov    $0x0,%eax
80104088:	eb 43                	jmp    801040cd <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
8010408a:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
8010408b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010408f:	74 0b                	je     8010409c <pipealloc+0x110>
    kfree((char*)p);
80104091:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104094:	89 04 24             	mov    %eax,(%esp)
80104097:	e8 1e ed ff ff       	call   80102dba <kfree>
  if(*f0)
8010409c:	8b 45 08             	mov    0x8(%ebp),%eax
8010409f:	8b 00                	mov    (%eax),%eax
801040a1:	85 c0                	test   %eax,%eax
801040a3:	74 0d                	je     801040b2 <pipealloc+0x126>
    fileclose(*f0);
801040a5:	8b 45 08             	mov    0x8(%ebp),%eax
801040a8:	8b 00                	mov    (%eax),%eax
801040aa:	89 04 24             	mov    %eax,(%esp)
801040ad:	e8 66 d2 ff ff       	call   80101318 <fileclose>
  if(*f1)
801040b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801040b5:	8b 00                	mov    (%eax),%eax
801040b7:	85 c0                	test   %eax,%eax
801040b9:	74 0d                	je     801040c8 <pipealloc+0x13c>
    fileclose(*f1);
801040bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801040be:	8b 00                	mov    (%eax),%eax
801040c0:	89 04 24             	mov    %eax,(%esp)
801040c3:	e8 50 d2 ff ff       	call   80101318 <fileclose>
  return -1;
801040c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801040cd:	c9                   	leave  
801040ce:	c3                   	ret    

801040cf <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801040cf:	55                   	push   %ebp
801040d0:	89 e5                	mov    %esp,%ebp
801040d2:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
801040d5:	8b 45 08             	mov    0x8(%ebp),%eax
801040d8:	89 04 24             	mov    %eax,(%esp)
801040db:	e8 cf 0f 00 00       	call   801050af <acquire>
  if(writable){
801040e0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801040e4:	74 1f                	je     80104105 <pipeclose+0x36>
    p->writeopen = 0;
801040e6:	8b 45 08             	mov    0x8(%ebp),%eax
801040e9:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801040f0:	00 00 00 
    wakeup(&p->nread);
801040f3:	8b 45 08             	mov    0x8(%ebp),%eax
801040f6:	05 34 02 00 00       	add    $0x234,%eax
801040fb:	89 04 24             	mov    %eax,(%esp)
801040fe:	e8 a2 0d 00 00       	call   80104ea5 <wakeup>
80104103:	eb 1d                	jmp    80104122 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104105:	8b 45 08             	mov    0x8(%ebp),%eax
80104108:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010410f:	00 00 00 
    wakeup(&p->nwrite);
80104112:	8b 45 08             	mov    0x8(%ebp),%eax
80104115:	05 38 02 00 00       	add    $0x238,%eax
8010411a:	89 04 24             	mov    %eax,(%esp)
8010411d:	e8 83 0d 00 00       	call   80104ea5 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104122:	8b 45 08             	mov    0x8(%ebp),%eax
80104125:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010412b:	85 c0                	test   %eax,%eax
8010412d:	75 25                	jne    80104154 <pipeclose+0x85>
8010412f:	8b 45 08             	mov    0x8(%ebp),%eax
80104132:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104138:	85 c0                	test   %eax,%eax
8010413a:	75 18                	jne    80104154 <pipeclose+0x85>
    release(&p->lock);
8010413c:	8b 45 08             	mov    0x8(%ebp),%eax
8010413f:	89 04 24             	mov    %eax,(%esp)
80104142:	e8 ca 0f 00 00       	call   80105111 <release>
    kfree((char*)p);
80104147:	8b 45 08             	mov    0x8(%ebp),%eax
8010414a:	89 04 24             	mov    %eax,(%esp)
8010414d:	e8 68 ec ff ff       	call   80102dba <kfree>
80104152:	eb 0b                	jmp    8010415f <pipeclose+0x90>
  } else
    release(&p->lock);
80104154:	8b 45 08             	mov    0x8(%ebp),%eax
80104157:	89 04 24             	mov    %eax,(%esp)
8010415a:	e8 b2 0f 00 00       	call   80105111 <release>
}
8010415f:	c9                   	leave  
80104160:	c3                   	ret    

80104161 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104161:	55                   	push   %ebp
80104162:	89 e5                	mov    %esp,%ebp
80104164:	53                   	push   %ebx
80104165:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104168:	8b 45 08             	mov    0x8(%ebp),%eax
8010416b:	89 04 24             	mov    %eax,(%esp)
8010416e:	e8 3c 0f 00 00       	call   801050af <acquire>
  for(i = 0; i < n; i++){
80104173:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010417a:	e9 a6 00 00 00       	jmp    80104225 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
8010417f:	8b 45 08             	mov    0x8(%ebp),%eax
80104182:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104188:	85 c0                	test   %eax,%eax
8010418a:	74 0d                	je     80104199 <pipewrite+0x38>
8010418c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104192:	8b 40 24             	mov    0x24(%eax),%eax
80104195:	85 c0                	test   %eax,%eax
80104197:	74 15                	je     801041ae <pipewrite+0x4d>
        release(&p->lock);
80104199:	8b 45 08             	mov    0x8(%ebp),%eax
8010419c:	89 04 24             	mov    %eax,(%esp)
8010419f:	e8 6d 0f 00 00       	call   80105111 <release>
        return -1;
801041a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041a9:	e9 9d 00 00 00       	jmp    8010424b <pipewrite+0xea>
      }
      wakeup(&p->nread);
801041ae:	8b 45 08             	mov    0x8(%ebp),%eax
801041b1:	05 34 02 00 00       	add    $0x234,%eax
801041b6:	89 04 24             	mov    %eax,(%esp)
801041b9:	e8 e7 0c 00 00       	call   80104ea5 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801041be:	8b 45 08             	mov    0x8(%ebp),%eax
801041c1:	8b 55 08             	mov    0x8(%ebp),%edx
801041c4:	81 c2 38 02 00 00    	add    $0x238,%edx
801041ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801041ce:	89 14 24             	mov    %edx,(%esp)
801041d1:	e8 f3 0b 00 00       	call   80104dc9 <sleep>
801041d6:	eb 01                	jmp    801041d9 <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801041d8:	90                   	nop
801041d9:	8b 45 08             	mov    0x8(%ebp),%eax
801041dc:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801041e2:	8b 45 08             	mov    0x8(%ebp),%eax
801041e5:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041eb:	05 00 02 00 00       	add    $0x200,%eax
801041f0:	39 c2                	cmp    %eax,%edx
801041f2:	74 8b                	je     8010417f <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801041f4:	8b 45 08             	mov    0x8(%ebp),%eax
801041f7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041fd:	89 c3                	mov    %eax,%ebx
801041ff:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80104205:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104208:	03 55 0c             	add    0xc(%ebp),%edx
8010420b:	0f b6 0a             	movzbl (%edx),%ecx
8010420e:	8b 55 08             	mov    0x8(%ebp),%edx
80104211:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
80104215:	8d 50 01             	lea    0x1(%eax),%edx
80104218:	8b 45 08             	mov    0x8(%ebp),%eax
8010421b:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104221:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104225:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104228:	3b 45 10             	cmp    0x10(%ebp),%eax
8010422b:	7c ab                	jl     801041d8 <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010422d:	8b 45 08             	mov    0x8(%ebp),%eax
80104230:	05 34 02 00 00       	add    $0x234,%eax
80104235:	89 04 24             	mov    %eax,(%esp)
80104238:	e8 68 0c 00 00       	call   80104ea5 <wakeup>
  release(&p->lock);
8010423d:	8b 45 08             	mov    0x8(%ebp),%eax
80104240:	89 04 24             	mov    %eax,(%esp)
80104243:	e8 c9 0e 00 00       	call   80105111 <release>
  return n;
80104248:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010424b:	83 c4 24             	add    $0x24,%esp
8010424e:	5b                   	pop    %ebx
8010424f:	5d                   	pop    %ebp
80104250:	c3                   	ret    

80104251 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104251:	55                   	push   %ebp
80104252:	89 e5                	mov    %esp,%ebp
80104254:	53                   	push   %ebx
80104255:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104258:	8b 45 08             	mov    0x8(%ebp),%eax
8010425b:	89 04 24             	mov    %eax,(%esp)
8010425e:	e8 4c 0e 00 00       	call   801050af <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104263:	eb 3a                	jmp    8010429f <piperead+0x4e>
    if(proc->killed){
80104265:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010426b:	8b 40 24             	mov    0x24(%eax),%eax
8010426e:	85 c0                	test   %eax,%eax
80104270:	74 15                	je     80104287 <piperead+0x36>
      release(&p->lock);
80104272:	8b 45 08             	mov    0x8(%ebp),%eax
80104275:	89 04 24             	mov    %eax,(%esp)
80104278:	e8 94 0e 00 00       	call   80105111 <release>
      return -1;
8010427d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104282:	e9 b6 00 00 00       	jmp    8010433d <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104287:	8b 45 08             	mov    0x8(%ebp),%eax
8010428a:	8b 55 08             	mov    0x8(%ebp),%edx
8010428d:	81 c2 34 02 00 00    	add    $0x234,%edx
80104293:	89 44 24 04          	mov    %eax,0x4(%esp)
80104297:	89 14 24             	mov    %edx,(%esp)
8010429a:	e8 2a 0b 00 00       	call   80104dc9 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010429f:	8b 45 08             	mov    0x8(%ebp),%eax
801042a2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042a8:	8b 45 08             	mov    0x8(%ebp),%eax
801042ab:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042b1:	39 c2                	cmp    %eax,%edx
801042b3:	75 0d                	jne    801042c2 <piperead+0x71>
801042b5:	8b 45 08             	mov    0x8(%ebp),%eax
801042b8:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042be:	85 c0                	test   %eax,%eax
801042c0:	75 a3                	jne    80104265 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042c9:	eb 49                	jmp    80104314 <piperead+0xc3>
    if(p->nread == p->nwrite)
801042cb:	8b 45 08             	mov    0x8(%ebp),%eax
801042ce:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042d4:	8b 45 08             	mov    0x8(%ebp),%eax
801042d7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042dd:	39 c2                	cmp    %eax,%edx
801042df:	74 3d                	je     8010431e <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801042e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e4:	89 c2                	mov    %eax,%edx
801042e6:	03 55 0c             	add    0xc(%ebp),%edx
801042e9:	8b 45 08             	mov    0x8(%ebp),%eax
801042ec:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042f2:	89 c3                	mov    %eax,%ebx
801042f4:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
801042fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
801042fd:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
80104302:	88 0a                	mov    %cl,(%edx)
80104304:	8d 50 01             	lea    0x1(%eax),%edx
80104307:	8b 45 08             	mov    0x8(%ebp),%eax
8010430a:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104310:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104314:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104317:	3b 45 10             	cmp    0x10(%ebp),%eax
8010431a:	7c af                	jl     801042cb <piperead+0x7a>
8010431c:	eb 01                	jmp    8010431f <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
8010431e:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010431f:	8b 45 08             	mov    0x8(%ebp),%eax
80104322:	05 38 02 00 00       	add    $0x238,%eax
80104327:	89 04 24             	mov    %eax,(%esp)
8010432a:	e8 76 0b 00 00       	call   80104ea5 <wakeup>
  release(&p->lock);
8010432f:	8b 45 08             	mov    0x8(%ebp),%eax
80104332:	89 04 24             	mov    %eax,(%esp)
80104335:	e8 d7 0d 00 00       	call   80105111 <release>
  return i;
8010433a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010433d:	83 c4 24             	add    $0x24,%esp
80104340:	5b                   	pop    %ebx
80104341:	5d                   	pop    %ebp
80104342:	c3                   	ret    
	...

80104344 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104344:	55                   	push   %ebp
80104345:	89 e5                	mov    %esp,%ebp
80104347:	53                   	push   %ebx
80104348:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010434b:	9c                   	pushf  
8010434c:	5b                   	pop    %ebx
8010434d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104350:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104353:	83 c4 10             	add    $0x10,%esp
80104356:	5b                   	pop    %ebx
80104357:	5d                   	pop    %ebp
80104358:	c3                   	ret    

80104359 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104359:	55                   	push   %ebp
8010435a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010435c:	fb                   	sti    
}
8010435d:	5d                   	pop    %ebp
8010435e:	c3                   	ret    

8010435f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010435f:	55                   	push   %ebp
80104360:	89 e5                	mov    %esp,%ebp
80104362:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104365:	c7 44 24 04 ed 89 10 	movl   $0x801089ed,0x4(%esp)
8010436c:	80 
8010436d:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104374:	e8 15 0d 00 00       	call   8010508e <initlock>
}
80104379:	c9                   	leave  
8010437a:	c3                   	ret    

8010437b <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010437b:	55                   	push   %ebp
8010437c:	89 e5                	mov    %esp,%ebp
8010437e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104381:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104388:	e8 22 0d 00 00       	call   801050af <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010438d:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104394:	eb 11                	jmp    801043a7 <allocproc+0x2c>
    if(p->state == UNUSED)
80104396:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104399:	8b 40 0c             	mov    0xc(%eax),%eax
8010439c:	85 c0                	test   %eax,%eax
8010439e:	74 26                	je     801043c6 <allocproc+0x4b>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043a0:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801043a7:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
801043ae:	72 e6                	jb     80104396 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801043b0:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801043b7:	e8 55 0d 00 00       	call   80105111 <release>
  return 0;
801043bc:	b8 00 00 00 00       	mov    $0x0,%eax
801043c1:	e9 b5 00 00 00       	jmp    8010447b <allocproc+0x100>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801043c6:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801043c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ca:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801043d1:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801043d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043d9:	89 42 10             	mov    %eax,0x10(%edx)
801043dc:	83 c0 01             	add    $0x1,%eax
801043df:	a3 04 b0 10 80       	mov    %eax,0x8010b004
  release(&ptable.lock);
801043e4:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801043eb:	e8 21 0d 00 00       	call   80105111 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043f0:	e8 5e ea ff ff       	call   80102e53 <kalloc>
801043f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043f8:	89 42 08             	mov    %eax,0x8(%edx)
801043fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043fe:	8b 40 08             	mov    0x8(%eax),%eax
80104401:	85 c0                	test   %eax,%eax
80104403:	75 11                	jne    80104416 <allocproc+0x9b>
    p->state = UNUSED;
80104405:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104408:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010440f:	b8 00 00 00 00       	mov    $0x0,%eax
80104414:	eb 65                	jmp    8010447b <allocproc+0x100>
  }
  sp = p->kstack + KSTACKSIZE;
80104416:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104419:	8b 40 08             	mov    0x8(%eax),%eax
8010441c:	05 00 10 00 00       	add    $0x1000,%eax
80104421:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104424:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010442e:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104431:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104435:	ba b4 67 10 80       	mov    $0x801067b4,%edx
8010443a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010443d:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010443f:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104443:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104446:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104449:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010444c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104452:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104459:	00 
8010445a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104461:	00 
80104462:	89 04 24             	mov    %eax,(%esp)
80104465:	e8 94 0e 00 00       	call   801052fe <memset>
  p->context->eip = (uint)forkret;
8010446a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104470:	ba 9d 4d 10 80       	mov    $0x80104d9d,%edx
80104475:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104478:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010447b:	c9                   	leave  
8010447c:	c3                   	ret    

8010447d <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010447d:	55                   	push   %ebp
8010447e:	89 e5                	mov    %esp,%ebp
80104480:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104483:	e8 f3 fe ff ff       	call   8010437b <allocproc>
80104488:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
8010448b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448e:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm(kalloc)) == 0)
80104493:	c7 04 24 53 2e 10 80 	movl   $0x80102e53,(%esp)
8010449a:	e8 32 3a 00 00       	call   80107ed1 <setupkvm>
8010449f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044a2:	89 42 04             	mov    %eax,0x4(%edx)
801044a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a8:	8b 40 04             	mov    0x4(%eax),%eax
801044ab:	85 c0                	test   %eax,%eax
801044ad:	75 0c                	jne    801044bb <userinit+0x3e>
    panic("userinit: out of memory?");
801044af:	c7 04 24 f4 89 10 80 	movl   $0x801089f4,(%esp)
801044b6:	e8 82 c0 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044bb:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c3:	8b 40 04             	mov    0x4(%eax),%eax
801044c6:	89 54 24 08          	mov    %edx,0x8(%esp)
801044ca:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
801044d1:	80 
801044d2:	89 04 24             	mov    %eax,(%esp)
801044d5:	e8 4f 3c 00 00       	call   80108129 <inituvm>
  p->sz = PGSIZE;
801044da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044dd:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e6:	8b 40 18             	mov    0x18(%eax),%eax
801044e9:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801044f0:	00 
801044f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801044f8:	00 
801044f9:	89 04 24             	mov    %eax,(%esp)
801044fc:	e8 fd 0d 00 00       	call   801052fe <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104504:	8b 40 18             	mov    0x18(%eax),%eax
80104507:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010450d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104510:	8b 40 18             	mov    0x18(%eax),%eax
80104513:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451c:	8b 40 18             	mov    0x18(%eax),%eax
8010451f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104522:	8b 52 18             	mov    0x18(%edx),%edx
80104525:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104529:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010452d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104530:	8b 40 18             	mov    0x18(%eax),%eax
80104533:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104536:	8b 52 18             	mov    0x18(%edx),%edx
80104539:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010453d:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104544:	8b 40 18             	mov    0x18(%eax),%eax
80104547:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010454e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104551:	8b 40 18             	mov    0x18(%eax),%eax
80104554:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010455b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455e:	8b 40 18             	mov    0x18(%eax),%eax
80104561:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104568:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456b:	83 c0 6c             	add    $0x6c,%eax
8010456e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104575:	00 
80104576:	c7 44 24 04 0d 8a 10 	movl   $0x80108a0d,0x4(%esp)
8010457d:	80 
8010457e:	89 04 24             	mov    %eax,(%esp)
80104581:	e8 a8 0f 00 00       	call   8010552e <safestrcpy>
  p->cwd = namei("/");
80104586:	c7 04 24 16 8a 10 80 	movl   $0x80108a16,(%esp)
8010458d:	e8 cc e1 ff ff       	call   8010275e <namei>
80104592:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104595:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
80104598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801045a2:	c9                   	leave  
801045a3:	c3                   	ret    

801045a4 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801045a4:	55                   	push   %ebp
801045a5:	89 e5                	mov    %esp,%ebp
801045a7:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801045aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045b0:	8b 00                	mov    (%eax),%eax
801045b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801045b5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045b9:	7e 34                	jle    801045ef <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801045bb:	8b 45 08             	mov    0x8(%ebp),%eax
801045be:	89 c2                	mov    %eax,%edx
801045c0:	03 55 f4             	add    -0xc(%ebp),%edx
801045c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045c9:	8b 40 04             	mov    0x4(%eax),%eax
801045cc:	89 54 24 08          	mov    %edx,0x8(%esp)
801045d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045d3:	89 54 24 04          	mov    %edx,0x4(%esp)
801045d7:	89 04 24             	mov    %eax,(%esp)
801045da:	e8 c4 3c 00 00       	call   801082a3 <allocuvm>
801045df:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045e6:	75 41                	jne    80104629 <growproc+0x85>
      return -1;
801045e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ed:	eb 58                	jmp    80104647 <growproc+0xa3>
  } else if(n < 0){
801045ef:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045f3:	79 34                	jns    80104629 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801045f5:	8b 45 08             	mov    0x8(%ebp),%eax
801045f8:	89 c2                	mov    %eax,%edx
801045fa:	03 55 f4             	add    -0xc(%ebp),%edx
801045fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104603:	8b 40 04             	mov    0x4(%eax),%eax
80104606:	89 54 24 08          	mov    %edx,0x8(%esp)
8010460a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010460d:	89 54 24 04          	mov    %edx,0x4(%esp)
80104611:	89 04 24             	mov    %eax,(%esp)
80104614:	e8 64 3d 00 00       	call   8010837d <deallocuvm>
80104619:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010461c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104620:	75 07                	jne    80104629 <growproc+0x85>
      return -1;
80104622:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104627:	eb 1e                	jmp    80104647 <growproc+0xa3>
  }
  proc->sz = sz;
80104629:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010462f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104632:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104634:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010463a:	89 04 24             	mov    %eax,(%esp)
8010463d:	e8 80 39 00 00       	call   80107fc2 <switchuvm>
  return 0;
80104642:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104647:	c9                   	leave  
80104648:	c3                   	ret    

80104649 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104649:	55                   	push   %ebp
8010464a:	89 e5                	mov    %esp,%ebp
8010464c:	57                   	push   %edi
8010464d:	56                   	push   %esi
8010464e:	53                   	push   %ebx
8010464f:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104652:	e8 24 fd ff ff       	call   8010437b <allocproc>
80104657:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010465a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010465e:	75 0a                	jne    8010466a <fork+0x21>
    return -1;
80104660:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104665:	e9 6c 01 00 00       	jmp    801047d6 <fork+0x18d>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010466a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104670:	8b 10                	mov    (%eax),%edx
80104672:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104678:	8b 40 04             	mov    0x4(%eax),%eax
8010467b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010467f:	89 04 24             	mov    %eax,(%esp)
80104682:	e8 86 3e 00 00       	call   8010850d <copyuvm>
80104687:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010468a:	89 42 04             	mov    %eax,0x4(%edx)
8010468d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104690:	8b 40 04             	mov    0x4(%eax),%eax
80104693:	85 c0                	test   %eax,%eax
80104695:	75 2c                	jne    801046c3 <fork+0x7a>
    kfree(np->kstack);
80104697:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010469a:	8b 40 08             	mov    0x8(%eax),%eax
8010469d:	89 04 24             	mov    %eax,(%esp)
801046a0:	e8 15 e7 ff ff       	call   80102dba <kfree>
    np->kstack = 0;
801046a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046af:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046b2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046be:	e9 13 01 00 00       	jmp    801047d6 <fork+0x18d>
  }
  np->sz = proc->sz;
801046c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046c9:	8b 10                	mov    (%eax),%edx
801046cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ce:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801046d0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046da:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801046dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e0:	8b 50 18             	mov    0x18(%eax),%edx
801046e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e9:	8b 40 18             	mov    0x18(%eax),%eax
801046ec:	89 c3                	mov    %eax,%ebx
801046ee:	b8 13 00 00 00       	mov    $0x13,%eax
801046f3:	89 d7                	mov    %edx,%edi
801046f5:	89 de                	mov    %ebx,%esi
801046f7:	89 c1                	mov    %eax,%ecx
801046f9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801046fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046fe:	8b 40 18             	mov    0x18(%eax),%eax
80104701:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104708:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010470f:	eb 3d                	jmp    8010474e <fork+0x105>
    if(proc->ofile[i])
80104711:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104717:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010471a:	83 c2 08             	add    $0x8,%edx
8010471d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104721:	85 c0                	test   %eax,%eax
80104723:	74 25                	je     8010474a <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
80104725:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010472b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010472e:	83 c2 08             	add    $0x8,%edx
80104731:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104735:	89 04 24             	mov    %eax,(%esp)
80104738:	e8 93 cb ff ff       	call   801012d0 <filedup>
8010473d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104740:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104743:	83 c1 08             	add    $0x8,%ecx
80104746:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010474a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010474e:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104752:	7e bd                	jle    80104711 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104754:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010475a:	8b 40 68             	mov    0x68(%eax),%eax
8010475d:	89 04 24             	mov    %eax,(%esp)
80104760:	e8 25 d4 ff ff       	call   80101b8a <idup>
80104765:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104768:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
8010476b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010476e:	8b 40 10             	mov    0x10(%eax),%eax
80104771:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
80104774:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104777:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010477e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104784:	8d 50 6c             	lea    0x6c(%eax),%edx
80104787:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010478a:	83 c0 6c             	add    $0x6c,%eax
8010478d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104794:	00 
80104795:	89 54 24 04          	mov    %edx,0x4(%esp)
80104799:	89 04 24             	mov    %eax,(%esp)
8010479c:	e8 8d 0d 00 00       	call   8010552e <safestrcpy>
  acquire(&tickslock);
801047a1:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801047a8:	e8 02 09 00 00       	call   801050af <acquire>
  np->ctime = ticks;
801047ad:	a1 c0 29 11 80       	mov    0x801129c0,%eax
801047b2:	89 c2                	mov    %eax,%edx
801047b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047b7:	89 50 7c             	mov    %edx,0x7c(%eax)
  release(&tickslock);
801047ba:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801047c1:	e8 4b 09 00 00       	call   80105111 <release>
  np->rtime = 0;
801047c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047c9:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
801047d0:	00 00 00 
  return pid;
801047d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801047d6:	83 c4 2c             	add    $0x2c,%esp
801047d9:	5b                   	pop    %ebx
801047da:	5e                   	pop    %esi
801047db:	5f                   	pop    %edi
801047dc:	5d                   	pop    %ebp
801047dd:	c3                   	ret    

801047de <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801047de:	55                   	push   %ebp
801047df:	89 e5                	mov    %esp,%ebp
801047e1:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801047e4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047eb:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801047f0:	39 c2                	cmp    %eax,%edx
801047f2:	75 0c                	jne    80104800 <exit+0x22>
    panic("init exiting");
801047f4:	c7 04 24 18 8a 10 80 	movl   $0x80108a18,(%esp)
801047fb:	e8 3d bd ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104800:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104807:	eb 44                	jmp    8010484d <exit+0x6f>
    if(proc->ofile[fd]){
80104809:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010480f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104812:	83 c2 08             	add    $0x8,%edx
80104815:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104819:	85 c0                	test   %eax,%eax
8010481b:	74 2c                	je     80104849 <exit+0x6b>
      fileclose(proc->ofile[fd]);
8010481d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104823:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104826:	83 c2 08             	add    $0x8,%edx
80104829:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010482d:	89 04 24             	mov    %eax,(%esp)
80104830:	e8 e3 ca ff ff       	call   80101318 <fileclose>
      proc->ofile[fd] = 0;
80104835:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010483b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010483e:	83 c2 08             	add    $0x8,%edx
80104841:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104848:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104849:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010484d:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104851:	7e b6                	jle    80104809 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
80104853:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104859:	8b 40 68             	mov    0x68(%eax),%eax
8010485c:	89 04 24             	mov    %eax,(%esp)
8010485f:	e8 0b d5 ff ff       	call   80101d6f <iput>
  proc->cwd = 0;
80104864:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010486a:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104871:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104878:	e8 32 08 00 00       	call   801050af <acquire>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
8010487d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104883:	8b 40 14             	mov    0x14(%eax),%eax
80104886:	89 04 24             	mov    %eax,(%esp)
80104889:	e8 d6 05 00 00       	call   80104e64 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010488e:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104895:	eb 3b                	jmp    801048d2 <exit+0xf4>
    if(p->parent == proc){
80104897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010489a:	8b 50 14             	mov    0x14(%eax),%edx
8010489d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048a3:	39 c2                	cmp    %eax,%edx
801048a5:	75 24                	jne    801048cb <exit+0xed>
      p->parent = initproc;
801048a7:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
801048ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b0:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b6:	8b 40 0c             	mov    0xc(%eax),%eax
801048b9:	83 f8 05             	cmp    $0x5,%eax
801048bc:	75 0d                	jne    801048cb <exit+0xed>
        wakeup1(initproc);
801048be:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801048c3:	89 04 24             	mov    %eax,(%esp)
801048c6:	e8 99 05 00 00       	call   80104e64 <wakeup1>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048cb:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801048d2:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
801048d9:	72 bc                	jb     80104897 <exit+0xb9>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  acquire(&tickslock);
801048db:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801048e2:	e8 c8 07 00 00       	call   801050af <acquire>
  proc->etime = ticks;
801048e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ed:	8b 15 c0 29 11 80    	mov    0x801129c0,%edx
801048f3:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  release(&tickslock);
801048f9:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80104900:	e8 0c 08 00 00       	call   80105111 <release>
  proc->state = ZOMBIE;
80104905:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010490b:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104912:	e8 a2 03 00 00       	call   80104cb9 <sched>
  panic("zombie exit");
80104917:	c7 04 24 25 8a 10 80 	movl   $0x80108a25,(%esp)
8010491e:	e8 1a bc ff ff       	call   8010053d <panic>

80104923 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104923:	55                   	push   %ebp
80104924:	89 e5                	mov    %esp,%ebp
80104926:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104929:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104930:	e8 7a 07 00 00       	call   801050af <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104935:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010493c:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104943:	e9 9d 00 00 00       	jmp    801049e5 <wait+0xc2>
      if(p->parent != proc)
80104948:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494b:	8b 50 14             	mov    0x14(%eax),%edx
8010494e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104954:	39 c2                	cmp    %eax,%edx
80104956:	0f 85 81 00 00 00    	jne    801049dd <wait+0xba>
        continue;
      havekids = 1;
8010495c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104966:	8b 40 0c             	mov    0xc(%eax),%eax
80104969:	83 f8 05             	cmp    $0x5,%eax
8010496c:	75 70                	jne    801049de <wait+0xbb>
        // Found one.
        pid = p->pid;
8010496e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104971:	8b 40 10             	mov    0x10(%eax),%eax
80104974:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497a:	8b 40 08             	mov    0x8(%eax),%eax
8010497d:	89 04 24             	mov    %eax,(%esp)
80104980:	e8 35 e4 ff ff       	call   80102dba <kfree>
        p->kstack = 0;
80104985:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104988:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010498f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104992:	8b 40 04             	mov    0x4(%eax),%eax
80104995:	89 04 24             	mov    %eax,(%esp)
80104998:	e8 9c 3a 00 00       	call   80108439 <freevm>
        p->state = UNUSED;
8010499d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801049a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049aa:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801049b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801049bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049be:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801049c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c5:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
801049cc:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801049d3:	e8 39 07 00 00       	call   80105111 <release>
        return pid;
801049d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049db:	eb 56                	jmp    80104a33 <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801049dd:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049de:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801049e5:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
801049ec:	0f 82 56 ff ff ff    	jb     80104948 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801049f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049f6:	74 0d                	je     80104a05 <wait+0xe2>
801049f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049fe:	8b 40 24             	mov    0x24(%eax),%eax
80104a01:	85 c0                	test   %eax,%eax
80104a03:	74 13                	je     80104a18 <wait+0xf5>
      release(&ptable.lock);
80104a05:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104a0c:	e8 00 07 00 00       	call   80105111 <release>
      return -1;
80104a11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a16:	eb 1b                	jmp    80104a33 <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104a18:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a1e:	c7 44 24 04 40 ff 10 	movl   $0x8010ff40,0x4(%esp)
80104a25:	80 
80104a26:	89 04 24             	mov    %eax,(%esp)
80104a29:	e8 9b 03 00 00       	call   80104dc9 <sleep>
  }
80104a2e:	e9 02 ff ff ff       	jmp    80104935 <wait+0x12>
}
80104a33:	c9                   	leave  
80104a34:	c3                   	ret    

80104a35 <wait2>:

int
wait2(int *wtime, int *rtime)
{
80104a35:	55                   	push   %ebp
80104a36:	89 e5                	mov    %esp,%ebp
80104a38:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a3b:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104a42:	e8 68 06 00 00       	call   801050af <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a47:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a4e:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104a55:	e9 d3 00 00 00       	jmp    80104b2d <wait2+0xf8>
      if(p->parent != proc)
80104a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a5d:	8b 50 14             	mov    0x14(%eax),%edx
80104a60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a66:	39 c2                	cmp    %eax,%edx
80104a68:	0f 85 b7 00 00 00    	jne    80104b25 <wait2+0xf0>
        continue;
      havekids = 1;
80104a6e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a78:	8b 40 0c             	mov    0xc(%eax),%eax
80104a7b:	83 f8 05             	cmp    $0x5,%eax
80104a7e:	0f 85 a2 00 00 00    	jne    80104b26 <wait2+0xf1>
	*rtime = proc->rtime;
80104a84:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a8a:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104a90:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a93:	89 10                	mov    %edx,(%eax)
	*wtime = p->etime - p->ctime - p->rtime;
80104a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a98:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa1:	8b 40 7c             	mov    0x7c(%eax),%eax
80104aa4:	29 c2                	sub    %eax,%edx
80104aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa9:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104aaf:	29 c2                	sub    %eax,%edx
80104ab1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab4:	89 10                	mov    %edx,(%eax)
	// Found one.
        pid = p->pid;
80104ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab9:	8b 40 10             	mov    0x10(%eax),%eax
80104abc:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac2:	8b 40 08             	mov    0x8(%eax),%eax
80104ac5:	89 04 24             	mov    %eax,(%esp)
80104ac8:	e8 ed e2 ff ff       	call   80102dba <kfree>
        p->kstack = 0;
80104acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ada:	8b 40 04             	mov    0x4(%eax),%eax
80104add:	89 04 24             	mov    %eax,(%esp)
80104ae0:	e8 54 39 00 00       	call   80108439 <freevm>
        p->state = UNUSED;
80104ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af2:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104afc:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b06:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0d:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104b14:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104b1b:	e8 f1 05 00 00       	call   80105111 <release>
        return pid;
80104b20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b23:	eb 56                	jmp    80104b7b <wait2+0x146>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104b25:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b26:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104b2d:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
80104b34:	0f 82 20 ff ff ff    	jb     80104a5a <wait2+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b3a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b3e:	74 0d                	je     80104b4d <wait2+0x118>
80104b40:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b46:	8b 40 24             	mov    0x24(%eax),%eax
80104b49:	85 c0                	test   %eax,%eax
80104b4b:	74 13                	je     80104b60 <wait2+0x12b>
      release(&ptable.lock);
80104b4d:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104b54:	e8 b8 05 00 00       	call   80105111 <release>
      return -1;
80104b59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b5e:	eb 1b                	jmp    80104b7b <wait2+0x146>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b66:	c7 44 24 04 40 ff 10 	movl   $0x8010ff40,0x4(%esp)
80104b6d:	80 
80104b6e:	89 04 24             	mov    %eax,(%esp)
80104b71:	e8 53 02 00 00       	call   80104dc9 <sleep>
  }
80104b76:	e9 cc fe ff ff       	jmp    80104a47 <wait2+0x12>
  
  
  return proc->pid;
}
80104b7b:	c9                   	leave  
80104b7c:	c3                   	ret    

80104b7d <register_handler>:

void
register_handler(sighandler_t sighandler)
{
80104b7d:	55                   	push   %ebp
80104b7e:	89 e5                	mov    %esp,%ebp
80104b80:	83 ec 28             	sub    $0x28,%esp
  char* addr = uva2ka(proc->pgdir, (char*)proc->tf->esp);
80104b83:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b89:	8b 40 18             	mov    0x18(%eax),%eax
80104b8c:	8b 40 44             	mov    0x44(%eax),%eax
80104b8f:	89 c2                	mov    %eax,%edx
80104b91:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b97:	8b 40 04             	mov    0x4(%eax),%eax
80104b9a:	89 54 24 04          	mov    %edx,0x4(%esp)
80104b9e:	89 04 24             	mov    %eax,(%esp)
80104ba1:	e8 78 3a 00 00       	call   8010861e <uva2ka>
80104ba6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if ((proc->tf->esp & 0xFFF) == 0)
80104ba9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104baf:	8b 40 18             	mov    0x18(%eax),%eax
80104bb2:	8b 40 44             	mov    0x44(%eax),%eax
80104bb5:	25 ff 0f 00 00       	and    $0xfff,%eax
80104bba:	85 c0                	test   %eax,%eax
80104bbc:	75 0c                	jne    80104bca <register_handler+0x4d>
    panic("esp_offset == 0");
80104bbe:	c7 04 24 31 8a 10 80 	movl   $0x80108a31,(%esp)
80104bc5:	e8 73 b9 ff ff       	call   8010053d <panic>

    /* open a new frame */
  *(int*)(addr + ((proc->tf->esp - 4) & 0xFFF))
80104bca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bd0:	8b 40 18             	mov    0x18(%eax),%eax
80104bd3:	8b 40 44             	mov    0x44(%eax),%eax
80104bd6:	83 e8 04             	sub    $0x4,%eax
80104bd9:	25 ff 0f 00 00       	and    $0xfff,%eax
80104bde:	03 45 f4             	add    -0xc(%ebp),%eax
          = proc->tf->eip;
80104be1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104be8:	8b 52 18             	mov    0x18(%edx),%edx
80104beb:	8b 52 38             	mov    0x38(%edx),%edx
80104bee:	89 10                	mov    %edx,(%eax)
  proc->tf->esp -= 4;
80104bf0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bf6:	8b 40 18             	mov    0x18(%eax),%eax
80104bf9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104c00:	8b 52 18             	mov    0x18(%edx),%edx
80104c03:	8b 52 44             	mov    0x44(%edx),%edx
80104c06:	83 ea 04             	sub    $0x4,%edx
80104c09:	89 50 44             	mov    %edx,0x44(%eax)

    /* update eip */
  proc->tf->eip = (uint)sighandler;
80104c0c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c12:	8b 40 18             	mov    0x18(%eax),%eax
80104c15:	8b 55 08             	mov    0x8(%ebp),%edx
80104c18:	89 50 38             	mov    %edx,0x38(%eax)
}
80104c1b:	c9                   	leave  
80104c1c:	c3                   	ret    

80104c1d <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c1d:	55                   	push   %ebp
80104c1e:	89 e5                	mov    %esp,%ebp
80104c20:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c23:	e8 31 f7 ff ff       	call   80104359 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104c28:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104c2f:	e8 7b 04 00 00       	call   801050af <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c34:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104c3b:	eb 62                	jmp    80104c9f <scheduler+0x82>
      if(p->state != RUNNABLE)
80104c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c40:	8b 40 0c             	mov    0xc(%eax),%eax
80104c43:	83 f8 03             	cmp    $0x3,%eax
80104c46:	75 4f                	jne    80104c97 <scheduler+0x7a>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c4b:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c54:	89 04 24             	mov    %eax,(%esp)
80104c57:	e8 66 33 00 00       	call   80107fc2 <switchuvm>
      p->state = RUNNING;
80104c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c5f:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104c66:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c6c:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c6f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104c76:	83 c2 04             	add    $0x4,%edx
80104c79:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c7d:	89 14 24             	mov    %edx,(%esp)
80104c80:	e8 1f 09 00 00       	call   801055a4 <swtch>
      switchkvm();
80104c85:	e8 1b 33 00 00       	call   80107fa5 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104c8a:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104c91:	00 00 00 00 
80104c95:	eb 01                	jmp    80104c98 <scheduler+0x7b>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104c97:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c98:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104c9f:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
80104ca6:	72 95                	jb     80104c3d <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104ca8:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104caf:	e8 5d 04 00 00       	call   80105111 <release>

  }
80104cb4:	e9 6a ff ff ff       	jmp    80104c23 <scheduler+0x6>

80104cb9 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104cb9:	55                   	push   %ebp
80104cba:	89 e5                	mov    %esp,%ebp
80104cbc:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104cbf:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104cc6:	e8 02 05 00 00       	call   801051cd <holding>
80104ccb:	85 c0                	test   %eax,%eax
80104ccd:	75 0c                	jne    80104cdb <sched+0x22>
    panic("sched ptable.lock");
80104ccf:	c7 04 24 41 8a 10 80 	movl   $0x80108a41,(%esp)
80104cd6:	e8 62 b8 ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80104cdb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ce1:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104ce7:	83 f8 01             	cmp    $0x1,%eax
80104cea:	74 0c                	je     80104cf8 <sched+0x3f>
    panic("sched locks");
80104cec:	c7 04 24 53 8a 10 80 	movl   $0x80108a53,(%esp)
80104cf3:	e8 45 b8 ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104cf8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cfe:	8b 40 0c             	mov    0xc(%eax),%eax
80104d01:	83 f8 04             	cmp    $0x4,%eax
80104d04:	75 0c                	jne    80104d12 <sched+0x59>
    panic("sched running");
80104d06:	c7 04 24 5f 8a 10 80 	movl   $0x80108a5f,(%esp)
80104d0d:	e8 2b b8 ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104d12:	e8 2d f6 ff ff       	call   80104344 <readeflags>
80104d17:	25 00 02 00 00       	and    $0x200,%eax
80104d1c:	85 c0                	test   %eax,%eax
80104d1e:	74 0c                	je     80104d2c <sched+0x73>
    panic("sched interruptible");
80104d20:	c7 04 24 6d 8a 10 80 	movl   $0x80108a6d,(%esp)
80104d27:	e8 11 b8 ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80104d2c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d32:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104d38:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104d3b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d41:	8b 40 04             	mov    0x4(%eax),%eax
80104d44:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104d4b:	83 c2 1c             	add    $0x1c,%edx
80104d4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d52:	89 14 24             	mov    %edx,(%esp)
80104d55:	e8 4a 08 00 00       	call   801055a4 <swtch>
  cpu->intena = intena;
80104d5a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d60:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d63:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104d69:	c9                   	leave  
80104d6a:	c3                   	ret    

80104d6b <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104d6b:	55                   	push   %ebp
80104d6c:	89 e5                	mov    %esp,%ebp
80104d6e:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104d71:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104d78:	e8 32 03 00 00       	call   801050af <acquire>
  proc->state = RUNNABLE;
80104d7d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d83:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104d8a:	e8 2a ff ff ff       	call   80104cb9 <sched>
  release(&ptable.lock);
80104d8f:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104d96:	e8 76 03 00 00       	call   80105111 <release>
}
80104d9b:	c9                   	leave  
80104d9c:	c3                   	ret    

80104d9d <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104d9d:	55                   	push   %ebp
80104d9e:	89 e5                	mov    %esp,%ebp
80104da0:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104da3:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104daa:	e8 62 03 00 00       	call   80105111 <release>

  if (first) {
80104daf:	a1 20 b0 10 80       	mov    0x8010b020,%eax
80104db4:	85 c0                	test   %eax,%eax
80104db6:	74 0f                	je     80104dc7 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104db8:	c7 05 20 b0 10 80 00 	movl   $0x0,0x8010b020
80104dbf:	00 00 00 
    initlog();
80104dc2:	e8 9d e5 ff ff       	call   80103364 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104dc7:	c9                   	leave  
80104dc8:	c3                   	ret    

80104dc9 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104dc9:	55                   	push   %ebp
80104dca:	89 e5                	mov    %esp,%ebp
80104dcc:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104dcf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dd5:	85 c0                	test   %eax,%eax
80104dd7:	75 0c                	jne    80104de5 <sleep+0x1c>
    panic("sleep");
80104dd9:	c7 04 24 81 8a 10 80 	movl   $0x80108a81,(%esp)
80104de0:	e8 58 b7 ff ff       	call   8010053d <panic>

  if(lk == 0)
80104de5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104de9:	75 0c                	jne    80104df7 <sleep+0x2e>
    panic("sleep without lk");
80104deb:	c7 04 24 87 8a 10 80 	movl   $0x80108a87,(%esp)
80104df2:	e8 46 b7 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104df7:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104dfe:	74 17                	je     80104e17 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104e00:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e07:	e8 a3 02 00 00       	call   801050af <acquire>
    release(lk);
80104e0c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e0f:	89 04 24             	mov    %eax,(%esp)
80104e12:	e8 fa 02 00 00       	call   80105111 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104e17:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e1d:	8b 55 08             	mov    0x8(%ebp),%edx
80104e20:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104e23:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e29:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104e30:	e8 84 fe ff ff       	call   80104cb9 <sched>

  // Tidy up.
  proc->chan = 0;
80104e35:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e3b:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104e42:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104e49:	74 17                	je     80104e62 <sleep+0x99>
    release(&ptable.lock);
80104e4b:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e52:	e8 ba 02 00 00       	call   80105111 <release>
    acquire(lk);
80104e57:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e5a:	89 04 24             	mov    %eax,(%esp)
80104e5d:	e8 4d 02 00 00       	call   801050af <acquire>
  }
}
80104e62:	c9                   	leave  
80104e63:	c3                   	ret    

80104e64 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104e64:	55                   	push   %ebp
80104e65:	89 e5                	mov    %esp,%ebp
80104e67:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e6a:	c7 45 fc 74 ff 10 80 	movl   $0x8010ff74,-0x4(%ebp)
80104e71:	eb 27                	jmp    80104e9a <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104e73:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e76:	8b 40 0c             	mov    0xc(%eax),%eax
80104e79:	83 f8 02             	cmp    $0x2,%eax
80104e7c:	75 15                	jne    80104e93 <wakeup1+0x2f>
80104e7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e81:	8b 40 20             	mov    0x20(%eax),%eax
80104e84:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e87:	75 0a                	jne    80104e93 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104e89:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e8c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e93:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
80104e9a:	81 7d fc 74 21 11 80 	cmpl   $0x80112174,-0x4(%ebp)
80104ea1:	72 d0                	jb     80104e73 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104ea3:	c9                   	leave  
80104ea4:	c3                   	ret    

80104ea5 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104ea5:	55                   	push   %ebp
80104ea6:	89 e5                	mov    %esp,%ebp
80104ea8:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104eab:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104eb2:	e8 f8 01 00 00       	call   801050af <acquire>
  wakeup1(chan);
80104eb7:	8b 45 08             	mov    0x8(%ebp),%eax
80104eba:	89 04 24             	mov    %eax,(%esp)
80104ebd:	e8 a2 ff ff ff       	call   80104e64 <wakeup1>
  release(&ptable.lock);
80104ec2:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104ec9:	e8 43 02 00 00       	call   80105111 <release>
}
80104ece:	c9                   	leave  
80104ecf:	c3                   	ret    

80104ed0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104ed0:	55                   	push   %ebp
80104ed1:	89 e5                	mov    %esp,%ebp
80104ed3:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104ed6:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104edd:	e8 cd 01 00 00       	call   801050af <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ee2:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104ee9:	eb 44                	jmp    80104f2f <kill+0x5f>
    if(p->pid == pid){
80104eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eee:	8b 40 10             	mov    0x10(%eax),%eax
80104ef1:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ef4:	75 32                	jne    80104f28 <kill+0x58>
      p->killed = 1;
80104ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ef9:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104f00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f03:	8b 40 0c             	mov    0xc(%eax),%eax
80104f06:	83 f8 02             	cmp    $0x2,%eax
80104f09:	75 0a                	jne    80104f15 <kill+0x45>
        p->state = RUNNABLE;
80104f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f0e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104f15:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f1c:	e8 f0 01 00 00       	call   80105111 <release>
      return 0;
80104f21:	b8 00 00 00 00       	mov    $0x0,%eax
80104f26:	eb 21                	jmp    80104f49 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f28:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104f2f:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
80104f36:	72 b3                	jb     80104eeb <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104f38:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f3f:	e8 cd 01 00 00       	call   80105111 <release>
  return -1;
80104f44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f49:	c9                   	leave  
80104f4a:	c3                   	ret    

80104f4b <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104f4b:	55                   	push   %ebp
80104f4c:	89 e5                	mov    %esp,%ebp
80104f4e:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f51:	c7 45 f0 74 ff 10 80 	movl   $0x8010ff74,-0x10(%ebp)
80104f58:	e9 db 00 00 00       	jmp    80105038 <procdump+0xed>
    if(p->state == UNUSED)
80104f5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f60:	8b 40 0c             	mov    0xc(%eax),%eax
80104f63:	85 c0                	test   %eax,%eax
80104f65:	0f 84 c5 00 00 00    	je     80105030 <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104f6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f6e:	8b 40 0c             	mov    0xc(%eax),%eax
80104f71:	83 f8 05             	cmp    $0x5,%eax
80104f74:	77 23                	ja     80104f99 <procdump+0x4e>
80104f76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f79:	8b 40 0c             	mov    0xc(%eax),%eax
80104f7c:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104f83:	85 c0                	test   %eax,%eax
80104f85:	74 12                	je     80104f99 <procdump+0x4e>
      state = states[p->state];
80104f87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f8a:	8b 40 0c             	mov    0xc(%eax),%eax
80104f8d:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104f94:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104f97:	eb 07                	jmp    80104fa0 <procdump+0x55>
    else
      state = "???";
80104f99:	c7 45 ec 98 8a 10 80 	movl   $0x80108a98,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104fa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fa3:	8d 50 6c             	lea    0x6c(%eax),%edx
80104fa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fa9:	8b 40 10             	mov    0x10(%eax),%eax
80104fac:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104fb0:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104fb3:	89 54 24 08          	mov    %edx,0x8(%esp)
80104fb7:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fbb:	c7 04 24 9c 8a 10 80 	movl   $0x80108a9c,(%esp)
80104fc2:	e8 da b3 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
80104fc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fca:	8b 40 0c             	mov    0xc(%eax),%eax
80104fcd:	83 f8 02             	cmp    $0x2,%eax
80104fd0:	75 50                	jne    80105022 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104fd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fd5:	8b 40 1c             	mov    0x1c(%eax),%eax
80104fd8:	8b 40 0c             	mov    0xc(%eax),%eax
80104fdb:	83 c0 08             	add    $0x8,%eax
80104fde:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104fe1:	89 54 24 04          	mov    %edx,0x4(%esp)
80104fe5:	89 04 24             	mov    %eax,(%esp)
80104fe8:	e8 73 01 00 00       	call   80105160 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104fed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104ff4:	eb 1b                	jmp    80105011 <procdump+0xc6>
        cprintf(" %p", pc[i]);
80104ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ff9:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104ffd:	89 44 24 04          	mov    %eax,0x4(%esp)
80105001:	c7 04 24 a5 8a 10 80 	movl   $0x80108aa5,(%esp)
80105008:	e8 94 b3 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
8010500d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105011:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105015:	7f 0b                	jg     80105022 <procdump+0xd7>
80105017:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010501a:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010501e:	85 c0                	test   %eax,%eax
80105020:	75 d4                	jne    80104ff6 <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105022:	c7 04 24 a9 8a 10 80 	movl   $0x80108aa9,(%esp)
80105029:	e8 73 b3 ff ff       	call   801003a1 <cprintf>
8010502e:	eb 01                	jmp    80105031 <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105030:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105031:	81 45 f0 88 00 00 00 	addl   $0x88,-0x10(%ebp)
80105038:	81 7d f0 74 21 11 80 	cmpl   $0x80112174,-0x10(%ebp)
8010503f:	0f 82 18 ff ff ff    	jb     80104f5d <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105045:	c9                   	leave  
80105046:	c3                   	ret    
	...

80105048 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105048:	55                   	push   %ebp
80105049:	89 e5                	mov    %esp,%ebp
8010504b:	53                   	push   %ebx
8010504c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010504f:	9c                   	pushf  
80105050:	5b                   	pop    %ebx
80105051:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80105054:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105057:	83 c4 10             	add    $0x10,%esp
8010505a:	5b                   	pop    %ebx
8010505b:	5d                   	pop    %ebp
8010505c:	c3                   	ret    

8010505d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010505d:	55                   	push   %ebp
8010505e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105060:	fa                   	cli    
}
80105061:	5d                   	pop    %ebp
80105062:	c3                   	ret    

80105063 <sti>:

static inline void
sti(void)
{
80105063:	55                   	push   %ebp
80105064:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105066:	fb                   	sti    
}
80105067:	5d                   	pop    %ebp
80105068:	c3                   	ret    

80105069 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105069:	55                   	push   %ebp
8010506a:	89 e5                	mov    %esp,%ebp
8010506c:	53                   	push   %ebx
8010506d:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80105070:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105073:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80105076:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105079:	89 c3                	mov    %eax,%ebx
8010507b:	89 d8                	mov    %ebx,%eax
8010507d:	f0 87 02             	lock xchg %eax,(%edx)
80105080:	89 c3                	mov    %eax,%ebx
80105082:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105085:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105088:	83 c4 10             	add    $0x10,%esp
8010508b:	5b                   	pop    %ebx
8010508c:	5d                   	pop    %ebp
8010508d:	c3                   	ret    

8010508e <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010508e:	55                   	push   %ebp
8010508f:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105091:	8b 45 08             	mov    0x8(%ebp),%eax
80105094:	8b 55 0c             	mov    0xc(%ebp),%edx
80105097:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010509a:	8b 45 08             	mov    0x8(%ebp),%eax
8010509d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801050a3:	8b 45 08             	mov    0x8(%ebp),%eax
801050a6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801050ad:	5d                   	pop    %ebp
801050ae:	c3                   	ret    

801050af <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801050af:	55                   	push   %ebp
801050b0:	89 e5                	mov    %esp,%ebp
801050b2:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801050b5:	e8 3d 01 00 00       	call   801051f7 <pushcli>
  if(holding(lk))
801050ba:	8b 45 08             	mov    0x8(%ebp),%eax
801050bd:	89 04 24             	mov    %eax,(%esp)
801050c0:	e8 08 01 00 00       	call   801051cd <holding>
801050c5:	85 c0                	test   %eax,%eax
801050c7:	74 0c                	je     801050d5 <acquire+0x26>
    panic("acquire");
801050c9:	c7 04 24 d5 8a 10 80 	movl   $0x80108ad5,(%esp)
801050d0:	e8 68 b4 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801050d5:	90                   	nop
801050d6:	8b 45 08             	mov    0x8(%ebp),%eax
801050d9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801050e0:	00 
801050e1:	89 04 24             	mov    %eax,(%esp)
801050e4:	e8 80 ff ff ff       	call   80105069 <xchg>
801050e9:	85 c0                	test   %eax,%eax
801050eb:	75 e9                	jne    801050d6 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801050ed:	8b 45 08             	mov    0x8(%ebp),%eax
801050f0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801050f7:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801050fa:	8b 45 08             	mov    0x8(%ebp),%eax
801050fd:	83 c0 0c             	add    $0xc,%eax
80105100:	89 44 24 04          	mov    %eax,0x4(%esp)
80105104:	8d 45 08             	lea    0x8(%ebp),%eax
80105107:	89 04 24             	mov    %eax,(%esp)
8010510a:	e8 51 00 00 00       	call   80105160 <getcallerpcs>
}
8010510f:	c9                   	leave  
80105110:	c3                   	ret    

80105111 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105111:	55                   	push   %ebp
80105112:	89 e5                	mov    %esp,%ebp
80105114:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105117:	8b 45 08             	mov    0x8(%ebp),%eax
8010511a:	89 04 24             	mov    %eax,(%esp)
8010511d:	e8 ab 00 00 00       	call   801051cd <holding>
80105122:	85 c0                	test   %eax,%eax
80105124:	75 0c                	jne    80105132 <release+0x21>
    panic("release");
80105126:	c7 04 24 dd 8a 10 80 	movl   $0x80108add,(%esp)
8010512d:	e8 0b b4 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
80105132:	8b 45 08             	mov    0x8(%ebp),%eax
80105135:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010513c:	8b 45 08             	mov    0x8(%ebp),%eax
8010513f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105146:	8b 45 08             	mov    0x8(%ebp),%eax
80105149:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105150:	00 
80105151:	89 04 24             	mov    %eax,(%esp)
80105154:	e8 10 ff ff ff       	call   80105069 <xchg>

  popcli();
80105159:	e8 e1 00 00 00       	call   8010523f <popcli>
}
8010515e:	c9                   	leave  
8010515f:	c3                   	ret    

80105160 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105160:	55                   	push   %ebp
80105161:	89 e5                	mov    %esp,%ebp
80105163:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105166:	8b 45 08             	mov    0x8(%ebp),%eax
80105169:	83 e8 08             	sub    $0x8,%eax
8010516c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010516f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105176:	eb 32                	jmp    801051aa <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105178:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010517c:	74 47                	je     801051c5 <getcallerpcs+0x65>
8010517e:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105185:	76 3e                	jbe    801051c5 <getcallerpcs+0x65>
80105187:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010518b:	74 38                	je     801051c5 <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010518d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105190:	c1 e0 02             	shl    $0x2,%eax
80105193:	03 45 0c             	add    0xc(%ebp),%eax
80105196:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105199:	8b 52 04             	mov    0x4(%edx),%edx
8010519c:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
8010519e:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051a1:	8b 00                	mov    (%eax),%eax
801051a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801051a6:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051aa:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051ae:	7e c8                	jle    80105178 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801051b0:	eb 13                	jmp    801051c5 <getcallerpcs+0x65>
    pcs[i] = 0;
801051b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051b5:	c1 e0 02             	shl    $0x2,%eax
801051b8:	03 45 0c             	add    0xc(%ebp),%eax
801051bb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801051c1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051c5:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051c9:	7e e7                	jle    801051b2 <getcallerpcs+0x52>
    pcs[i] = 0;
}
801051cb:	c9                   	leave  
801051cc:	c3                   	ret    

801051cd <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801051cd:	55                   	push   %ebp
801051ce:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801051d0:	8b 45 08             	mov    0x8(%ebp),%eax
801051d3:	8b 00                	mov    (%eax),%eax
801051d5:	85 c0                	test   %eax,%eax
801051d7:	74 17                	je     801051f0 <holding+0x23>
801051d9:	8b 45 08             	mov    0x8(%ebp),%eax
801051dc:	8b 50 08             	mov    0x8(%eax),%edx
801051df:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051e5:	39 c2                	cmp    %eax,%edx
801051e7:	75 07                	jne    801051f0 <holding+0x23>
801051e9:	b8 01 00 00 00       	mov    $0x1,%eax
801051ee:	eb 05                	jmp    801051f5 <holding+0x28>
801051f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051f5:	5d                   	pop    %ebp
801051f6:	c3                   	ret    

801051f7 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801051f7:	55                   	push   %ebp
801051f8:	89 e5                	mov    %esp,%ebp
801051fa:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801051fd:	e8 46 fe ff ff       	call   80105048 <readeflags>
80105202:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105205:	e8 53 fe ff ff       	call   8010505d <cli>
  if(cpu->ncli++ == 0)
8010520a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105210:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105216:	85 d2                	test   %edx,%edx
80105218:	0f 94 c1             	sete   %cl
8010521b:	83 c2 01             	add    $0x1,%edx
8010521e:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105224:	84 c9                	test   %cl,%cl
80105226:	74 15                	je     8010523d <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80105228:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010522e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105231:	81 e2 00 02 00 00    	and    $0x200,%edx
80105237:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010523d:	c9                   	leave  
8010523e:	c3                   	ret    

8010523f <popcli>:

void
popcli(void)
{
8010523f:	55                   	push   %ebp
80105240:	89 e5                	mov    %esp,%ebp
80105242:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105245:	e8 fe fd ff ff       	call   80105048 <readeflags>
8010524a:	25 00 02 00 00       	and    $0x200,%eax
8010524f:	85 c0                	test   %eax,%eax
80105251:	74 0c                	je     8010525f <popcli+0x20>
    panic("popcli - interruptible");
80105253:	c7 04 24 e5 8a 10 80 	movl   $0x80108ae5,(%esp)
8010525a:	e8 de b2 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
8010525f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105265:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010526b:	83 ea 01             	sub    $0x1,%edx
8010526e:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105274:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010527a:	85 c0                	test   %eax,%eax
8010527c:	79 0c                	jns    8010528a <popcli+0x4b>
    panic("popcli");
8010527e:	c7 04 24 fc 8a 10 80 	movl   $0x80108afc,(%esp)
80105285:	e8 b3 b2 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
8010528a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105290:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105296:	85 c0                	test   %eax,%eax
80105298:	75 15                	jne    801052af <popcli+0x70>
8010529a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052a0:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801052a6:	85 c0                	test   %eax,%eax
801052a8:	74 05                	je     801052af <popcli+0x70>
    sti();
801052aa:	e8 b4 fd ff ff       	call   80105063 <sti>
}
801052af:	c9                   	leave  
801052b0:	c3                   	ret    
801052b1:	00 00                	add    %al,(%eax)
	...

801052b4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801052b4:	55                   	push   %ebp
801052b5:	89 e5                	mov    %esp,%ebp
801052b7:	57                   	push   %edi
801052b8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801052b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052bc:	8b 55 10             	mov    0x10(%ebp),%edx
801052bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801052c2:	89 cb                	mov    %ecx,%ebx
801052c4:	89 df                	mov    %ebx,%edi
801052c6:	89 d1                	mov    %edx,%ecx
801052c8:	fc                   	cld    
801052c9:	f3 aa                	rep stos %al,%es:(%edi)
801052cb:	89 ca                	mov    %ecx,%edx
801052cd:	89 fb                	mov    %edi,%ebx
801052cf:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052d2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801052d5:	5b                   	pop    %ebx
801052d6:	5f                   	pop    %edi
801052d7:	5d                   	pop    %ebp
801052d8:	c3                   	ret    

801052d9 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801052d9:	55                   	push   %ebp
801052da:	89 e5                	mov    %esp,%ebp
801052dc:	57                   	push   %edi
801052dd:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801052de:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052e1:	8b 55 10             	mov    0x10(%ebp),%edx
801052e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801052e7:	89 cb                	mov    %ecx,%ebx
801052e9:	89 df                	mov    %ebx,%edi
801052eb:	89 d1                	mov    %edx,%ecx
801052ed:	fc                   	cld    
801052ee:	f3 ab                	rep stos %eax,%es:(%edi)
801052f0:	89 ca                	mov    %ecx,%edx
801052f2:	89 fb                	mov    %edi,%ebx
801052f4:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052f7:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801052fa:	5b                   	pop    %ebx
801052fb:	5f                   	pop    %edi
801052fc:	5d                   	pop    %ebp
801052fd:	c3                   	ret    

801052fe <memset>:
#include "x86.h"
#include "string.h"

void*
memset(void *dst, int c, uint n)
{
801052fe:	55                   	push   %ebp
801052ff:	89 e5                	mov    %esp,%ebp
80105301:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105304:	8b 45 08             	mov    0x8(%ebp),%eax
80105307:	83 e0 03             	and    $0x3,%eax
8010530a:	85 c0                	test   %eax,%eax
8010530c:	75 49                	jne    80105357 <memset+0x59>
8010530e:	8b 45 10             	mov    0x10(%ebp),%eax
80105311:	83 e0 03             	and    $0x3,%eax
80105314:	85 c0                	test   %eax,%eax
80105316:	75 3f                	jne    80105357 <memset+0x59>
    c &= 0xFF;
80105318:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010531f:	8b 45 10             	mov    0x10(%ebp),%eax
80105322:	c1 e8 02             	shr    $0x2,%eax
80105325:	89 c2                	mov    %eax,%edx
80105327:	8b 45 0c             	mov    0xc(%ebp),%eax
8010532a:	89 c1                	mov    %eax,%ecx
8010532c:	c1 e1 18             	shl    $0x18,%ecx
8010532f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105332:	c1 e0 10             	shl    $0x10,%eax
80105335:	09 c1                	or     %eax,%ecx
80105337:	8b 45 0c             	mov    0xc(%ebp),%eax
8010533a:	c1 e0 08             	shl    $0x8,%eax
8010533d:	09 c8                	or     %ecx,%eax
8010533f:	0b 45 0c             	or     0xc(%ebp),%eax
80105342:	89 54 24 08          	mov    %edx,0x8(%esp)
80105346:	89 44 24 04          	mov    %eax,0x4(%esp)
8010534a:	8b 45 08             	mov    0x8(%ebp),%eax
8010534d:	89 04 24             	mov    %eax,(%esp)
80105350:	e8 84 ff ff ff       	call   801052d9 <stosl>
80105355:	eb 19                	jmp    80105370 <memset+0x72>
  } else
    stosb(dst, c, n);
80105357:	8b 45 10             	mov    0x10(%ebp),%eax
8010535a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010535e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105361:	89 44 24 04          	mov    %eax,0x4(%esp)
80105365:	8b 45 08             	mov    0x8(%ebp),%eax
80105368:	89 04 24             	mov    %eax,(%esp)
8010536b:	e8 44 ff ff ff       	call   801052b4 <stosb>
  return dst;
80105370:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105373:	c9                   	leave  
80105374:	c3                   	ret    

80105375 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105375:	55                   	push   %ebp
80105376:	89 e5                	mov    %esp,%ebp
80105378:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010537b:	8b 45 08             	mov    0x8(%ebp),%eax
8010537e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105381:	8b 45 0c             	mov    0xc(%ebp),%eax
80105384:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105387:	eb 32                	jmp    801053bb <memcmp+0x46>
    if(*s1 != *s2)
80105389:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010538c:	0f b6 10             	movzbl (%eax),%edx
8010538f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105392:	0f b6 00             	movzbl (%eax),%eax
80105395:	38 c2                	cmp    %al,%dl
80105397:	74 1a                	je     801053b3 <memcmp+0x3e>
      return *s1 - *s2;
80105399:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010539c:	0f b6 00             	movzbl (%eax),%eax
8010539f:	0f b6 d0             	movzbl %al,%edx
801053a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053a5:	0f b6 00             	movzbl (%eax),%eax
801053a8:	0f b6 c0             	movzbl %al,%eax
801053ab:	89 d1                	mov    %edx,%ecx
801053ad:	29 c1                	sub    %eax,%ecx
801053af:	89 c8                	mov    %ecx,%eax
801053b1:	eb 1c                	jmp    801053cf <memcmp+0x5a>
    s1++, s2++;
801053b3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801053b7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801053bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053bf:	0f 95 c0             	setne  %al
801053c2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801053c6:	84 c0                	test   %al,%al
801053c8:	75 bf                	jne    80105389 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801053ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053cf:	c9                   	leave  
801053d0:	c3                   	ret    

801053d1 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801053d1:	55                   	push   %ebp
801053d2:	89 e5                	mov    %esp,%ebp
801053d4:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801053d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801053da:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801053dd:	8b 45 08             	mov    0x8(%ebp),%eax
801053e0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801053e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053e6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801053e9:	73 54                	jae    8010543f <memmove+0x6e>
801053eb:	8b 45 10             	mov    0x10(%ebp),%eax
801053ee:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053f1:	01 d0                	add    %edx,%eax
801053f3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801053f6:	76 47                	jbe    8010543f <memmove+0x6e>
    s += n;
801053f8:	8b 45 10             	mov    0x10(%ebp),%eax
801053fb:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801053fe:	8b 45 10             	mov    0x10(%ebp),%eax
80105401:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105404:	eb 13                	jmp    80105419 <memmove+0x48>
      *--d = *--s;
80105406:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010540a:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010540e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105411:	0f b6 10             	movzbl (%eax),%edx
80105414:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105417:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105419:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010541d:	0f 95 c0             	setne  %al
80105420:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105424:	84 c0                	test   %al,%al
80105426:	75 de                	jne    80105406 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105428:	eb 25                	jmp    8010544f <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
8010542a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010542d:	0f b6 10             	movzbl (%eax),%edx
80105430:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105433:	88 10                	mov    %dl,(%eax)
80105435:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105439:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010543d:	eb 01                	jmp    80105440 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010543f:	90                   	nop
80105440:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105444:	0f 95 c0             	setne  %al
80105447:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010544b:	84 c0                	test   %al,%al
8010544d:	75 db                	jne    8010542a <memmove+0x59>
      *d++ = *s++;

  return dst;
8010544f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105452:	c9                   	leave  
80105453:	c3                   	ret    

80105454 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105454:	55                   	push   %ebp
80105455:	89 e5                	mov    %esp,%ebp
80105457:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010545a:	8b 45 10             	mov    0x10(%ebp),%eax
8010545d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105461:	8b 45 0c             	mov    0xc(%ebp),%eax
80105464:	89 44 24 04          	mov    %eax,0x4(%esp)
80105468:	8b 45 08             	mov    0x8(%ebp),%eax
8010546b:	89 04 24             	mov    %eax,(%esp)
8010546e:	e8 5e ff ff ff       	call   801053d1 <memmove>
}
80105473:	c9                   	leave  
80105474:	c3                   	ret    

80105475 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105475:	55                   	push   %ebp
80105476:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105478:	eb 0c                	jmp    80105486 <strncmp+0x11>
    n--, p++, q++;
8010547a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010547e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105482:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105486:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010548a:	74 1a                	je     801054a6 <strncmp+0x31>
8010548c:	8b 45 08             	mov    0x8(%ebp),%eax
8010548f:	0f b6 00             	movzbl (%eax),%eax
80105492:	84 c0                	test   %al,%al
80105494:	74 10                	je     801054a6 <strncmp+0x31>
80105496:	8b 45 08             	mov    0x8(%ebp),%eax
80105499:	0f b6 10             	movzbl (%eax),%edx
8010549c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010549f:	0f b6 00             	movzbl (%eax),%eax
801054a2:	38 c2                	cmp    %al,%dl
801054a4:	74 d4                	je     8010547a <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801054a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054aa:	75 07                	jne    801054b3 <strncmp+0x3e>
    return 0;
801054ac:	b8 00 00 00 00       	mov    $0x0,%eax
801054b1:	eb 18                	jmp    801054cb <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
801054b3:	8b 45 08             	mov    0x8(%ebp),%eax
801054b6:	0f b6 00             	movzbl (%eax),%eax
801054b9:	0f b6 d0             	movzbl %al,%edx
801054bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801054bf:	0f b6 00             	movzbl (%eax),%eax
801054c2:	0f b6 c0             	movzbl %al,%eax
801054c5:	89 d1                	mov    %edx,%ecx
801054c7:	29 c1                	sub    %eax,%ecx
801054c9:	89 c8                	mov    %ecx,%eax
}
801054cb:	5d                   	pop    %ebp
801054cc:	c3                   	ret    

801054cd <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801054cd:	55                   	push   %ebp
801054ce:	89 e5                	mov    %esp,%ebp
801054d0:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801054d3:	8b 45 08             	mov    0x8(%ebp),%eax
801054d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801054d9:	90                   	nop
801054da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054de:	0f 9f c0             	setg   %al
801054e1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054e5:	84 c0                	test   %al,%al
801054e7:	74 30                	je     80105519 <strncpy+0x4c>
801054e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ec:	0f b6 10             	movzbl (%eax),%edx
801054ef:	8b 45 08             	mov    0x8(%ebp),%eax
801054f2:	88 10                	mov    %dl,(%eax)
801054f4:	8b 45 08             	mov    0x8(%ebp),%eax
801054f7:	0f b6 00             	movzbl (%eax),%eax
801054fa:	84 c0                	test   %al,%al
801054fc:	0f 95 c0             	setne  %al
801054ff:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105503:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105507:	84 c0                	test   %al,%al
80105509:	75 cf                	jne    801054da <strncpy+0xd>
    ;
  while(n-- > 0)
8010550b:	eb 0c                	jmp    80105519 <strncpy+0x4c>
    *s++ = 0;
8010550d:	8b 45 08             	mov    0x8(%ebp),%eax
80105510:	c6 00 00             	movb   $0x0,(%eax)
80105513:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105517:	eb 01                	jmp    8010551a <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105519:	90                   	nop
8010551a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010551e:	0f 9f c0             	setg   %al
80105521:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105525:	84 c0                	test   %al,%al
80105527:	75 e4                	jne    8010550d <strncpy+0x40>
    *s++ = 0;
  return os;
80105529:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010552c:	c9                   	leave  
8010552d:	c3                   	ret    

8010552e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010552e:	55                   	push   %ebp
8010552f:	89 e5                	mov    %esp,%ebp
80105531:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105534:	8b 45 08             	mov    0x8(%ebp),%eax
80105537:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010553a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010553e:	7f 05                	jg     80105545 <safestrcpy+0x17>
    return os;
80105540:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105543:	eb 35                	jmp    8010557a <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105545:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105549:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010554d:	7e 22                	jle    80105571 <safestrcpy+0x43>
8010554f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105552:	0f b6 10             	movzbl (%eax),%edx
80105555:	8b 45 08             	mov    0x8(%ebp),%eax
80105558:	88 10                	mov    %dl,(%eax)
8010555a:	8b 45 08             	mov    0x8(%ebp),%eax
8010555d:	0f b6 00             	movzbl (%eax),%eax
80105560:	84 c0                	test   %al,%al
80105562:	0f 95 c0             	setne  %al
80105565:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105569:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
8010556d:	84 c0                	test   %al,%al
8010556f:	75 d4                	jne    80105545 <safestrcpy+0x17>
    ;
  *s = 0;
80105571:	8b 45 08             	mov    0x8(%ebp),%eax
80105574:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105577:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010557a:	c9                   	leave  
8010557b:	c3                   	ret    

8010557c <strlen>:

int
strlen(const char *s)
{
8010557c:	55                   	push   %ebp
8010557d:	89 e5                	mov    %esp,%ebp
8010557f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105582:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105589:	eb 04                	jmp    8010558f <strlen+0x13>
8010558b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010558f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105592:	03 45 08             	add    0x8(%ebp),%eax
80105595:	0f b6 00             	movzbl (%eax),%eax
80105598:	84 c0                	test   %al,%al
8010559a:	75 ef                	jne    8010558b <strlen+0xf>
    ;
  return n;
8010559c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010559f:	c9                   	leave  
801055a0:	c3                   	ret    
801055a1:	00 00                	add    %al,(%eax)
	...

801055a4 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801055a4:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801055a8:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801055ac:	55                   	push   %ebp
  pushl %ebx
801055ad:	53                   	push   %ebx
  pushl %esi
801055ae:	56                   	push   %esi
  pushl %edi
801055af:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801055b0:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801055b2:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801055b4:	5f                   	pop    %edi
  popl %esi
801055b5:	5e                   	pop    %esi
  popl %ebx
801055b6:	5b                   	pop    %ebx
  popl %ebp
801055b7:	5d                   	pop    %ebp
  ret
801055b8:	c3                   	ret    
801055b9:	00 00                	add    %al,(%eax)
	...

801055bc <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
801055bc:	55                   	push   %ebp
801055bd:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
801055bf:	8b 45 08             	mov    0x8(%ebp),%eax
801055c2:	8b 00                	mov    (%eax),%eax
801055c4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801055c7:	76 0f                	jbe    801055d8 <fetchint+0x1c>
801055c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801055cc:	8d 50 04             	lea    0x4(%eax),%edx
801055cf:	8b 45 08             	mov    0x8(%ebp),%eax
801055d2:	8b 00                	mov    (%eax),%eax
801055d4:	39 c2                	cmp    %eax,%edx
801055d6:	76 07                	jbe    801055df <fetchint+0x23>
    return -1;
801055d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055dd:	eb 0f                	jmp    801055ee <fetchint+0x32>
  *ip = *(int*)(addr);
801055df:	8b 45 0c             	mov    0xc(%ebp),%eax
801055e2:	8b 10                	mov    (%eax),%edx
801055e4:	8b 45 10             	mov    0x10(%ebp),%eax
801055e7:	89 10                	mov    %edx,(%eax)
  return 0;
801055e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055ee:	5d                   	pop    %ebp
801055ef:	c3                   	ret    

801055f0 <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
801055f0:	55                   	push   %ebp
801055f1:	89 e5                	mov    %esp,%ebp
801055f3:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= p->sz)
801055f6:	8b 45 08             	mov    0x8(%ebp),%eax
801055f9:	8b 00                	mov    (%eax),%eax
801055fb:	3b 45 0c             	cmp    0xc(%ebp),%eax
801055fe:	77 07                	ja     80105607 <fetchstr+0x17>
    return -1;
80105600:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105605:	eb 45                	jmp    8010564c <fetchstr+0x5c>
  *pp = (char*)addr;
80105607:	8b 55 0c             	mov    0xc(%ebp),%edx
8010560a:	8b 45 10             	mov    0x10(%ebp),%eax
8010560d:	89 10                	mov    %edx,(%eax)
  ep = (char*)p->sz;
8010560f:	8b 45 08             	mov    0x8(%ebp),%eax
80105612:	8b 00                	mov    (%eax),%eax
80105614:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105617:	8b 45 10             	mov    0x10(%ebp),%eax
8010561a:	8b 00                	mov    (%eax),%eax
8010561c:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010561f:	eb 1e                	jmp    8010563f <fetchstr+0x4f>
    if(*s == 0)
80105621:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105624:	0f b6 00             	movzbl (%eax),%eax
80105627:	84 c0                	test   %al,%al
80105629:	75 10                	jne    8010563b <fetchstr+0x4b>
      return s - *pp;
8010562b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010562e:	8b 45 10             	mov    0x10(%ebp),%eax
80105631:	8b 00                	mov    (%eax),%eax
80105633:	89 d1                	mov    %edx,%ecx
80105635:	29 c1                	sub    %eax,%ecx
80105637:	89 c8                	mov    %ecx,%eax
80105639:	eb 11                	jmp    8010564c <fetchstr+0x5c>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
8010563b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010563f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105642:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105645:	72 da                	jb     80105621 <fetchstr+0x31>
    if(*s == 0)
      return s - *pp;
  return -1;
80105647:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010564c:	c9                   	leave  
8010564d:	c3                   	ret    

8010564e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010564e:	55                   	push   %ebp
8010564f:	89 e5                	mov    %esp,%ebp
80105651:	83 ec 0c             	sub    $0xc,%esp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
80105654:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010565a:	8b 40 18             	mov    0x18(%eax),%eax
8010565d:	8b 50 44             	mov    0x44(%eax),%edx
80105660:	8b 45 08             	mov    0x8(%ebp),%eax
80105663:	c1 e0 02             	shl    $0x2,%eax
80105666:	01 d0                	add    %edx,%eax
80105668:	8d 48 04             	lea    0x4(%eax),%ecx
8010566b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105671:	8b 55 0c             	mov    0xc(%ebp),%edx
80105674:	89 54 24 08          	mov    %edx,0x8(%esp)
80105678:	89 4c 24 04          	mov    %ecx,0x4(%esp)
8010567c:	89 04 24             	mov    %eax,(%esp)
8010567f:	e8 38 ff ff ff       	call   801055bc <fetchint>
}
80105684:	c9                   	leave  
80105685:	c3                   	ret    

80105686 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105686:	55                   	push   %ebp
80105687:	89 e5                	mov    %esp,%ebp
80105689:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010568c:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010568f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105693:	8b 45 08             	mov    0x8(%ebp),%eax
80105696:	89 04 24             	mov    %eax,(%esp)
80105699:	e8 b0 ff ff ff       	call   8010564e <argint>
8010569e:	85 c0                	test   %eax,%eax
801056a0:	79 07                	jns    801056a9 <argptr+0x23>
    return -1;
801056a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056a7:	eb 3d                	jmp    801056e6 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801056a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056ac:	89 c2                	mov    %eax,%edx
801056ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056b4:	8b 00                	mov    (%eax),%eax
801056b6:	39 c2                	cmp    %eax,%edx
801056b8:	73 16                	jae    801056d0 <argptr+0x4a>
801056ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056bd:	89 c2                	mov    %eax,%edx
801056bf:	8b 45 10             	mov    0x10(%ebp),%eax
801056c2:	01 c2                	add    %eax,%edx
801056c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056ca:	8b 00                	mov    (%eax),%eax
801056cc:	39 c2                	cmp    %eax,%edx
801056ce:	76 07                	jbe    801056d7 <argptr+0x51>
    return -1;
801056d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056d5:	eb 0f                	jmp    801056e6 <argptr+0x60>
  *pp = (char*)i;
801056d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056da:	89 c2                	mov    %eax,%edx
801056dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801056df:	89 10                	mov    %edx,(%eax)
  return 0;
801056e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056e6:	c9                   	leave  
801056e7:	c3                   	ret    

801056e8 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801056e8:	55                   	push   %ebp
801056e9:	89 e5                	mov    %esp,%ebp
801056eb:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  if(argint(n, &addr) < 0)
801056ee:	8d 45 fc             	lea    -0x4(%ebp),%eax
801056f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801056f5:	8b 45 08             	mov    0x8(%ebp),%eax
801056f8:	89 04 24             	mov    %eax,(%esp)
801056fb:	e8 4e ff ff ff       	call   8010564e <argint>
80105700:	85 c0                	test   %eax,%eax
80105702:	79 07                	jns    8010570b <argstr+0x23>
    return -1;
80105704:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105709:	eb 1e                	jmp    80105729 <argstr+0x41>
  return fetchstr(proc, addr, pp);
8010570b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010570e:	89 c2                	mov    %eax,%edx
80105710:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105716:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105719:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010571d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105721:	89 04 24             	mov    %eax,(%esp)
80105724:	e8 c7 fe ff ff       	call   801055f0 <fetchstr>
}
80105729:	c9                   	leave  
8010572a:	c3                   	ret    

8010572b <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
8010572b:	55                   	push   %ebp
8010572c:	89 e5                	mov    %esp,%ebp
8010572e:	53                   	push   %ebx
8010572f:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105732:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105738:	8b 40 18             	mov    0x18(%eax),%eax
8010573b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010573e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num >= 0 && num < SYS_open && syscalls[num]) {
80105741:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105745:	78 2e                	js     80105775 <syscall+0x4a>
80105747:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
8010574b:	7f 28                	jg     80105775 <syscall+0x4a>
8010574d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105750:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105757:	85 c0                	test   %eax,%eax
80105759:	74 1a                	je     80105775 <syscall+0x4a>
    proc->tf->eax = syscalls[num]();
8010575b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105761:	8b 58 18             	mov    0x18(%eax),%ebx
80105764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105767:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010576e:	ff d0                	call   *%eax
80105770:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105773:	eb 73                	jmp    801057e8 <syscall+0xbd>
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
80105775:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80105779:	7e 30                	jle    801057ab <syscall+0x80>
8010577b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010577e:	83 f8 16             	cmp    $0x16,%eax
80105781:	77 28                	ja     801057ab <syscall+0x80>
80105783:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105786:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010578d:	85 c0                	test   %eax,%eax
8010578f:	74 1a                	je     801057ab <syscall+0x80>
    proc->tf->eax = syscalls[num]();
80105791:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105797:	8b 58 18             	mov    0x18(%eax),%ebx
8010579a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010579d:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801057a4:	ff d0                	call   *%eax
801057a6:	89 43 1c             	mov    %eax,0x1c(%ebx)
801057a9:	eb 3d                	jmp    801057e8 <syscall+0xbd>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801057ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057b1:	8d 48 6c             	lea    0x6c(%eax),%ecx
801057b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(num >= 0 && num < SYS_open && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801057ba:	8b 40 10             	mov    0x10(%eax),%eax
801057bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057c0:	89 54 24 0c          	mov    %edx,0xc(%esp)
801057c4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801057c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801057cc:	c7 04 24 03 8b 10 80 	movl   $0x80108b03,(%esp)
801057d3:	e8 c9 ab ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801057d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057de:	8b 40 18             	mov    0x18(%eax),%eax
801057e1:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801057e8:	83 c4 24             	add    $0x24,%esp
801057eb:	5b                   	pop    %ebx
801057ec:	5d                   	pop    %ebp
801057ed:	c3                   	ret    
	...

801057f0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801057f0:	55                   	push   %ebp
801057f1:	89 e5                	mov    %esp,%ebp
801057f3:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801057f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801057fd:	8b 45 08             	mov    0x8(%ebp),%eax
80105800:	89 04 24             	mov    %eax,(%esp)
80105803:	e8 46 fe ff ff       	call   8010564e <argint>
80105808:	85 c0                	test   %eax,%eax
8010580a:	79 07                	jns    80105813 <argfd+0x23>
    return -1;
8010580c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105811:	eb 50                	jmp    80105863 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105813:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105816:	85 c0                	test   %eax,%eax
80105818:	78 21                	js     8010583b <argfd+0x4b>
8010581a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010581d:	83 f8 0f             	cmp    $0xf,%eax
80105820:	7f 19                	jg     8010583b <argfd+0x4b>
80105822:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105828:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010582b:	83 c2 08             	add    $0x8,%edx
8010582e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105832:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105835:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105839:	75 07                	jne    80105842 <argfd+0x52>
    return -1;
8010583b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105840:	eb 21                	jmp    80105863 <argfd+0x73>
  if(pfd)
80105842:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105846:	74 08                	je     80105850 <argfd+0x60>
    *pfd = fd;
80105848:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010584b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010584e:	89 10                	mov    %edx,(%eax)
  if(pf)
80105850:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105854:	74 08                	je     8010585e <argfd+0x6e>
    *pf = f;
80105856:	8b 45 10             	mov    0x10(%ebp),%eax
80105859:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010585c:	89 10                	mov    %edx,(%eax)
  return 0;
8010585e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105863:	c9                   	leave  
80105864:	c3                   	ret    

80105865 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105865:	55                   	push   %ebp
80105866:	89 e5                	mov    %esp,%ebp
80105868:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010586b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105872:	eb 30                	jmp    801058a4 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105874:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010587a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010587d:	83 c2 08             	add    $0x8,%edx
80105880:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105884:	85 c0                	test   %eax,%eax
80105886:	75 18                	jne    801058a0 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105888:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010588e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105891:	8d 4a 08             	lea    0x8(%edx),%ecx
80105894:	8b 55 08             	mov    0x8(%ebp),%edx
80105897:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010589b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010589e:	eb 0f                	jmp    801058af <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801058a0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801058a4:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801058a8:	7e ca                	jle    80105874 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801058aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058af:	c9                   	leave  
801058b0:	c3                   	ret    

801058b1 <sys_dup>:

int
sys_dup(void)
{
801058b1:	55                   	push   %ebp
801058b2:	89 e5                	mov    %esp,%ebp
801058b4:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801058b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058ba:	89 44 24 08          	mov    %eax,0x8(%esp)
801058be:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801058c5:	00 
801058c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801058cd:	e8 1e ff ff ff       	call   801057f0 <argfd>
801058d2:	85 c0                	test   %eax,%eax
801058d4:	79 07                	jns    801058dd <sys_dup+0x2c>
    return -1;
801058d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058db:	eb 29                	jmp    80105906 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801058dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e0:	89 04 24             	mov    %eax,(%esp)
801058e3:	e8 7d ff ff ff       	call   80105865 <fdalloc>
801058e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058ef:	79 07                	jns    801058f8 <sys_dup+0x47>
    return -1;
801058f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058f6:	eb 0e                	jmp    80105906 <sys_dup+0x55>
  filedup(f);
801058f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058fb:	89 04 24             	mov    %eax,(%esp)
801058fe:	e8 cd b9 ff ff       	call   801012d0 <filedup>
  return fd;
80105903:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105906:	c9                   	leave  
80105907:	c3                   	ret    

80105908 <sys_read>:

int
sys_read(void)
{
80105908:	55                   	push   %ebp
80105909:	89 e5                	mov    %esp,%ebp
8010590b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010590e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105911:	89 44 24 08          	mov    %eax,0x8(%esp)
80105915:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010591c:	00 
8010591d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105924:	e8 c7 fe ff ff       	call   801057f0 <argfd>
80105929:	85 c0                	test   %eax,%eax
8010592b:	78 35                	js     80105962 <sys_read+0x5a>
8010592d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105930:	89 44 24 04          	mov    %eax,0x4(%esp)
80105934:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010593b:	e8 0e fd ff ff       	call   8010564e <argint>
80105940:	85 c0                	test   %eax,%eax
80105942:	78 1e                	js     80105962 <sys_read+0x5a>
80105944:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105947:	89 44 24 08          	mov    %eax,0x8(%esp)
8010594b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010594e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105952:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105959:	e8 28 fd ff ff       	call   80105686 <argptr>
8010595e:	85 c0                	test   %eax,%eax
80105960:	79 07                	jns    80105969 <sys_read+0x61>
    return -1;
80105962:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105967:	eb 19                	jmp    80105982 <sys_read+0x7a>
  return fileread(f, p, n);
80105969:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010596c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010596f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105972:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105976:	89 54 24 04          	mov    %edx,0x4(%esp)
8010597a:	89 04 24             	mov    %eax,(%esp)
8010597d:	e8 bb ba ff ff       	call   8010143d <fileread>
}
80105982:	c9                   	leave  
80105983:	c3                   	ret    

80105984 <sys_write>:

int
sys_write(void)
{
80105984:	55                   	push   %ebp
80105985:	89 e5                	mov    %esp,%ebp
80105987:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010598a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010598d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105991:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105998:	00 
80105999:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059a0:	e8 4b fe ff ff       	call   801057f0 <argfd>
801059a5:	85 c0                	test   %eax,%eax
801059a7:	78 35                	js     801059de <sys_write+0x5a>
801059a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801059b0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801059b7:	e8 92 fc ff ff       	call   8010564e <argint>
801059bc:	85 c0                	test   %eax,%eax
801059be:	78 1e                	js     801059de <sys_write+0x5a>
801059c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059c3:	89 44 24 08          	mov    %eax,0x8(%esp)
801059c7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801059ce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801059d5:	e8 ac fc ff ff       	call   80105686 <argptr>
801059da:	85 c0                	test   %eax,%eax
801059dc:	79 07                	jns    801059e5 <sys_write+0x61>
    return -1;
801059de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059e3:	eb 19                	jmp    801059fe <sys_write+0x7a>
  return filewrite(f, p, n);
801059e5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801059e8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801059eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ee:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801059f2:	89 54 24 04          	mov    %edx,0x4(%esp)
801059f6:	89 04 24             	mov    %eax,(%esp)
801059f9:	e8 fb ba ff ff       	call   801014f9 <filewrite>
}
801059fe:	c9                   	leave  
801059ff:	c3                   	ret    

80105a00 <sys_close>:

int
sys_close(void)
{
80105a00:	55                   	push   %ebp
80105a01:	89 e5                	mov    %esp,%ebp
80105a03:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105a06:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a09:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a10:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a14:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a1b:	e8 d0 fd ff ff       	call   801057f0 <argfd>
80105a20:	85 c0                	test   %eax,%eax
80105a22:	79 07                	jns    80105a2b <sys_close+0x2b>
    return -1;
80105a24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a29:	eb 24                	jmp    80105a4f <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105a2b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a31:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a34:	83 c2 08             	add    $0x8,%edx
80105a37:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105a3e:	00 
  fileclose(f);
80105a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a42:	89 04 24             	mov    %eax,(%esp)
80105a45:	e8 ce b8 ff ff       	call   80101318 <fileclose>
  return 0;
80105a4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a4f:	c9                   	leave  
80105a50:	c3                   	ret    

80105a51 <sys_fstat>:

int
sys_fstat(void)
{
80105a51:	55                   	push   %ebp
80105a52:	89 e5                	mov    %esp,%ebp
80105a54:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105a57:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a5a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a5e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a65:	00 
80105a66:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a6d:	e8 7e fd ff ff       	call   801057f0 <argfd>
80105a72:	85 c0                	test   %eax,%eax
80105a74:	78 1f                	js     80105a95 <sys_fstat+0x44>
80105a76:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105a7d:	00 
80105a7e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a81:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a85:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a8c:	e8 f5 fb ff ff       	call   80105686 <argptr>
80105a91:	85 c0                	test   %eax,%eax
80105a93:	79 07                	jns    80105a9c <sys_fstat+0x4b>
    return -1;
80105a95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a9a:	eb 12                	jmp    80105aae <sys_fstat+0x5d>
  return filestat(f, st);
80105a9c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa2:	89 54 24 04          	mov    %edx,0x4(%esp)
80105aa6:	89 04 24             	mov    %eax,(%esp)
80105aa9:	e8 40 b9 ff ff       	call   801013ee <filestat>
}
80105aae:	c9                   	leave  
80105aaf:	c3                   	ret    

80105ab0 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105ab0:	55                   	push   %ebp
80105ab1:	89 e5                	mov    %esp,%ebp
80105ab3:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105ab6:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105ab9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105abd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ac4:	e8 1f fc ff ff       	call   801056e8 <argstr>
80105ac9:	85 c0                	test   %eax,%eax
80105acb:	78 17                	js     80105ae4 <sys_link+0x34>
80105acd:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105ad0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ad4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105adb:	e8 08 fc ff ff       	call   801056e8 <argstr>
80105ae0:	85 c0                	test   %eax,%eax
80105ae2:	79 0a                	jns    80105aee <sys_link+0x3e>
    return -1;
80105ae4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ae9:	e9 3c 01 00 00       	jmp    80105c2a <sys_link+0x17a>
  if((ip = namei(old)) == 0)
80105aee:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105af1:	89 04 24             	mov    %eax,(%esp)
80105af4:	e8 65 cc ff ff       	call   8010275e <namei>
80105af9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105afc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b00:	75 0a                	jne    80105b0c <sys_link+0x5c>
    return -1;
80105b02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b07:	e9 1e 01 00 00       	jmp    80105c2a <sys_link+0x17a>

  begin_trans();
80105b0c:	e8 60 da ff ff       	call   80103571 <begin_trans>

  ilock(ip);
80105b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b14:	89 04 24             	mov    %eax,(%esp)
80105b17:	e8 a0 c0 ff ff       	call   80101bbc <ilock>
  if(ip->type == T_DIR){
80105b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b1f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105b23:	66 83 f8 01          	cmp    $0x1,%ax
80105b27:	75 1a                	jne    80105b43 <sys_link+0x93>
    iunlockput(ip);
80105b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b2c:	89 04 24             	mov    %eax,(%esp)
80105b2f:	e8 0c c3 ff ff       	call   80101e40 <iunlockput>
    commit_trans();
80105b34:	e8 81 da ff ff       	call   801035ba <commit_trans>
    return -1;
80105b39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b3e:	e9 e7 00 00 00       	jmp    80105c2a <sys_link+0x17a>
  }

  ip->nlink++;
80105b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b46:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b4a:	8d 50 01             	lea    0x1(%eax),%edx
80105b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b50:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b57:	89 04 24             	mov    %eax,(%esp)
80105b5a:	e8 a1 be ff ff       	call   80101a00 <iupdate>
  iunlock(ip);
80105b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b62:	89 04 24             	mov    %eax,(%esp)
80105b65:	e8 a0 c1 ff ff       	call   80101d0a <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105b6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105b6d:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105b70:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b74:	89 04 24             	mov    %eax,(%esp)
80105b77:	e8 04 cc ff ff       	call   80102780 <nameiparent>
80105b7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b7f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b83:	74 68                	je     80105bed <sys_link+0x13d>
    goto bad;
  ilock(dp);
80105b85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b88:	89 04 24             	mov    %eax,(%esp)
80105b8b:	e8 2c c0 ff ff       	call   80101bbc <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105b90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b93:	8b 10                	mov    (%eax),%edx
80105b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b98:	8b 00                	mov    (%eax),%eax
80105b9a:	39 c2                	cmp    %eax,%edx
80105b9c:	75 20                	jne    80105bbe <sys_link+0x10e>
80105b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba1:	8b 40 04             	mov    0x4(%eax),%eax
80105ba4:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ba8:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105bab:	89 44 24 04          	mov    %eax,0x4(%esp)
80105baf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb2:	89 04 24             	mov    %eax,(%esp)
80105bb5:	e8 e3 c8 ff ff       	call   8010249d <dirlink>
80105bba:	85 c0                	test   %eax,%eax
80105bbc:	79 0d                	jns    80105bcb <sys_link+0x11b>
    iunlockput(dp);
80105bbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc1:	89 04 24             	mov    %eax,(%esp)
80105bc4:	e8 77 c2 ff ff       	call   80101e40 <iunlockput>
    goto bad;
80105bc9:	eb 23                	jmp    80105bee <sys_link+0x13e>
  }
  iunlockput(dp);
80105bcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bce:	89 04 24             	mov    %eax,(%esp)
80105bd1:	e8 6a c2 ff ff       	call   80101e40 <iunlockput>
  iput(ip);
80105bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd9:	89 04 24             	mov    %eax,(%esp)
80105bdc:	e8 8e c1 ff ff       	call   80101d6f <iput>

  commit_trans();
80105be1:	e8 d4 d9 ff ff       	call   801035ba <commit_trans>

  return 0;
80105be6:	b8 00 00 00 00       	mov    $0x0,%eax
80105beb:	eb 3d                	jmp    80105c2a <sys_link+0x17a>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105bed:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
80105bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf1:	89 04 24             	mov    %eax,(%esp)
80105bf4:	e8 c3 bf ff ff       	call   80101bbc <ilock>
  ip->nlink--;
80105bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bfc:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c00:	8d 50 ff             	lea    -0x1(%eax),%edx
80105c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c06:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c0d:	89 04 24             	mov    %eax,(%esp)
80105c10:	e8 eb bd ff ff       	call   80101a00 <iupdate>
  iunlockput(ip);
80105c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c18:	89 04 24             	mov    %eax,(%esp)
80105c1b:	e8 20 c2 ff ff       	call   80101e40 <iunlockput>
  commit_trans();
80105c20:	e8 95 d9 ff ff       	call   801035ba <commit_trans>
  return -1;
80105c25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c2a:	c9                   	leave  
80105c2b:	c3                   	ret    

80105c2c <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105c2c:	55                   	push   %ebp
80105c2d:	89 e5                	mov    %esp,%ebp
80105c2f:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c32:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105c39:	eb 4b                	jmp    80105c86 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c3e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105c45:	00 
80105c46:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c4a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c51:	8b 45 08             	mov    0x8(%ebp),%eax
80105c54:	89 04 24             	mov    %eax,(%esp)
80105c57:	e8 56 c4 ff ff       	call   801020b2 <readi>
80105c5c:	83 f8 10             	cmp    $0x10,%eax
80105c5f:	74 0c                	je     80105c6d <isdirempty+0x41>
      panic("isdirempty: readi");
80105c61:	c7 04 24 1f 8b 10 80 	movl   $0x80108b1f,(%esp)
80105c68:	e8 d0 a8 ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80105c6d:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105c71:	66 85 c0             	test   %ax,%ax
80105c74:	74 07                	je     80105c7d <isdirempty+0x51>
      return 0;
80105c76:	b8 00 00 00 00       	mov    $0x0,%eax
80105c7b:	eb 1b                	jmp    80105c98 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c80:	83 c0 10             	add    $0x10,%eax
80105c83:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c86:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c89:	8b 45 08             	mov    0x8(%ebp),%eax
80105c8c:	8b 40 18             	mov    0x18(%eax),%eax
80105c8f:	39 c2                	cmp    %eax,%edx
80105c91:	72 a8                	jb     80105c3b <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105c93:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105c98:	c9                   	leave  
80105c99:	c3                   	ret    

80105c9a <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105c9a:	55                   	push   %ebp
80105c9b:	89 e5                	mov    %esp,%ebp
80105c9d:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105ca0:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105ca3:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ca7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105cae:	e8 35 fa ff ff       	call   801056e8 <argstr>
80105cb3:	85 c0                	test   %eax,%eax
80105cb5:	79 0a                	jns    80105cc1 <sys_unlink+0x27>
    return -1;
80105cb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cbc:	e9 aa 01 00 00       	jmp    80105e6b <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
80105cc1:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105cc4:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105cc7:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ccb:	89 04 24             	mov    %eax,(%esp)
80105cce:	e8 ad ca ff ff       	call   80102780 <nameiparent>
80105cd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cd6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cda:	75 0a                	jne    80105ce6 <sys_unlink+0x4c>
    return -1;
80105cdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ce1:	e9 85 01 00 00       	jmp    80105e6b <sys_unlink+0x1d1>

  begin_trans();
80105ce6:	e8 86 d8 ff ff       	call   80103571 <begin_trans>

  ilock(dp);
80105ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cee:	89 04 24             	mov    %eax,(%esp)
80105cf1:	e8 c6 be ff ff       	call   80101bbc <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105cf6:	c7 44 24 04 31 8b 10 	movl   $0x80108b31,0x4(%esp)
80105cfd:	80 
80105cfe:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d01:	89 04 24             	mov    %eax,(%esp)
80105d04:	e8 aa c6 ff ff       	call   801023b3 <namecmp>
80105d09:	85 c0                	test   %eax,%eax
80105d0b:	0f 84 45 01 00 00    	je     80105e56 <sys_unlink+0x1bc>
80105d11:	c7 44 24 04 33 8b 10 	movl   $0x80108b33,0x4(%esp)
80105d18:	80 
80105d19:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d1c:	89 04 24             	mov    %eax,(%esp)
80105d1f:	e8 8f c6 ff ff       	call   801023b3 <namecmp>
80105d24:	85 c0                	test   %eax,%eax
80105d26:	0f 84 2a 01 00 00    	je     80105e56 <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105d2c:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105d2f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d33:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d36:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d3d:	89 04 24             	mov    %eax,(%esp)
80105d40:	e8 90 c6 ff ff       	call   801023d5 <dirlookup>
80105d45:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d48:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d4c:	0f 84 03 01 00 00    	je     80105e55 <sys_unlink+0x1bb>
    goto bad;
  ilock(ip);
80105d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d55:	89 04 24             	mov    %eax,(%esp)
80105d58:	e8 5f be ff ff       	call   80101bbc <ilock>

  if(ip->nlink < 1)
80105d5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d60:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d64:	66 85 c0             	test   %ax,%ax
80105d67:	7f 0c                	jg     80105d75 <sys_unlink+0xdb>
    panic("unlink: nlink < 1");
80105d69:	c7 04 24 36 8b 10 80 	movl   $0x80108b36,(%esp)
80105d70:	e8 c8 a7 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d78:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d7c:	66 83 f8 01          	cmp    $0x1,%ax
80105d80:	75 1f                	jne    80105da1 <sys_unlink+0x107>
80105d82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d85:	89 04 24             	mov    %eax,(%esp)
80105d88:	e8 9f fe ff ff       	call   80105c2c <isdirempty>
80105d8d:	85 c0                	test   %eax,%eax
80105d8f:	75 10                	jne    80105da1 <sys_unlink+0x107>
    iunlockput(ip);
80105d91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d94:	89 04 24             	mov    %eax,(%esp)
80105d97:	e8 a4 c0 ff ff       	call   80101e40 <iunlockput>
    goto bad;
80105d9c:	e9 b5 00 00 00       	jmp    80105e56 <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
80105da1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105da8:	00 
80105da9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105db0:	00 
80105db1:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105db4:	89 04 24             	mov    %eax,(%esp)
80105db7:	e8 42 f5 ff ff       	call   801052fe <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105dbc:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105dbf:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105dc6:	00 
80105dc7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105dcb:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105dce:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd5:	89 04 24             	mov    %eax,(%esp)
80105dd8:	e8 40 c4 ff ff       	call   8010221d <writei>
80105ddd:	83 f8 10             	cmp    $0x10,%eax
80105de0:	74 0c                	je     80105dee <sys_unlink+0x154>
    panic("unlink: writei");
80105de2:	c7 04 24 48 8b 10 80 	movl   $0x80108b48,(%esp)
80105de9:	e8 4f a7 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80105dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105df1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105df5:	66 83 f8 01          	cmp    $0x1,%ax
80105df9:	75 1c                	jne    80105e17 <sys_unlink+0x17d>
    dp->nlink--;
80105dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dfe:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e02:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e08:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0f:	89 04 24             	mov    %eax,(%esp)
80105e12:	e8 e9 bb ff ff       	call   80101a00 <iupdate>
  }
  iunlockput(dp);
80105e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1a:	89 04 24             	mov    %eax,(%esp)
80105e1d:	e8 1e c0 ff ff       	call   80101e40 <iunlockput>

  ip->nlink--;
80105e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e25:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e29:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e2f:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105e33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e36:	89 04 24             	mov    %eax,(%esp)
80105e39:	e8 c2 bb ff ff       	call   80101a00 <iupdate>
  iunlockput(ip);
80105e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e41:	89 04 24             	mov    %eax,(%esp)
80105e44:	e8 f7 bf ff ff       	call   80101e40 <iunlockput>

  commit_trans();
80105e49:	e8 6c d7 ff ff       	call   801035ba <commit_trans>

  return 0;
80105e4e:	b8 00 00 00 00       	mov    $0x0,%eax
80105e53:	eb 16                	jmp    80105e6b <sys_unlink+0x1d1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105e55:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
80105e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e59:	89 04 24             	mov    %eax,(%esp)
80105e5c:	e8 df bf ff ff       	call   80101e40 <iunlockput>
  commit_trans();
80105e61:	e8 54 d7 ff ff       	call   801035ba <commit_trans>
  return -1;
80105e66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e6b:	c9                   	leave  
80105e6c:	c3                   	ret    

80105e6d <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105e6d:	55                   	push   %ebp
80105e6e:	89 e5                	mov    %esp,%ebp
80105e70:	83 ec 48             	sub    $0x48,%esp
80105e73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105e76:	8b 55 10             	mov    0x10(%ebp),%edx
80105e79:	8b 45 14             	mov    0x14(%ebp),%eax
80105e7c:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105e80:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105e84:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105e88:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e8b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e8f:	8b 45 08             	mov    0x8(%ebp),%eax
80105e92:	89 04 24             	mov    %eax,(%esp)
80105e95:	e8 e6 c8 ff ff       	call   80102780 <nameiparent>
80105e9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e9d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ea1:	75 0a                	jne    80105ead <create+0x40>
    return 0;
80105ea3:	b8 00 00 00 00       	mov    $0x0,%eax
80105ea8:	e9 7e 01 00 00       	jmp    8010602b <create+0x1be>
  ilock(dp);
80105ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb0:	89 04 24             	mov    %eax,(%esp)
80105eb3:	e8 04 bd ff ff       	call   80101bbc <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105eb8:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ebb:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ebf:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ec2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec9:	89 04 24             	mov    %eax,(%esp)
80105ecc:	e8 04 c5 ff ff       	call   801023d5 <dirlookup>
80105ed1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ed4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ed8:	74 47                	je     80105f21 <create+0xb4>
    iunlockput(dp);
80105eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105edd:	89 04 24             	mov    %eax,(%esp)
80105ee0:	e8 5b bf ff ff       	call   80101e40 <iunlockput>
    ilock(ip);
80105ee5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee8:	89 04 24             	mov    %eax,(%esp)
80105eeb:	e8 cc bc ff ff       	call   80101bbc <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105ef0:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105ef5:	75 15                	jne    80105f0c <create+0x9f>
80105ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105efa:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105efe:	66 83 f8 02          	cmp    $0x2,%ax
80105f02:	75 08                	jne    80105f0c <create+0x9f>
      return ip;
80105f04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f07:	e9 1f 01 00 00       	jmp    8010602b <create+0x1be>
    iunlockput(ip);
80105f0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f0f:	89 04 24             	mov    %eax,(%esp)
80105f12:	e8 29 bf ff ff       	call   80101e40 <iunlockput>
    return 0;
80105f17:	b8 00 00 00 00       	mov    $0x0,%eax
80105f1c:	e9 0a 01 00 00       	jmp    8010602b <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105f21:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f28:	8b 00                	mov    (%eax),%eax
80105f2a:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f2e:	89 04 24             	mov    %eax,(%esp)
80105f31:	e8 ed b9 ff ff       	call   80101923 <ialloc>
80105f36:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f39:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f3d:	75 0c                	jne    80105f4b <create+0xde>
    panic("create: ialloc");
80105f3f:	c7 04 24 57 8b 10 80 	movl   $0x80108b57,(%esp)
80105f46:	e8 f2 a5 ff ff       	call   8010053d <panic>

  ilock(ip);
80105f4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f4e:	89 04 24             	mov    %eax,(%esp)
80105f51:	e8 66 bc ff ff       	call   80101bbc <ilock>
  ip->major = major;
80105f56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f59:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105f5d:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105f61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f64:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105f68:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105f6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f6f:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105f75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f78:	89 04 24             	mov    %eax,(%esp)
80105f7b:	e8 80 ba ff ff       	call   80101a00 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105f80:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105f85:	75 6a                	jne    80105ff1 <create+0x184>
    dp->nlink++;  // for ".."
80105f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f8a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f8e:	8d 50 01             	lea    0x1(%eax),%edx
80105f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f94:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f9b:	89 04 24             	mov    %eax,(%esp)
80105f9e:	e8 5d ba ff ff       	call   80101a00 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105fa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa6:	8b 40 04             	mov    0x4(%eax),%eax
80105fa9:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fad:	c7 44 24 04 31 8b 10 	movl   $0x80108b31,0x4(%esp)
80105fb4:	80 
80105fb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb8:	89 04 24             	mov    %eax,(%esp)
80105fbb:	e8 dd c4 ff ff       	call   8010249d <dirlink>
80105fc0:	85 c0                	test   %eax,%eax
80105fc2:	78 21                	js     80105fe5 <create+0x178>
80105fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc7:	8b 40 04             	mov    0x4(%eax),%eax
80105fca:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fce:	c7 44 24 04 33 8b 10 	movl   $0x80108b33,0x4(%esp)
80105fd5:	80 
80105fd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd9:	89 04 24             	mov    %eax,(%esp)
80105fdc:	e8 bc c4 ff ff       	call   8010249d <dirlink>
80105fe1:	85 c0                	test   %eax,%eax
80105fe3:	79 0c                	jns    80105ff1 <create+0x184>
      panic("create dots");
80105fe5:	c7 04 24 66 8b 10 80 	movl   $0x80108b66,(%esp)
80105fec:	e8 4c a5 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105ff1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ff4:	8b 40 04             	mov    0x4(%eax),%eax
80105ff7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ffb:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ffe:	89 44 24 04          	mov    %eax,0x4(%esp)
80106002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106005:	89 04 24             	mov    %eax,(%esp)
80106008:	e8 90 c4 ff ff       	call   8010249d <dirlink>
8010600d:	85 c0                	test   %eax,%eax
8010600f:	79 0c                	jns    8010601d <create+0x1b0>
    panic("create: dirlink");
80106011:	c7 04 24 72 8b 10 80 	movl   $0x80108b72,(%esp)
80106018:	e8 20 a5 ff ff       	call   8010053d <panic>

  iunlockput(dp);
8010601d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106020:	89 04 24             	mov    %eax,(%esp)
80106023:	e8 18 be ff ff       	call   80101e40 <iunlockput>

  return ip;
80106028:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010602b:	c9                   	leave  
8010602c:	c3                   	ret    

8010602d <sys_open>:

int
sys_open(void)
{
8010602d:	55                   	push   %ebp
8010602e:	89 e5                	mov    %esp,%ebp
80106030:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106033:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106036:	89 44 24 04          	mov    %eax,0x4(%esp)
8010603a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106041:	e8 a2 f6 ff ff       	call   801056e8 <argstr>
80106046:	85 c0                	test   %eax,%eax
80106048:	78 17                	js     80106061 <sys_open+0x34>
8010604a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010604d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106051:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106058:	e8 f1 f5 ff ff       	call   8010564e <argint>
8010605d:	85 c0                	test   %eax,%eax
8010605f:	79 0a                	jns    8010606b <sys_open+0x3e>
    return -1;
80106061:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106066:	e9 46 01 00 00       	jmp    801061b1 <sys_open+0x184>
  if(omode & O_CREATE){
8010606b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010606e:	25 00 02 00 00       	and    $0x200,%eax
80106073:	85 c0                	test   %eax,%eax
80106075:	74 40                	je     801060b7 <sys_open+0x8a>
    begin_trans();
80106077:	e8 f5 d4 ff ff       	call   80103571 <begin_trans>
    ip = create(path, T_FILE, 0, 0);
8010607c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010607f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106086:	00 
80106087:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010608e:	00 
8010608f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106096:	00 
80106097:	89 04 24             	mov    %eax,(%esp)
8010609a:	e8 ce fd ff ff       	call   80105e6d <create>
8010609f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
801060a2:	e8 13 d5 ff ff       	call   801035ba <commit_trans>
    if(ip == 0)
801060a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060ab:	75 5c                	jne    80106109 <sys_open+0xdc>
      return -1;
801060ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060b2:	e9 fa 00 00 00       	jmp    801061b1 <sys_open+0x184>
  } else {
    if((ip = namei(path)) == 0)
801060b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060ba:	89 04 24             	mov    %eax,(%esp)
801060bd:	e8 9c c6 ff ff       	call   8010275e <namei>
801060c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060c9:	75 0a                	jne    801060d5 <sys_open+0xa8>
      return -1;
801060cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d0:	e9 dc 00 00 00       	jmp    801061b1 <sys_open+0x184>
    ilock(ip);
801060d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060d8:	89 04 24             	mov    %eax,(%esp)
801060db:	e8 dc ba ff ff       	call   80101bbc <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801060e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060e3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060e7:	66 83 f8 01          	cmp    $0x1,%ax
801060eb:	75 1c                	jne    80106109 <sys_open+0xdc>
801060ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060f0:	85 c0                	test   %eax,%eax
801060f2:	74 15                	je     80106109 <sys_open+0xdc>
      iunlockput(ip);
801060f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060f7:	89 04 24             	mov    %eax,(%esp)
801060fa:	e8 41 bd ff ff       	call   80101e40 <iunlockput>
      return -1;
801060ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106104:	e9 a8 00 00 00       	jmp    801061b1 <sys_open+0x184>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106109:	e8 62 b1 ff ff       	call   80101270 <filealloc>
8010610e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106111:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106115:	74 14                	je     8010612b <sys_open+0xfe>
80106117:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010611a:	89 04 24             	mov    %eax,(%esp)
8010611d:	e8 43 f7 ff ff       	call   80105865 <fdalloc>
80106122:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106125:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106129:	79 23                	jns    8010614e <sys_open+0x121>
    if(f)
8010612b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010612f:	74 0b                	je     8010613c <sys_open+0x10f>
      fileclose(f);
80106131:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106134:	89 04 24             	mov    %eax,(%esp)
80106137:	e8 dc b1 ff ff       	call   80101318 <fileclose>
    iunlockput(ip);
8010613c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010613f:	89 04 24             	mov    %eax,(%esp)
80106142:	e8 f9 bc ff ff       	call   80101e40 <iunlockput>
    return -1;
80106147:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010614c:	eb 63                	jmp    801061b1 <sys_open+0x184>
  }
  iunlock(ip);
8010614e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106151:	89 04 24             	mov    %eax,(%esp)
80106154:	e8 b1 bb ff ff       	call   80101d0a <iunlock>

  f->type = FD_INODE;
80106159:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010615c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106162:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106165:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106168:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010616b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010616e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106175:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106178:	83 e0 01             	and    $0x1,%eax
8010617b:	85 c0                	test   %eax,%eax
8010617d:	0f 94 c2             	sete   %dl
80106180:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106183:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106186:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106189:	83 e0 01             	and    $0x1,%eax
8010618c:	84 c0                	test   %al,%al
8010618e:	75 0a                	jne    8010619a <sys_open+0x16d>
80106190:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106193:	83 e0 02             	and    $0x2,%eax
80106196:	85 c0                	test   %eax,%eax
80106198:	74 07                	je     801061a1 <sys_open+0x174>
8010619a:	b8 01 00 00 00       	mov    $0x1,%eax
8010619f:	eb 05                	jmp    801061a6 <sys_open+0x179>
801061a1:	b8 00 00 00 00       	mov    $0x0,%eax
801061a6:	89 c2                	mov    %eax,%edx
801061a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ab:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801061ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801061b1:	c9                   	leave  
801061b2:	c3                   	ret    

801061b3 <sys_mkdir>:

int
sys_mkdir(void)
{
801061b3:	55                   	push   %ebp
801061b4:	89 e5                	mov    %esp,%ebp
801061b6:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
801061b9:	e8 b3 d3 ff ff       	call   80103571 <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801061be:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801061c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801061cc:	e8 17 f5 ff ff       	call   801056e8 <argstr>
801061d1:	85 c0                	test   %eax,%eax
801061d3:	78 2c                	js     80106201 <sys_mkdir+0x4e>
801061d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801061df:	00 
801061e0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801061e7:	00 
801061e8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801061ef:	00 
801061f0:	89 04 24             	mov    %eax,(%esp)
801061f3:	e8 75 fc ff ff       	call   80105e6d <create>
801061f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061ff:	75 0c                	jne    8010620d <sys_mkdir+0x5a>
    commit_trans();
80106201:	e8 b4 d3 ff ff       	call   801035ba <commit_trans>
    return -1;
80106206:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010620b:	eb 15                	jmp    80106222 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
8010620d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106210:	89 04 24             	mov    %eax,(%esp)
80106213:	e8 28 bc ff ff       	call   80101e40 <iunlockput>
  commit_trans();
80106218:	e8 9d d3 ff ff       	call   801035ba <commit_trans>
  return 0;
8010621d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106222:	c9                   	leave  
80106223:	c3                   	ret    

80106224 <sys_mknod>:

int
sys_mknod(void)
{
80106224:	55                   	push   %ebp
80106225:	89 e5                	mov    %esp,%ebp
80106227:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
8010622a:	e8 42 d3 ff ff       	call   80103571 <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
8010622f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106232:	89 44 24 04          	mov    %eax,0x4(%esp)
80106236:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010623d:	e8 a6 f4 ff ff       	call   801056e8 <argstr>
80106242:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106245:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106249:	78 5e                	js     801062a9 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
8010624b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010624e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106252:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106259:	e8 f0 f3 ff ff       	call   8010564e <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
8010625e:	85 c0                	test   %eax,%eax
80106260:	78 47                	js     801062a9 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106262:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106265:	89 44 24 04          	mov    %eax,0x4(%esp)
80106269:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106270:	e8 d9 f3 ff ff       	call   8010564e <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106275:	85 c0                	test   %eax,%eax
80106277:	78 30                	js     801062a9 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106279:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010627c:	0f bf c8             	movswl %ax,%ecx
8010627f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106282:	0f bf d0             	movswl %ax,%edx
80106285:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106288:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010628c:	89 54 24 08          	mov    %edx,0x8(%esp)
80106290:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106297:	00 
80106298:	89 04 24             	mov    %eax,(%esp)
8010629b:	e8 cd fb ff ff       	call   80105e6d <create>
801062a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062a7:	75 0c                	jne    801062b5 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
801062a9:	e8 0c d3 ff ff       	call   801035ba <commit_trans>
    return -1;
801062ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062b3:	eb 15                	jmp    801062ca <sys_mknod+0xa6>
  }
  iunlockput(ip);
801062b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062b8:	89 04 24             	mov    %eax,(%esp)
801062bb:	e8 80 bb ff ff       	call   80101e40 <iunlockput>
  commit_trans();
801062c0:	e8 f5 d2 ff ff       	call   801035ba <commit_trans>
  return 0;
801062c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062ca:	c9                   	leave  
801062cb:	c3                   	ret    

801062cc <sys_chdir>:

int
sys_chdir(void)
{
801062cc:	55                   	push   %ebp
801062cd:	89 e5                	mov    %esp,%ebp
801062cf:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
801062d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801062d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062e0:	e8 03 f4 ff ff       	call   801056e8 <argstr>
801062e5:	85 c0                	test   %eax,%eax
801062e7:	78 14                	js     801062fd <sys_chdir+0x31>
801062e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ec:	89 04 24             	mov    %eax,(%esp)
801062ef:	e8 6a c4 ff ff       	call   8010275e <namei>
801062f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062fb:	75 07                	jne    80106304 <sys_chdir+0x38>
    return -1;
801062fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106302:	eb 57                	jmp    8010635b <sys_chdir+0x8f>
  ilock(ip);
80106304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106307:	89 04 24             	mov    %eax,(%esp)
8010630a:	e8 ad b8 ff ff       	call   80101bbc <ilock>
  if(ip->type != T_DIR){
8010630f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106312:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106316:	66 83 f8 01          	cmp    $0x1,%ax
8010631a:	74 12                	je     8010632e <sys_chdir+0x62>
    iunlockput(ip);
8010631c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010631f:	89 04 24             	mov    %eax,(%esp)
80106322:	e8 19 bb ff ff       	call   80101e40 <iunlockput>
    return -1;
80106327:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010632c:	eb 2d                	jmp    8010635b <sys_chdir+0x8f>
  }
  iunlock(ip);
8010632e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106331:	89 04 24             	mov    %eax,(%esp)
80106334:	e8 d1 b9 ff ff       	call   80101d0a <iunlock>
  iput(proc->cwd);
80106339:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010633f:	8b 40 68             	mov    0x68(%eax),%eax
80106342:	89 04 24             	mov    %eax,(%esp)
80106345:	e8 25 ba ff ff       	call   80101d6f <iput>
  proc->cwd = ip;
8010634a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106350:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106353:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106356:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010635b:	c9                   	leave  
8010635c:	c3                   	ret    

8010635d <sys_exec>:

int
sys_exec(void)
{
8010635d:	55                   	push   %ebp
8010635e:	89 e5                	mov    %esp,%ebp
80106360:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106366:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106369:	89 44 24 04          	mov    %eax,0x4(%esp)
8010636d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106374:	e8 6f f3 ff ff       	call   801056e8 <argstr>
80106379:	85 c0                	test   %eax,%eax
8010637b:	78 1a                	js     80106397 <sys_exec+0x3a>
8010637d:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106383:	89 44 24 04          	mov    %eax,0x4(%esp)
80106387:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010638e:	e8 bb f2 ff ff       	call   8010564e <argint>
80106393:	85 c0                	test   %eax,%eax
80106395:	79 0a                	jns    801063a1 <sys_exec+0x44>
    return -1;
80106397:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010639c:	e9 e2 00 00 00       	jmp    80106483 <sys_exec+0x126>
  }
  memset(argv, 0, sizeof(argv));
801063a1:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801063a8:	00 
801063a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801063b0:	00 
801063b1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801063b7:	89 04 24             	mov    %eax,(%esp)
801063ba:	e8 3f ef ff ff       	call   801052fe <memset>
  for(i=0;; i++){
801063bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801063c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c9:	83 f8 1f             	cmp    $0x1f,%eax
801063cc:	76 0a                	jbe    801063d8 <sys_exec+0x7b>
      return -1;
801063ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d3:	e9 ab 00 00 00       	jmp    80106483 <sys_exec+0x126>
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
801063d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063db:	c1 e0 02             	shl    $0x2,%eax
801063de:	89 c2                	mov    %eax,%edx
801063e0:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801063e6:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
801063e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063ef:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
801063f5:	89 54 24 08          	mov    %edx,0x8(%esp)
801063f9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
801063fd:	89 04 24             	mov    %eax,(%esp)
80106400:	e8 b7 f1 ff ff       	call   801055bc <fetchint>
80106405:	85 c0                	test   %eax,%eax
80106407:	79 07                	jns    80106410 <sys_exec+0xb3>
      return -1;
80106409:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010640e:	eb 73                	jmp    80106483 <sys_exec+0x126>
    if(uarg == 0){
80106410:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106416:	85 c0                	test   %eax,%eax
80106418:	75 26                	jne    80106440 <sys_exec+0xe3>
      argv[i] = 0;
8010641a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010641d:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106424:	00 00 00 00 
      break;
80106428:	90                   	nop
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106429:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010642c:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106432:	89 54 24 04          	mov    %edx,0x4(%esp)
80106436:	89 04 24             	mov    %eax,(%esp)
80106439:	e8 12 aa ff ff       	call   80100e50 <exec>
8010643e:	eb 43                	jmp    80106483 <sys_exec+0x126>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
80106440:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106443:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010644a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106450:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
80106453:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
80106459:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010645f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106463:	89 54 24 04          	mov    %edx,0x4(%esp)
80106467:	89 04 24             	mov    %eax,(%esp)
8010646a:	e8 81 f1 ff ff       	call   801055f0 <fetchstr>
8010646f:	85 c0                	test   %eax,%eax
80106471:	79 07                	jns    8010647a <sys_exec+0x11d>
      return -1;
80106473:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106478:	eb 09                	jmp    80106483 <sys_exec+0x126>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010647a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
8010647e:	e9 43 ff ff ff       	jmp    801063c6 <sys_exec+0x69>
  return exec(path, argv);
}
80106483:	c9                   	leave  
80106484:	c3                   	ret    

80106485 <sys_pipe>:

int
sys_pipe(void)
{
80106485:	55                   	push   %ebp
80106486:	89 e5                	mov    %esp,%ebp
80106488:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010648b:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106492:	00 
80106493:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106496:	89 44 24 04          	mov    %eax,0x4(%esp)
8010649a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064a1:	e8 e0 f1 ff ff       	call   80105686 <argptr>
801064a6:	85 c0                	test   %eax,%eax
801064a8:	79 0a                	jns    801064b4 <sys_pipe+0x2f>
    return -1;
801064aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064af:	e9 9b 00 00 00       	jmp    8010654f <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801064b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801064b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801064bb:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064be:	89 04 24             	mov    %eax,(%esp)
801064c1:	e8 c6 da ff ff       	call   80103f8c <pipealloc>
801064c6:	85 c0                	test   %eax,%eax
801064c8:	79 07                	jns    801064d1 <sys_pipe+0x4c>
    return -1;
801064ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064cf:	eb 7e                	jmp    8010654f <sys_pipe+0xca>
  fd0 = -1;
801064d1:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801064d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064db:	89 04 24             	mov    %eax,(%esp)
801064de:	e8 82 f3 ff ff       	call   80105865 <fdalloc>
801064e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064ea:	78 14                	js     80106500 <sys_pipe+0x7b>
801064ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064ef:	89 04 24             	mov    %eax,(%esp)
801064f2:	e8 6e f3 ff ff       	call   80105865 <fdalloc>
801064f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064fa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064fe:	79 37                	jns    80106537 <sys_pipe+0xb2>
    if(fd0 >= 0)
80106500:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106504:	78 14                	js     8010651a <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80106506:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010650c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010650f:	83 c2 08             	add    $0x8,%edx
80106512:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106519:	00 
    fileclose(rf);
8010651a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010651d:	89 04 24             	mov    %eax,(%esp)
80106520:	e8 f3 ad ff ff       	call   80101318 <fileclose>
    fileclose(wf);
80106525:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106528:	89 04 24             	mov    %eax,(%esp)
8010652b:	e8 e8 ad ff ff       	call   80101318 <fileclose>
    return -1;
80106530:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106535:	eb 18                	jmp    8010654f <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106537:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010653a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010653d:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010653f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106542:	8d 50 04             	lea    0x4(%eax),%edx
80106545:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106548:	89 02                	mov    %eax,(%edx)
  return 0;
8010654a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010654f:	c9                   	leave  
80106550:	c3                   	ret    
80106551:	00 00                	add    %al,(%eax)
	...

80106554 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106554:	55                   	push   %ebp
80106555:	89 e5                	mov    %esp,%ebp
80106557:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010655a:	e8 ea e0 ff ff       	call   80104649 <fork>
}
8010655f:	c9                   	leave  
80106560:	c3                   	ret    

80106561 <sys_exit>:

int
sys_exit(void)
{
80106561:	55                   	push   %ebp
80106562:	89 e5                	mov    %esp,%ebp
80106564:	83 ec 08             	sub    $0x8,%esp
  exit();
80106567:	e8 72 e2 ff ff       	call   801047de <exit>
  return 0;  // not reached
8010656c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106571:	c9                   	leave  
80106572:	c3                   	ret    

80106573 <sys_wait>:

int
sys_wait(void)
{
80106573:	55                   	push   %ebp
80106574:	89 e5                	mov    %esp,%ebp
80106576:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106579:	e8 a5 e3 ff ff       	call   80104923 <wait>
}
8010657e:	c9                   	leave  
8010657f:	c3                   	ret    

80106580 <sys_wait2>:

int
sys_wait2(void)
{
80106580:	55                   	push   %ebp
80106581:	89 e5                	mov    %esp,%ebp
80106583:	83 ec 28             	sub    $0x28,%esp
  char *rtime=0;
80106586:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  char *wtime=0;
8010658d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  argptr(1,&rtime,sizeof(rtime));
80106594:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
8010659b:	00 
8010659c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010659f:	89 44 24 04          	mov    %eax,0x4(%esp)
801065a3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801065aa:	e8 d7 f0 ff ff       	call   80105686 <argptr>
  argptr(0,&wtime,sizeof(wtime));
801065af:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801065b6:	00 
801065b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801065be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065c5:	e8 bc f0 ff ff       	call   80105686 <argptr>
  return wait2((int*)wtime, (int*)rtime);
801065ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065d0:	89 54 24 04          	mov    %edx,0x4(%esp)
801065d4:	89 04 24             	mov    %eax,(%esp)
801065d7:	e8 59 e4 ff ff       	call   80104a35 <wait2>
}
801065dc:	c9                   	leave  
801065dd:	c3                   	ret    

801065de <sys_kill>:

int
sys_kill(void)
{
801065de:	55                   	push   %ebp
801065df:	89 e5                	mov    %esp,%ebp
801065e1:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801065e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801065eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065f2:	e8 57 f0 ff ff       	call   8010564e <argint>
801065f7:	85 c0                	test   %eax,%eax
801065f9:	79 07                	jns    80106602 <sys_kill+0x24>
    return -1;
801065fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106600:	eb 0b                	jmp    8010660d <sys_kill+0x2f>
  return kill(pid);
80106602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106605:	89 04 24             	mov    %eax,(%esp)
80106608:	e8 c3 e8 ff ff       	call   80104ed0 <kill>
}
8010660d:	c9                   	leave  
8010660e:	c3                   	ret    

8010660f <sys_getpid>:

int
sys_getpid(void)
{
8010660f:	55                   	push   %ebp
80106610:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106612:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106618:	8b 40 10             	mov    0x10(%eax),%eax
}
8010661b:	5d                   	pop    %ebp
8010661c:	c3                   	ret    

8010661d <sys_sbrk>:

int
sys_sbrk(void)
{
8010661d:	55                   	push   %ebp
8010661e:	89 e5                	mov    %esp,%ebp
80106620:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106623:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106626:	89 44 24 04          	mov    %eax,0x4(%esp)
8010662a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106631:	e8 18 f0 ff ff       	call   8010564e <argint>
80106636:	85 c0                	test   %eax,%eax
80106638:	79 07                	jns    80106641 <sys_sbrk+0x24>
    return -1;
8010663a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010663f:	eb 24                	jmp    80106665 <sys_sbrk+0x48>
  addr = proc->sz;
80106641:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106647:	8b 00                	mov    (%eax),%eax
80106649:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010664c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010664f:	89 04 24             	mov    %eax,(%esp)
80106652:	e8 4d df ff ff       	call   801045a4 <growproc>
80106657:	85 c0                	test   %eax,%eax
80106659:	79 07                	jns    80106662 <sys_sbrk+0x45>
    return -1;
8010665b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106660:	eb 03                	jmp    80106665 <sys_sbrk+0x48>
  return addr;
80106662:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106665:	c9                   	leave  
80106666:	c3                   	ret    

80106667 <sys_sleep>:

int
sys_sleep(void)
{
80106667:	55                   	push   %ebp
80106668:	89 e5                	mov    %esp,%ebp
8010666a:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
8010666d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106670:	89 44 24 04          	mov    %eax,0x4(%esp)
80106674:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010667b:	e8 ce ef ff ff       	call   8010564e <argint>
80106680:	85 c0                	test   %eax,%eax
80106682:	79 07                	jns    8010668b <sys_sleep+0x24>
    return -1;
80106684:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106689:	eb 6c                	jmp    801066f7 <sys_sleep+0x90>
  acquire(&tickslock);
8010668b:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106692:	e8 18 ea ff ff       	call   801050af <acquire>
  ticks0 = ticks;
80106697:	a1 c0 29 11 80       	mov    0x801129c0,%eax
8010669c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010669f:	eb 34                	jmp    801066d5 <sys_sleep+0x6e>
    if(proc->killed){
801066a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066a7:	8b 40 24             	mov    0x24(%eax),%eax
801066aa:	85 c0                	test   %eax,%eax
801066ac:	74 13                	je     801066c1 <sys_sleep+0x5a>
      release(&tickslock);
801066ae:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801066b5:	e8 57 ea ff ff       	call   80105111 <release>
      return -1;
801066ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066bf:	eb 36                	jmp    801066f7 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
801066c1:	c7 44 24 04 80 21 11 	movl   $0x80112180,0x4(%esp)
801066c8:	80 
801066c9:	c7 04 24 c0 29 11 80 	movl   $0x801129c0,(%esp)
801066d0:	e8 f4 e6 ff ff       	call   80104dc9 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801066d5:	a1 c0 29 11 80       	mov    0x801129c0,%eax
801066da:	89 c2                	mov    %eax,%edx
801066dc:	2b 55 f4             	sub    -0xc(%ebp),%edx
801066df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066e2:	39 c2                	cmp    %eax,%edx
801066e4:	72 bb                	jb     801066a1 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801066e6:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801066ed:	e8 1f ea ff ff       	call   80105111 <release>
  return 0;
801066f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066f7:	c9                   	leave  
801066f8:	c3                   	ret    

801066f9 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801066f9:	55                   	push   %ebp
801066fa:	89 e5                	mov    %esp,%ebp
801066fc:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
801066ff:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106706:	e8 a4 e9 ff ff       	call   801050af <acquire>
  xticks = ticks;
8010670b:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80106710:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106713:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
8010671a:	e8 f2 e9 ff ff       	call   80105111 <release>
  return xticks;
8010671f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106722:	c9                   	leave  
80106723:	c3                   	ret    

80106724 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106724:	55                   	push   %ebp
80106725:	89 e5                	mov    %esp,%ebp
80106727:	83 ec 08             	sub    $0x8,%esp
8010672a:	8b 55 08             	mov    0x8(%ebp),%edx
8010672d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106730:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106734:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106737:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010673b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010673f:	ee                   	out    %al,(%dx)
}
80106740:	c9                   	leave  
80106741:	c3                   	ret    

80106742 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106742:	55                   	push   %ebp
80106743:	89 e5                	mov    %esp,%ebp
80106745:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106748:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
8010674f:	00 
80106750:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106757:	e8 c8 ff ff ff       	call   80106724 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
8010675c:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106763:	00 
80106764:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010676b:	e8 b4 ff ff ff       	call   80106724 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106770:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106777:	00 
80106778:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010677f:	e8 a0 ff ff ff       	call   80106724 <outb>
  picenable(IRQ_TIMER);
80106784:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010678b:	e8 85 d6 ff ff       	call   80103e15 <picenable>
}
80106790:	c9                   	leave  
80106791:	c3                   	ret    
	...

80106794 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106794:	1e                   	push   %ds
  pushl %es
80106795:	06                   	push   %es
  pushl %fs
80106796:	0f a0                	push   %fs
  pushl %gs
80106798:	0f a8                	push   %gs
  pushal
8010679a:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010679b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010679f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801067a1:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801067a3:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801067a7:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801067a9:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801067ab:	54                   	push   %esp
  call trap
801067ac:	e8 de 01 00 00       	call   8010698f <trap>
  addl $4, %esp
801067b1:	83 c4 04             	add    $0x4,%esp

801067b4 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801067b4:	61                   	popa   
  popl %gs
801067b5:	0f a9                	pop    %gs
  popl %fs
801067b7:	0f a1                	pop    %fs
  popl %es
801067b9:	07                   	pop    %es
  popl %ds
801067ba:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801067bb:	83 c4 08             	add    $0x8,%esp
  iret
801067be:	cf                   	iret   
	...

801067c0 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801067c0:	55                   	push   %ebp
801067c1:	89 e5                	mov    %esp,%ebp
801067c3:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801067c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801067c9:	83 e8 01             	sub    $0x1,%eax
801067cc:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801067d0:	8b 45 08             	mov    0x8(%ebp),%eax
801067d3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801067d7:	8b 45 08             	mov    0x8(%ebp),%eax
801067da:	c1 e8 10             	shr    $0x10,%eax
801067dd:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801067e1:	8d 45 fa             	lea    -0x6(%ebp),%eax
801067e4:	0f 01 18             	lidtl  (%eax)
}
801067e7:	c9                   	leave  
801067e8:	c3                   	ret    

801067e9 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801067e9:	55                   	push   %ebp
801067ea:	89 e5                	mov    %esp,%ebp
801067ec:	53                   	push   %ebx
801067ed:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801067f0:	0f 20 d3             	mov    %cr2,%ebx
801067f3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
801067f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801067f9:	83 c4 10             	add    $0x10,%esp
801067fc:	5b                   	pop    %ebx
801067fd:	5d                   	pop    %ebp
801067fe:	c3                   	ret    

801067ff <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801067ff:	55                   	push   %ebp
80106800:	89 e5                	mov    %esp,%ebp
80106802:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106805:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010680c:	e9 c3 00 00 00       	jmp    801068d4 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106814:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
8010681b:	89 c2                	mov    %eax,%edx
8010681d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106820:	66 89 14 c5 c0 21 11 	mov    %dx,-0x7feede40(,%eax,8)
80106827:	80 
80106828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010682b:	66 c7 04 c5 c2 21 11 	movw   $0x8,-0x7feede3e(,%eax,8)
80106832:	80 08 00 
80106835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106838:	0f b6 14 c5 c4 21 11 	movzbl -0x7feede3c(,%eax,8),%edx
8010683f:	80 
80106840:	83 e2 e0             	and    $0xffffffe0,%edx
80106843:	88 14 c5 c4 21 11 80 	mov    %dl,-0x7feede3c(,%eax,8)
8010684a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010684d:	0f b6 14 c5 c4 21 11 	movzbl -0x7feede3c(,%eax,8),%edx
80106854:	80 
80106855:	83 e2 1f             	and    $0x1f,%edx
80106858:	88 14 c5 c4 21 11 80 	mov    %dl,-0x7feede3c(,%eax,8)
8010685f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106862:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
80106869:	80 
8010686a:	83 e2 f0             	and    $0xfffffff0,%edx
8010686d:	83 ca 0e             	or     $0xe,%edx
80106870:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
80106877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010687a:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
80106881:	80 
80106882:	83 e2 ef             	and    $0xffffffef,%edx
80106885:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
8010688c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010688f:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
80106896:	80 
80106897:	83 e2 9f             	and    $0xffffff9f,%edx
8010689a:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
801068a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068a4:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
801068ab:	80 
801068ac:	83 ca 80             	or     $0xffffff80,%edx
801068af:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
801068b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068b9:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
801068c0:	c1 e8 10             	shr    $0x10,%eax
801068c3:	89 c2                	mov    %eax,%edx
801068c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068c8:	66 89 14 c5 c6 21 11 	mov    %dx,-0x7feede3a(,%eax,8)
801068cf:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801068d0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801068d4:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801068db:	0f 8e 30 ff ff ff    	jle    80106811 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801068e1:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
801068e6:	66 a3 c0 23 11 80    	mov    %ax,0x801123c0
801068ec:	66 c7 05 c2 23 11 80 	movw   $0x8,0x801123c2
801068f3:	08 00 
801068f5:	0f b6 05 c4 23 11 80 	movzbl 0x801123c4,%eax
801068fc:	83 e0 e0             	and    $0xffffffe0,%eax
801068ff:	a2 c4 23 11 80       	mov    %al,0x801123c4
80106904:	0f b6 05 c4 23 11 80 	movzbl 0x801123c4,%eax
8010690b:	83 e0 1f             	and    $0x1f,%eax
8010690e:	a2 c4 23 11 80       	mov    %al,0x801123c4
80106913:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
8010691a:	83 c8 0f             	or     $0xf,%eax
8010691d:	a2 c5 23 11 80       	mov    %al,0x801123c5
80106922:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
80106929:	83 e0 ef             	and    $0xffffffef,%eax
8010692c:	a2 c5 23 11 80       	mov    %al,0x801123c5
80106931:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
80106938:	83 c8 60             	or     $0x60,%eax
8010693b:	a2 c5 23 11 80       	mov    %al,0x801123c5
80106940:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
80106947:	83 c8 80             	or     $0xffffff80,%eax
8010694a:	a2 c5 23 11 80       	mov    %al,0x801123c5
8010694f:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
80106954:	c1 e8 10             	shr    $0x10,%eax
80106957:	66 a3 c6 23 11 80    	mov    %ax,0x801123c6
  
  initlock(&tickslock, "time");
8010695d:	c7 44 24 04 84 8b 10 	movl   $0x80108b84,0x4(%esp)
80106964:	80 
80106965:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
8010696c:	e8 1d e7 ff ff       	call   8010508e <initlock>
}
80106971:	c9                   	leave  
80106972:	c3                   	ret    

80106973 <idtinit>:

void
idtinit(void)
{
80106973:	55                   	push   %ebp
80106974:	89 e5                	mov    %esp,%ebp
80106976:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106979:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106980:	00 
80106981:	c7 04 24 c0 21 11 80 	movl   $0x801121c0,(%esp)
80106988:	e8 33 fe ff ff       	call   801067c0 <lidt>
}
8010698d:	c9                   	leave  
8010698e:	c3                   	ret    

8010698f <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010698f:	55                   	push   %ebp
80106990:	89 e5                	mov    %esp,%ebp
80106992:	57                   	push   %edi
80106993:	56                   	push   %esi
80106994:	53                   	push   %ebx
80106995:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106998:	8b 45 08             	mov    0x8(%ebp),%eax
8010699b:	8b 40 30             	mov    0x30(%eax),%eax
8010699e:	83 f8 40             	cmp    $0x40,%eax
801069a1:	75 3e                	jne    801069e1 <trap+0x52>
    if(proc->killed)
801069a3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069a9:	8b 40 24             	mov    0x24(%eax),%eax
801069ac:	85 c0                	test   %eax,%eax
801069ae:	74 05                	je     801069b5 <trap+0x26>
      exit();
801069b0:	e8 29 de ff ff       	call   801047de <exit>
    proc->tf = tf;
801069b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069bb:	8b 55 08             	mov    0x8(%ebp),%edx
801069be:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801069c1:	e8 65 ed ff ff       	call   8010572b <syscall>
    if(proc->killed)
801069c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069cc:	8b 40 24             	mov    0x24(%eax),%eax
801069cf:	85 c0                	test   %eax,%eax
801069d1:	0f 84 53 02 00 00    	je     80106c2a <trap+0x29b>
      exit();
801069d7:	e8 02 de ff ff       	call   801047de <exit>
    return;
801069dc:	e9 49 02 00 00       	jmp    80106c2a <trap+0x29b>
  }

  switch(tf->trapno){
801069e1:	8b 45 08             	mov    0x8(%ebp),%eax
801069e4:	8b 40 30             	mov    0x30(%eax),%eax
801069e7:	83 e8 20             	sub    $0x20,%eax
801069ea:	83 f8 1f             	cmp    $0x1f,%eax
801069ed:	0f 87 db 00 00 00    	ja     80106ace <trap+0x13f>
801069f3:	8b 04 85 2c 8c 10 80 	mov    -0x7fef73d4(,%eax,4),%eax
801069fa:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801069fc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a02:	0f b6 00             	movzbl (%eax),%eax
80106a05:	84 c0                	test   %al,%al
80106a07:	75 50                	jne    80106a59 <trap+0xca>
      acquire(&tickslock);
80106a09:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106a10:	e8 9a e6 ff ff       	call   801050af <acquire>
      ticks++;
80106a15:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80106a1a:	83 c0 01             	add    $0x1,%eax
80106a1d:	a3 c0 29 11 80       	mov    %eax,0x801129c0
      if(proc)
80106a22:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a28:	85 c0                	test   %eax,%eax
80106a2a:	74 15                	je     80106a41 <trap+0xb2>
	(proc->rtime)++;
80106a2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a32:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80106a38:	83 c2 01             	add    $0x1,%edx
80106a3b:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
      wakeup(&ticks);
80106a41:	c7 04 24 c0 29 11 80 	movl   $0x801129c0,(%esp)
80106a48:	e8 58 e4 ff ff       	call   80104ea5 <wakeup>
      release(&tickslock);
80106a4d:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106a54:	e8 b8 e6 ff ff       	call   80105111 <release>
    }
    lapiceoi();
80106a59:	e8 df c7 ff ff       	call   8010323d <lapiceoi>
    break;
80106a5e:	e9 41 01 00 00       	jmp    80106ba4 <trap+0x215>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106a63:	e8 dd bf ff ff       	call   80102a45 <ideintr>
    lapiceoi();
80106a68:	e8 d0 c7 ff ff       	call   8010323d <lapiceoi>
    break;
80106a6d:	e9 32 01 00 00       	jmp    80106ba4 <trap+0x215>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106a72:	e8 a4 c5 ff ff       	call   8010301b <kbdintr>
    lapiceoi();
80106a77:	e8 c1 c7 ff ff       	call   8010323d <lapiceoi>
    break;
80106a7c:	e9 23 01 00 00       	jmp    80106ba4 <trap+0x215>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106a81:	e8 aa 03 00 00       	call   80106e30 <uartintr>
    lapiceoi();
80106a86:	e8 b2 c7 ff ff       	call   8010323d <lapiceoi>
    break;
80106a8b:	e9 14 01 00 00       	jmp    80106ba4 <trap+0x215>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106a90:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a93:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106a96:	8b 45 08             	mov    0x8(%ebp),%eax
80106a99:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a9d:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106aa0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106aa6:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106aa9:	0f b6 c0             	movzbl %al,%eax
80106aac:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106ab0:	89 54 24 08          	mov    %edx,0x8(%esp)
80106ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ab8:	c7 04 24 8c 8b 10 80 	movl   $0x80108b8c,(%esp)
80106abf:	e8 dd 98 ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106ac4:	e8 74 c7 ff ff       	call   8010323d <lapiceoi>
    break;
80106ac9:	e9 d6 00 00 00       	jmp    80106ba4 <trap+0x215>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106ace:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ad4:	85 c0                	test   %eax,%eax
80106ad6:	74 11                	je     80106ae9 <trap+0x15a>
80106ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80106adb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106adf:	0f b7 c0             	movzwl %ax,%eax
80106ae2:	83 e0 03             	and    $0x3,%eax
80106ae5:	85 c0                	test   %eax,%eax
80106ae7:	75 46                	jne    80106b2f <trap+0x1a0>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106ae9:	e8 fb fc ff ff       	call   801067e9 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106aee:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106af1:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106af4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106afb:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106afe:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106b01:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106b04:	8b 52 30             	mov    0x30(%edx),%edx
80106b07:	89 44 24 10          	mov    %eax,0x10(%esp)
80106b0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106b0f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106b13:	89 54 24 04          	mov    %edx,0x4(%esp)
80106b17:	c7 04 24 b0 8b 10 80 	movl   $0x80108bb0,(%esp)
80106b1e:	e8 7e 98 ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106b23:	c7 04 24 e2 8b 10 80 	movl   $0x80108be2,(%esp)
80106b2a:	e8 0e 9a ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b2f:	e8 b5 fc ff ff       	call   801067e9 <rcr2>
80106b34:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b36:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b39:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b3c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b42:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b45:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b48:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b4b:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b4e:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b51:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b54:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b5a:	83 c0 6c             	add    $0x6c,%eax
80106b5d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106b60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b66:	8b 40 10             	mov    0x10(%eax),%eax
80106b69:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106b6d:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106b71:	89 74 24 14          	mov    %esi,0x14(%esp)
80106b75:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106b79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106b7d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106b80:	89 54 24 08          	mov    %edx,0x8(%esp)
80106b84:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b88:	c7 04 24 e8 8b 10 80 	movl   $0x80108be8,(%esp)
80106b8f:	e8 0d 98 ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106b94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b9a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106ba1:	eb 01                	jmp    80106ba4 <trap+0x215>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106ba3:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106ba4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106baa:	85 c0                	test   %eax,%eax
80106bac:	74 24                	je     80106bd2 <trap+0x243>
80106bae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bb4:	8b 40 24             	mov    0x24(%eax),%eax
80106bb7:	85 c0                	test   %eax,%eax
80106bb9:	74 17                	je     80106bd2 <trap+0x243>
80106bbb:	8b 45 08             	mov    0x8(%ebp),%eax
80106bbe:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106bc2:	0f b7 c0             	movzwl %ax,%eax
80106bc5:	83 e0 03             	and    $0x3,%eax
80106bc8:	83 f8 03             	cmp    $0x3,%eax
80106bcb:	75 05                	jne    80106bd2 <trap+0x243>
    exit();
80106bcd:	e8 0c dc ff ff       	call   801047de <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106bd2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bd8:	85 c0                	test   %eax,%eax
80106bda:	74 1e                	je     80106bfa <trap+0x26b>
80106bdc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106be2:	8b 40 0c             	mov    0xc(%eax),%eax
80106be5:	83 f8 04             	cmp    $0x4,%eax
80106be8:	75 10                	jne    80106bfa <trap+0x26b>
80106bea:	8b 45 08             	mov    0x8(%ebp),%eax
80106bed:	8b 40 30             	mov    0x30(%eax),%eax
80106bf0:	83 f8 20             	cmp    $0x20,%eax
80106bf3:	75 05                	jne    80106bfa <trap+0x26b>
    yield();
80106bf5:	e8 71 e1 ff ff       	call   80104d6b <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106bfa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c00:	85 c0                	test   %eax,%eax
80106c02:	74 27                	je     80106c2b <trap+0x29c>
80106c04:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c0a:	8b 40 24             	mov    0x24(%eax),%eax
80106c0d:	85 c0                	test   %eax,%eax
80106c0f:	74 1a                	je     80106c2b <trap+0x29c>
80106c11:	8b 45 08             	mov    0x8(%ebp),%eax
80106c14:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c18:	0f b7 c0             	movzwl %ax,%eax
80106c1b:	83 e0 03             	and    $0x3,%eax
80106c1e:	83 f8 03             	cmp    $0x3,%eax
80106c21:	75 08                	jne    80106c2b <trap+0x29c>
    exit();
80106c23:	e8 b6 db ff ff       	call   801047de <exit>
80106c28:	eb 01                	jmp    80106c2b <trap+0x29c>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106c2a:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106c2b:	83 c4 3c             	add    $0x3c,%esp
80106c2e:	5b                   	pop    %ebx
80106c2f:	5e                   	pop    %esi
80106c30:	5f                   	pop    %edi
80106c31:	5d                   	pop    %ebp
80106c32:	c3                   	ret    
	...

80106c34 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106c34:	55                   	push   %ebp
80106c35:	89 e5                	mov    %esp,%ebp
80106c37:	53                   	push   %ebx
80106c38:	83 ec 14             	sub    $0x14,%esp
80106c3b:	8b 45 08             	mov    0x8(%ebp),%eax
80106c3e:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106c42:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80106c46:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80106c4a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80106c4e:	ec                   	in     (%dx),%al
80106c4f:	89 c3                	mov    %eax,%ebx
80106c51:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80106c54:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80106c58:	83 c4 14             	add    $0x14,%esp
80106c5b:	5b                   	pop    %ebx
80106c5c:	5d                   	pop    %ebp
80106c5d:	c3                   	ret    

80106c5e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106c5e:	55                   	push   %ebp
80106c5f:	89 e5                	mov    %esp,%ebp
80106c61:	83 ec 08             	sub    $0x8,%esp
80106c64:	8b 55 08             	mov    0x8(%ebp),%edx
80106c67:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c6a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106c6e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106c71:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106c75:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106c79:	ee                   	out    %al,(%dx)
}
80106c7a:	c9                   	leave  
80106c7b:	c3                   	ret    

80106c7c <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106c7c:	55                   	push   %ebp
80106c7d:	89 e5                	mov    %esp,%ebp
80106c7f:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106c82:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c89:	00 
80106c8a:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106c91:	e8 c8 ff ff ff       	call   80106c5e <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106c96:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106c9d:	00 
80106c9e:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106ca5:	e8 b4 ff ff ff       	call   80106c5e <outb>
  outb(COM1+0, 115200/9600);
80106caa:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106cb1:	00 
80106cb2:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106cb9:	e8 a0 ff ff ff       	call   80106c5e <outb>
  outb(COM1+1, 0);
80106cbe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106cc5:	00 
80106cc6:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106ccd:	e8 8c ff ff ff       	call   80106c5e <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106cd2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106cd9:	00 
80106cda:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106ce1:	e8 78 ff ff ff       	call   80106c5e <outb>
  outb(COM1+4, 0);
80106ce6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106ced:	00 
80106cee:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106cf5:	e8 64 ff ff ff       	call   80106c5e <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106cfa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106d01:	00 
80106d02:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106d09:	e8 50 ff ff ff       	call   80106c5e <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106d0e:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106d15:	e8 1a ff ff ff       	call   80106c34 <inb>
80106d1a:	3c ff                	cmp    $0xff,%al
80106d1c:	74 6c                	je     80106d8a <uartinit+0x10e>
    return;
  uart = 1;
80106d1e:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106d25:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106d28:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106d2f:	e8 00 ff ff ff       	call   80106c34 <inb>
  inb(COM1+0);
80106d34:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106d3b:	e8 f4 fe ff ff       	call   80106c34 <inb>
  picenable(IRQ_COM1);
80106d40:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106d47:	e8 c9 d0 ff ff       	call   80103e15 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106d4c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d53:	00 
80106d54:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106d5b:	e8 6a bf ff ff       	call   80102cca <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d60:	c7 45 f4 ac 8c 10 80 	movl   $0x80108cac,-0xc(%ebp)
80106d67:	eb 15                	jmp    80106d7e <uartinit+0x102>
    uartputc(*p);
80106d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d6c:	0f b6 00             	movzbl (%eax),%eax
80106d6f:	0f be c0             	movsbl %al,%eax
80106d72:	89 04 24             	mov    %eax,(%esp)
80106d75:	e8 13 00 00 00       	call   80106d8d <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d7a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d81:	0f b6 00             	movzbl (%eax),%eax
80106d84:	84 c0                	test   %al,%al
80106d86:	75 e1                	jne    80106d69 <uartinit+0xed>
80106d88:	eb 01                	jmp    80106d8b <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106d8a:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106d8b:	c9                   	leave  
80106d8c:	c3                   	ret    

80106d8d <uartputc>:

void
uartputc(int c)
{
80106d8d:	55                   	push   %ebp
80106d8e:	89 e5                	mov    %esp,%ebp
80106d90:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106d93:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106d98:	85 c0                	test   %eax,%eax
80106d9a:	74 4d                	je     80106de9 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d9c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106da3:	eb 10                	jmp    80106db5 <uartputc+0x28>
    microdelay(10);
80106da5:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106dac:	e8 b1 c4 ff ff       	call   80103262 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106db1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106db5:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106db9:	7f 16                	jg     80106dd1 <uartputc+0x44>
80106dbb:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106dc2:	e8 6d fe ff ff       	call   80106c34 <inb>
80106dc7:	0f b6 c0             	movzbl %al,%eax
80106dca:	83 e0 20             	and    $0x20,%eax
80106dcd:	85 c0                	test   %eax,%eax
80106dcf:	74 d4                	je     80106da5 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80106dd4:	0f b6 c0             	movzbl %al,%eax
80106dd7:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ddb:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106de2:	e8 77 fe ff ff       	call   80106c5e <outb>
80106de7:	eb 01                	jmp    80106dea <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106de9:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106dea:	c9                   	leave  
80106deb:	c3                   	ret    

80106dec <uartgetc>:

static int
uartgetc(void)
{
80106dec:	55                   	push   %ebp
80106ded:	89 e5                	mov    %esp,%ebp
80106def:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106df2:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106df7:	85 c0                	test   %eax,%eax
80106df9:	75 07                	jne    80106e02 <uartgetc+0x16>
    return -1;
80106dfb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e00:	eb 2c                	jmp    80106e2e <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106e02:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106e09:	e8 26 fe ff ff       	call   80106c34 <inb>
80106e0e:	0f b6 c0             	movzbl %al,%eax
80106e11:	83 e0 01             	and    $0x1,%eax
80106e14:	85 c0                	test   %eax,%eax
80106e16:	75 07                	jne    80106e1f <uartgetc+0x33>
    return -1;
80106e18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e1d:	eb 0f                	jmp    80106e2e <uartgetc+0x42>
  return inb(COM1+0);
80106e1f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e26:	e8 09 fe ff ff       	call   80106c34 <inb>
80106e2b:	0f b6 c0             	movzbl %al,%eax
}
80106e2e:	c9                   	leave  
80106e2f:	c3                   	ret    

80106e30 <uartintr>:

void
uartintr(void)
{
80106e30:	55                   	push   %ebp
80106e31:	89 e5                	mov    %esp,%ebp
80106e33:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106e36:	c7 04 24 ec 6d 10 80 	movl   $0x80106dec,(%esp)
80106e3d:	e8 8c 9a ff ff       	call   801008ce <consoleintr>
}
80106e42:	c9                   	leave  
80106e43:	c3                   	ret    

80106e44 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106e44:	6a 00                	push   $0x0
  pushl $0
80106e46:	6a 00                	push   $0x0
  jmp alltraps
80106e48:	e9 47 f9 ff ff       	jmp    80106794 <alltraps>

80106e4d <vector1>:
.globl vector1
vector1:
  pushl $0
80106e4d:	6a 00                	push   $0x0
  pushl $1
80106e4f:	6a 01                	push   $0x1
  jmp alltraps
80106e51:	e9 3e f9 ff ff       	jmp    80106794 <alltraps>

80106e56 <vector2>:
.globl vector2
vector2:
  pushl $0
80106e56:	6a 00                	push   $0x0
  pushl $2
80106e58:	6a 02                	push   $0x2
  jmp alltraps
80106e5a:	e9 35 f9 ff ff       	jmp    80106794 <alltraps>

80106e5f <vector3>:
.globl vector3
vector3:
  pushl $0
80106e5f:	6a 00                	push   $0x0
  pushl $3
80106e61:	6a 03                	push   $0x3
  jmp alltraps
80106e63:	e9 2c f9 ff ff       	jmp    80106794 <alltraps>

80106e68 <vector4>:
.globl vector4
vector4:
  pushl $0
80106e68:	6a 00                	push   $0x0
  pushl $4
80106e6a:	6a 04                	push   $0x4
  jmp alltraps
80106e6c:	e9 23 f9 ff ff       	jmp    80106794 <alltraps>

80106e71 <vector5>:
.globl vector5
vector5:
  pushl $0
80106e71:	6a 00                	push   $0x0
  pushl $5
80106e73:	6a 05                	push   $0x5
  jmp alltraps
80106e75:	e9 1a f9 ff ff       	jmp    80106794 <alltraps>

80106e7a <vector6>:
.globl vector6
vector6:
  pushl $0
80106e7a:	6a 00                	push   $0x0
  pushl $6
80106e7c:	6a 06                	push   $0x6
  jmp alltraps
80106e7e:	e9 11 f9 ff ff       	jmp    80106794 <alltraps>

80106e83 <vector7>:
.globl vector7
vector7:
  pushl $0
80106e83:	6a 00                	push   $0x0
  pushl $7
80106e85:	6a 07                	push   $0x7
  jmp alltraps
80106e87:	e9 08 f9 ff ff       	jmp    80106794 <alltraps>

80106e8c <vector8>:
.globl vector8
vector8:
  pushl $8
80106e8c:	6a 08                	push   $0x8
  jmp alltraps
80106e8e:	e9 01 f9 ff ff       	jmp    80106794 <alltraps>

80106e93 <vector9>:
.globl vector9
vector9:
  pushl $0
80106e93:	6a 00                	push   $0x0
  pushl $9
80106e95:	6a 09                	push   $0x9
  jmp alltraps
80106e97:	e9 f8 f8 ff ff       	jmp    80106794 <alltraps>

80106e9c <vector10>:
.globl vector10
vector10:
  pushl $10
80106e9c:	6a 0a                	push   $0xa
  jmp alltraps
80106e9e:	e9 f1 f8 ff ff       	jmp    80106794 <alltraps>

80106ea3 <vector11>:
.globl vector11
vector11:
  pushl $11
80106ea3:	6a 0b                	push   $0xb
  jmp alltraps
80106ea5:	e9 ea f8 ff ff       	jmp    80106794 <alltraps>

80106eaa <vector12>:
.globl vector12
vector12:
  pushl $12
80106eaa:	6a 0c                	push   $0xc
  jmp alltraps
80106eac:	e9 e3 f8 ff ff       	jmp    80106794 <alltraps>

80106eb1 <vector13>:
.globl vector13
vector13:
  pushl $13
80106eb1:	6a 0d                	push   $0xd
  jmp alltraps
80106eb3:	e9 dc f8 ff ff       	jmp    80106794 <alltraps>

80106eb8 <vector14>:
.globl vector14
vector14:
  pushl $14
80106eb8:	6a 0e                	push   $0xe
  jmp alltraps
80106eba:	e9 d5 f8 ff ff       	jmp    80106794 <alltraps>

80106ebf <vector15>:
.globl vector15
vector15:
  pushl $0
80106ebf:	6a 00                	push   $0x0
  pushl $15
80106ec1:	6a 0f                	push   $0xf
  jmp alltraps
80106ec3:	e9 cc f8 ff ff       	jmp    80106794 <alltraps>

80106ec8 <vector16>:
.globl vector16
vector16:
  pushl $0
80106ec8:	6a 00                	push   $0x0
  pushl $16
80106eca:	6a 10                	push   $0x10
  jmp alltraps
80106ecc:	e9 c3 f8 ff ff       	jmp    80106794 <alltraps>

80106ed1 <vector17>:
.globl vector17
vector17:
  pushl $17
80106ed1:	6a 11                	push   $0x11
  jmp alltraps
80106ed3:	e9 bc f8 ff ff       	jmp    80106794 <alltraps>

80106ed8 <vector18>:
.globl vector18
vector18:
  pushl $0
80106ed8:	6a 00                	push   $0x0
  pushl $18
80106eda:	6a 12                	push   $0x12
  jmp alltraps
80106edc:	e9 b3 f8 ff ff       	jmp    80106794 <alltraps>

80106ee1 <vector19>:
.globl vector19
vector19:
  pushl $0
80106ee1:	6a 00                	push   $0x0
  pushl $19
80106ee3:	6a 13                	push   $0x13
  jmp alltraps
80106ee5:	e9 aa f8 ff ff       	jmp    80106794 <alltraps>

80106eea <vector20>:
.globl vector20
vector20:
  pushl $0
80106eea:	6a 00                	push   $0x0
  pushl $20
80106eec:	6a 14                	push   $0x14
  jmp alltraps
80106eee:	e9 a1 f8 ff ff       	jmp    80106794 <alltraps>

80106ef3 <vector21>:
.globl vector21
vector21:
  pushl $0
80106ef3:	6a 00                	push   $0x0
  pushl $21
80106ef5:	6a 15                	push   $0x15
  jmp alltraps
80106ef7:	e9 98 f8 ff ff       	jmp    80106794 <alltraps>

80106efc <vector22>:
.globl vector22
vector22:
  pushl $0
80106efc:	6a 00                	push   $0x0
  pushl $22
80106efe:	6a 16                	push   $0x16
  jmp alltraps
80106f00:	e9 8f f8 ff ff       	jmp    80106794 <alltraps>

80106f05 <vector23>:
.globl vector23
vector23:
  pushl $0
80106f05:	6a 00                	push   $0x0
  pushl $23
80106f07:	6a 17                	push   $0x17
  jmp alltraps
80106f09:	e9 86 f8 ff ff       	jmp    80106794 <alltraps>

80106f0e <vector24>:
.globl vector24
vector24:
  pushl $0
80106f0e:	6a 00                	push   $0x0
  pushl $24
80106f10:	6a 18                	push   $0x18
  jmp alltraps
80106f12:	e9 7d f8 ff ff       	jmp    80106794 <alltraps>

80106f17 <vector25>:
.globl vector25
vector25:
  pushl $0
80106f17:	6a 00                	push   $0x0
  pushl $25
80106f19:	6a 19                	push   $0x19
  jmp alltraps
80106f1b:	e9 74 f8 ff ff       	jmp    80106794 <alltraps>

80106f20 <vector26>:
.globl vector26
vector26:
  pushl $0
80106f20:	6a 00                	push   $0x0
  pushl $26
80106f22:	6a 1a                	push   $0x1a
  jmp alltraps
80106f24:	e9 6b f8 ff ff       	jmp    80106794 <alltraps>

80106f29 <vector27>:
.globl vector27
vector27:
  pushl $0
80106f29:	6a 00                	push   $0x0
  pushl $27
80106f2b:	6a 1b                	push   $0x1b
  jmp alltraps
80106f2d:	e9 62 f8 ff ff       	jmp    80106794 <alltraps>

80106f32 <vector28>:
.globl vector28
vector28:
  pushl $0
80106f32:	6a 00                	push   $0x0
  pushl $28
80106f34:	6a 1c                	push   $0x1c
  jmp alltraps
80106f36:	e9 59 f8 ff ff       	jmp    80106794 <alltraps>

80106f3b <vector29>:
.globl vector29
vector29:
  pushl $0
80106f3b:	6a 00                	push   $0x0
  pushl $29
80106f3d:	6a 1d                	push   $0x1d
  jmp alltraps
80106f3f:	e9 50 f8 ff ff       	jmp    80106794 <alltraps>

80106f44 <vector30>:
.globl vector30
vector30:
  pushl $0
80106f44:	6a 00                	push   $0x0
  pushl $30
80106f46:	6a 1e                	push   $0x1e
  jmp alltraps
80106f48:	e9 47 f8 ff ff       	jmp    80106794 <alltraps>

80106f4d <vector31>:
.globl vector31
vector31:
  pushl $0
80106f4d:	6a 00                	push   $0x0
  pushl $31
80106f4f:	6a 1f                	push   $0x1f
  jmp alltraps
80106f51:	e9 3e f8 ff ff       	jmp    80106794 <alltraps>

80106f56 <vector32>:
.globl vector32
vector32:
  pushl $0
80106f56:	6a 00                	push   $0x0
  pushl $32
80106f58:	6a 20                	push   $0x20
  jmp alltraps
80106f5a:	e9 35 f8 ff ff       	jmp    80106794 <alltraps>

80106f5f <vector33>:
.globl vector33
vector33:
  pushl $0
80106f5f:	6a 00                	push   $0x0
  pushl $33
80106f61:	6a 21                	push   $0x21
  jmp alltraps
80106f63:	e9 2c f8 ff ff       	jmp    80106794 <alltraps>

80106f68 <vector34>:
.globl vector34
vector34:
  pushl $0
80106f68:	6a 00                	push   $0x0
  pushl $34
80106f6a:	6a 22                	push   $0x22
  jmp alltraps
80106f6c:	e9 23 f8 ff ff       	jmp    80106794 <alltraps>

80106f71 <vector35>:
.globl vector35
vector35:
  pushl $0
80106f71:	6a 00                	push   $0x0
  pushl $35
80106f73:	6a 23                	push   $0x23
  jmp alltraps
80106f75:	e9 1a f8 ff ff       	jmp    80106794 <alltraps>

80106f7a <vector36>:
.globl vector36
vector36:
  pushl $0
80106f7a:	6a 00                	push   $0x0
  pushl $36
80106f7c:	6a 24                	push   $0x24
  jmp alltraps
80106f7e:	e9 11 f8 ff ff       	jmp    80106794 <alltraps>

80106f83 <vector37>:
.globl vector37
vector37:
  pushl $0
80106f83:	6a 00                	push   $0x0
  pushl $37
80106f85:	6a 25                	push   $0x25
  jmp alltraps
80106f87:	e9 08 f8 ff ff       	jmp    80106794 <alltraps>

80106f8c <vector38>:
.globl vector38
vector38:
  pushl $0
80106f8c:	6a 00                	push   $0x0
  pushl $38
80106f8e:	6a 26                	push   $0x26
  jmp alltraps
80106f90:	e9 ff f7 ff ff       	jmp    80106794 <alltraps>

80106f95 <vector39>:
.globl vector39
vector39:
  pushl $0
80106f95:	6a 00                	push   $0x0
  pushl $39
80106f97:	6a 27                	push   $0x27
  jmp alltraps
80106f99:	e9 f6 f7 ff ff       	jmp    80106794 <alltraps>

80106f9e <vector40>:
.globl vector40
vector40:
  pushl $0
80106f9e:	6a 00                	push   $0x0
  pushl $40
80106fa0:	6a 28                	push   $0x28
  jmp alltraps
80106fa2:	e9 ed f7 ff ff       	jmp    80106794 <alltraps>

80106fa7 <vector41>:
.globl vector41
vector41:
  pushl $0
80106fa7:	6a 00                	push   $0x0
  pushl $41
80106fa9:	6a 29                	push   $0x29
  jmp alltraps
80106fab:	e9 e4 f7 ff ff       	jmp    80106794 <alltraps>

80106fb0 <vector42>:
.globl vector42
vector42:
  pushl $0
80106fb0:	6a 00                	push   $0x0
  pushl $42
80106fb2:	6a 2a                	push   $0x2a
  jmp alltraps
80106fb4:	e9 db f7 ff ff       	jmp    80106794 <alltraps>

80106fb9 <vector43>:
.globl vector43
vector43:
  pushl $0
80106fb9:	6a 00                	push   $0x0
  pushl $43
80106fbb:	6a 2b                	push   $0x2b
  jmp alltraps
80106fbd:	e9 d2 f7 ff ff       	jmp    80106794 <alltraps>

80106fc2 <vector44>:
.globl vector44
vector44:
  pushl $0
80106fc2:	6a 00                	push   $0x0
  pushl $44
80106fc4:	6a 2c                	push   $0x2c
  jmp alltraps
80106fc6:	e9 c9 f7 ff ff       	jmp    80106794 <alltraps>

80106fcb <vector45>:
.globl vector45
vector45:
  pushl $0
80106fcb:	6a 00                	push   $0x0
  pushl $45
80106fcd:	6a 2d                	push   $0x2d
  jmp alltraps
80106fcf:	e9 c0 f7 ff ff       	jmp    80106794 <alltraps>

80106fd4 <vector46>:
.globl vector46
vector46:
  pushl $0
80106fd4:	6a 00                	push   $0x0
  pushl $46
80106fd6:	6a 2e                	push   $0x2e
  jmp alltraps
80106fd8:	e9 b7 f7 ff ff       	jmp    80106794 <alltraps>

80106fdd <vector47>:
.globl vector47
vector47:
  pushl $0
80106fdd:	6a 00                	push   $0x0
  pushl $47
80106fdf:	6a 2f                	push   $0x2f
  jmp alltraps
80106fe1:	e9 ae f7 ff ff       	jmp    80106794 <alltraps>

80106fe6 <vector48>:
.globl vector48
vector48:
  pushl $0
80106fe6:	6a 00                	push   $0x0
  pushl $48
80106fe8:	6a 30                	push   $0x30
  jmp alltraps
80106fea:	e9 a5 f7 ff ff       	jmp    80106794 <alltraps>

80106fef <vector49>:
.globl vector49
vector49:
  pushl $0
80106fef:	6a 00                	push   $0x0
  pushl $49
80106ff1:	6a 31                	push   $0x31
  jmp alltraps
80106ff3:	e9 9c f7 ff ff       	jmp    80106794 <alltraps>

80106ff8 <vector50>:
.globl vector50
vector50:
  pushl $0
80106ff8:	6a 00                	push   $0x0
  pushl $50
80106ffa:	6a 32                	push   $0x32
  jmp alltraps
80106ffc:	e9 93 f7 ff ff       	jmp    80106794 <alltraps>

80107001 <vector51>:
.globl vector51
vector51:
  pushl $0
80107001:	6a 00                	push   $0x0
  pushl $51
80107003:	6a 33                	push   $0x33
  jmp alltraps
80107005:	e9 8a f7 ff ff       	jmp    80106794 <alltraps>

8010700a <vector52>:
.globl vector52
vector52:
  pushl $0
8010700a:	6a 00                	push   $0x0
  pushl $52
8010700c:	6a 34                	push   $0x34
  jmp alltraps
8010700e:	e9 81 f7 ff ff       	jmp    80106794 <alltraps>

80107013 <vector53>:
.globl vector53
vector53:
  pushl $0
80107013:	6a 00                	push   $0x0
  pushl $53
80107015:	6a 35                	push   $0x35
  jmp alltraps
80107017:	e9 78 f7 ff ff       	jmp    80106794 <alltraps>

8010701c <vector54>:
.globl vector54
vector54:
  pushl $0
8010701c:	6a 00                	push   $0x0
  pushl $54
8010701e:	6a 36                	push   $0x36
  jmp alltraps
80107020:	e9 6f f7 ff ff       	jmp    80106794 <alltraps>

80107025 <vector55>:
.globl vector55
vector55:
  pushl $0
80107025:	6a 00                	push   $0x0
  pushl $55
80107027:	6a 37                	push   $0x37
  jmp alltraps
80107029:	e9 66 f7 ff ff       	jmp    80106794 <alltraps>

8010702e <vector56>:
.globl vector56
vector56:
  pushl $0
8010702e:	6a 00                	push   $0x0
  pushl $56
80107030:	6a 38                	push   $0x38
  jmp alltraps
80107032:	e9 5d f7 ff ff       	jmp    80106794 <alltraps>

80107037 <vector57>:
.globl vector57
vector57:
  pushl $0
80107037:	6a 00                	push   $0x0
  pushl $57
80107039:	6a 39                	push   $0x39
  jmp alltraps
8010703b:	e9 54 f7 ff ff       	jmp    80106794 <alltraps>

80107040 <vector58>:
.globl vector58
vector58:
  pushl $0
80107040:	6a 00                	push   $0x0
  pushl $58
80107042:	6a 3a                	push   $0x3a
  jmp alltraps
80107044:	e9 4b f7 ff ff       	jmp    80106794 <alltraps>

80107049 <vector59>:
.globl vector59
vector59:
  pushl $0
80107049:	6a 00                	push   $0x0
  pushl $59
8010704b:	6a 3b                	push   $0x3b
  jmp alltraps
8010704d:	e9 42 f7 ff ff       	jmp    80106794 <alltraps>

80107052 <vector60>:
.globl vector60
vector60:
  pushl $0
80107052:	6a 00                	push   $0x0
  pushl $60
80107054:	6a 3c                	push   $0x3c
  jmp alltraps
80107056:	e9 39 f7 ff ff       	jmp    80106794 <alltraps>

8010705b <vector61>:
.globl vector61
vector61:
  pushl $0
8010705b:	6a 00                	push   $0x0
  pushl $61
8010705d:	6a 3d                	push   $0x3d
  jmp alltraps
8010705f:	e9 30 f7 ff ff       	jmp    80106794 <alltraps>

80107064 <vector62>:
.globl vector62
vector62:
  pushl $0
80107064:	6a 00                	push   $0x0
  pushl $62
80107066:	6a 3e                	push   $0x3e
  jmp alltraps
80107068:	e9 27 f7 ff ff       	jmp    80106794 <alltraps>

8010706d <vector63>:
.globl vector63
vector63:
  pushl $0
8010706d:	6a 00                	push   $0x0
  pushl $63
8010706f:	6a 3f                	push   $0x3f
  jmp alltraps
80107071:	e9 1e f7 ff ff       	jmp    80106794 <alltraps>

80107076 <vector64>:
.globl vector64
vector64:
  pushl $0
80107076:	6a 00                	push   $0x0
  pushl $64
80107078:	6a 40                	push   $0x40
  jmp alltraps
8010707a:	e9 15 f7 ff ff       	jmp    80106794 <alltraps>

8010707f <vector65>:
.globl vector65
vector65:
  pushl $0
8010707f:	6a 00                	push   $0x0
  pushl $65
80107081:	6a 41                	push   $0x41
  jmp alltraps
80107083:	e9 0c f7 ff ff       	jmp    80106794 <alltraps>

80107088 <vector66>:
.globl vector66
vector66:
  pushl $0
80107088:	6a 00                	push   $0x0
  pushl $66
8010708a:	6a 42                	push   $0x42
  jmp alltraps
8010708c:	e9 03 f7 ff ff       	jmp    80106794 <alltraps>

80107091 <vector67>:
.globl vector67
vector67:
  pushl $0
80107091:	6a 00                	push   $0x0
  pushl $67
80107093:	6a 43                	push   $0x43
  jmp alltraps
80107095:	e9 fa f6 ff ff       	jmp    80106794 <alltraps>

8010709a <vector68>:
.globl vector68
vector68:
  pushl $0
8010709a:	6a 00                	push   $0x0
  pushl $68
8010709c:	6a 44                	push   $0x44
  jmp alltraps
8010709e:	e9 f1 f6 ff ff       	jmp    80106794 <alltraps>

801070a3 <vector69>:
.globl vector69
vector69:
  pushl $0
801070a3:	6a 00                	push   $0x0
  pushl $69
801070a5:	6a 45                	push   $0x45
  jmp alltraps
801070a7:	e9 e8 f6 ff ff       	jmp    80106794 <alltraps>

801070ac <vector70>:
.globl vector70
vector70:
  pushl $0
801070ac:	6a 00                	push   $0x0
  pushl $70
801070ae:	6a 46                	push   $0x46
  jmp alltraps
801070b0:	e9 df f6 ff ff       	jmp    80106794 <alltraps>

801070b5 <vector71>:
.globl vector71
vector71:
  pushl $0
801070b5:	6a 00                	push   $0x0
  pushl $71
801070b7:	6a 47                	push   $0x47
  jmp alltraps
801070b9:	e9 d6 f6 ff ff       	jmp    80106794 <alltraps>

801070be <vector72>:
.globl vector72
vector72:
  pushl $0
801070be:	6a 00                	push   $0x0
  pushl $72
801070c0:	6a 48                	push   $0x48
  jmp alltraps
801070c2:	e9 cd f6 ff ff       	jmp    80106794 <alltraps>

801070c7 <vector73>:
.globl vector73
vector73:
  pushl $0
801070c7:	6a 00                	push   $0x0
  pushl $73
801070c9:	6a 49                	push   $0x49
  jmp alltraps
801070cb:	e9 c4 f6 ff ff       	jmp    80106794 <alltraps>

801070d0 <vector74>:
.globl vector74
vector74:
  pushl $0
801070d0:	6a 00                	push   $0x0
  pushl $74
801070d2:	6a 4a                	push   $0x4a
  jmp alltraps
801070d4:	e9 bb f6 ff ff       	jmp    80106794 <alltraps>

801070d9 <vector75>:
.globl vector75
vector75:
  pushl $0
801070d9:	6a 00                	push   $0x0
  pushl $75
801070db:	6a 4b                	push   $0x4b
  jmp alltraps
801070dd:	e9 b2 f6 ff ff       	jmp    80106794 <alltraps>

801070e2 <vector76>:
.globl vector76
vector76:
  pushl $0
801070e2:	6a 00                	push   $0x0
  pushl $76
801070e4:	6a 4c                	push   $0x4c
  jmp alltraps
801070e6:	e9 a9 f6 ff ff       	jmp    80106794 <alltraps>

801070eb <vector77>:
.globl vector77
vector77:
  pushl $0
801070eb:	6a 00                	push   $0x0
  pushl $77
801070ed:	6a 4d                	push   $0x4d
  jmp alltraps
801070ef:	e9 a0 f6 ff ff       	jmp    80106794 <alltraps>

801070f4 <vector78>:
.globl vector78
vector78:
  pushl $0
801070f4:	6a 00                	push   $0x0
  pushl $78
801070f6:	6a 4e                	push   $0x4e
  jmp alltraps
801070f8:	e9 97 f6 ff ff       	jmp    80106794 <alltraps>

801070fd <vector79>:
.globl vector79
vector79:
  pushl $0
801070fd:	6a 00                	push   $0x0
  pushl $79
801070ff:	6a 4f                	push   $0x4f
  jmp alltraps
80107101:	e9 8e f6 ff ff       	jmp    80106794 <alltraps>

80107106 <vector80>:
.globl vector80
vector80:
  pushl $0
80107106:	6a 00                	push   $0x0
  pushl $80
80107108:	6a 50                	push   $0x50
  jmp alltraps
8010710a:	e9 85 f6 ff ff       	jmp    80106794 <alltraps>

8010710f <vector81>:
.globl vector81
vector81:
  pushl $0
8010710f:	6a 00                	push   $0x0
  pushl $81
80107111:	6a 51                	push   $0x51
  jmp alltraps
80107113:	e9 7c f6 ff ff       	jmp    80106794 <alltraps>

80107118 <vector82>:
.globl vector82
vector82:
  pushl $0
80107118:	6a 00                	push   $0x0
  pushl $82
8010711a:	6a 52                	push   $0x52
  jmp alltraps
8010711c:	e9 73 f6 ff ff       	jmp    80106794 <alltraps>

80107121 <vector83>:
.globl vector83
vector83:
  pushl $0
80107121:	6a 00                	push   $0x0
  pushl $83
80107123:	6a 53                	push   $0x53
  jmp alltraps
80107125:	e9 6a f6 ff ff       	jmp    80106794 <alltraps>

8010712a <vector84>:
.globl vector84
vector84:
  pushl $0
8010712a:	6a 00                	push   $0x0
  pushl $84
8010712c:	6a 54                	push   $0x54
  jmp alltraps
8010712e:	e9 61 f6 ff ff       	jmp    80106794 <alltraps>

80107133 <vector85>:
.globl vector85
vector85:
  pushl $0
80107133:	6a 00                	push   $0x0
  pushl $85
80107135:	6a 55                	push   $0x55
  jmp alltraps
80107137:	e9 58 f6 ff ff       	jmp    80106794 <alltraps>

8010713c <vector86>:
.globl vector86
vector86:
  pushl $0
8010713c:	6a 00                	push   $0x0
  pushl $86
8010713e:	6a 56                	push   $0x56
  jmp alltraps
80107140:	e9 4f f6 ff ff       	jmp    80106794 <alltraps>

80107145 <vector87>:
.globl vector87
vector87:
  pushl $0
80107145:	6a 00                	push   $0x0
  pushl $87
80107147:	6a 57                	push   $0x57
  jmp alltraps
80107149:	e9 46 f6 ff ff       	jmp    80106794 <alltraps>

8010714e <vector88>:
.globl vector88
vector88:
  pushl $0
8010714e:	6a 00                	push   $0x0
  pushl $88
80107150:	6a 58                	push   $0x58
  jmp alltraps
80107152:	e9 3d f6 ff ff       	jmp    80106794 <alltraps>

80107157 <vector89>:
.globl vector89
vector89:
  pushl $0
80107157:	6a 00                	push   $0x0
  pushl $89
80107159:	6a 59                	push   $0x59
  jmp alltraps
8010715b:	e9 34 f6 ff ff       	jmp    80106794 <alltraps>

80107160 <vector90>:
.globl vector90
vector90:
  pushl $0
80107160:	6a 00                	push   $0x0
  pushl $90
80107162:	6a 5a                	push   $0x5a
  jmp alltraps
80107164:	e9 2b f6 ff ff       	jmp    80106794 <alltraps>

80107169 <vector91>:
.globl vector91
vector91:
  pushl $0
80107169:	6a 00                	push   $0x0
  pushl $91
8010716b:	6a 5b                	push   $0x5b
  jmp alltraps
8010716d:	e9 22 f6 ff ff       	jmp    80106794 <alltraps>

80107172 <vector92>:
.globl vector92
vector92:
  pushl $0
80107172:	6a 00                	push   $0x0
  pushl $92
80107174:	6a 5c                	push   $0x5c
  jmp alltraps
80107176:	e9 19 f6 ff ff       	jmp    80106794 <alltraps>

8010717b <vector93>:
.globl vector93
vector93:
  pushl $0
8010717b:	6a 00                	push   $0x0
  pushl $93
8010717d:	6a 5d                	push   $0x5d
  jmp alltraps
8010717f:	e9 10 f6 ff ff       	jmp    80106794 <alltraps>

80107184 <vector94>:
.globl vector94
vector94:
  pushl $0
80107184:	6a 00                	push   $0x0
  pushl $94
80107186:	6a 5e                	push   $0x5e
  jmp alltraps
80107188:	e9 07 f6 ff ff       	jmp    80106794 <alltraps>

8010718d <vector95>:
.globl vector95
vector95:
  pushl $0
8010718d:	6a 00                	push   $0x0
  pushl $95
8010718f:	6a 5f                	push   $0x5f
  jmp alltraps
80107191:	e9 fe f5 ff ff       	jmp    80106794 <alltraps>

80107196 <vector96>:
.globl vector96
vector96:
  pushl $0
80107196:	6a 00                	push   $0x0
  pushl $96
80107198:	6a 60                	push   $0x60
  jmp alltraps
8010719a:	e9 f5 f5 ff ff       	jmp    80106794 <alltraps>

8010719f <vector97>:
.globl vector97
vector97:
  pushl $0
8010719f:	6a 00                	push   $0x0
  pushl $97
801071a1:	6a 61                	push   $0x61
  jmp alltraps
801071a3:	e9 ec f5 ff ff       	jmp    80106794 <alltraps>

801071a8 <vector98>:
.globl vector98
vector98:
  pushl $0
801071a8:	6a 00                	push   $0x0
  pushl $98
801071aa:	6a 62                	push   $0x62
  jmp alltraps
801071ac:	e9 e3 f5 ff ff       	jmp    80106794 <alltraps>

801071b1 <vector99>:
.globl vector99
vector99:
  pushl $0
801071b1:	6a 00                	push   $0x0
  pushl $99
801071b3:	6a 63                	push   $0x63
  jmp alltraps
801071b5:	e9 da f5 ff ff       	jmp    80106794 <alltraps>

801071ba <vector100>:
.globl vector100
vector100:
  pushl $0
801071ba:	6a 00                	push   $0x0
  pushl $100
801071bc:	6a 64                	push   $0x64
  jmp alltraps
801071be:	e9 d1 f5 ff ff       	jmp    80106794 <alltraps>

801071c3 <vector101>:
.globl vector101
vector101:
  pushl $0
801071c3:	6a 00                	push   $0x0
  pushl $101
801071c5:	6a 65                	push   $0x65
  jmp alltraps
801071c7:	e9 c8 f5 ff ff       	jmp    80106794 <alltraps>

801071cc <vector102>:
.globl vector102
vector102:
  pushl $0
801071cc:	6a 00                	push   $0x0
  pushl $102
801071ce:	6a 66                	push   $0x66
  jmp alltraps
801071d0:	e9 bf f5 ff ff       	jmp    80106794 <alltraps>

801071d5 <vector103>:
.globl vector103
vector103:
  pushl $0
801071d5:	6a 00                	push   $0x0
  pushl $103
801071d7:	6a 67                	push   $0x67
  jmp alltraps
801071d9:	e9 b6 f5 ff ff       	jmp    80106794 <alltraps>

801071de <vector104>:
.globl vector104
vector104:
  pushl $0
801071de:	6a 00                	push   $0x0
  pushl $104
801071e0:	6a 68                	push   $0x68
  jmp alltraps
801071e2:	e9 ad f5 ff ff       	jmp    80106794 <alltraps>

801071e7 <vector105>:
.globl vector105
vector105:
  pushl $0
801071e7:	6a 00                	push   $0x0
  pushl $105
801071e9:	6a 69                	push   $0x69
  jmp alltraps
801071eb:	e9 a4 f5 ff ff       	jmp    80106794 <alltraps>

801071f0 <vector106>:
.globl vector106
vector106:
  pushl $0
801071f0:	6a 00                	push   $0x0
  pushl $106
801071f2:	6a 6a                	push   $0x6a
  jmp alltraps
801071f4:	e9 9b f5 ff ff       	jmp    80106794 <alltraps>

801071f9 <vector107>:
.globl vector107
vector107:
  pushl $0
801071f9:	6a 00                	push   $0x0
  pushl $107
801071fb:	6a 6b                	push   $0x6b
  jmp alltraps
801071fd:	e9 92 f5 ff ff       	jmp    80106794 <alltraps>

80107202 <vector108>:
.globl vector108
vector108:
  pushl $0
80107202:	6a 00                	push   $0x0
  pushl $108
80107204:	6a 6c                	push   $0x6c
  jmp alltraps
80107206:	e9 89 f5 ff ff       	jmp    80106794 <alltraps>

8010720b <vector109>:
.globl vector109
vector109:
  pushl $0
8010720b:	6a 00                	push   $0x0
  pushl $109
8010720d:	6a 6d                	push   $0x6d
  jmp alltraps
8010720f:	e9 80 f5 ff ff       	jmp    80106794 <alltraps>

80107214 <vector110>:
.globl vector110
vector110:
  pushl $0
80107214:	6a 00                	push   $0x0
  pushl $110
80107216:	6a 6e                	push   $0x6e
  jmp alltraps
80107218:	e9 77 f5 ff ff       	jmp    80106794 <alltraps>

8010721d <vector111>:
.globl vector111
vector111:
  pushl $0
8010721d:	6a 00                	push   $0x0
  pushl $111
8010721f:	6a 6f                	push   $0x6f
  jmp alltraps
80107221:	e9 6e f5 ff ff       	jmp    80106794 <alltraps>

80107226 <vector112>:
.globl vector112
vector112:
  pushl $0
80107226:	6a 00                	push   $0x0
  pushl $112
80107228:	6a 70                	push   $0x70
  jmp alltraps
8010722a:	e9 65 f5 ff ff       	jmp    80106794 <alltraps>

8010722f <vector113>:
.globl vector113
vector113:
  pushl $0
8010722f:	6a 00                	push   $0x0
  pushl $113
80107231:	6a 71                	push   $0x71
  jmp alltraps
80107233:	e9 5c f5 ff ff       	jmp    80106794 <alltraps>

80107238 <vector114>:
.globl vector114
vector114:
  pushl $0
80107238:	6a 00                	push   $0x0
  pushl $114
8010723a:	6a 72                	push   $0x72
  jmp alltraps
8010723c:	e9 53 f5 ff ff       	jmp    80106794 <alltraps>

80107241 <vector115>:
.globl vector115
vector115:
  pushl $0
80107241:	6a 00                	push   $0x0
  pushl $115
80107243:	6a 73                	push   $0x73
  jmp alltraps
80107245:	e9 4a f5 ff ff       	jmp    80106794 <alltraps>

8010724a <vector116>:
.globl vector116
vector116:
  pushl $0
8010724a:	6a 00                	push   $0x0
  pushl $116
8010724c:	6a 74                	push   $0x74
  jmp alltraps
8010724e:	e9 41 f5 ff ff       	jmp    80106794 <alltraps>

80107253 <vector117>:
.globl vector117
vector117:
  pushl $0
80107253:	6a 00                	push   $0x0
  pushl $117
80107255:	6a 75                	push   $0x75
  jmp alltraps
80107257:	e9 38 f5 ff ff       	jmp    80106794 <alltraps>

8010725c <vector118>:
.globl vector118
vector118:
  pushl $0
8010725c:	6a 00                	push   $0x0
  pushl $118
8010725e:	6a 76                	push   $0x76
  jmp alltraps
80107260:	e9 2f f5 ff ff       	jmp    80106794 <alltraps>

80107265 <vector119>:
.globl vector119
vector119:
  pushl $0
80107265:	6a 00                	push   $0x0
  pushl $119
80107267:	6a 77                	push   $0x77
  jmp alltraps
80107269:	e9 26 f5 ff ff       	jmp    80106794 <alltraps>

8010726e <vector120>:
.globl vector120
vector120:
  pushl $0
8010726e:	6a 00                	push   $0x0
  pushl $120
80107270:	6a 78                	push   $0x78
  jmp alltraps
80107272:	e9 1d f5 ff ff       	jmp    80106794 <alltraps>

80107277 <vector121>:
.globl vector121
vector121:
  pushl $0
80107277:	6a 00                	push   $0x0
  pushl $121
80107279:	6a 79                	push   $0x79
  jmp alltraps
8010727b:	e9 14 f5 ff ff       	jmp    80106794 <alltraps>

80107280 <vector122>:
.globl vector122
vector122:
  pushl $0
80107280:	6a 00                	push   $0x0
  pushl $122
80107282:	6a 7a                	push   $0x7a
  jmp alltraps
80107284:	e9 0b f5 ff ff       	jmp    80106794 <alltraps>

80107289 <vector123>:
.globl vector123
vector123:
  pushl $0
80107289:	6a 00                	push   $0x0
  pushl $123
8010728b:	6a 7b                	push   $0x7b
  jmp alltraps
8010728d:	e9 02 f5 ff ff       	jmp    80106794 <alltraps>

80107292 <vector124>:
.globl vector124
vector124:
  pushl $0
80107292:	6a 00                	push   $0x0
  pushl $124
80107294:	6a 7c                	push   $0x7c
  jmp alltraps
80107296:	e9 f9 f4 ff ff       	jmp    80106794 <alltraps>

8010729b <vector125>:
.globl vector125
vector125:
  pushl $0
8010729b:	6a 00                	push   $0x0
  pushl $125
8010729d:	6a 7d                	push   $0x7d
  jmp alltraps
8010729f:	e9 f0 f4 ff ff       	jmp    80106794 <alltraps>

801072a4 <vector126>:
.globl vector126
vector126:
  pushl $0
801072a4:	6a 00                	push   $0x0
  pushl $126
801072a6:	6a 7e                	push   $0x7e
  jmp alltraps
801072a8:	e9 e7 f4 ff ff       	jmp    80106794 <alltraps>

801072ad <vector127>:
.globl vector127
vector127:
  pushl $0
801072ad:	6a 00                	push   $0x0
  pushl $127
801072af:	6a 7f                	push   $0x7f
  jmp alltraps
801072b1:	e9 de f4 ff ff       	jmp    80106794 <alltraps>

801072b6 <vector128>:
.globl vector128
vector128:
  pushl $0
801072b6:	6a 00                	push   $0x0
  pushl $128
801072b8:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801072bd:	e9 d2 f4 ff ff       	jmp    80106794 <alltraps>

801072c2 <vector129>:
.globl vector129
vector129:
  pushl $0
801072c2:	6a 00                	push   $0x0
  pushl $129
801072c4:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801072c9:	e9 c6 f4 ff ff       	jmp    80106794 <alltraps>

801072ce <vector130>:
.globl vector130
vector130:
  pushl $0
801072ce:	6a 00                	push   $0x0
  pushl $130
801072d0:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801072d5:	e9 ba f4 ff ff       	jmp    80106794 <alltraps>

801072da <vector131>:
.globl vector131
vector131:
  pushl $0
801072da:	6a 00                	push   $0x0
  pushl $131
801072dc:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801072e1:	e9 ae f4 ff ff       	jmp    80106794 <alltraps>

801072e6 <vector132>:
.globl vector132
vector132:
  pushl $0
801072e6:	6a 00                	push   $0x0
  pushl $132
801072e8:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801072ed:	e9 a2 f4 ff ff       	jmp    80106794 <alltraps>

801072f2 <vector133>:
.globl vector133
vector133:
  pushl $0
801072f2:	6a 00                	push   $0x0
  pushl $133
801072f4:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801072f9:	e9 96 f4 ff ff       	jmp    80106794 <alltraps>

801072fe <vector134>:
.globl vector134
vector134:
  pushl $0
801072fe:	6a 00                	push   $0x0
  pushl $134
80107300:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107305:	e9 8a f4 ff ff       	jmp    80106794 <alltraps>

8010730a <vector135>:
.globl vector135
vector135:
  pushl $0
8010730a:	6a 00                	push   $0x0
  pushl $135
8010730c:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107311:	e9 7e f4 ff ff       	jmp    80106794 <alltraps>

80107316 <vector136>:
.globl vector136
vector136:
  pushl $0
80107316:	6a 00                	push   $0x0
  pushl $136
80107318:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010731d:	e9 72 f4 ff ff       	jmp    80106794 <alltraps>

80107322 <vector137>:
.globl vector137
vector137:
  pushl $0
80107322:	6a 00                	push   $0x0
  pushl $137
80107324:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107329:	e9 66 f4 ff ff       	jmp    80106794 <alltraps>

8010732e <vector138>:
.globl vector138
vector138:
  pushl $0
8010732e:	6a 00                	push   $0x0
  pushl $138
80107330:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107335:	e9 5a f4 ff ff       	jmp    80106794 <alltraps>

8010733a <vector139>:
.globl vector139
vector139:
  pushl $0
8010733a:	6a 00                	push   $0x0
  pushl $139
8010733c:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107341:	e9 4e f4 ff ff       	jmp    80106794 <alltraps>

80107346 <vector140>:
.globl vector140
vector140:
  pushl $0
80107346:	6a 00                	push   $0x0
  pushl $140
80107348:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010734d:	e9 42 f4 ff ff       	jmp    80106794 <alltraps>

80107352 <vector141>:
.globl vector141
vector141:
  pushl $0
80107352:	6a 00                	push   $0x0
  pushl $141
80107354:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107359:	e9 36 f4 ff ff       	jmp    80106794 <alltraps>

8010735e <vector142>:
.globl vector142
vector142:
  pushl $0
8010735e:	6a 00                	push   $0x0
  pushl $142
80107360:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107365:	e9 2a f4 ff ff       	jmp    80106794 <alltraps>

8010736a <vector143>:
.globl vector143
vector143:
  pushl $0
8010736a:	6a 00                	push   $0x0
  pushl $143
8010736c:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107371:	e9 1e f4 ff ff       	jmp    80106794 <alltraps>

80107376 <vector144>:
.globl vector144
vector144:
  pushl $0
80107376:	6a 00                	push   $0x0
  pushl $144
80107378:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010737d:	e9 12 f4 ff ff       	jmp    80106794 <alltraps>

80107382 <vector145>:
.globl vector145
vector145:
  pushl $0
80107382:	6a 00                	push   $0x0
  pushl $145
80107384:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107389:	e9 06 f4 ff ff       	jmp    80106794 <alltraps>

8010738e <vector146>:
.globl vector146
vector146:
  pushl $0
8010738e:	6a 00                	push   $0x0
  pushl $146
80107390:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107395:	e9 fa f3 ff ff       	jmp    80106794 <alltraps>

8010739a <vector147>:
.globl vector147
vector147:
  pushl $0
8010739a:	6a 00                	push   $0x0
  pushl $147
8010739c:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801073a1:	e9 ee f3 ff ff       	jmp    80106794 <alltraps>

801073a6 <vector148>:
.globl vector148
vector148:
  pushl $0
801073a6:	6a 00                	push   $0x0
  pushl $148
801073a8:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801073ad:	e9 e2 f3 ff ff       	jmp    80106794 <alltraps>

801073b2 <vector149>:
.globl vector149
vector149:
  pushl $0
801073b2:	6a 00                	push   $0x0
  pushl $149
801073b4:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801073b9:	e9 d6 f3 ff ff       	jmp    80106794 <alltraps>

801073be <vector150>:
.globl vector150
vector150:
  pushl $0
801073be:	6a 00                	push   $0x0
  pushl $150
801073c0:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801073c5:	e9 ca f3 ff ff       	jmp    80106794 <alltraps>

801073ca <vector151>:
.globl vector151
vector151:
  pushl $0
801073ca:	6a 00                	push   $0x0
  pushl $151
801073cc:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801073d1:	e9 be f3 ff ff       	jmp    80106794 <alltraps>

801073d6 <vector152>:
.globl vector152
vector152:
  pushl $0
801073d6:	6a 00                	push   $0x0
  pushl $152
801073d8:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801073dd:	e9 b2 f3 ff ff       	jmp    80106794 <alltraps>

801073e2 <vector153>:
.globl vector153
vector153:
  pushl $0
801073e2:	6a 00                	push   $0x0
  pushl $153
801073e4:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801073e9:	e9 a6 f3 ff ff       	jmp    80106794 <alltraps>

801073ee <vector154>:
.globl vector154
vector154:
  pushl $0
801073ee:	6a 00                	push   $0x0
  pushl $154
801073f0:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801073f5:	e9 9a f3 ff ff       	jmp    80106794 <alltraps>

801073fa <vector155>:
.globl vector155
vector155:
  pushl $0
801073fa:	6a 00                	push   $0x0
  pushl $155
801073fc:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107401:	e9 8e f3 ff ff       	jmp    80106794 <alltraps>

80107406 <vector156>:
.globl vector156
vector156:
  pushl $0
80107406:	6a 00                	push   $0x0
  pushl $156
80107408:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010740d:	e9 82 f3 ff ff       	jmp    80106794 <alltraps>

80107412 <vector157>:
.globl vector157
vector157:
  pushl $0
80107412:	6a 00                	push   $0x0
  pushl $157
80107414:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107419:	e9 76 f3 ff ff       	jmp    80106794 <alltraps>

8010741e <vector158>:
.globl vector158
vector158:
  pushl $0
8010741e:	6a 00                	push   $0x0
  pushl $158
80107420:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107425:	e9 6a f3 ff ff       	jmp    80106794 <alltraps>

8010742a <vector159>:
.globl vector159
vector159:
  pushl $0
8010742a:	6a 00                	push   $0x0
  pushl $159
8010742c:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107431:	e9 5e f3 ff ff       	jmp    80106794 <alltraps>

80107436 <vector160>:
.globl vector160
vector160:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $160
80107438:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010743d:	e9 52 f3 ff ff       	jmp    80106794 <alltraps>

80107442 <vector161>:
.globl vector161
vector161:
  pushl $0
80107442:	6a 00                	push   $0x0
  pushl $161
80107444:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107449:	e9 46 f3 ff ff       	jmp    80106794 <alltraps>

8010744e <vector162>:
.globl vector162
vector162:
  pushl $0
8010744e:	6a 00                	push   $0x0
  pushl $162
80107450:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107455:	e9 3a f3 ff ff       	jmp    80106794 <alltraps>

8010745a <vector163>:
.globl vector163
vector163:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $163
8010745c:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107461:	e9 2e f3 ff ff       	jmp    80106794 <alltraps>

80107466 <vector164>:
.globl vector164
vector164:
  pushl $0
80107466:	6a 00                	push   $0x0
  pushl $164
80107468:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010746d:	e9 22 f3 ff ff       	jmp    80106794 <alltraps>

80107472 <vector165>:
.globl vector165
vector165:
  pushl $0
80107472:	6a 00                	push   $0x0
  pushl $165
80107474:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107479:	e9 16 f3 ff ff       	jmp    80106794 <alltraps>

8010747e <vector166>:
.globl vector166
vector166:
  pushl $0
8010747e:	6a 00                	push   $0x0
  pushl $166
80107480:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107485:	e9 0a f3 ff ff       	jmp    80106794 <alltraps>

8010748a <vector167>:
.globl vector167
vector167:
  pushl $0
8010748a:	6a 00                	push   $0x0
  pushl $167
8010748c:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107491:	e9 fe f2 ff ff       	jmp    80106794 <alltraps>

80107496 <vector168>:
.globl vector168
vector168:
  pushl $0
80107496:	6a 00                	push   $0x0
  pushl $168
80107498:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010749d:	e9 f2 f2 ff ff       	jmp    80106794 <alltraps>

801074a2 <vector169>:
.globl vector169
vector169:
  pushl $0
801074a2:	6a 00                	push   $0x0
  pushl $169
801074a4:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801074a9:	e9 e6 f2 ff ff       	jmp    80106794 <alltraps>

801074ae <vector170>:
.globl vector170
vector170:
  pushl $0
801074ae:	6a 00                	push   $0x0
  pushl $170
801074b0:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801074b5:	e9 da f2 ff ff       	jmp    80106794 <alltraps>

801074ba <vector171>:
.globl vector171
vector171:
  pushl $0
801074ba:	6a 00                	push   $0x0
  pushl $171
801074bc:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801074c1:	e9 ce f2 ff ff       	jmp    80106794 <alltraps>

801074c6 <vector172>:
.globl vector172
vector172:
  pushl $0
801074c6:	6a 00                	push   $0x0
  pushl $172
801074c8:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801074cd:	e9 c2 f2 ff ff       	jmp    80106794 <alltraps>

801074d2 <vector173>:
.globl vector173
vector173:
  pushl $0
801074d2:	6a 00                	push   $0x0
  pushl $173
801074d4:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801074d9:	e9 b6 f2 ff ff       	jmp    80106794 <alltraps>

801074de <vector174>:
.globl vector174
vector174:
  pushl $0
801074de:	6a 00                	push   $0x0
  pushl $174
801074e0:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801074e5:	e9 aa f2 ff ff       	jmp    80106794 <alltraps>

801074ea <vector175>:
.globl vector175
vector175:
  pushl $0
801074ea:	6a 00                	push   $0x0
  pushl $175
801074ec:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801074f1:	e9 9e f2 ff ff       	jmp    80106794 <alltraps>

801074f6 <vector176>:
.globl vector176
vector176:
  pushl $0
801074f6:	6a 00                	push   $0x0
  pushl $176
801074f8:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801074fd:	e9 92 f2 ff ff       	jmp    80106794 <alltraps>

80107502 <vector177>:
.globl vector177
vector177:
  pushl $0
80107502:	6a 00                	push   $0x0
  pushl $177
80107504:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107509:	e9 86 f2 ff ff       	jmp    80106794 <alltraps>

8010750e <vector178>:
.globl vector178
vector178:
  pushl $0
8010750e:	6a 00                	push   $0x0
  pushl $178
80107510:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107515:	e9 7a f2 ff ff       	jmp    80106794 <alltraps>

8010751a <vector179>:
.globl vector179
vector179:
  pushl $0
8010751a:	6a 00                	push   $0x0
  pushl $179
8010751c:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107521:	e9 6e f2 ff ff       	jmp    80106794 <alltraps>

80107526 <vector180>:
.globl vector180
vector180:
  pushl $0
80107526:	6a 00                	push   $0x0
  pushl $180
80107528:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010752d:	e9 62 f2 ff ff       	jmp    80106794 <alltraps>

80107532 <vector181>:
.globl vector181
vector181:
  pushl $0
80107532:	6a 00                	push   $0x0
  pushl $181
80107534:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107539:	e9 56 f2 ff ff       	jmp    80106794 <alltraps>

8010753e <vector182>:
.globl vector182
vector182:
  pushl $0
8010753e:	6a 00                	push   $0x0
  pushl $182
80107540:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107545:	e9 4a f2 ff ff       	jmp    80106794 <alltraps>

8010754a <vector183>:
.globl vector183
vector183:
  pushl $0
8010754a:	6a 00                	push   $0x0
  pushl $183
8010754c:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107551:	e9 3e f2 ff ff       	jmp    80106794 <alltraps>

80107556 <vector184>:
.globl vector184
vector184:
  pushl $0
80107556:	6a 00                	push   $0x0
  pushl $184
80107558:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010755d:	e9 32 f2 ff ff       	jmp    80106794 <alltraps>

80107562 <vector185>:
.globl vector185
vector185:
  pushl $0
80107562:	6a 00                	push   $0x0
  pushl $185
80107564:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107569:	e9 26 f2 ff ff       	jmp    80106794 <alltraps>

8010756e <vector186>:
.globl vector186
vector186:
  pushl $0
8010756e:	6a 00                	push   $0x0
  pushl $186
80107570:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107575:	e9 1a f2 ff ff       	jmp    80106794 <alltraps>

8010757a <vector187>:
.globl vector187
vector187:
  pushl $0
8010757a:	6a 00                	push   $0x0
  pushl $187
8010757c:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107581:	e9 0e f2 ff ff       	jmp    80106794 <alltraps>

80107586 <vector188>:
.globl vector188
vector188:
  pushl $0
80107586:	6a 00                	push   $0x0
  pushl $188
80107588:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010758d:	e9 02 f2 ff ff       	jmp    80106794 <alltraps>

80107592 <vector189>:
.globl vector189
vector189:
  pushl $0
80107592:	6a 00                	push   $0x0
  pushl $189
80107594:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107599:	e9 f6 f1 ff ff       	jmp    80106794 <alltraps>

8010759e <vector190>:
.globl vector190
vector190:
  pushl $0
8010759e:	6a 00                	push   $0x0
  pushl $190
801075a0:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801075a5:	e9 ea f1 ff ff       	jmp    80106794 <alltraps>

801075aa <vector191>:
.globl vector191
vector191:
  pushl $0
801075aa:	6a 00                	push   $0x0
  pushl $191
801075ac:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801075b1:	e9 de f1 ff ff       	jmp    80106794 <alltraps>

801075b6 <vector192>:
.globl vector192
vector192:
  pushl $0
801075b6:	6a 00                	push   $0x0
  pushl $192
801075b8:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801075bd:	e9 d2 f1 ff ff       	jmp    80106794 <alltraps>

801075c2 <vector193>:
.globl vector193
vector193:
  pushl $0
801075c2:	6a 00                	push   $0x0
  pushl $193
801075c4:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801075c9:	e9 c6 f1 ff ff       	jmp    80106794 <alltraps>

801075ce <vector194>:
.globl vector194
vector194:
  pushl $0
801075ce:	6a 00                	push   $0x0
  pushl $194
801075d0:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801075d5:	e9 ba f1 ff ff       	jmp    80106794 <alltraps>

801075da <vector195>:
.globl vector195
vector195:
  pushl $0
801075da:	6a 00                	push   $0x0
  pushl $195
801075dc:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801075e1:	e9 ae f1 ff ff       	jmp    80106794 <alltraps>

801075e6 <vector196>:
.globl vector196
vector196:
  pushl $0
801075e6:	6a 00                	push   $0x0
  pushl $196
801075e8:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801075ed:	e9 a2 f1 ff ff       	jmp    80106794 <alltraps>

801075f2 <vector197>:
.globl vector197
vector197:
  pushl $0
801075f2:	6a 00                	push   $0x0
  pushl $197
801075f4:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801075f9:	e9 96 f1 ff ff       	jmp    80106794 <alltraps>

801075fe <vector198>:
.globl vector198
vector198:
  pushl $0
801075fe:	6a 00                	push   $0x0
  pushl $198
80107600:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107605:	e9 8a f1 ff ff       	jmp    80106794 <alltraps>

8010760a <vector199>:
.globl vector199
vector199:
  pushl $0
8010760a:	6a 00                	push   $0x0
  pushl $199
8010760c:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107611:	e9 7e f1 ff ff       	jmp    80106794 <alltraps>

80107616 <vector200>:
.globl vector200
vector200:
  pushl $0
80107616:	6a 00                	push   $0x0
  pushl $200
80107618:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010761d:	e9 72 f1 ff ff       	jmp    80106794 <alltraps>

80107622 <vector201>:
.globl vector201
vector201:
  pushl $0
80107622:	6a 00                	push   $0x0
  pushl $201
80107624:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107629:	e9 66 f1 ff ff       	jmp    80106794 <alltraps>

8010762e <vector202>:
.globl vector202
vector202:
  pushl $0
8010762e:	6a 00                	push   $0x0
  pushl $202
80107630:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107635:	e9 5a f1 ff ff       	jmp    80106794 <alltraps>

8010763a <vector203>:
.globl vector203
vector203:
  pushl $0
8010763a:	6a 00                	push   $0x0
  pushl $203
8010763c:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107641:	e9 4e f1 ff ff       	jmp    80106794 <alltraps>

80107646 <vector204>:
.globl vector204
vector204:
  pushl $0
80107646:	6a 00                	push   $0x0
  pushl $204
80107648:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010764d:	e9 42 f1 ff ff       	jmp    80106794 <alltraps>

80107652 <vector205>:
.globl vector205
vector205:
  pushl $0
80107652:	6a 00                	push   $0x0
  pushl $205
80107654:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107659:	e9 36 f1 ff ff       	jmp    80106794 <alltraps>

8010765e <vector206>:
.globl vector206
vector206:
  pushl $0
8010765e:	6a 00                	push   $0x0
  pushl $206
80107660:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107665:	e9 2a f1 ff ff       	jmp    80106794 <alltraps>

8010766a <vector207>:
.globl vector207
vector207:
  pushl $0
8010766a:	6a 00                	push   $0x0
  pushl $207
8010766c:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107671:	e9 1e f1 ff ff       	jmp    80106794 <alltraps>

80107676 <vector208>:
.globl vector208
vector208:
  pushl $0
80107676:	6a 00                	push   $0x0
  pushl $208
80107678:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010767d:	e9 12 f1 ff ff       	jmp    80106794 <alltraps>

80107682 <vector209>:
.globl vector209
vector209:
  pushl $0
80107682:	6a 00                	push   $0x0
  pushl $209
80107684:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107689:	e9 06 f1 ff ff       	jmp    80106794 <alltraps>

8010768e <vector210>:
.globl vector210
vector210:
  pushl $0
8010768e:	6a 00                	push   $0x0
  pushl $210
80107690:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107695:	e9 fa f0 ff ff       	jmp    80106794 <alltraps>

8010769a <vector211>:
.globl vector211
vector211:
  pushl $0
8010769a:	6a 00                	push   $0x0
  pushl $211
8010769c:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801076a1:	e9 ee f0 ff ff       	jmp    80106794 <alltraps>

801076a6 <vector212>:
.globl vector212
vector212:
  pushl $0
801076a6:	6a 00                	push   $0x0
  pushl $212
801076a8:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801076ad:	e9 e2 f0 ff ff       	jmp    80106794 <alltraps>

801076b2 <vector213>:
.globl vector213
vector213:
  pushl $0
801076b2:	6a 00                	push   $0x0
  pushl $213
801076b4:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801076b9:	e9 d6 f0 ff ff       	jmp    80106794 <alltraps>

801076be <vector214>:
.globl vector214
vector214:
  pushl $0
801076be:	6a 00                	push   $0x0
  pushl $214
801076c0:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801076c5:	e9 ca f0 ff ff       	jmp    80106794 <alltraps>

801076ca <vector215>:
.globl vector215
vector215:
  pushl $0
801076ca:	6a 00                	push   $0x0
  pushl $215
801076cc:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801076d1:	e9 be f0 ff ff       	jmp    80106794 <alltraps>

801076d6 <vector216>:
.globl vector216
vector216:
  pushl $0
801076d6:	6a 00                	push   $0x0
  pushl $216
801076d8:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801076dd:	e9 b2 f0 ff ff       	jmp    80106794 <alltraps>

801076e2 <vector217>:
.globl vector217
vector217:
  pushl $0
801076e2:	6a 00                	push   $0x0
  pushl $217
801076e4:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801076e9:	e9 a6 f0 ff ff       	jmp    80106794 <alltraps>

801076ee <vector218>:
.globl vector218
vector218:
  pushl $0
801076ee:	6a 00                	push   $0x0
  pushl $218
801076f0:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801076f5:	e9 9a f0 ff ff       	jmp    80106794 <alltraps>

801076fa <vector219>:
.globl vector219
vector219:
  pushl $0
801076fa:	6a 00                	push   $0x0
  pushl $219
801076fc:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107701:	e9 8e f0 ff ff       	jmp    80106794 <alltraps>

80107706 <vector220>:
.globl vector220
vector220:
  pushl $0
80107706:	6a 00                	push   $0x0
  pushl $220
80107708:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010770d:	e9 82 f0 ff ff       	jmp    80106794 <alltraps>

80107712 <vector221>:
.globl vector221
vector221:
  pushl $0
80107712:	6a 00                	push   $0x0
  pushl $221
80107714:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107719:	e9 76 f0 ff ff       	jmp    80106794 <alltraps>

8010771e <vector222>:
.globl vector222
vector222:
  pushl $0
8010771e:	6a 00                	push   $0x0
  pushl $222
80107720:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107725:	e9 6a f0 ff ff       	jmp    80106794 <alltraps>

8010772a <vector223>:
.globl vector223
vector223:
  pushl $0
8010772a:	6a 00                	push   $0x0
  pushl $223
8010772c:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107731:	e9 5e f0 ff ff       	jmp    80106794 <alltraps>

80107736 <vector224>:
.globl vector224
vector224:
  pushl $0
80107736:	6a 00                	push   $0x0
  pushl $224
80107738:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010773d:	e9 52 f0 ff ff       	jmp    80106794 <alltraps>

80107742 <vector225>:
.globl vector225
vector225:
  pushl $0
80107742:	6a 00                	push   $0x0
  pushl $225
80107744:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107749:	e9 46 f0 ff ff       	jmp    80106794 <alltraps>

8010774e <vector226>:
.globl vector226
vector226:
  pushl $0
8010774e:	6a 00                	push   $0x0
  pushl $226
80107750:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107755:	e9 3a f0 ff ff       	jmp    80106794 <alltraps>

8010775a <vector227>:
.globl vector227
vector227:
  pushl $0
8010775a:	6a 00                	push   $0x0
  pushl $227
8010775c:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107761:	e9 2e f0 ff ff       	jmp    80106794 <alltraps>

80107766 <vector228>:
.globl vector228
vector228:
  pushl $0
80107766:	6a 00                	push   $0x0
  pushl $228
80107768:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010776d:	e9 22 f0 ff ff       	jmp    80106794 <alltraps>

80107772 <vector229>:
.globl vector229
vector229:
  pushl $0
80107772:	6a 00                	push   $0x0
  pushl $229
80107774:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107779:	e9 16 f0 ff ff       	jmp    80106794 <alltraps>

8010777e <vector230>:
.globl vector230
vector230:
  pushl $0
8010777e:	6a 00                	push   $0x0
  pushl $230
80107780:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107785:	e9 0a f0 ff ff       	jmp    80106794 <alltraps>

8010778a <vector231>:
.globl vector231
vector231:
  pushl $0
8010778a:	6a 00                	push   $0x0
  pushl $231
8010778c:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107791:	e9 fe ef ff ff       	jmp    80106794 <alltraps>

80107796 <vector232>:
.globl vector232
vector232:
  pushl $0
80107796:	6a 00                	push   $0x0
  pushl $232
80107798:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010779d:	e9 f2 ef ff ff       	jmp    80106794 <alltraps>

801077a2 <vector233>:
.globl vector233
vector233:
  pushl $0
801077a2:	6a 00                	push   $0x0
  pushl $233
801077a4:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801077a9:	e9 e6 ef ff ff       	jmp    80106794 <alltraps>

801077ae <vector234>:
.globl vector234
vector234:
  pushl $0
801077ae:	6a 00                	push   $0x0
  pushl $234
801077b0:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801077b5:	e9 da ef ff ff       	jmp    80106794 <alltraps>

801077ba <vector235>:
.globl vector235
vector235:
  pushl $0
801077ba:	6a 00                	push   $0x0
  pushl $235
801077bc:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801077c1:	e9 ce ef ff ff       	jmp    80106794 <alltraps>

801077c6 <vector236>:
.globl vector236
vector236:
  pushl $0
801077c6:	6a 00                	push   $0x0
  pushl $236
801077c8:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801077cd:	e9 c2 ef ff ff       	jmp    80106794 <alltraps>

801077d2 <vector237>:
.globl vector237
vector237:
  pushl $0
801077d2:	6a 00                	push   $0x0
  pushl $237
801077d4:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801077d9:	e9 b6 ef ff ff       	jmp    80106794 <alltraps>

801077de <vector238>:
.globl vector238
vector238:
  pushl $0
801077de:	6a 00                	push   $0x0
  pushl $238
801077e0:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801077e5:	e9 aa ef ff ff       	jmp    80106794 <alltraps>

801077ea <vector239>:
.globl vector239
vector239:
  pushl $0
801077ea:	6a 00                	push   $0x0
  pushl $239
801077ec:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801077f1:	e9 9e ef ff ff       	jmp    80106794 <alltraps>

801077f6 <vector240>:
.globl vector240
vector240:
  pushl $0
801077f6:	6a 00                	push   $0x0
  pushl $240
801077f8:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801077fd:	e9 92 ef ff ff       	jmp    80106794 <alltraps>

80107802 <vector241>:
.globl vector241
vector241:
  pushl $0
80107802:	6a 00                	push   $0x0
  pushl $241
80107804:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107809:	e9 86 ef ff ff       	jmp    80106794 <alltraps>

8010780e <vector242>:
.globl vector242
vector242:
  pushl $0
8010780e:	6a 00                	push   $0x0
  pushl $242
80107810:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107815:	e9 7a ef ff ff       	jmp    80106794 <alltraps>

8010781a <vector243>:
.globl vector243
vector243:
  pushl $0
8010781a:	6a 00                	push   $0x0
  pushl $243
8010781c:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107821:	e9 6e ef ff ff       	jmp    80106794 <alltraps>

80107826 <vector244>:
.globl vector244
vector244:
  pushl $0
80107826:	6a 00                	push   $0x0
  pushl $244
80107828:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010782d:	e9 62 ef ff ff       	jmp    80106794 <alltraps>

80107832 <vector245>:
.globl vector245
vector245:
  pushl $0
80107832:	6a 00                	push   $0x0
  pushl $245
80107834:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107839:	e9 56 ef ff ff       	jmp    80106794 <alltraps>

8010783e <vector246>:
.globl vector246
vector246:
  pushl $0
8010783e:	6a 00                	push   $0x0
  pushl $246
80107840:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107845:	e9 4a ef ff ff       	jmp    80106794 <alltraps>

8010784a <vector247>:
.globl vector247
vector247:
  pushl $0
8010784a:	6a 00                	push   $0x0
  pushl $247
8010784c:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107851:	e9 3e ef ff ff       	jmp    80106794 <alltraps>

80107856 <vector248>:
.globl vector248
vector248:
  pushl $0
80107856:	6a 00                	push   $0x0
  pushl $248
80107858:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010785d:	e9 32 ef ff ff       	jmp    80106794 <alltraps>

80107862 <vector249>:
.globl vector249
vector249:
  pushl $0
80107862:	6a 00                	push   $0x0
  pushl $249
80107864:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107869:	e9 26 ef ff ff       	jmp    80106794 <alltraps>

8010786e <vector250>:
.globl vector250
vector250:
  pushl $0
8010786e:	6a 00                	push   $0x0
  pushl $250
80107870:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107875:	e9 1a ef ff ff       	jmp    80106794 <alltraps>

8010787a <vector251>:
.globl vector251
vector251:
  pushl $0
8010787a:	6a 00                	push   $0x0
  pushl $251
8010787c:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107881:	e9 0e ef ff ff       	jmp    80106794 <alltraps>

80107886 <vector252>:
.globl vector252
vector252:
  pushl $0
80107886:	6a 00                	push   $0x0
  pushl $252
80107888:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010788d:	e9 02 ef ff ff       	jmp    80106794 <alltraps>

80107892 <vector253>:
.globl vector253
vector253:
  pushl $0
80107892:	6a 00                	push   $0x0
  pushl $253
80107894:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107899:	e9 f6 ee ff ff       	jmp    80106794 <alltraps>

8010789e <vector254>:
.globl vector254
vector254:
  pushl $0
8010789e:	6a 00                	push   $0x0
  pushl $254
801078a0:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801078a5:	e9 ea ee ff ff       	jmp    80106794 <alltraps>

801078aa <vector255>:
.globl vector255
vector255:
  pushl $0
801078aa:	6a 00                	push   $0x0
  pushl $255
801078ac:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801078b1:	e9 de ee ff ff       	jmp    80106794 <alltraps>
	...

801078b8 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801078b8:	55                   	push   %ebp
801078b9:	89 e5                	mov    %esp,%ebp
801078bb:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801078be:	8b 45 0c             	mov    0xc(%ebp),%eax
801078c1:	83 e8 01             	sub    $0x1,%eax
801078c4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801078c8:	8b 45 08             	mov    0x8(%ebp),%eax
801078cb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801078cf:	8b 45 08             	mov    0x8(%ebp),%eax
801078d2:	c1 e8 10             	shr    $0x10,%eax
801078d5:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801078d9:	8d 45 fa             	lea    -0x6(%ebp),%eax
801078dc:	0f 01 10             	lgdtl  (%eax)
}
801078df:	c9                   	leave  
801078e0:	c3                   	ret    

801078e1 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801078e1:	55                   	push   %ebp
801078e2:	89 e5                	mov    %esp,%ebp
801078e4:	83 ec 04             	sub    $0x4,%esp
801078e7:	8b 45 08             	mov    0x8(%ebp),%eax
801078ea:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801078ee:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801078f2:	0f 00 d8             	ltr    %ax
}
801078f5:	c9                   	leave  
801078f6:	c3                   	ret    

801078f7 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801078f7:	55                   	push   %ebp
801078f8:	89 e5                	mov    %esp,%ebp
801078fa:	83 ec 04             	sub    $0x4,%esp
801078fd:	8b 45 08             	mov    0x8(%ebp),%eax
80107900:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107904:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107908:	8e e8                	mov    %eax,%gs
}
8010790a:	c9                   	leave  
8010790b:	c3                   	ret    

8010790c <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
8010790c:	55                   	push   %ebp
8010790d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010790f:	8b 45 08             	mov    0x8(%ebp),%eax
80107912:	0f 22 d8             	mov    %eax,%cr3
}
80107915:	5d                   	pop    %ebp
80107916:	c3                   	ret    

80107917 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107917:	55                   	push   %ebp
80107918:	89 e5                	mov    %esp,%ebp
8010791a:	8b 45 08             	mov    0x8(%ebp),%eax
8010791d:	05 00 00 00 80       	add    $0x80000000,%eax
80107922:	5d                   	pop    %ebp
80107923:	c3                   	ret    

80107924 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107924:	55                   	push   %ebp
80107925:	89 e5                	mov    %esp,%ebp
80107927:	8b 45 08             	mov    0x8(%ebp),%eax
8010792a:	05 00 00 00 80       	add    $0x80000000,%eax
8010792f:	5d                   	pop    %ebp
80107930:	c3                   	ret    

80107931 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107931:	55                   	push   %ebp
80107932:	89 e5                	mov    %esp,%ebp
80107934:	53                   	push   %ebx
80107935:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107938:	e8 a4 b8 ff ff       	call   801031e1 <cpunum>
8010793d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107943:	05 40 f9 10 80       	add    $0x8010f940,%eax
80107948:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010794b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794e:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107954:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107957:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010795d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107960:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107964:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107967:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010796b:	83 e2 f0             	and    $0xfffffff0,%edx
8010796e:	83 ca 0a             	or     $0xa,%edx
80107971:	88 50 7d             	mov    %dl,0x7d(%eax)
80107974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107977:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010797b:	83 ca 10             	or     $0x10,%edx
8010797e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107981:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107984:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107988:	83 e2 9f             	and    $0xffffff9f,%edx
8010798b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010798e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107991:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107995:	83 ca 80             	or     $0xffffff80,%edx
80107998:	88 50 7d             	mov    %dl,0x7d(%eax)
8010799b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079a2:	83 ca 0f             	or     $0xf,%edx
801079a5:	88 50 7e             	mov    %dl,0x7e(%eax)
801079a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ab:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079af:	83 e2 ef             	and    $0xffffffef,%edx
801079b2:	88 50 7e             	mov    %dl,0x7e(%eax)
801079b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079bc:	83 e2 df             	and    $0xffffffdf,%edx
801079bf:	88 50 7e             	mov    %dl,0x7e(%eax)
801079c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079c9:	83 ca 40             	or     $0x40,%edx
801079cc:	88 50 7e             	mov    %dl,0x7e(%eax)
801079cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079d6:	83 ca 80             	or     $0xffffff80,%edx
801079d9:	88 50 7e             	mov    %dl,0x7e(%eax)
801079dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079df:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801079e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e6:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801079ed:	ff ff 
801079ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f2:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801079f9:	00 00 
801079fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079fe:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a08:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a0f:	83 e2 f0             	and    $0xfffffff0,%edx
80107a12:	83 ca 02             	or     $0x2,%edx
80107a15:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a25:	83 ca 10             	or     $0x10,%edx
80107a28:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a31:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a38:	83 e2 9f             	and    $0xffffff9f,%edx
80107a3b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a44:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a4b:	83 ca 80             	or     $0xffffff80,%edx
80107a4e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a57:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a5e:	83 ca 0f             	or     $0xf,%edx
80107a61:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a71:	83 e2 ef             	and    $0xffffffef,%edx
80107a74:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a84:	83 e2 df             	and    $0xffffffdf,%edx
80107a87:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a90:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a97:	83 ca 40             	or     $0x40,%edx
80107a9a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107aaa:	83 ca 80             	or     $0xffffff80,%edx
80107aad:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab6:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac0:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107ac7:	ff ff 
80107ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107acc:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107ad3:	00 00 
80107ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad8:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ae9:	83 e2 f0             	and    $0xfffffff0,%edx
80107aec:	83 ca 0a             	or     $0xa,%edx
80107aef:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af8:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107aff:	83 ca 10             	or     $0x10,%edx
80107b02:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b12:	83 ca 60             	or     $0x60,%edx
80107b15:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b25:	83 ca 80             	or     $0xffffff80,%edx
80107b28:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b31:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b38:	83 ca 0f             	or     $0xf,%edx
80107b3b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b44:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b4b:	83 e2 ef             	and    $0xffffffef,%edx
80107b4e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b57:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b5e:	83 e2 df             	and    $0xffffffdf,%edx
80107b61:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b71:	83 ca 40             	or     $0x40,%edx
80107b74:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b84:	83 ca 80             	or     $0xffffff80,%edx
80107b87:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b90:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9a:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107ba1:	ff ff 
80107ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba6:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107bad:	00 00 
80107baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb2:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbc:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107bc3:	83 e2 f0             	and    $0xfffffff0,%edx
80107bc6:	83 ca 02             	or     $0x2,%edx
80107bc9:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd2:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107bd9:	83 ca 10             	or     $0x10,%edx
80107bdc:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be5:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107bec:	83 ca 60             	or     $0x60,%edx
80107bef:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf8:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107bff:	83 ca 80             	or     $0xffffff80,%edx
80107c02:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c12:	83 ca 0f             	or     $0xf,%edx
80107c15:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c25:	83 e2 ef             	and    $0xffffffef,%edx
80107c28:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c31:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c38:	83 e2 df             	and    $0xffffffdf,%edx
80107c3b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c44:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c4b:	83 ca 40             	or     $0x40,%edx
80107c4e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c57:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c5e:	83 ca 80             	or     $0xffffff80,%edx
80107c61:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6a:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c74:	05 b4 00 00 00       	add    $0xb4,%eax
80107c79:	89 c3                	mov    %eax,%ebx
80107c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7e:	05 b4 00 00 00       	add    $0xb4,%eax
80107c83:	c1 e8 10             	shr    $0x10,%eax
80107c86:	89 c1                	mov    %eax,%ecx
80107c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8b:	05 b4 00 00 00       	add    $0xb4,%eax
80107c90:	c1 e8 18             	shr    $0x18,%eax
80107c93:	89 c2                	mov    %eax,%edx
80107c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c98:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107c9f:	00 00 
80107ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca4:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cae:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb7:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107cbe:	83 e1 f0             	and    $0xfffffff0,%ecx
80107cc1:	83 c9 02             	or     $0x2,%ecx
80107cc4:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ccd:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107cd4:	83 c9 10             	or     $0x10,%ecx
80107cd7:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce0:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107ce7:	83 e1 9f             	and    $0xffffff9f,%ecx
80107cea:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf3:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107cfa:	83 c9 80             	or     $0xffffff80,%ecx
80107cfd:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d06:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d0d:	83 e1 f0             	and    $0xfffffff0,%ecx
80107d10:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d19:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d20:	83 e1 ef             	and    $0xffffffef,%ecx
80107d23:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2c:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d33:	83 e1 df             	and    $0xffffffdf,%ecx
80107d36:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3f:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d46:	83 c9 40             	or     $0x40,%ecx
80107d49:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d52:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d59:	83 c9 80             	or     $0xffffff80,%ecx
80107d5c:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d65:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6e:	83 c0 70             	add    $0x70,%eax
80107d71:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107d78:	00 
80107d79:	89 04 24             	mov    %eax,(%esp)
80107d7c:	e8 37 fb ff ff       	call   801078b8 <lgdt>
  loadgs(SEG_KCPU << 3);
80107d81:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107d88:	e8 6a fb ff ff       	call   801078f7 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d90:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107d96:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107d9d:	00 00 00 00 
}
80107da1:	83 c4 24             	add    $0x24,%esp
80107da4:	5b                   	pop    %ebx
80107da5:	5d                   	pop    %ebp
80107da6:	c3                   	ret    

80107da7 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107da7:	55                   	push   %ebp
80107da8:	89 e5                	mov    %esp,%ebp
80107daa:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107dad:	8b 45 0c             	mov    0xc(%ebp),%eax
80107db0:	c1 e8 16             	shr    $0x16,%eax
80107db3:	c1 e0 02             	shl    $0x2,%eax
80107db6:	03 45 08             	add    0x8(%ebp),%eax
80107db9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107dbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dbf:	8b 00                	mov    (%eax),%eax
80107dc1:	83 e0 01             	and    $0x1,%eax
80107dc4:	84 c0                	test   %al,%al
80107dc6:	74 17                	je     80107ddf <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107dc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dcb:	8b 00                	mov    (%eax),%eax
80107dcd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107dd2:	89 04 24             	mov    %eax,(%esp)
80107dd5:	e8 4a fb ff ff       	call   80107924 <p2v>
80107dda:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ddd:	eb 4b                	jmp    80107e2a <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107ddf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107de3:	74 0e                	je     80107df3 <walkpgdir+0x4c>
80107de5:	e8 69 b0 ff ff       	call   80102e53 <kalloc>
80107dea:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ded:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107df1:	75 07                	jne    80107dfa <walkpgdir+0x53>
      return 0;
80107df3:	b8 00 00 00 00       	mov    $0x0,%eax
80107df8:	eb 41                	jmp    80107e3b <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107dfa:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e01:	00 
80107e02:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107e09:	00 
80107e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0d:	89 04 24             	mov    %eax,(%esp)
80107e10:	e8 e9 d4 ff ff       	call   801052fe <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e18:	89 04 24             	mov    %eax,(%esp)
80107e1b:	e8 f7 fa ff ff       	call   80107917 <v2p>
80107e20:	89 c2                	mov    %eax,%edx
80107e22:	83 ca 07             	or     $0x7,%edx
80107e25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e28:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107e2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e2d:	c1 e8 0c             	shr    $0xc,%eax
80107e30:	25 ff 03 00 00       	and    $0x3ff,%eax
80107e35:	c1 e0 02             	shl    $0x2,%eax
80107e38:	03 45 f4             	add    -0xc(%ebp),%eax
}
80107e3b:	c9                   	leave  
80107e3c:	c3                   	ret    

80107e3d <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107e3d:	55                   	push   %ebp
80107e3e:	89 e5                	mov    %esp,%ebp
80107e40:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107e43:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e46:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e51:	03 45 10             	add    0x10(%ebp),%eax
80107e54:	83 e8 01             	sub    $0x1,%eax
80107e57:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107e5f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107e66:	00 
80107e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e6e:	8b 45 08             	mov    0x8(%ebp),%eax
80107e71:	89 04 24             	mov    %eax,(%esp)
80107e74:	e8 2e ff ff ff       	call   80107da7 <walkpgdir>
80107e79:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e7c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e80:	75 07                	jne    80107e89 <mappages+0x4c>
      return -1;
80107e82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e87:	eb 46                	jmp    80107ecf <mappages+0x92>
    if(*pte & PTE_P)
80107e89:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e8c:	8b 00                	mov    (%eax),%eax
80107e8e:	83 e0 01             	and    $0x1,%eax
80107e91:	84 c0                	test   %al,%al
80107e93:	74 0c                	je     80107ea1 <mappages+0x64>
      panic("remap");
80107e95:	c7 04 24 b4 8c 10 80 	movl   $0x80108cb4,(%esp)
80107e9c:	e8 9c 86 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80107ea1:	8b 45 18             	mov    0x18(%ebp),%eax
80107ea4:	0b 45 14             	or     0x14(%ebp),%eax
80107ea7:	89 c2                	mov    %eax,%edx
80107ea9:	83 ca 01             	or     $0x1,%edx
80107eac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107eaf:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107eb7:	74 10                	je     80107ec9 <mappages+0x8c>
      break;
    a += PGSIZE;
80107eb9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107ec0:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107ec7:	eb 96                	jmp    80107e5f <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107ec9:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107eca:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ecf:	c9                   	leave  
80107ed0:	c3                   	ret    

80107ed1 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm()
{
80107ed1:	55                   	push   %ebp
80107ed2:	89 e5                	mov    %esp,%ebp
80107ed4:	53                   	push   %ebx
80107ed5:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107ed8:	e8 76 af ff ff       	call   80102e53 <kalloc>
80107edd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ee0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ee4:	75 0a                	jne    80107ef0 <setupkvm+0x1f>
    return 0;
80107ee6:	b8 00 00 00 00       	mov    $0x0,%eax
80107eeb:	e9 98 00 00 00       	jmp    80107f88 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107ef0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107ef7:	00 
80107ef8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107eff:	00 
80107f00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f03:	89 04 24             	mov    %eax,(%esp)
80107f06:	e8 f3 d3 ff ff       	call   801052fe <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107f0b:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107f12:	e8 0d fa ff ff       	call   80107924 <p2v>
80107f17:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107f1c:	76 0c                	jbe    80107f2a <setupkvm+0x59>
    panic("PHYSTOP too high");
80107f1e:	c7 04 24 ba 8c 10 80 	movl   $0x80108cba,(%esp)
80107f25:	e8 13 86 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107f2a:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107f31:	eb 49                	jmp    80107f7c <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
80107f33:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107f36:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80107f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107f3c:	8b 50 04             	mov    0x4(%eax),%edx
80107f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f42:	8b 58 08             	mov    0x8(%eax),%ebx
80107f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f48:	8b 40 04             	mov    0x4(%eax),%eax
80107f4b:	29 c3                	sub    %eax,%ebx
80107f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f50:	8b 00                	mov    (%eax),%eax
80107f52:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107f56:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107f5a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107f5e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f65:	89 04 24             	mov    %eax,(%esp)
80107f68:	e8 d0 fe ff ff       	call   80107e3d <mappages>
80107f6d:	85 c0                	test   %eax,%eax
80107f6f:	79 07                	jns    80107f78 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107f71:	b8 00 00 00 00       	mov    $0x0,%eax
80107f76:	eb 10                	jmp    80107f88 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107f78:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107f7c:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107f83:	72 ae                	jb     80107f33 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107f85:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107f88:	83 c4 34             	add    $0x34,%esp
80107f8b:	5b                   	pop    %ebx
80107f8c:	5d                   	pop    %ebp
80107f8d:	c3                   	ret    

80107f8e <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107f8e:	55                   	push   %ebp
80107f8f:	89 e5                	mov    %esp,%ebp
80107f91:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107f94:	e8 38 ff ff ff       	call   80107ed1 <setupkvm>
80107f99:	a3 18 2a 11 80       	mov    %eax,0x80112a18
  switchkvm();
80107f9e:	e8 02 00 00 00       	call   80107fa5 <switchkvm>
}
80107fa3:	c9                   	leave  
80107fa4:	c3                   	ret    

80107fa5 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107fa5:	55                   	push   %ebp
80107fa6:	89 e5                	mov    %esp,%ebp
80107fa8:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107fab:	a1 18 2a 11 80       	mov    0x80112a18,%eax
80107fb0:	89 04 24             	mov    %eax,(%esp)
80107fb3:	e8 5f f9 ff ff       	call   80107917 <v2p>
80107fb8:	89 04 24             	mov    %eax,(%esp)
80107fbb:	e8 4c f9 ff ff       	call   8010790c <lcr3>
}
80107fc0:	c9                   	leave  
80107fc1:	c3                   	ret    

80107fc2 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107fc2:	55                   	push   %ebp
80107fc3:	89 e5                	mov    %esp,%ebp
80107fc5:	53                   	push   %ebx
80107fc6:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107fc9:	e8 29 d2 ff ff       	call   801051f7 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107fce:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107fd4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107fdb:	83 c2 08             	add    $0x8,%edx
80107fde:	89 d3                	mov    %edx,%ebx
80107fe0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107fe7:	83 c2 08             	add    $0x8,%edx
80107fea:	c1 ea 10             	shr    $0x10,%edx
80107fed:	89 d1                	mov    %edx,%ecx
80107fef:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107ff6:	83 c2 08             	add    $0x8,%edx
80107ff9:	c1 ea 18             	shr    $0x18,%edx
80107ffc:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108003:	67 00 
80108005:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
8010800c:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80108012:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108019:	83 e1 f0             	and    $0xfffffff0,%ecx
8010801c:	83 c9 09             	or     $0x9,%ecx
8010801f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108025:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010802c:	83 c9 10             	or     $0x10,%ecx
8010802f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108035:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010803c:	83 e1 9f             	and    $0xffffff9f,%ecx
8010803f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108045:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010804c:	83 c9 80             	or     $0xffffff80,%ecx
8010804f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108055:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010805c:	83 e1 f0             	and    $0xfffffff0,%ecx
8010805f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108065:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010806c:	83 e1 ef             	and    $0xffffffef,%ecx
8010806f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108075:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010807c:	83 e1 df             	and    $0xffffffdf,%ecx
8010807f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108085:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010808c:	83 c9 40             	or     $0x40,%ecx
8010808f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108095:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010809c:	83 e1 7f             	and    $0x7f,%ecx
8010809f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801080a5:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801080ab:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801080b1:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801080b8:	83 e2 ef             	and    $0xffffffef,%edx
801080bb:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801080c1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801080c7:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801080cd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801080d3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801080da:	8b 52 08             	mov    0x8(%edx),%edx
801080dd:	81 c2 00 10 00 00    	add    $0x1000,%edx
801080e3:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801080e6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
801080ed:	e8 ef f7 ff ff       	call   801078e1 <ltr>
  if(p->pgdir == 0)
801080f2:	8b 45 08             	mov    0x8(%ebp),%eax
801080f5:	8b 40 04             	mov    0x4(%eax),%eax
801080f8:	85 c0                	test   %eax,%eax
801080fa:	75 0c                	jne    80108108 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
801080fc:	c7 04 24 cb 8c 10 80 	movl   $0x80108ccb,(%esp)
80108103:	e8 35 84 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108108:	8b 45 08             	mov    0x8(%ebp),%eax
8010810b:	8b 40 04             	mov    0x4(%eax),%eax
8010810e:	89 04 24             	mov    %eax,(%esp)
80108111:	e8 01 f8 ff ff       	call   80107917 <v2p>
80108116:	89 04 24             	mov    %eax,(%esp)
80108119:	e8 ee f7 ff ff       	call   8010790c <lcr3>
  popcli();
8010811e:	e8 1c d1 ff ff       	call   8010523f <popcli>
}
80108123:	83 c4 14             	add    $0x14,%esp
80108126:	5b                   	pop    %ebx
80108127:	5d                   	pop    %ebp
80108128:	c3                   	ret    

80108129 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108129:	55                   	push   %ebp
8010812a:	89 e5                	mov    %esp,%ebp
8010812c:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
8010812f:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108136:	76 0c                	jbe    80108144 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108138:	c7 04 24 df 8c 10 80 	movl   $0x80108cdf,(%esp)
8010813f:	e8 f9 83 ff ff       	call   8010053d <panic>
  mem = kalloc();
80108144:	e8 0a ad ff ff       	call   80102e53 <kalloc>
80108149:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010814c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108153:	00 
80108154:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010815b:	00 
8010815c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010815f:	89 04 24             	mov    %eax,(%esp)
80108162:	e8 97 d1 ff ff       	call   801052fe <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108167:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010816a:	89 04 24             	mov    %eax,(%esp)
8010816d:	e8 a5 f7 ff ff       	call   80107917 <v2p>
80108172:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108179:	00 
8010817a:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010817e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108185:	00 
80108186:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010818d:	00 
8010818e:	8b 45 08             	mov    0x8(%ebp),%eax
80108191:	89 04 24             	mov    %eax,(%esp)
80108194:	e8 a4 fc ff ff       	call   80107e3d <mappages>
  memmove(mem, init, sz);
80108199:	8b 45 10             	mov    0x10(%ebp),%eax
8010819c:	89 44 24 08          	mov    %eax,0x8(%esp)
801081a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801081a3:	89 44 24 04          	mov    %eax,0x4(%esp)
801081a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081aa:	89 04 24             	mov    %eax,(%esp)
801081ad:	e8 1f d2 ff ff       	call   801053d1 <memmove>
}
801081b2:	c9                   	leave  
801081b3:	c3                   	ret    

801081b4 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801081b4:	55                   	push   %ebp
801081b5:	89 e5                	mov    %esp,%ebp
801081b7:	53                   	push   %ebx
801081b8:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801081bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801081be:	25 ff 0f 00 00       	and    $0xfff,%eax
801081c3:	85 c0                	test   %eax,%eax
801081c5:	74 0c                	je     801081d3 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801081c7:	c7 04 24 fc 8c 10 80 	movl   $0x80108cfc,(%esp)
801081ce:	e8 6a 83 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
801081d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081da:	e9 ad 00 00 00       	jmp    8010828c <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801081df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e2:	8b 55 0c             	mov    0xc(%ebp),%edx
801081e5:	01 d0                	add    %edx,%eax
801081e7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801081ee:	00 
801081ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801081f3:	8b 45 08             	mov    0x8(%ebp),%eax
801081f6:	89 04 24             	mov    %eax,(%esp)
801081f9:	e8 a9 fb ff ff       	call   80107da7 <walkpgdir>
801081fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108201:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108205:	75 0c                	jne    80108213 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80108207:	c7 04 24 1f 8d 10 80 	movl   $0x80108d1f,(%esp)
8010820e:	e8 2a 83 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80108213:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108216:	8b 00                	mov    (%eax),%eax
80108218:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010821d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108220:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108223:	8b 55 18             	mov    0x18(%ebp),%edx
80108226:	89 d1                	mov    %edx,%ecx
80108228:	29 c1                	sub    %eax,%ecx
8010822a:	89 c8                	mov    %ecx,%eax
8010822c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108231:	77 11                	ja     80108244 <loaduvm+0x90>
      n = sz - i;
80108233:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108236:	8b 55 18             	mov    0x18(%ebp),%edx
80108239:	89 d1                	mov    %edx,%ecx
8010823b:	29 c1                	sub    %eax,%ecx
8010823d:	89 c8                	mov    %ecx,%eax
8010823f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108242:	eb 07                	jmp    8010824b <loaduvm+0x97>
    else
      n = PGSIZE;
80108244:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
8010824b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010824e:	8b 55 14             	mov    0x14(%ebp),%edx
80108251:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108254:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108257:	89 04 24             	mov    %eax,(%esp)
8010825a:	e8 c5 f6 ff ff       	call   80107924 <p2v>
8010825f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108262:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108266:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010826a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010826e:	8b 45 10             	mov    0x10(%ebp),%eax
80108271:	89 04 24             	mov    %eax,(%esp)
80108274:	e8 39 9e ff ff       	call   801020b2 <readi>
80108279:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010827c:	74 07                	je     80108285 <loaduvm+0xd1>
      return -1;
8010827e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108283:	eb 18                	jmp    8010829d <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108285:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010828c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010828f:	3b 45 18             	cmp    0x18(%ebp),%eax
80108292:	0f 82 47 ff ff ff    	jb     801081df <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108298:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010829d:	83 c4 24             	add    $0x24,%esp
801082a0:	5b                   	pop    %ebx
801082a1:	5d                   	pop    %ebp
801082a2:	c3                   	ret    

801082a3 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801082a3:	55                   	push   %ebp
801082a4:	89 e5                	mov    %esp,%ebp
801082a6:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801082a9:	8b 45 10             	mov    0x10(%ebp),%eax
801082ac:	85 c0                	test   %eax,%eax
801082ae:	79 0a                	jns    801082ba <allocuvm+0x17>
    return 0;
801082b0:	b8 00 00 00 00       	mov    $0x0,%eax
801082b5:	e9 c1 00 00 00       	jmp    8010837b <allocuvm+0xd8>
  if(newsz < oldsz)
801082ba:	8b 45 10             	mov    0x10(%ebp),%eax
801082bd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082c0:	73 08                	jae    801082ca <allocuvm+0x27>
    return oldsz;
801082c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801082c5:	e9 b1 00 00 00       	jmp    8010837b <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
801082ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801082cd:	05 ff 0f 00 00       	add    $0xfff,%eax
801082d2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801082da:	e9 8d 00 00 00       	jmp    8010836c <allocuvm+0xc9>
    mem = kalloc();
801082df:	e8 6f ab ff ff       	call   80102e53 <kalloc>
801082e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801082e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082eb:	75 2c                	jne    80108319 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
801082ed:	c7 04 24 3d 8d 10 80 	movl   $0x80108d3d,(%esp)
801082f4:	e8 a8 80 ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801082f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801082fc:	89 44 24 08          	mov    %eax,0x8(%esp)
80108300:	8b 45 10             	mov    0x10(%ebp),%eax
80108303:	89 44 24 04          	mov    %eax,0x4(%esp)
80108307:	8b 45 08             	mov    0x8(%ebp),%eax
8010830a:	89 04 24             	mov    %eax,(%esp)
8010830d:	e8 6b 00 00 00       	call   8010837d <deallocuvm>
      return 0;
80108312:	b8 00 00 00 00       	mov    $0x0,%eax
80108317:	eb 62                	jmp    8010837b <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108319:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108320:	00 
80108321:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108328:	00 
80108329:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010832c:	89 04 24             	mov    %eax,(%esp)
8010832f:	e8 ca cf ff ff       	call   801052fe <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108337:	89 04 24             	mov    %eax,(%esp)
8010833a:	e8 d8 f5 ff ff       	call   80107917 <v2p>
8010833f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108342:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108349:	00 
8010834a:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010834e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108355:	00 
80108356:	89 54 24 04          	mov    %edx,0x4(%esp)
8010835a:	8b 45 08             	mov    0x8(%ebp),%eax
8010835d:	89 04 24             	mov    %eax,(%esp)
80108360:	e8 d8 fa ff ff       	call   80107e3d <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108365:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010836c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010836f:	3b 45 10             	cmp    0x10(%ebp),%eax
80108372:	0f 82 67 ff ff ff    	jb     801082df <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108378:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010837b:	c9                   	leave  
8010837c:	c3                   	ret    

8010837d <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010837d:	55                   	push   %ebp
8010837e:	89 e5                	mov    %esp,%ebp
80108380:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108383:	8b 45 10             	mov    0x10(%ebp),%eax
80108386:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108389:	72 08                	jb     80108393 <deallocuvm+0x16>
    return oldsz;
8010838b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010838e:	e9 a4 00 00 00       	jmp    80108437 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108393:	8b 45 10             	mov    0x10(%ebp),%eax
80108396:	05 ff 0f 00 00       	add    $0xfff,%eax
8010839b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801083a3:	e9 80 00 00 00       	jmp    80108428 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
801083a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801083b2:	00 
801083b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801083b7:	8b 45 08             	mov    0x8(%ebp),%eax
801083ba:	89 04 24             	mov    %eax,(%esp)
801083bd:	e8 e5 f9 ff ff       	call   80107da7 <walkpgdir>
801083c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801083c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083c9:	75 09                	jne    801083d4 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
801083cb:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801083d2:	eb 4d                	jmp    80108421 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
801083d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083d7:	8b 00                	mov    (%eax),%eax
801083d9:	83 e0 01             	and    $0x1,%eax
801083dc:	84 c0                	test   %al,%al
801083de:	74 41                	je     80108421 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
801083e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083e3:	8b 00                	mov    (%eax),%eax
801083e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801083ed:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083f1:	75 0c                	jne    801083ff <deallocuvm+0x82>
        panic("kfree");
801083f3:	c7 04 24 55 8d 10 80 	movl   $0x80108d55,(%esp)
801083fa:	e8 3e 81 ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
801083ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108402:	89 04 24             	mov    %eax,(%esp)
80108405:	e8 1a f5 ff ff       	call   80107924 <p2v>
8010840a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010840d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108410:	89 04 24             	mov    %eax,(%esp)
80108413:	e8 a2 a9 ff ff       	call   80102dba <kfree>
      *pte = 0;
80108418:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010841b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108421:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010842e:	0f 82 74 ff ff ff    	jb     801083a8 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108434:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108437:	c9                   	leave  
80108438:	c3                   	ret    

80108439 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108439:	55                   	push   %ebp
8010843a:	89 e5                	mov    %esp,%ebp
8010843c:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
8010843f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108443:	75 0c                	jne    80108451 <freevm+0x18>
    panic("freevm: no pgdir");
80108445:	c7 04 24 5b 8d 10 80 	movl   $0x80108d5b,(%esp)
8010844c:	e8 ec 80 ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108451:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108458:	00 
80108459:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108460:	80 
80108461:	8b 45 08             	mov    0x8(%ebp),%eax
80108464:	89 04 24             	mov    %eax,(%esp)
80108467:	e8 11 ff ff ff       	call   8010837d <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010846c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108473:	eb 3c                	jmp    801084b1 <freevm+0x78>
    if(pgdir[i] & PTE_P){
80108475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108478:	c1 e0 02             	shl    $0x2,%eax
8010847b:	03 45 08             	add    0x8(%ebp),%eax
8010847e:	8b 00                	mov    (%eax),%eax
80108480:	83 e0 01             	and    $0x1,%eax
80108483:	84 c0                	test   %al,%al
80108485:	74 26                	je     801084ad <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010848a:	c1 e0 02             	shl    $0x2,%eax
8010848d:	03 45 08             	add    0x8(%ebp),%eax
80108490:	8b 00                	mov    (%eax),%eax
80108492:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108497:	89 04 24             	mov    %eax,(%esp)
8010849a:	e8 85 f4 ff ff       	call   80107924 <p2v>
8010849f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801084a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084a5:	89 04 24             	mov    %eax,(%esp)
801084a8:	e8 0d a9 ff ff       	call   80102dba <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801084ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801084b1:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801084b8:	76 bb                	jbe    80108475 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801084ba:	8b 45 08             	mov    0x8(%ebp),%eax
801084bd:	89 04 24             	mov    %eax,(%esp)
801084c0:	e8 f5 a8 ff ff       	call   80102dba <kfree>
}
801084c5:	c9                   	leave  
801084c6:	c3                   	ret    

801084c7 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801084c7:	55                   	push   %ebp
801084c8:	89 e5                	mov    %esp,%ebp
801084ca:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801084cd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801084d4:	00 
801084d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801084d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801084dc:	8b 45 08             	mov    0x8(%ebp),%eax
801084df:	89 04 24             	mov    %eax,(%esp)
801084e2:	e8 c0 f8 ff ff       	call   80107da7 <walkpgdir>
801084e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801084ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801084ee:	75 0c                	jne    801084fc <clearpteu+0x35>
    panic("clearpteu");
801084f0:	c7 04 24 6c 8d 10 80 	movl   $0x80108d6c,(%esp)
801084f7:	e8 41 80 ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
801084fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ff:	8b 00                	mov    (%eax),%eax
80108501:	89 c2                	mov    %eax,%edx
80108503:	83 e2 fb             	and    $0xfffffffb,%edx
80108506:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108509:	89 10                	mov    %edx,(%eax)
}
8010850b:	c9                   	leave  
8010850c:	c3                   	ret    

8010850d <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010850d:	55                   	push   %ebp
8010850e:	89 e5                	mov    %esp,%ebp
80108510:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
80108513:	e8 b9 f9 ff ff       	call   80107ed1 <setupkvm>
80108518:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010851b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010851f:	75 0a                	jne    8010852b <copyuvm+0x1e>
    return 0;
80108521:	b8 00 00 00 00       	mov    $0x0,%eax
80108526:	e9 f1 00 00 00       	jmp    8010861c <copyuvm+0x10f>
  for(i = 0; i < sz; i += PGSIZE){
8010852b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108532:	e9 c0 00 00 00       	jmp    801085f7 <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108541:	00 
80108542:	89 44 24 04          	mov    %eax,0x4(%esp)
80108546:	8b 45 08             	mov    0x8(%ebp),%eax
80108549:	89 04 24             	mov    %eax,(%esp)
8010854c:	e8 56 f8 ff ff       	call   80107da7 <walkpgdir>
80108551:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108554:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108558:	75 0c                	jne    80108566 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
8010855a:	c7 04 24 76 8d 10 80 	movl   $0x80108d76,(%esp)
80108561:	e8 d7 7f ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
80108566:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108569:	8b 00                	mov    (%eax),%eax
8010856b:	83 e0 01             	and    $0x1,%eax
8010856e:	85 c0                	test   %eax,%eax
80108570:	75 0c                	jne    8010857e <copyuvm+0x71>
      panic("copyuvm: page not present");
80108572:	c7 04 24 90 8d 10 80 	movl   $0x80108d90,(%esp)
80108579:	e8 bf 7f ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
8010857e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108581:	8b 00                	mov    (%eax),%eax
80108583:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108588:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((mem = kalloc()) == 0)
8010858b:	e8 c3 a8 ff ff       	call   80102e53 <kalloc>
80108590:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80108593:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108597:	74 6f                	je     80108608 <copyuvm+0xfb>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108599:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010859c:	89 04 24             	mov    %eax,(%esp)
8010859f:	e8 80 f3 ff ff       	call   80107924 <p2v>
801085a4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801085ab:	00 
801085ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801085b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801085b3:	89 04 24             	mov    %eax,(%esp)
801085b6:	e8 16 ce ff ff       	call   801053d1 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
801085bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801085be:	89 04 24             	mov    %eax,(%esp)
801085c1:	e8 51 f3 ff ff       	call   80107917 <v2p>
801085c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801085c9:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801085d0:	00 
801085d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
801085d5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801085dc:	00 
801085dd:	89 54 24 04          	mov    %edx,0x4(%esp)
801085e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085e4:	89 04 24             	mov    %eax,(%esp)
801085e7:	e8 51 f8 ff ff       	call   80107e3d <mappages>
801085ec:	85 c0                	test   %eax,%eax
801085ee:	78 1b                	js     8010860b <copyuvm+0xfe>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801085f0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801085f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085fa:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085fd:	0f 82 34 ff ff ff    	jb     80108537 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
  }
  return d;
80108603:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108606:	eb 14                	jmp    8010861c <copyuvm+0x10f>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108608:	90                   	nop
80108609:	eb 01                	jmp    8010860c <copyuvm+0xff>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
8010860b:	90                   	nop
  }
  return d;

bad:
  freevm(d);
8010860c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010860f:	89 04 24             	mov    %eax,(%esp)
80108612:	e8 22 fe ff ff       	call   80108439 <freevm>
  return 0;
80108617:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010861c:	c9                   	leave  
8010861d:	c3                   	ret    

8010861e <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010861e:	55                   	push   %ebp
8010861f:	89 e5                	mov    %esp,%ebp
80108621:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108624:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010862b:	00 
8010862c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010862f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108633:	8b 45 08             	mov    0x8(%ebp),%eax
80108636:	89 04 24             	mov    %eax,(%esp)
80108639:	e8 69 f7 ff ff       	call   80107da7 <walkpgdir>
8010863e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108641:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108644:	8b 00                	mov    (%eax),%eax
80108646:	83 e0 01             	and    $0x1,%eax
80108649:	85 c0                	test   %eax,%eax
8010864b:	75 07                	jne    80108654 <uva2ka+0x36>
    return 0;
8010864d:	b8 00 00 00 00       	mov    $0x0,%eax
80108652:	eb 25                	jmp    80108679 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108654:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108657:	8b 00                	mov    (%eax),%eax
80108659:	83 e0 04             	and    $0x4,%eax
8010865c:	85 c0                	test   %eax,%eax
8010865e:	75 07                	jne    80108667 <uva2ka+0x49>
    return 0;
80108660:	b8 00 00 00 00       	mov    $0x0,%eax
80108665:	eb 12                	jmp    80108679 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108667:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010866a:	8b 00                	mov    (%eax),%eax
8010866c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108671:	89 04 24             	mov    %eax,(%esp)
80108674:	e8 ab f2 ff ff       	call   80107924 <p2v>
}
80108679:	c9                   	leave  
8010867a:	c3                   	ret    

8010867b <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010867b:	55                   	push   %ebp
8010867c:	89 e5                	mov    %esp,%ebp
8010867e:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108681:	8b 45 10             	mov    0x10(%ebp),%eax
80108684:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108687:	e9 8b 00 00 00       	jmp    80108717 <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
8010868c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010868f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108694:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108697:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010869a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010869e:	8b 45 08             	mov    0x8(%ebp),%eax
801086a1:	89 04 24             	mov    %eax,(%esp)
801086a4:	e8 75 ff ff ff       	call   8010861e <uva2ka>
801086a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801086ac:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801086b0:	75 07                	jne    801086b9 <copyout+0x3e>
      return -1;
801086b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801086b7:	eb 6d                	jmp    80108726 <copyout+0xab>
    n = PGSIZE - (va - va0);
801086b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801086bc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801086bf:	89 d1                	mov    %edx,%ecx
801086c1:	29 c1                	sub    %eax,%ecx
801086c3:	89 c8                	mov    %ecx,%eax
801086c5:	05 00 10 00 00       	add    $0x1000,%eax
801086ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801086cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086d0:	3b 45 14             	cmp    0x14(%ebp),%eax
801086d3:	76 06                	jbe    801086db <copyout+0x60>
      n = len;
801086d5:	8b 45 14             	mov    0x14(%ebp),%eax
801086d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801086db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086de:	8b 55 0c             	mov    0xc(%ebp),%edx
801086e1:	89 d1                	mov    %edx,%ecx
801086e3:	29 c1                	sub    %eax,%ecx
801086e5:	89 c8                	mov    %ecx,%eax
801086e7:	03 45 e8             	add    -0x18(%ebp),%eax
801086ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
801086ed:	89 54 24 08          	mov    %edx,0x8(%esp)
801086f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086f4:	89 54 24 04          	mov    %edx,0x4(%esp)
801086f8:	89 04 24             	mov    %eax,(%esp)
801086fb:	e8 d1 cc ff ff       	call   801053d1 <memmove>
    len -= n;
80108700:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108703:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108706:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108709:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010870c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010870f:	05 00 10 00 00       	add    $0x1000,%eax
80108714:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108717:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010871b:	0f 85 6b ff ff ff    	jne    8010868c <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108721:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108726:	c9                   	leave  
80108727:	c3                   	ret    

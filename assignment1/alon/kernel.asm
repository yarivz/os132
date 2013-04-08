
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
8010002d:	b8 5f 37 10 80       	mov    $0x8010375f,%eax
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
8010003a:	c7 44 24 04 9c 88 10 	movl   $0x8010889c,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 80 51 00 00       	call   801051ce <initlock>

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
801000bd:	e8 2d 51 00 00       	call   801051ef <acquire>

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
80100104:	e8 48 51 00 00       	call   80105251 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 62 4d 00 00       	call   80104e86 <sleep>
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
8010017c:	e8 d0 50 00 00       	call   80105251 <release>
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
80100198:	c7 04 24 a3 88 10 80 	movl   $0x801088a3,(%esp)
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
801001d3:	e8 34 29 00 00       	call   80102b0c <iderw>
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
801001ef:	c7 04 24 b4 88 10 80 	movl   $0x801088b4,(%esp)
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
80100210:	e8 f7 28 00 00       	call   80102b0c <iderw>
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
80100229:	c7 04 24 bb 88 10 80 	movl   $0x801088bb,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 ae 4f 00 00       	call   801051ef <acquire>

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
8010029d:	e8 c0 4c 00 00       	call   80104f62 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 a3 4f 00 00       	call   80105251 <release>
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
801003bc:	e8 2e 4e 00 00       	call   801051ef <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 c2 88 10 80 	movl   $0x801088c2,(%esp)
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
801004af:	c7 45 ec cb 88 10 80 	movl   $0x801088cb,-0x14(%ebp)
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
80100536:	e8 16 4d 00 00       	call   80105251 <release>
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
80100562:	c7 04 24 d2 88 10 80 	movl   $0x801088d2,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 e1 88 10 80 	movl   $0x801088e1,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 09 4d 00 00       	call   801052a0 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 e3 88 10 80 	movl   $0x801088e3,(%esp)
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
8010072b:	e8 e1 4d 00 00       	call   80105511 <memmove>
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
8010075a:	e8 df 4c 00 00       	call   8010543e <memset>
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
80100801:	e8 fb 66 00 00       	call   80106f01 <uartputc>
80100806:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010080d:	e8 ef 66 00 00       	call   80106f01 <uartputc>
80100812:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100819:	e8 e3 66 00 00       	call   80106f01 <uartputc>
8010081e:	eb 0b                	jmp    8010082b <consputc+0x50>
  }
  else if (c == KEY_RT){
    uartputc(0x601);
  }*/
  else
    uartputc(c);
80100820:	8b 45 08             	mov    0x8(%ebp),%eax
80100823:	89 04 24             	mov    %eax,(%esp)
80100826:	e8 d6 66 00 00       	call   80106f01 <uartputc>
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
  int j=0;
8010083e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(;j < k /*&& e+j < INPUT_BUF*/;e--,j++){
80100845:	eb 21                	jmp    80100868 <shiftRightBuf+0x30>
    input.buf[e] = input.buf[e-1];
80100847:	8b 45 08             	mov    0x8(%ebp),%eax
8010084a:	83 e8 01             	sub    $0x1,%eax
8010084d:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
80100854:	8b 55 08             	mov    0x8(%ebp),%edx
80100857:	81 c2 d0 dd 10 80    	add    $0x8010ddd0,%edx
8010085d:	88 42 04             	mov    %al,0x4(%edx)

void
shiftRightBuf(int e, int k)
{
  int j=0;
  for(;j < k /*&& e+j < INPUT_BUF*/;e--,j++){
80100860:	83 6d 08 01          	subl   $0x1,0x8(%ebp)
80100864:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80100868:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010086b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010086e:	7c d7                	jl     80100847 <shiftRightBuf+0xf>
    input.buf[e] = input.buf[e-1];
  }
}
80100870:	c9                   	leave  
80100871:	c3                   	ret    

80100872 <shiftLeftBuf>:

void
shiftLeftBuf(int e, int k)
{
80100872:	55                   	push   %ebp
80100873:	89 e5                	mov    %esp,%ebp
80100875:	83 ec 10             	sub    $0x10,%esp
  int i = e+k;
80100878:	8b 45 0c             	mov    0xc(%ebp),%eax
8010087b:	8b 55 08             	mov    0x8(%ebp),%edx
8010087e:	01 d0                	add    %edx,%eax
80100880:	89 45 fc             	mov    %eax,-0x4(%ebp)
  int j=0;
80100883:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(;j < (-1)*k ;i++,j++){
8010088a:	eb 21                	jmp    801008ad <shiftLeftBuf+0x3b>
    input.buf[i] = input.buf[i+1];
8010088c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010088f:	83 c0 01             	add    $0x1,%eax
80100892:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
80100899:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010089c:	81 c2 d0 dd 10 80    	add    $0x8010ddd0,%edx
801008a2:	88 42 04             	mov    %al,0x4(%edx)
void
shiftLeftBuf(int e, int k)
{
  int i = e+k;
  int j=0;
  for(;j < (-1)*k ;i++,j++){
801008a5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801008a9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801008ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801008b0:	f7 d8                	neg    %eax
801008b2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801008b5:	7f d5                	jg     8010088c <shiftLeftBuf+0x1a>
    input.buf[i] = input.buf[i+1];
  }
  input.buf[e] = ' ';
801008b7:	8b 45 08             	mov    0x8(%ebp),%eax
801008ba:	05 d0 dd 10 80       	add    $0x8010ddd0,%eax
801008bf:	c6 40 04 20          	movb   $0x20,0x4(%eax)
}
801008c3:	c9                   	leave  
801008c4:	c3                   	ret    

801008c5 <consoleintr>:

void
consoleintr(int (*getc)(void))
{
801008c5:	55                   	push   %ebp
801008c6:	89 e5                	mov    %esp,%ebp
801008c8:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
801008cb:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
801008d2:	e8 18 49 00 00       	call   801051ef <acquire>
  while((c = getc()) >= 0){
801008d7:	e9 7f 03 00 00       	jmp    80100c5b <consoleintr+0x396>
    switch(c){
801008dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801008df:	83 f8 15             	cmp    $0x15,%eax
801008e2:	74 59                	je     8010093d <consoleintr+0x78>
801008e4:	83 f8 15             	cmp    $0x15,%eax
801008e7:	7f 0f                	jg     801008f8 <consoleintr+0x33>
801008e9:	83 f8 08             	cmp    $0x8,%eax
801008ec:	74 7e                	je     8010096c <consoleintr+0xa7>
801008ee:	83 f8 10             	cmp    $0x10,%eax
801008f1:	74 25                	je     80100918 <consoleintr+0x53>
801008f3:	e9 d7 01 00 00       	jmp    80100acf <consoleintr+0x20a>
801008f8:	3d e4 00 00 00       	cmp    $0xe4,%eax
801008fd:	0f 84 4d 01 00 00    	je     80100a50 <consoleintr+0x18b>
80100903:	3d e5 00 00 00       	cmp    $0xe5,%eax
80100908:	0f 84 85 01 00 00    	je     80100a93 <consoleintr+0x1ce>
8010090e:	83 f8 7f             	cmp    $0x7f,%eax
80100911:	74 59                	je     8010096c <consoleintr+0xa7>
80100913:	e9 b7 01 00 00       	jmp    80100acf <consoleintr+0x20a>
    case C('P'):  // Process listing.
      procdump();
80100918:	e8 eb 46 00 00       	call   80105008 <procdump>
      break;
8010091d:	e9 39 03 00 00       	jmp    80100c5b <consoleintr+0x396>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100922:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100927:	83 e8 01             	sub    $0x1,%eax
8010092a:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(BACKSPACE);
8010092f:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100936:	e8 a0 fe ff ff       	call   801007db <consputc>
8010093b:	eb 01                	jmp    8010093e <consoleintr+0x79>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010093d:	90                   	nop
8010093e:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100944:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100949:	39 c2                	cmp    %eax,%edx
8010094b:	0f 84 fd 02 00 00    	je     80100c4e <consoleintr+0x389>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100951:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100956:	83 e8 01             	sub    $0x1,%eax
80100959:	83 e0 7f             	and    $0x7f,%eax
8010095c:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100963:	3c 0a                	cmp    $0xa,%al
80100965:	75 bb                	jne    80100922 <consoleintr+0x5d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100967:	e9 e2 02 00 00       	jmp    80100c4e <consoleintr+0x389>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010096c:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100972:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100977:	39 c2                	cmp    %eax,%edx
80100979:	0f 84 d2 02 00 00    	je     80100c51 <consoleintr+0x38c>
	if(input.a<0)
8010097f:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100984:	85 c0                	test   %eax,%eax
80100986:	0f 89 a6 00 00 00    	jns    80100a32 <consoleintr+0x16d>
	{
	    shiftLeftBuf((input.e-1) % INPUT_BUF,input.a);
8010098c:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100991:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100997:	83 ea 01             	sub    $0x1,%edx
8010099a:	83 e2 7f             	and    $0x7f,%edx
8010099d:	89 44 24 04          	mov    %eax,0x4(%esp)
801009a1:	89 14 24             	mov    %edx,(%esp)
801009a4:	e8 c9 fe ff ff       	call   80100872 <shiftLeftBuf>
	    int i = input.e+input.a-1;
801009a9:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
801009af:	a1 60 de 10 80       	mov    0x8010de60,%eax
801009b4:	01 d0                	add    %edx,%eax
801009b6:	83 e8 01             	sub    $0x1,%eax
801009b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    consputc(KEY_LF);
801009bc:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
801009c3:	e8 13 fe ff ff       	call   801007db <consputc>
	    for(;i<input.e;i++){
801009c8:	eb 28                	jmp    801009f2 <consoleintr+0x12d>
	      consputc(input.buf[i%INPUT_BUF]);
801009ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801009cd:	89 c2                	mov    %eax,%edx
801009cf:	c1 fa 1f             	sar    $0x1f,%edx
801009d2:	c1 ea 19             	shr    $0x19,%edx
801009d5:	01 d0                	add    %edx,%eax
801009d7:	83 e0 7f             	and    $0x7f,%eax
801009da:	29 d0                	sub    %edx,%eax
801009dc:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
801009e3:	0f be c0             	movsbl %al,%eax
801009e6:	89 04 24             	mov    %eax,(%esp)
801009e9:	e8 ed fd ff ff       	call   801007db <consputc>
	if(input.a<0)
	{
	    shiftLeftBuf((input.e-1) % INPUT_BUF,input.a);
	    int i = input.e+input.a-1;
	    consputc(KEY_LF);
	    for(;i<input.e;i++){
801009ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801009f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801009f5:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801009fa:	39 c2                	cmp    %eax,%edx
801009fc:	72 cc                	jb     801009ca <consoleintr+0x105>
	      consputc(input.buf[i%INPUT_BUF]);
	    }
	    i = input.e+input.a;
801009fe:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100a04:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a09:	01 d0                	add    %edx,%eax
80100a0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    for(;i<input.e+1;i++){
80100a0e:	eb 10                	jmp    80100a20 <consoleintr+0x15b>
	      consputc(KEY_LF);
80100a10:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100a17:	e8 bf fd ff ff       	call   801007db <consputc>
	    consputc(KEY_LF);
	    for(;i<input.e;i++){
	      consputc(input.buf[i%INPUT_BUF]);
	    }
	    i = input.e+input.a;
	    for(;i<input.e+1;i++){
80100a1c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a23:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100a29:	83 c2 01             	add    $0x1,%edx
80100a2c:	39 d0                	cmp    %edx,%eax
80100a2e:	72 e0                	jb     80100a10 <consoleintr+0x14b>
80100a30:	eb 0c                	jmp    80100a3e <consoleintr+0x179>
	      consputc(KEY_LF);
	    }
	}
	else
	{
	  consputc(BACKSPACE);
80100a32:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100a39:	e8 9d fd ff ff       	call   801007db <consputc>
	}
	input.e--;
80100a3e:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100a43:	83 e8 01             	sub    $0x1,%eax
80100a46:	a3 5c de 10 80       	mov    %eax,0x8010de5c
      }
      break;
80100a4b:	e9 01 02 00 00       	jmp    80100c51 <consoleintr+0x38c>
    case KEY_LF: //LEFT KEY
     if(input.e % INPUT_BUF > 0 && input.e+input.a>0)
80100a50:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100a55:	83 e0 7f             	and    $0x7f,%eax
80100a58:	85 c0                	test   %eax,%eax
80100a5a:	0f 84 f4 01 00 00    	je     80100c54 <consoleintr+0x38f>
80100a60:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100a66:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a6b:	01 d0                	add    %edx,%eax
80100a6d:	85 c0                	test   %eax,%eax
80100a6f:	0f 84 df 01 00 00    	je     80100c54 <consoleintr+0x38f>
      {
        input.a--;
80100a75:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a7a:	83 e8 01             	sub    $0x1,%eax
80100a7d:	a3 60 de 10 80       	mov    %eax,0x8010de60
        consputc(KEY_LF);
80100a82:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100a89:	e8 4d fd ff ff       	call   801007db <consputc>
      }
      break;
80100a8e:	e9 c1 01 00 00       	jmp    80100c54 <consoleintr+0x38f>
    case KEY_RT: //RIGHT KEY
      if(input.a < 0 && input.e % INPUT_BUF < INPUT_BUF-1)
80100a93:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a98:	85 c0                	test   %eax,%eax
80100a9a:	0f 89 b7 01 00 00    	jns    80100c57 <consoleintr+0x392>
80100aa0:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100aa5:	83 e0 7f             	and    $0x7f,%eax
80100aa8:	83 f8 7e             	cmp    $0x7e,%eax
80100aab:	0f 87 a6 01 00 00    	ja     80100c57 <consoleintr+0x392>
      {
        input.a++;
80100ab1:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100ab6:	83 c0 01             	add    $0x1,%eax
80100ab9:	a3 60 de 10 80       	mov    %eax,0x8010de60
        consputc(KEY_RT);
80100abe:	c7 04 24 e5 00 00 00 	movl   $0xe5,(%esp)
80100ac5:	e8 11 fd ff ff       	call   801007db <consputc>
      }
      break;
80100aca:	e9 88 01 00 00       	jmp    80100c57 <consoleintr+0x392>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF)
80100acf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100ad3:	0f 84 81 01 00 00    	je     80100c5a <consoleintr+0x395>
80100ad9:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100adf:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100ae4:	89 d1                	mov    %edx,%ecx
80100ae6:	29 c1                	sub    %eax,%ecx
80100ae8:	89 c8                	mov    %ecx,%eax
80100aea:	83 f8 7f             	cmp    $0x7f,%eax
80100aed:	0f 87 67 01 00 00    	ja     80100c5a <consoleintr+0x395>
      {
	c = (c == '\r') ? '\n' : c;
80100af3:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
80100af7:	74 05                	je     80100afe <consoleintr+0x239>
80100af9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100afc:	eb 05                	jmp    80100b03 <consoleintr+0x23e>
80100afe:	b8 0a 00 00 00       	mov    $0xa,%eax
80100b03:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(c != '\n' && input.a < 0)
80100b06:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100b0a:	0f 84 d8 00 00 00    	je     80100be8 <consoleintr+0x323>
80100b10:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100b15:	85 c0                	test   %eax,%eax
80100b17:	0f 89 cb 00 00 00    	jns    80100be8 <consoleintr+0x323>
	{
	    int k = (-1)*input.a;
80100b1d:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100b22:	f7 d8                	neg    %eax
80100b24:	89 45 e8             	mov    %eax,-0x18(%ebp)
	    shiftRightBuf((input.e) % INPUT_BUF,k);
80100b27:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b2c:	89 c2                	mov    %eax,%edx
80100b2e:	83 e2 7f             	and    $0x7f,%edx
80100b31:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100b34:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b38:	89 14 24             	mov    %edx,(%esp)
80100b3b:	e8 f8 fc ff ff       	call   80100838 <shiftRightBuf>
	    input.buf[(input.e-k) % INPUT_BUF] = c;
80100b40:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100b46:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100b49:	89 d1                	mov    %edx,%ecx
80100b4b:	29 c1                	sub    %eax,%ecx
80100b4d:	89 c8                	mov    %ecx,%eax
80100b4f:	89 c2                	mov    %eax,%edx
80100b51:	83 e2 7f             	and    $0x7f,%edx
80100b54:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100b57:	88 82 d4 dd 10 80    	mov    %al,-0x7fef222c(%edx)
	    int i = input.e-k;
80100b5d:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100b63:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100b66:	89 d1                	mov    %edx,%ecx
80100b68:	29 c1                	sub    %eax,%ecx
80100b6a:	89 c8                	mov    %ecx,%eax
80100b6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    
	    for(;i<input.e+1;i++){
80100b6f:	eb 28                	jmp    80100b99 <consoleintr+0x2d4>
	      consputc(input.buf[i%INPUT_BUF]);
80100b71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100b74:	89 c2                	mov    %eax,%edx
80100b76:	c1 fa 1f             	sar    $0x1f,%edx
80100b79:	c1 ea 19             	shr    $0x19,%edx
80100b7c:	01 d0                	add    %edx,%eax
80100b7e:	83 e0 7f             	and    $0x7f,%eax
80100b81:	29 d0                	sub    %edx,%eax
80100b83:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
80100b8a:	0f be c0             	movsbl %al,%eax
80100b8d:	89 04 24             	mov    %eax,(%esp)
80100b90:	e8 46 fc ff ff       	call   801007db <consputc>
	    int k = (-1)*input.a;
	    shiftRightBuf((input.e) % INPUT_BUF,k);
	    input.buf[(input.e-k) % INPUT_BUF] = c;
	    int i = input.e-k;
	    
	    for(;i<input.e+1;i++){
80100b95:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100b9c:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100ba2:	83 c2 01             	add    $0x1,%edx
80100ba5:	39 d0                	cmp    %edx,%eax
80100ba7:	72 c8                	jb     80100b71 <consoleintr+0x2ac>
	      consputc(input.buf[i%INPUT_BUF]);
	    }
	    i = input.e-k;
80100ba9:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100baf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100bb2:	89 d1                	mov    %edx,%ecx
80100bb4:	29 c1                	sub    %eax,%ecx
80100bb6:	89 c8                	mov    %ecx,%eax
80100bb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    for(;i<input.e;i++){
80100bbb:	eb 10                	jmp    80100bcd <consoleintr+0x308>
	      consputc(KEY_LF);
80100bbd:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100bc4:	e8 12 fc ff ff       	call   801007db <consputc>
	    
	    for(;i<input.e+1;i++){
	      consputc(input.buf[i%INPUT_BUF]);
	    }
	    i = input.e-k;
	    for(;i<input.e;i++){
80100bc9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100bcd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100bd0:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100bd5:	39 c2                	cmp    %eax,%edx
80100bd7:	72 e4                	jb     80100bbd <consoleintr+0x2f8>
	      consputc(KEY_LF);
	    }
	    input.e++;
80100bd9:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100bde:	83 c0 01             	add    $0x1,%eax
80100be1:	a3 5c de 10 80       	mov    %eax,0x8010de5c
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF)
      {
	c = (c == '\r') ? '\n' : c;
	if(c != '\n' && input.a < 0)
	{
80100be6:	eb 26                	jmp    80100c0e <consoleintr+0x349>
	      consputc(KEY_LF);
	    }
	    input.e++;
	}
	else {
	  input.buf[input.e++ % INPUT_BUF] = c;
80100be8:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100bed:	89 c1                	mov    %eax,%ecx
80100bef:	83 e1 7f             	and    $0x7f,%ecx
80100bf2:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100bf5:	88 91 d4 dd 10 80    	mov    %dl,-0x7fef222c(%ecx)
80100bfb:	83 c0 01             	add    $0x1,%eax
80100bfe:	a3 5c de 10 80       	mov    %eax,0x8010de5c
          consputc(c);
80100c03:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100c06:	89 04 24             	mov    %eax,(%esp)
80100c09:	e8 cd fb ff ff       	call   801007db <consputc>
	}
	if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100c0e:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100c12:	74 18                	je     80100c2c <consoleintr+0x367>
80100c14:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80100c18:	74 12                	je     80100c2c <consoleintr+0x367>
80100c1a:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100c1f:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
80100c25:	83 ea 80             	sub    $0xffffff80,%edx
80100c28:	39 d0                	cmp    %edx,%eax
80100c2a:	75 2e                	jne    80100c5a <consoleintr+0x395>
          input.a = 0;
80100c2c:	c7 05 60 de 10 80 00 	movl   $0x0,0x8010de60
80100c33:	00 00 00 
	  input.w = input.e;
80100c36:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100c3b:	a3 58 de 10 80       	mov    %eax,0x8010de58
          wakeup(&input.r);
80100c40:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100c47:	e8 16 43 00 00       	call   80104f62 <wakeup>
        }
      }
      break;
80100c4c:	eb 0c                	jmp    80100c5a <consoleintr+0x395>
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100c4e:	90                   	nop
80100c4f:	eb 0a                	jmp    80100c5b <consoleintr+0x396>
	{
	  consputc(BACKSPACE);
	}
	input.e--;
      }
      break;
80100c51:	90                   	nop
80100c52:	eb 07                	jmp    80100c5b <consoleintr+0x396>
     if(input.e % INPUT_BUF > 0 && input.e+input.a>0)
      {
        input.a--;
        consputc(KEY_LF);
      }
      break;
80100c54:	90                   	nop
80100c55:	eb 04                	jmp    80100c5b <consoleintr+0x396>
      if(input.a < 0 && input.e % INPUT_BUF < INPUT_BUF-1)
      {
        input.a++;
        consputc(KEY_RT);
      }
      break;
80100c57:	90                   	nop
80100c58:	eb 01                	jmp    80100c5b <consoleintr+0x396>
          input.a = 0;
	  input.w = input.e;
          wakeup(&input.r);
        }
      }
      break;
80100c5a:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100c5b:	8b 45 08             	mov    0x8(%ebp),%eax
80100c5e:	ff d0                	call   *%eax
80100c60:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100c63:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100c67:	0f 89 6f fc ff ff    	jns    801008dc <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100c6d:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100c74:	e8 d8 45 00 00       	call   80105251 <release>
}
80100c79:	c9                   	leave  
80100c7a:	c3                   	ret    

80100c7b <consoleread>:


int
consoleread(struct inode *ip, char *dst, int n)
{
80100c7b:	55                   	push   %ebp
80100c7c:	89 e5                	mov    %esp,%ebp
80100c7e:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100c81:	8b 45 08             	mov    0x8(%ebp),%eax
80100c84:	89 04 24             	mov    %eax,(%esp)
80100c87:	e8 82 10 00 00       	call   80101d0e <iunlock>
  target = n;
80100c8c:	8b 45 10             	mov    0x10(%ebp),%eax
80100c8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100c92:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100c99:	e8 51 45 00 00       	call   801051ef <acquire>
  while(n > 0){
80100c9e:	e9 a8 00 00 00       	jmp    80100d4b <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
80100ca3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ca9:	8b 40 24             	mov    0x24(%eax),%eax
80100cac:	85 c0                	test   %eax,%eax
80100cae:	74 21                	je     80100cd1 <consoleread+0x56>
        release(&input.lock);
80100cb0:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100cb7:	e8 95 45 00 00       	call   80105251 <release>
        ilock(ip);
80100cbc:	8b 45 08             	mov    0x8(%ebp),%eax
80100cbf:	89 04 24             	mov    %eax,(%esp)
80100cc2:	e8 f9 0e 00 00       	call   80101bc0 <ilock>
        return -1;
80100cc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ccc:	e9 a9 00 00 00       	jmp    80100d7a <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
80100cd1:	c7 44 24 04 a0 dd 10 	movl   $0x8010dda0,0x4(%esp)
80100cd8:	80 
80100cd9:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100ce0:	e8 a1 41 00 00       	call   80104e86 <sleep>
80100ce5:	eb 01                	jmp    80100ce8 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100ce7:	90                   	nop
80100ce8:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
80100cee:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100cf3:	39 c2                	cmp    %eax,%edx
80100cf5:	74 ac                	je     80100ca3 <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100cf7:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100cfc:	89 c2                	mov    %eax,%edx
80100cfe:	83 e2 7f             	and    $0x7f,%edx
80100d01:	0f b6 92 d4 dd 10 80 	movzbl -0x7fef222c(%edx),%edx
80100d08:	0f be d2             	movsbl %dl,%edx
80100d0b:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100d0e:	83 c0 01             	add    $0x1,%eax
80100d11:	a3 54 de 10 80       	mov    %eax,0x8010de54
    if(c == C('D')){  // EOF
80100d16:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100d1a:	75 17                	jne    80100d33 <consoleread+0xb8>
      if(n < target){
80100d1c:	8b 45 10             	mov    0x10(%ebp),%eax
80100d1f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100d22:	73 2f                	jae    80100d53 <consoleread+0xd8>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100d24:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100d29:	83 e8 01             	sub    $0x1,%eax
80100d2c:	a3 54 de 10 80       	mov    %eax,0x8010de54
      }
      break;
80100d31:	eb 20                	jmp    80100d53 <consoleread+0xd8>
    }
    *dst++ = c;
80100d33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100d36:	89 c2                	mov    %eax,%edx
80100d38:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d3b:	88 10                	mov    %dl,(%eax)
80100d3d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    --n;
80100d41:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100d45:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100d49:	74 0b                	je     80100d56 <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100d4b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100d4f:	7f 96                	jg     80100ce7 <consoleread+0x6c>
80100d51:	eb 04                	jmp    80100d57 <consoleread+0xdc>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100d53:	90                   	nop
80100d54:	eb 01                	jmp    80100d57 <consoleread+0xdc>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100d56:	90                   	nop
  }
  release(&input.lock);
80100d57:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100d5e:	e8 ee 44 00 00       	call   80105251 <release>
  ilock(ip);
80100d63:	8b 45 08             	mov    0x8(%ebp),%eax
80100d66:	89 04 24             	mov    %eax,(%esp)
80100d69:	e8 52 0e 00 00       	call   80101bc0 <ilock>

  return target - n;
80100d6e:	8b 45 10             	mov    0x10(%ebp),%eax
80100d71:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100d74:	89 d1                	mov    %edx,%ecx
80100d76:	29 c1                	sub    %eax,%ecx
80100d78:	89 c8                	mov    %ecx,%eax
}
80100d7a:	c9                   	leave  
80100d7b:	c3                   	ret    

80100d7c <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100d7c:	55                   	push   %ebp
80100d7d:	89 e5                	mov    %esp,%ebp
80100d7f:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100d82:	8b 45 08             	mov    0x8(%ebp),%eax
80100d85:	89 04 24             	mov    %eax,(%esp)
80100d88:	e8 81 0f 00 00       	call   80101d0e <iunlock>
  acquire(&cons.lock);
80100d8d:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100d94:	e8 56 44 00 00       	call   801051ef <acquire>
  for(i = 0; i < n; i++)
80100d99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100da0:	eb 1d                	jmp    80100dbf <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100da5:	03 45 0c             	add    0xc(%ebp),%eax
80100da8:	0f b6 00             	movzbl (%eax),%eax
80100dab:	0f be c0             	movsbl %al,%eax
80100dae:	25 ff 00 00 00       	and    $0xff,%eax
80100db3:	89 04 24             	mov    %eax,(%esp)
80100db6:	e8 20 fa ff ff       	call   801007db <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100dbb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100dc2:	3b 45 10             	cmp    0x10(%ebp),%eax
80100dc5:	7c db                	jl     80100da2 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100dc7:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100dce:	e8 7e 44 00 00       	call   80105251 <release>
  ilock(ip);
80100dd3:	8b 45 08             	mov    0x8(%ebp),%eax
80100dd6:	89 04 24             	mov    %eax,(%esp)
80100dd9:	e8 e2 0d 00 00       	call   80101bc0 <ilock>

  return n;
80100dde:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100de1:	c9                   	leave  
80100de2:	c3                   	ret    

80100de3 <consoleinit>:

void
consoleinit(void)
{
80100de3:	55                   	push   %ebp
80100de4:	89 e5                	mov    %esp,%ebp
80100de6:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100de9:	c7 44 24 04 e7 88 10 	movl   $0x801088e7,0x4(%esp)
80100df0:	80 
80100df1:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100df8:	e8 d1 43 00 00       	call   801051ce <initlock>
  initlock(&input.lock, "input");
80100dfd:	c7 44 24 04 ef 88 10 	movl   $0x801088ef,0x4(%esp)
80100e04:	80 
80100e05:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100e0c:	e8 bd 43 00 00       	call   801051ce <initlock>

  devsw[CONSOLE].write = consolewrite;
80100e11:	c7 05 2c e8 10 80 7c 	movl   $0x80100d7c,0x8010e82c
80100e18:	0d 10 80 
  devsw[CONSOLE].read = consoleread;
80100e1b:	c7 05 28 e8 10 80 7b 	movl   $0x80100c7b,0x8010e828
80100e22:	0c 10 80 
  cons.locking = 1;
80100e25:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100e2c:	00 00 00 

  picenable(IRQ_KBD);
80100e2f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100e36:	e8 de 2f 00 00       	call   80103e19 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100e3b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100e42:	00 
80100e43:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100e4a:	e8 7f 1e 00 00       	call   80102cce <ioapicenable>
}
80100e4f:	c9                   	leave  
80100e50:	c3                   	ret    
80100e51:	00 00                	add    %al,(%eax)
	...

80100e54 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100e54:	55                   	push   %ebp
80100e55:	89 e5                	mov    %esp,%ebp
80100e57:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100e5d:	8b 45 08             	mov    0x8(%ebp),%eax
80100e60:	89 04 24             	mov    %eax,(%esp)
80100e63:	e8 fa 18 00 00       	call   80102762 <namei>
80100e68:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100e6b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100e6f:	75 0a                	jne    80100e7b <exec+0x27>
    return -1;
80100e71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100e76:	e9 da 03 00 00       	jmp    80101255 <exec+0x401>
  ilock(ip);
80100e7b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e7e:	89 04 24             	mov    %eax,(%esp)
80100e81:	e8 3a 0d 00 00       	call   80101bc0 <ilock>
  pgdir = 0;
80100e86:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100e8d:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100e94:	00 
80100e95:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100e9c:	00 
80100e9d:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100ea3:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ea7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100eaa:	89 04 24             	mov    %eax,(%esp)
80100ead:	e8 04 12 00 00       	call   801020b6 <readi>
80100eb2:	83 f8 33             	cmp    $0x33,%eax
80100eb5:	0f 86 54 03 00 00    	jbe    8010120f <exec+0x3bb>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100ebb:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100ec1:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100ec6:	0f 85 46 03 00 00    	jne    80101212 <exec+0x3be>
    goto bad;

  if((pgdir = setupkvm(kalloc)) == 0)
80100ecc:	c7 04 24 57 2e 10 80 	movl   $0x80102e57,(%esp)
80100ed3:	e8 6d 71 00 00       	call   80108045 <setupkvm>
80100ed8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100edb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100edf:	0f 84 30 03 00 00    	je     80101215 <exec+0x3c1>
    goto bad;

  // Load program into memory.
  sz = 0;
80100ee5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100eec:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100ef3:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100ef9:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100efc:	e9 c5 00 00 00       	jmp    80100fc6 <exec+0x172>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100f01:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100f04:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100f0b:	00 
80100f0c:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f10:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100f16:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f1a:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f1d:	89 04 24             	mov    %eax,(%esp)
80100f20:	e8 91 11 00 00       	call   801020b6 <readi>
80100f25:	83 f8 20             	cmp    $0x20,%eax
80100f28:	0f 85 ea 02 00 00    	jne    80101218 <exec+0x3c4>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100f2e:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100f34:	83 f8 01             	cmp    $0x1,%eax
80100f37:	75 7f                	jne    80100fb8 <exec+0x164>
      continue;
    if(ph.memsz < ph.filesz)
80100f39:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100f3f:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100f45:	39 c2                	cmp    %eax,%edx
80100f47:	0f 82 ce 02 00 00    	jb     8010121b <exec+0x3c7>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100f4d:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100f53:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100f59:	01 d0                	add    %edx,%eax
80100f5b:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f62:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f66:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f69:	89 04 24             	mov    %eax,(%esp)
80100f6c:	e8 a6 74 00 00       	call   80108417 <allocuvm>
80100f71:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100f74:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100f78:	0f 84 a0 02 00 00    	je     8010121e <exec+0x3ca>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100f7e:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100f84:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100f8a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100f90:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100f94:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100f98:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100f9b:	89 54 24 08          	mov    %edx,0x8(%esp)
80100f9f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100fa3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100fa6:	89 04 24             	mov    %eax,(%esp)
80100fa9:	e8 7a 73 00 00       	call   80108328 <loaduvm>
80100fae:	85 c0                	test   %eax,%eax
80100fb0:	0f 88 6b 02 00 00    	js     80101221 <exec+0x3cd>
80100fb6:	eb 01                	jmp    80100fb9 <exec+0x165>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100fb8:	90                   	nop
  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100fb9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100fbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100fc0:	83 c0 20             	add    $0x20,%eax
80100fc3:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100fc6:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100fcd:	0f b7 c0             	movzwl %ax,%eax
80100fd0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100fd3:	0f 8f 28 ff ff ff    	jg     80100f01 <exec+0xad>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100fd9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100fdc:	89 04 24             	mov    %eax,(%esp)
80100fdf:	e8 60 0e 00 00       	call   80101e44 <iunlockput>
  ip = 0;
80100fe4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100feb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fee:	05 ff 0f 00 00       	add    $0xfff,%eax
80100ff3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ff8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100ffb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ffe:	05 00 20 00 00       	add    $0x2000,%eax
80101003:	89 44 24 08          	mov    %eax,0x8(%esp)
80101007:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010100a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010100e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101011:	89 04 24             	mov    %eax,(%esp)
80101014:	e8 fe 73 00 00       	call   80108417 <allocuvm>
80101019:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010101c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101020:	0f 84 fe 01 00 00    	je     80101224 <exec+0x3d0>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80101026:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101029:	2d 00 20 00 00       	sub    $0x2000,%eax
8010102e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101032:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101035:	89 04 24             	mov    %eax,(%esp)
80101038:	e8 fe 75 00 00       	call   8010863b <clearpteu>
  sp = sz;
8010103d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101040:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80101043:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010104a:	e9 81 00 00 00       	jmp    801010d0 <exec+0x27c>
    if(argc >= MAXARG)
8010104f:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80101053:	0f 87 ce 01 00 00    	ja     80101227 <exec+0x3d3>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80101059:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010105c:	c1 e0 02             	shl    $0x2,%eax
8010105f:	03 45 0c             	add    0xc(%ebp),%eax
80101062:	8b 00                	mov    (%eax),%eax
80101064:	89 04 24             	mov    %eax,(%esp)
80101067:	e8 50 46 00 00       	call   801056bc <strlen>
8010106c:	f7 d0                	not    %eax
8010106e:	03 45 dc             	add    -0x24(%ebp),%eax
80101071:	83 e0 fc             	and    $0xfffffffc,%eax
80101074:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80101077:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010107a:	c1 e0 02             	shl    $0x2,%eax
8010107d:	03 45 0c             	add    0xc(%ebp),%eax
80101080:	8b 00                	mov    (%eax),%eax
80101082:	89 04 24             	mov    %eax,(%esp)
80101085:	e8 32 46 00 00       	call   801056bc <strlen>
8010108a:	83 c0 01             	add    $0x1,%eax
8010108d:	89 c2                	mov    %eax,%edx
8010108f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101092:	c1 e0 02             	shl    $0x2,%eax
80101095:	03 45 0c             	add    0xc(%ebp),%eax
80101098:	8b 00                	mov    (%eax),%eax
8010109a:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010109e:	89 44 24 08          	mov    %eax,0x8(%esp)
801010a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801010a9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801010ac:	89 04 24             	mov    %eax,(%esp)
801010af:	e8 3b 77 00 00       	call   801087ef <copyout>
801010b4:	85 c0                	test   %eax,%eax
801010b6:	0f 88 6e 01 00 00    	js     8010122a <exec+0x3d6>
      goto bad;
    ustack[3+argc] = sp;
801010bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010bf:	8d 50 03             	lea    0x3(%eax),%edx
801010c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010c5:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
801010cc:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801010d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010d3:	c1 e0 02             	shl    $0x2,%eax
801010d6:	03 45 0c             	add    0xc(%ebp),%eax
801010d9:	8b 00                	mov    (%eax),%eax
801010db:	85 c0                	test   %eax,%eax
801010dd:	0f 85 6c ff ff ff    	jne    8010104f <exec+0x1fb>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
801010e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010e6:	83 c0 03             	add    $0x3,%eax
801010e9:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
801010f0:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
801010f4:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
801010fb:	ff ff ff 
  ustack[1] = argc;
801010fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101101:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80101107:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010110a:	83 c0 01             	add    $0x1,%eax
8010110d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101114:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101117:	29 d0                	sub    %edx,%eax
80101119:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
8010111f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101122:	83 c0 04             	add    $0x4,%eax
80101125:	c1 e0 02             	shl    $0x2,%eax
80101128:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
8010112b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010112e:	83 c0 04             	add    $0x4,%eax
80101131:	c1 e0 02             	shl    $0x2,%eax
80101134:	89 44 24 0c          	mov    %eax,0xc(%esp)
80101138:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
8010113e:	89 44 24 08          	mov    %eax,0x8(%esp)
80101142:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101145:	89 44 24 04          	mov    %eax,0x4(%esp)
80101149:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010114c:	89 04 24             	mov    %eax,(%esp)
8010114f:	e8 9b 76 00 00       	call   801087ef <copyout>
80101154:	85 c0                	test   %eax,%eax
80101156:	0f 88 d1 00 00 00    	js     8010122d <exec+0x3d9>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
8010115c:	8b 45 08             	mov    0x8(%ebp),%eax
8010115f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101165:	89 45 f0             	mov    %eax,-0x10(%ebp)
80101168:	eb 17                	jmp    80101181 <exec+0x32d>
    if(*s == '/')
8010116a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010116d:	0f b6 00             	movzbl (%eax),%eax
80101170:	3c 2f                	cmp    $0x2f,%al
80101172:	75 09                	jne    8010117d <exec+0x329>
      last = s+1;
80101174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101177:	83 c0 01             	add    $0x1,%eax
8010117a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
8010117d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101184:	0f b6 00             	movzbl (%eax),%eax
80101187:	84 c0                	test   %al,%al
80101189:	75 df                	jne    8010116a <exec+0x316>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
8010118b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101191:	8d 50 6c             	lea    0x6c(%eax),%edx
80101194:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010119b:	00 
8010119c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010119f:	89 44 24 04          	mov    %eax,0x4(%esp)
801011a3:	89 14 24             	mov    %edx,(%esp)
801011a6:	e8 c3 44 00 00       	call   8010566e <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
801011ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011b1:	8b 40 04             	mov    0x4(%eax),%eax
801011b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
801011b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011bd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801011c0:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
801011c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011c9:	8b 55 e0             	mov    -0x20(%ebp),%edx
801011cc:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
801011ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011d4:	8b 40 18             	mov    0x18(%eax),%eax
801011d7:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
801011dd:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
801011e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011e6:	8b 40 18             	mov    0x18(%eax),%eax
801011e9:	8b 55 dc             	mov    -0x24(%ebp),%edx
801011ec:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
801011ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011f5:	89 04 24             	mov    %eax,(%esp)
801011f8:	e8 39 6f 00 00       	call   80108136 <switchuvm>
  freevm(oldpgdir);
801011fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101200:	89 04 24             	mov    %eax,(%esp)
80101203:	e8 a5 73 00 00       	call   801085ad <freevm>
  return 0;
80101208:	b8 00 00 00 00       	mov    $0x0,%eax
8010120d:	eb 46                	jmp    80101255 <exec+0x401>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
8010120f:	90                   	nop
80101210:	eb 1c                	jmp    8010122e <exec+0x3da>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80101212:	90                   	nop
80101213:	eb 19                	jmp    8010122e <exec+0x3da>

  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;
80101215:	90                   	nop
80101216:	eb 16                	jmp    8010122e <exec+0x3da>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80101218:	90                   	nop
80101219:	eb 13                	jmp    8010122e <exec+0x3da>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
8010121b:	90                   	nop
8010121c:	eb 10                	jmp    8010122e <exec+0x3da>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
8010121e:	90                   	nop
8010121f:	eb 0d                	jmp    8010122e <exec+0x3da>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80101221:	90                   	nop
80101222:	eb 0a                	jmp    8010122e <exec+0x3da>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80101224:	90                   	nop
80101225:	eb 07                	jmp    8010122e <exec+0x3da>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80101227:	90                   	nop
80101228:	eb 04                	jmp    8010122e <exec+0x3da>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
8010122a:	90                   	nop
8010122b:	eb 01                	jmp    8010122e <exec+0x3da>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
8010122d:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
8010122e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101232:	74 0b                	je     8010123f <exec+0x3eb>
    freevm(pgdir);
80101234:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101237:	89 04 24             	mov    %eax,(%esp)
8010123a:	e8 6e 73 00 00       	call   801085ad <freevm>
  if(ip)
8010123f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101243:	74 0b                	je     80101250 <exec+0x3fc>
    iunlockput(ip);
80101245:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101248:	89 04 24             	mov    %eax,(%esp)
8010124b:	e8 f4 0b 00 00       	call   80101e44 <iunlockput>
  return -1;
80101250:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101255:	c9                   	leave  
80101256:	c3                   	ret    
	...

80101258 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101258:	55                   	push   %ebp
80101259:	89 e5                	mov    %esp,%ebp
8010125b:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
8010125e:	c7 44 24 04 f5 88 10 	movl   $0x801088f5,0x4(%esp)
80101265:	80 
80101266:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
8010126d:	e8 5c 3f 00 00       	call   801051ce <initlock>
}
80101272:	c9                   	leave  
80101273:	c3                   	ret    

80101274 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101274:	55                   	push   %ebp
80101275:	89 e5                	mov    %esp,%ebp
80101277:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
8010127a:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101281:	e8 69 3f 00 00       	call   801051ef <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101286:	c7 45 f4 b4 de 10 80 	movl   $0x8010deb4,-0xc(%ebp)
8010128d:	eb 29                	jmp    801012b8 <filealloc+0x44>
    if(f->ref == 0){
8010128f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101292:	8b 40 04             	mov    0x4(%eax),%eax
80101295:	85 c0                	test   %eax,%eax
80101297:	75 1b                	jne    801012b4 <filealloc+0x40>
      f->ref = 1;
80101299:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010129c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
801012a3:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012aa:	e8 a2 3f 00 00       	call   80105251 <release>
      return f;
801012af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012b2:	eb 1e                	jmp    801012d2 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801012b4:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801012b8:	81 7d f4 14 e8 10 80 	cmpl   $0x8010e814,-0xc(%ebp)
801012bf:	72 ce                	jb     8010128f <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
801012c1:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012c8:	e8 84 3f 00 00       	call   80105251 <release>
  return 0;
801012cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801012d2:	c9                   	leave  
801012d3:	c3                   	ret    

801012d4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801012d4:	55                   	push   %ebp
801012d5:	89 e5                	mov    %esp,%ebp
801012d7:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
801012da:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012e1:	e8 09 3f 00 00       	call   801051ef <acquire>
  if(f->ref < 1)
801012e6:	8b 45 08             	mov    0x8(%ebp),%eax
801012e9:	8b 40 04             	mov    0x4(%eax),%eax
801012ec:	85 c0                	test   %eax,%eax
801012ee:	7f 0c                	jg     801012fc <filedup+0x28>
    panic("filedup");
801012f0:	c7 04 24 fc 88 10 80 	movl   $0x801088fc,(%esp)
801012f7:	e8 41 f2 ff ff       	call   8010053d <panic>
  f->ref++;
801012fc:	8b 45 08             	mov    0x8(%ebp),%eax
801012ff:	8b 40 04             	mov    0x4(%eax),%eax
80101302:	8d 50 01             	lea    0x1(%eax),%edx
80101305:	8b 45 08             	mov    0x8(%ebp),%eax
80101308:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010130b:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101312:	e8 3a 3f 00 00       	call   80105251 <release>
  return f;
80101317:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010131a:	c9                   	leave  
8010131b:	c3                   	ret    

8010131c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010131c:	55                   	push   %ebp
8010131d:	89 e5                	mov    %esp,%ebp
8010131f:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80101322:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101329:	e8 c1 3e 00 00       	call   801051ef <acquire>
  if(f->ref < 1)
8010132e:	8b 45 08             	mov    0x8(%ebp),%eax
80101331:	8b 40 04             	mov    0x4(%eax),%eax
80101334:	85 c0                	test   %eax,%eax
80101336:	7f 0c                	jg     80101344 <fileclose+0x28>
    panic("fileclose");
80101338:	c7 04 24 04 89 10 80 	movl   $0x80108904,(%esp)
8010133f:	e8 f9 f1 ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
80101344:	8b 45 08             	mov    0x8(%ebp),%eax
80101347:	8b 40 04             	mov    0x4(%eax),%eax
8010134a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010134d:	8b 45 08             	mov    0x8(%ebp),%eax
80101350:	89 50 04             	mov    %edx,0x4(%eax)
80101353:	8b 45 08             	mov    0x8(%ebp),%eax
80101356:	8b 40 04             	mov    0x4(%eax),%eax
80101359:	85 c0                	test   %eax,%eax
8010135b:	7e 11                	jle    8010136e <fileclose+0x52>
    release(&ftable.lock);
8010135d:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101364:	e8 e8 3e 00 00       	call   80105251 <release>
    return;
80101369:	e9 82 00 00 00       	jmp    801013f0 <fileclose+0xd4>
  }
  ff = *f;
8010136e:	8b 45 08             	mov    0x8(%ebp),%eax
80101371:	8b 10                	mov    (%eax),%edx
80101373:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101376:	8b 50 04             	mov    0x4(%eax),%edx
80101379:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010137c:	8b 50 08             	mov    0x8(%eax),%edx
8010137f:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101382:	8b 50 0c             	mov    0xc(%eax),%edx
80101385:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101388:	8b 50 10             	mov    0x10(%eax),%edx
8010138b:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010138e:	8b 40 14             	mov    0x14(%eax),%eax
80101391:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101394:	8b 45 08             	mov    0x8(%ebp),%eax
80101397:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010139e:	8b 45 08             	mov    0x8(%ebp),%eax
801013a1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801013a7:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801013ae:	e8 9e 3e 00 00       	call   80105251 <release>
  
  if(ff.type == FD_PIPE)
801013b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013b6:	83 f8 01             	cmp    $0x1,%eax
801013b9:	75 18                	jne    801013d3 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
801013bb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801013bf:	0f be d0             	movsbl %al,%edx
801013c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013c5:	89 54 24 04          	mov    %edx,0x4(%esp)
801013c9:	89 04 24             	mov    %eax,(%esp)
801013cc:	e8 02 2d 00 00       	call   801040d3 <pipeclose>
801013d1:	eb 1d                	jmp    801013f0 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801013d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013d6:	83 f8 02             	cmp    $0x2,%eax
801013d9:	75 15                	jne    801013f0 <fileclose+0xd4>
    begin_trans();
801013db:	e8 95 21 00 00       	call   80103575 <begin_trans>
    iput(ff.ip);
801013e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013e3:	89 04 24             	mov    %eax,(%esp)
801013e6:	e8 88 09 00 00       	call   80101d73 <iput>
    commit_trans();
801013eb:	e8 ce 21 00 00       	call   801035be <commit_trans>
  }
}
801013f0:	c9                   	leave  
801013f1:	c3                   	ret    

801013f2 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801013f2:	55                   	push   %ebp
801013f3:	89 e5                	mov    %esp,%ebp
801013f5:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801013f8:	8b 45 08             	mov    0x8(%ebp),%eax
801013fb:	8b 00                	mov    (%eax),%eax
801013fd:	83 f8 02             	cmp    $0x2,%eax
80101400:	75 38                	jne    8010143a <filestat+0x48>
    ilock(f->ip);
80101402:	8b 45 08             	mov    0x8(%ebp),%eax
80101405:	8b 40 10             	mov    0x10(%eax),%eax
80101408:	89 04 24             	mov    %eax,(%esp)
8010140b:	e8 b0 07 00 00       	call   80101bc0 <ilock>
    stati(f->ip, st);
80101410:	8b 45 08             	mov    0x8(%ebp),%eax
80101413:	8b 40 10             	mov    0x10(%eax),%eax
80101416:	8b 55 0c             	mov    0xc(%ebp),%edx
80101419:	89 54 24 04          	mov    %edx,0x4(%esp)
8010141d:	89 04 24             	mov    %eax,(%esp)
80101420:	e8 4c 0c 00 00       	call   80102071 <stati>
    iunlock(f->ip);
80101425:	8b 45 08             	mov    0x8(%ebp),%eax
80101428:	8b 40 10             	mov    0x10(%eax),%eax
8010142b:	89 04 24             	mov    %eax,(%esp)
8010142e:	e8 db 08 00 00       	call   80101d0e <iunlock>
    return 0;
80101433:	b8 00 00 00 00       	mov    $0x0,%eax
80101438:	eb 05                	jmp    8010143f <filestat+0x4d>
  }
  return -1;
8010143a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010143f:	c9                   	leave  
80101440:	c3                   	ret    

80101441 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101441:	55                   	push   %ebp
80101442:	89 e5                	mov    %esp,%ebp
80101444:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101447:	8b 45 08             	mov    0x8(%ebp),%eax
8010144a:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010144e:	84 c0                	test   %al,%al
80101450:	75 0a                	jne    8010145c <fileread+0x1b>
    return -1;
80101452:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101457:	e9 9f 00 00 00       	jmp    801014fb <fileread+0xba>
  if(f->type == FD_PIPE)
8010145c:	8b 45 08             	mov    0x8(%ebp),%eax
8010145f:	8b 00                	mov    (%eax),%eax
80101461:	83 f8 01             	cmp    $0x1,%eax
80101464:	75 1e                	jne    80101484 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101466:	8b 45 08             	mov    0x8(%ebp),%eax
80101469:	8b 40 0c             	mov    0xc(%eax),%eax
8010146c:	8b 55 10             	mov    0x10(%ebp),%edx
8010146f:	89 54 24 08          	mov    %edx,0x8(%esp)
80101473:	8b 55 0c             	mov    0xc(%ebp),%edx
80101476:	89 54 24 04          	mov    %edx,0x4(%esp)
8010147a:	89 04 24             	mov    %eax,(%esp)
8010147d:	e8 d3 2d 00 00       	call   80104255 <piperead>
80101482:	eb 77                	jmp    801014fb <fileread+0xba>
  if(f->type == FD_INODE){
80101484:	8b 45 08             	mov    0x8(%ebp),%eax
80101487:	8b 00                	mov    (%eax),%eax
80101489:	83 f8 02             	cmp    $0x2,%eax
8010148c:	75 61                	jne    801014ef <fileread+0xae>
    ilock(f->ip);
8010148e:	8b 45 08             	mov    0x8(%ebp),%eax
80101491:	8b 40 10             	mov    0x10(%eax),%eax
80101494:	89 04 24             	mov    %eax,(%esp)
80101497:	e8 24 07 00 00       	call   80101bc0 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010149c:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010149f:	8b 45 08             	mov    0x8(%ebp),%eax
801014a2:	8b 50 14             	mov    0x14(%eax),%edx
801014a5:	8b 45 08             	mov    0x8(%ebp),%eax
801014a8:	8b 40 10             	mov    0x10(%eax),%eax
801014ab:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801014af:	89 54 24 08          	mov    %edx,0x8(%esp)
801014b3:	8b 55 0c             	mov    0xc(%ebp),%edx
801014b6:	89 54 24 04          	mov    %edx,0x4(%esp)
801014ba:	89 04 24             	mov    %eax,(%esp)
801014bd:	e8 f4 0b 00 00       	call   801020b6 <readi>
801014c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801014c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801014c9:	7e 11                	jle    801014dc <fileread+0x9b>
      f->off += r;
801014cb:	8b 45 08             	mov    0x8(%ebp),%eax
801014ce:	8b 50 14             	mov    0x14(%eax),%edx
801014d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014d4:	01 c2                	add    %eax,%edx
801014d6:	8b 45 08             	mov    0x8(%ebp),%eax
801014d9:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801014dc:	8b 45 08             	mov    0x8(%ebp),%eax
801014df:	8b 40 10             	mov    0x10(%eax),%eax
801014e2:	89 04 24             	mov    %eax,(%esp)
801014e5:	e8 24 08 00 00       	call   80101d0e <iunlock>
    return r;
801014ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ed:	eb 0c                	jmp    801014fb <fileread+0xba>
  }
  panic("fileread");
801014ef:	c7 04 24 0e 89 10 80 	movl   $0x8010890e,(%esp)
801014f6:	e8 42 f0 ff ff       	call   8010053d <panic>
}
801014fb:	c9                   	leave  
801014fc:	c3                   	ret    

801014fd <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801014fd:	55                   	push   %ebp
801014fe:	89 e5                	mov    %esp,%ebp
80101500:	53                   	push   %ebx
80101501:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
80101504:	8b 45 08             	mov    0x8(%ebp),%eax
80101507:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010150b:	84 c0                	test   %al,%al
8010150d:	75 0a                	jne    80101519 <filewrite+0x1c>
    return -1;
8010150f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101514:	e9 23 01 00 00       	jmp    8010163c <filewrite+0x13f>
  if(f->type == FD_PIPE)
80101519:	8b 45 08             	mov    0x8(%ebp),%eax
8010151c:	8b 00                	mov    (%eax),%eax
8010151e:	83 f8 01             	cmp    $0x1,%eax
80101521:	75 21                	jne    80101544 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101523:	8b 45 08             	mov    0x8(%ebp),%eax
80101526:	8b 40 0c             	mov    0xc(%eax),%eax
80101529:	8b 55 10             	mov    0x10(%ebp),%edx
8010152c:	89 54 24 08          	mov    %edx,0x8(%esp)
80101530:	8b 55 0c             	mov    0xc(%ebp),%edx
80101533:	89 54 24 04          	mov    %edx,0x4(%esp)
80101537:	89 04 24             	mov    %eax,(%esp)
8010153a:	e8 26 2c 00 00       	call   80104165 <pipewrite>
8010153f:	e9 f8 00 00 00       	jmp    8010163c <filewrite+0x13f>
  if(f->type == FD_INODE){
80101544:	8b 45 08             	mov    0x8(%ebp),%eax
80101547:	8b 00                	mov    (%eax),%eax
80101549:	83 f8 02             	cmp    $0x2,%eax
8010154c:	0f 85 de 00 00 00    	jne    80101630 <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101552:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101559:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101560:	e9 a8 00 00 00       	jmp    8010160d <filewrite+0x110>
      int n1 = n - i;
80101565:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101568:	8b 55 10             	mov    0x10(%ebp),%edx
8010156b:	89 d1                	mov    %edx,%ecx
8010156d:	29 c1                	sub    %eax,%ecx
8010156f:	89 c8                	mov    %ecx,%eax
80101571:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101574:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101577:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010157a:	7e 06                	jle    80101582 <filewrite+0x85>
        n1 = max;
8010157c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010157f:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
80101582:	e8 ee 1f 00 00       	call   80103575 <begin_trans>
      ilock(f->ip);
80101587:	8b 45 08             	mov    0x8(%ebp),%eax
8010158a:	8b 40 10             	mov    0x10(%eax),%eax
8010158d:	89 04 24             	mov    %eax,(%esp)
80101590:	e8 2b 06 00 00       	call   80101bc0 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101595:	8b 5d f0             	mov    -0x10(%ebp),%ebx
80101598:	8b 45 08             	mov    0x8(%ebp),%eax
8010159b:	8b 48 14             	mov    0x14(%eax),%ecx
8010159e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a1:	89 c2                	mov    %eax,%edx
801015a3:	03 55 0c             	add    0xc(%ebp),%edx
801015a6:	8b 45 08             	mov    0x8(%ebp),%eax
801015a9:	8b 40 10             	mov    0x10(%eax),%eax
801015ac:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
801015b0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801015b4:	89 54 24 04          	mov    %edx,0x4(%esp)
801015b8:	89 04 24             	mov    %eax,(%esp)
801015bb:	e8 61 0c 00 00       	call   80102221 <writei>
801015c0:	89 45 e8             	mov    %eax,-0x18(%ebp)
801015c3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801015c7:	7e 11                	jle    801015da <filewrite+0xdd>
        f->off += r;
801015c9:	8b 45 08             	mov    0x8(%ebp),%eax
801015cc:	8b 50 14             	mov    0x14(%eax),%edx
801015cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801015d2:	01 c2                	add    %eax,%edx
801015d4:	8b 45 08             	mov    0x8(%ebp),%eax
801015d7:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801015da:	8b 45 08             	mov    0x8(%ebp),%eax
801015dd:	8b 40 10             	mov    0x10(%eax),%eax
801015e0:	89 04 24             	mov    %eax,(%esp)
801015e3:	e8 26 07 00 00       	call   80101d0e <iunlock>
      commit_trans();
801015e8:	e8 d1 1f 00 00       	call   801035be <commit_trans>

      if(r < 0)
801015ed:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801015f1:	78 28                	js     8010161b <filewrite+0x11e>
        break;
      if(r != n1)
801015f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801015f6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801015f9:	74 0c                	je     80101607 <filewrite+0x10a>
        panic("short filewrite");
801015fb:	c7 04 24 17 89 10 80 	movl   $0x80108917,(%esp)
80101602:	e8 36 ef ff ff       	call   8010053d <panic>
      i += r;
80101607:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010160a:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010160d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101610:	3b 45 10             	cmp    0x10(%ebp),%eax
80101613:	0f 8c 4c ff ff ff    	jl     80101565 <filewrite+0x68>
80101619:	eb 01                	jmp    8010161c <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
8010161b:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
8010161c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010161f:	3b 45 10             	cmp    0x10(%ebp),%eax
80101622:	75 05                	jne    80101629 <filewrite+0x12c>
80101624:	8b 45 10             	mov    0x10(%ebp),%eax
80101627:	eb 05                	jmp    8010162e <filewrite+0x131>
80101629:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010162e:	eb 0c                	jmp    8010163c <filewrite+0x13f>
  }
  panic("filewrite");
80101630:	c7 04 24 27 89 10 80 	movl   $0x80108927,(%esp)
80101637:	e8 01 ef ff ff       	call   8010053d <panic>
}
8010163c:	83 c4 24             	add    $0x24,%esp
8010163f:	5b                   	pop    %ebx
80101640:	5d                   	pop    %ebp
80101641:	c3                   	ret    
	...

80101644 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101644:	55                   	push   %ebp
80101645:	89 e5                	mov    %esp,%ebp
80101647:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010164a:	8b 45 08             	mov    0x8(%ebp),%eax
8010164d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101654:	00 
80101655:	89 04 24             	mov    %eax,(%esp)
80101658:	e8 49 eb ff ff       	call   801001a6 <bread>
8010165d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101663:	83 c0 18             	add    $0x18,%eax
80101666:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010166d:	00 
8010166e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101672:	8b 45 0c             	mov    0xc(%ebp),%eax
80101675:	89 04 24             	mov    %eax,(%esp)
80101678:	e8 94 3e 00 00       	call   80105511 <memmove>
  brelse(bp);
8010167d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101680:	89 04 24             	mov    %eax,(%esp)
80101683:	e8 8f eb ff ff       	call   80100217 <brelse>
}
80101688:	c9                   	leave  
80101689:	c3                   	ret    

8010168a <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010168a:	55                   	push   %ebp
8010168b:	89 e5                	mov    %esp,%ebp
8010168d:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101690:	8b 55 0c             	mov    0xc(%ebp),%edx
80101693:	8b 45 08             	mov    0x8(%ebp),%eax
80101696:	89 54 24 04          	mov    %edx,0x4(%esp)
8010169a:	89 04 24             	mov    %eax,(%esp)
8010169d:	e8 04 eb ff ff       	call   801001a6 <bread>
801016a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801016a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016a8:	83 c0 18             	add    $0x18,%eax
801016ab:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801016b2:	00 
801016b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801016ba:	00 
801016bb:	89 04 24             	mov    %eax,(%esp)
801016be:	e8 7b 3d 00 00       	call   8010543e <memset>
  log_write(bp);
801016c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016c6:	89 04 24             	mov    %eax,(%esp)
801016c9:	e8 48 1f 00 00       	call   80103616 <log_write>
  brelse(bp);
801016ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d1:	89 04 24             	mov    %eax,(%esp)
801016d4:	e8 3e eb ff ff       	call   80100217 <brelse>
}
801016d9:	c9                   	leave  
801016da:	c3                   	ret    

801016db <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801016db:	55                   	push   %ebp
801016dc:	89 e5                	mov    %esp,%ebp
801016de:	53                   	push   %ebx
801016df:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
801016e2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
801016e9:	8b 45 08             	mov    0x8(%ebp),%eax
801016ec:	8d 55 d8             	lea    -0x28(%ebp),%edx
801016ef:	89 54 24 04          	mov    %edx,0x4(%esp)
801016f3:	89 04 24             	mov    %eax,(%esp)
801016f6:	e8 49 ff ff ff       	call   80101644 <readsb>
  for(b = 0; b < sb.size; b += BPB){
801016fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101702:	e9 11 01 00 00       	jmp    80101818 <balloc+0x13d>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
80101707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010170a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101710:	85 c0                	test   %eax,%eax
80101712:	0f 48 c2             	cmovs  %edx,%eax
80101715:	c1 f8 0c             	sar    $0xc,%eax
80101718:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010171b:	c1 ea 03             	shr    $0x3,%edx
8010171e:	01 d0                	add    %edx,%eax
80101720:	83 c0 03             	add    $0x3,%eax
80101723:	89 44 24 04          	mov    %eax,0x4(%esp)
80101727:	8b 45 08             	mov    0x8(%ebp),%eax
8010172a:	89 04 24             	mov    %eax,(%esp)
8010172d:	e8 74 ea ff ff       	call   801001a6 <bread>
80101732:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101735:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010173c:	e9 a7 00 00 00       	jmp    801017e8 <balloc+0x10d>
      m = 1 << (bi % 8);
80101741:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101744:	89 c2                	mov    %eax,%edx
80101746:	c1 fa 1f             	sar    $0x1f,%edx
80101749:	c1 ea 1d             	shr    $0x1d,%edx
8010174c:	01 d0                	add    %edx,%eax
8010174e:	83 e0 07             	and    $0x7,%eax
80101751:	29 d0                	sub    %edx,%eax
80101753:	ba 01 00 00 00       	mov    $0x1,%edx
80101758:	89 d3                	mov    %edx,%ebx
8010175a:	89 c1                	mov    %eax,%ecx
8010175c:	d3 e3                	shl    %cl,%ebx
8010175e:	89 d8                	mov    %ebx,%eax
80101760:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101763:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101766:	8d 50 07             	lea    0x7(%eax),%edx
80101769:	85 c0                	test   %eax,%eax
8010176b:	0f 48 c2             	cmovs  %edx,%eax
8010176e:	c1 f8 03             	sar    $0x3,%eax
80101771:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101774:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101779:	0f b6 c0             	movzbl %al,%eax
8010177c:	23 45 e8             	and    -0x18(%ebp),%eax
8010177f:	85 c0                	test   %eax,%eax
80101781:	75 61                	jne    801017e4 <balloc+0x109>
        bp->data[bi/8] |= m;  // Mark block in use.
80101783:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101786:	8d 50 07             	lea    0x7(%eax),%edx
80101789:	85 c0                	test   %eax,%eax
8010178b:	0f 48 c2             	cmovs  %edx,%eax
8010178e:	c1 f8 03             	sar    $0x3,%eax
80101791:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101794:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101799:	89 d1                	mov    %edx,%ecx
8010179b:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010179e:	09 ca                	or     %ecx,%edx
801017a0:	89 d1                	mov    %edx,%ecx
801017a2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017a5:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801017a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017ac:	89 04 24             	mov    %eax,(%esp)
801017af:	e8 62 1e 00 00       	call   80103616 <log_write>
        brelse(bp);
801017b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017b7:	89 04 24             	mov    %eax,(%esp)
801017ba:	e8 58 ea ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
801017bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017c5:	01 c2                	add    %eax,%edx
801017c7:	8b 45 08             	mov    0x8(%ebp),%eax
801017ca:	89 54 24 04          	mov    %edx,0x4(%esp)
801017ce:	89 04 24             	mov    %eax,(%esp)
801017d1:	e8 b4 fe ff ff       	call   8010168a <bzero>
        return b + bi;
801017d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017dc:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
801017de:	83 c4 34             	add    $0x34,%esp
801017e1:	5b                   	pop    %ebx
801017e2:	5d                   	pop    %ebp
801017e3:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801017e4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801017e8:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801017ef:	7f 15                	jg     80101806 <balloc+0x12b>
801017f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017f7:	01 d0                	add    %edx,%eax
801017f9:	89 c2                	mov    %eax,%edx
801017fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
801017fe:	39 c2                	cmp    %eax,%edx
80101800:	0f 82 3b ff ff ff    	jb     80101741 <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101806:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101809:	89 04 24             	mov    %eax,(%esp)
8010180c:	e8 06 ea ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
80101811:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101818:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010181b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010181e:	39 c2                	cmp    %eax,%edx
80101820:	0f 82 e1 fe ff ff    	jb     80101707 <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101826:	c7 04 24 31 89 10 80 	movl   $0x80108931,(%esp)
8010182d:	e8 0b ed ff ff       	call   8010053d <panic>

80101832 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101832:	55                   	push   %ebp
80101833:	89 e5                	mov    %esp,%ebp
80101835:	53                   	push   %ebx
80101836:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
80101839:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010183c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101840:	8b 45 08             	mov    0x8(%ebp),%eax
80101843:	89 04 24             	mov    %eax,(%esp)
80101846:	e8 f9 fd ff ff       	call   80101644 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
8010184b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010184e:	89 c2                	mov    %eax,%edx
80101850:	c1 ea 0c             	shr    $0xc,%edx
80101853:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101856:	c1 e8 03             	shr    $0x3,%eax
80101859:	01 d0                	add    %edx,%eax
8010185b:	8d 50 03             	lea    0x3(%eax),%edx
8010185e:	8b 45 08             	mov    0x8(%ebp),%eax
80101861:	89 54 24 04          	mov    %edx,0x4(%esp)
80101865:	89 04 24             	mov    %eax,(%esp)
80101868:	e8 39 e9 ff ff       	call   801001a6 <bread>
8010186d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101870:	8b 45 0c             	mov    0xc(%ebp),%eax
80101873:	25 ff 0f 00 00       	and    $0xfff,%eax
80101878:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010187b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010187e:	89 c2                	mov    %eax,%edx
80101880:	c1 fa 1f             	sar    $0x1f,%edx
80101883:	c1 ea 1d             	shr    $0x1d,%edx
80101886:	01 d0                	add    %edx,%eax
80101888:	83 e0 07             	and    $0x7,%eax
8010188b:	29 d0                	sub    %edx,%eax
8010188d:	ba 01 00 00 00       	mov    $0x1,%edx
80101892:	89 d3                	mov    %edx,%ebx
80101894:	89 c1                	mov    %eax,%ecx
80101896:	d3 e3                	shl    %cl,%ebx
80101898:	89 d8                	mov    %ebx,%eax
8010189a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010189d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018a0:	8d 50 07             	lea    0x7(%eax),%edx
801018a3:	85 c0                	test   %eax,%eax
801018a5:	0f 48 c2             	cmovs  %edx,%eax
801018a8:	c1 f8 03             	sar    $0x3,%eax
801018ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018ae:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
801018b3:	0f b6 c0             	movzbl %al,%eax
801018b6:	23 45 ec             	and    -0x14(%ebp),%eax
801018b9:	85 c0                	test   %eax,%eax
801018bb:	75 0c                	jne    801018c9 <bfree+0x97>
    panic("freeing free block");
801018bd:	c7 04 24 47 89 10 80 	movl   $0x80108947,(%esp)
801018c4:	e8 74 ec ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
801018c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018cc:	8d 50 07             	lea    0x7(%eax),%edx
801018cf:	85 c0                	test   %eax,%eax
801018d1:	0f 48 c2             	cmovs  %edx,%eax
801018d4:	c1 f8 03             	sar    $0x3,%eax
801018d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018da:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801018df:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801018e2:	f7 d1                	not    %ecx
801018e4:	21 ca                	and    %ecx,%edx
801018e6:	89 d1                	mov    %edx,%ecx
801018e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018eb:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801018ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f2:	89 04 24             	mov    %eax,(%esp)
801018f5:	e8 1c 1d 00 00       	call   80103616 <log_write>
  brelse(bp);
801018fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018fd:	89 04 24             	mov    %eax,(%esp)
80101900:	e8 12 e9 ff ff       	call   80100217 <brelse>
}
80101905:	83 c4 34             	add    $0x34,%esp
80101908:	5b                   	pop    %ebx
80101909:	5d                   	pop    %ebp
8010190a:	c3                   	ret    

8010190b <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
8010190b:	55                   	push   %ebp
8010190c:	89 e5                	mov    %esp,%ebp
8010190e:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
80101911:	c7 44 24 04 5a 89 10 	movl   $0x8010895a,0x4(%esp)
80101918:	80 
80101919:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101920:	e8 a9 38 00 00       	call   801051ce <initlock>
}
80101925:	c9                   	leave  
80101926:	c3                   	ret    

80101927 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101927:	55                   	push   %ebp
80101928:	89 e5                	mov    %esp,%ebp
8010192a:	83 ec 48             	sub    $0x48,%esp
8010192d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101930:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
80101934:	8b 45 08             	mov    0x8(%ebp),%eax
80101937:	8d 55 dc             	lea    -0x24(%ebp),%edx
8010193a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010193e:	89 04 24             	mov    %eax,(%esp)
80101941:	e8 fe fc ff ff       	call   80101644 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
80101946:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010194d:	e9 98 00 00 00       	jmp    801019ea <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
80101952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101955:	c1 e8 03             	shr    $0x3,%eax
80101958:	83 c0 02             	add    $0x2,%eax
8010195b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010195f:	8b 45 08             	mov    0x8(%ebp),%eax
80101962:	89 04 24             	mov    %eax,(%esp)
80101965:	e8 3c e8 ff ff       	call   801001a6 <bread>
8010196a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010196d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101970:	8d 50 18             	lea    0x18(%eax),%edx
80101973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101976:	83 e0 07             	and    $0x7,%eax
80101979:	c1 e0 06             	shl    $0x6,%eax
8010197c:	01 d0                	add    %edx,%eax
8010197e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101981:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101984:	0f b7 00             	movzwl (%eax),%eax
80101987:	66 85 c0             	test   %ax,%ax
8010198a:	75 4f                	jne    801019db <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
8010198c:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101993:	00 
80101994:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010199b:	00 
8010199c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010199f:	89 04 24             	mov    %eax,(%esp)
801019a2:	e8 97 3a 00 00       	call   8010543e <memset>
      dip->type = type;
801019a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801019aa:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
801019ae:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801019b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b4:	89 04 24             	mov    %eax,(%esp)
801019b7:	e8 5a 1c 00 00       	call   80103616 <log_write>
      brelse(bp);
801019bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019bf:	89 04 24             	mov    %eax,(%esp)
801019c2:	e8 50 e8 ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
801019c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801019ce:	8b 45 08             	mov    0x8(%ebp),%eax
801019d1:	89 04 24             	mov    %eax,(%esp)
801019d4:	e8 e3 00 00 00       	call   80101abc <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
801019d9:	c9                   	leave  
801019da:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
801019db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019de:	89 04 24             	mov    %eax,(%esp)
801019e1:	e8 31 e8 ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
801019e6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801019ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801019ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801019f0:	39 c2                	cmp    %eax,%edx
801019f2:	0f 82 5a ff ff ff    	jb     80101952 <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801019f8:	c7 04 24 61 89 10 80 	movl   $0x80108961,(%esp)
801019ff:	e8 39 eb ff ff       	call   8010053d <panic>

80101a04 <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101a04:	55                   	push   %ebp
80101a05:	89 e5                	mov    %esp,%ebp
80101a07:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
80101a0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0d:	8b 40 04             	mov    0x4(%eax),%eax
80101a10:	c1 e8 03             	shr    $0x3,%eax
80101a13:	8d 50 02             	lea    0x2(%eax),%edx
80101a16:	8b 45 08             	mov    0x8(%ebp),%eax
80101a19:	8b 00                	mov    (%eax),%eax
80101a1b:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a1f:	89 04 24             	mov    %eax,(%esp)
80101a22:	e8 7f e7 ff ff       	call   801001a6 <bread>
80101a27:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a2d:	8d 50 18             	lea    0x18(%eax),%edx
80101a30:	8b 45 08             	mov    0x8(%ebp),%eax
80101a33:	8b 40 04             	mov    0x4(%eax),%eax
80101a36:	83 e0 07             	and    $0x7,%eax
80101a39:	c1 e0 06             	shl    $0x6,%eax
80101a3c:	01 d0                	add    %edx,%eax
80101a3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101a41:	8b 45 08             	mov    0x8(%ebp),%eax
80101a44:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101a48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a4b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101a4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a51:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a58:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101a5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5f:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101a63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a66:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101a6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6d:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101a71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a74:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101a78:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7b:	8b 50 18             	mov    0x18(%eax),%edx
80101a7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a81:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101a84:	8b 45 08             	mov    0x8(%ebp),%eax
80101a87:	8d 50 1c             	lea    0x1c(%eax),%edx
80101a8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a8d:	83 c0 0c             	add    $0xc,%eax
80101a90:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101a97:	00 
80101a98:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a9c:	89 04 24             	mov    %eax,(%esp)
80101a9f:	e8 6d 3a 00 00       	call   80105511 <memmove>
  log_write(bp);
80101aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aa7:	89 04 24             	mov    %eax,(%esp)
80101aaa:	e8 67 1b 00 00       	call   80103616 <log_write>
  brelse(bp);
80101aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab2:	89 04 24             	mov    %eax,(%esp)
80101ab5:	e8 5d e7 ff ff       	call   80100217 <brelse>
}
80101aba:	c9                   	leave  
80101abb:	c3                   	ret    

80101abc <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101abc:	55                   	push   %ebp
80101abd:	89 e5                	mov    %esp,%ebp
80101abf:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101ac2:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101ac9:	e8 21 37 00 00       	call   801051ef <acquire>

  // Is the inode already cached?
  empty = 0;
80101ace:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101ad5:	c7 45 f4 b4 e8 10 80 	movl   $0x8010e8b4,-0xc(%ebp)
80101adc:	eb 59                	jmp    80101b37 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ae1:	8b 40 08             	mov    0x8(%eax),%eax
80101ae4:	85 c0                	test   %eax,%eax
80101ae6:	7e 35                	jle    80101b1d <iget+0x61>
80101ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aeb:	8b 00                	mov    (%eax),%eax
80101aed:	3b 45 08             	cmp    0x8(%ebp),%eax
80101af0:	75 2b                	jne    80101b1d <iget+0x61>
80101af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101af5:	8b 40 04             	mov    0x4(%eax),%eax
80101af8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101afb:	75 20                	jne    80101b1d <iget+0x61>
      ip->ref++;
80101afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b00:	8b 40 08             	mov    0x8(%eax),%eax
80101b03:	8d 50 01             	lea    0x1(%eax),%edx
80101b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b09:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101b0c:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b13:	e8 39 37 00 00       	call   80105251 <release>
      return ip;
80101b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b1b:	eb 6f                	jmp    80101b8c <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101b1d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101b21:	75 10                	jne    80101b33 <iget+0x77>
80101b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b26:	8b 40 08             	mov    0x8(%eax),%eax
80101b29:	85 c0                	test   %eax,%eax
80101b2b:	75 06                	jne    80101b33 <iget+0x77>
      empty = ip;
80101b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b30:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101b33:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101b37:	81 7d f4 54 f8 10 80 	cmpl   $0x8010f854,-0xc(%ebp)
80101b3e:	72 9e                	jb     80101ade <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101b40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101b44:	75 0c                	jne    80101b52 <iget+0x96>
    panic("iget: no inodes");
80101b46:	c7 04 24 73 89 10 80 	movl   $0x80108973,(%esp)
80101b4d:	e8 eb e9 ff ff       	call   8010053d <panic>

  ip = empty;
80101b52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b55:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b5b:	8b 55 08             	mov    0x8(%ebp),%edx
80101b5e:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b63:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b66:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b6c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b76:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101b7d:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b84:	e8 c8 36 00 00       	call   80105251 <release>

  return ip;
80101b89:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101b8c:	c9                   	leave  
80101b8d:	c3                   	ret    

80101b8e <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101b8e:	55                   	push   %ebp
80101b8f:	89 e5                	mov    %esp,%ebp
80101b91:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101b94:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b9b:	e8 4f 36 00 00       	call   801051ef <acquire>
  ip->ref++;
80101ba0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba3:	8b 40 08             	mov    0x8(%eax),%eax
80101ba6:	8d 50 01             	lea    0x1(%eax),%edx
80101ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bac:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101baf:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101bb6:	e8 96 36 00 00       	call   80105251 <release>
  return ip;
80101bbb:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101bbe:	c9                   	leave  
80101bbf:	c3                   	ret    

80101bc0 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101bc0:	55                   	push   %ebp
80101bc1:	89 e5                	mov    %esp,%ebp
80101bc3:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101bc6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101bca:	74 0a                	je     80101bd6 <ilock+0x16>
80101bcc:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcf:	8b 40 08             	mov    0x8(%eax),%eax
80101bd2:	85 c0                	test   %eax,%eax
80101bd4:	7f 0c                	jg     80101be2 <ilock+0x22>
    panic("ilock");
80101bd6:	c7 04 24 83 89 10 80 	movl   $0x80108983,(%esp)
80101bdd:	e8 5b e9 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101be2:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101be9:	e8 01 36 00 00       	call   801051ef <acquire>
  while(ip->flags & I_BUSY)
80101bee:	eb 13                	jmp    80101c03 <ilock+0x43>
    sleep(ip, &icache.lock);
80101bf0:	c7 44 24 04 80 e8 10 	movl   $0x8010e880,0x4(%esp)
80101bf7:	80 
80101bf8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfb:	89 04 24             	mov    %eax,(%esp)
80101bfe:	e8 83 32 00 00       	call   80104e86 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101c03:	8b 45 08             	mov    0x8(%ebp),%eax
80101c06:	8b 40 0c             	mov    0xc(%eax),%eax
80101c09:	83 e0 01             	and    $0x1,%eax
80101c0c:	84 c0                	test   %al,%al
80101c0e:	75 e0                	jne    80101bf0 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101c10:	8b 45 08             	mov    0x8(%ebp),%eax
80101c13:	8b 40 0c             	mov    0xc(%eax),%eax
80101c16:	89 c2                	mov    %eax,%edx
80101c18:	83 ca 01             	or     $0x1,%edx
80101c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1e:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101c21:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101c28:	e8 24 36 00 00       	call   80105251 <release>

  if(!(ip->flags & I_VALID)){
80101c2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c30:	8b 40 0c             	mov    0xc(%eax),%eax
80101c33:	83 e0 02             	and    $0x2,%eax
80101c36:	85 c0                	test   %eax,%eax
80101c38:	0f 85 ce 00 00 00    	jne    80101d0c <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
80101c3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c41:	8b 40 04             	mov    0x4(%eax),%eax
80101c44:	c1 e8 03             	shr    $0x3,%eax
80101c47:	8d 50 02             	lea    0x2(%eax),%edx
80101c4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4d:	8b 00                	mov    (%eax),%eax
80101c4f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c53:	89 04 24             	mov    %eax,(%esp)
80101c56:	e8 4b e5 ff ff       	call   801001a6 <bread>
80101c5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c61:	8d 50 18             	lea    0x18(%eax),%edx
80101c64:	8b 45 08             	mov    0x8(%ebp),%eax
80101c67:	8b 40 04             	mov    0x4(%eax),%eax
80101c6a:	83 e0 07             	and    $0x7,%eax
80101c6d:	c1 e0 06             	shl    $0x6,%eax
80101c70:	01 d0                	add    %edx,%eax
80101c72:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101c75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c78:	0f b7 10             	movzwl (%eax),%edx
80101c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7e:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c85:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101c89:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8c:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101c90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c93:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101c97:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9a:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101c9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ca1:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101ca5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca8:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101cac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101caf:	8b 50 08             	mov    0x8(%eax),%edx
80101cb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb5:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101cb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cbb:	8d 50 0c             	lea    0xc(%eax),%edx
80101cbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc1:	83 c0 1c             	add    $0x1c,%eax
80101cc4:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101ccb:	00 
80101ccc:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cd0:	89 04 24             	mov    %eax,(%esp)
80101cd3:	e8 39 38 00 00       	call   80105511 <memmove>
    brelse(bp);
80101cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cdb:	89 04 24             	mov    %eax,(%esp)
80101cde:	e8 34 e5 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101ce3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce6:	8b 40 0c             	mov    0xc(%eax),%eax
80101ce9:	89 c2                	mov    %eax,%edx
80101ceb:	83 ca 02             	or     $0x2,%edx
80101cee:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf1:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101cf4:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf7:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101cfb:	66 85 c0             	test   %ax,%ax
80101cfe:	75 0c                	jne    80101d0c <ilock+0x14c>
      panic("ilock: no type");
80101d00:	c7 04 24 89 89 10 80 	movl   $0x80108989,(%esp)
80101d07:	e8 31 e8 ff ff       	call   8010053d <panic>
  }
}
80101d0c:	c9                   	leave  
80101d0d:	c3                   	ret    

80101d0e <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101d0e:	55                   	push   %ebp
80101d0f:	89 e5                	mov    %esp,%ebp
80101d11:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101d14:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101d18:	74 17                	je     80101d31 <iunlock+0x23>
80101d1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1d:	8b 40 0c             	mov    0xc(%eax),%eax
80101d20:	83 e0 01             	and    $0x1,%eax
80101d23:	85 c0                	test   %eax,%eax
80101d25:	74 0a                	je     80101d31 <iunlock+0x23>
80101d27:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2a:	8b 40 08             	mov    0x8(%eax),%eax
80101d2d:	85 c0                	test   %eax,%eax
80101d2f:	7f 0c                	jg     80101d3d <iunlock+0x2f>
    panic("iunlock");
80101d31:	c7 04 24 98 89 10 80 	movl   $0x80108998,(%esp)
80101d38:	e8 00 e8 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101d3d:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d44:	e8 a6 34 00 00       	call   801051ef <acquire>
  ip->flags &= ~I_BUSY;
80101d49:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4c:	8b 40 0c             	mov    0xc(%eax),%eax
80101d4f:	89 c2                	mov    %eax,%edx
80101d51:	83 e2 fe             	and    $0xfffffffe,%edx
80101d54:	8b 45 08             	mov    0x8(%ebp),%eax
80101d57:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101d5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5d:	89 04 24             	mov    %eax,(%esp)
80101d60:	e8 fd 31 00 00       	call   80104f62 <wakeup>
  release(&icache.lock);
80101d65:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d6c:	e8 e0 34 00 00       	call   80105251 <release>
}
80101d71:	c9                   	leave  
80101d72:	c3                   	ret    

80101d73 <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101d73:	55                   	push   %ebp
80101d74:	89 e5                	mov    %esp,%ebp
80101d76:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101d79:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d80:	e8 6a 34 00 00       	call   801051ef <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101d85:	8b 45 08             	mov    0x8(%ebp),%eax
80101d88:	8b 40 08             	mov    0x8(%eax),%eax
80101d8b:	83 f8 01             	cmp    $0x1,%eax
80101d8e:	0f 85 93 00 00 00    	jne    80101e27 <iput+0xb4>
80101d94:	8b 45 08             	mov    0x8(%ebp),%eax
80101d97:	8b 40 0c             	mov    0xc(%eax),%eax
80101d9a:	83 e0 02             	and    $0x2,%eax
80101d9d:	85 c0                	test   %eax,%eax
80101d9f:	0f 84 82 00 00 00    	je     80101e27 <iput+0xb4>
80101da5:	8b 45 08             	mov    0x8(%ebp),%eax
80101da8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101dac:	66 85 c0             	test   %ax,%ax
80101daf:	75 76                	jne    80101e27 <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101db1:	8b 45 08             	mov    0x8(%ebp),%eax
80101db4:	8b 40 0c             	mov    0xc(%eax),%eax
80101db7:	83 e0 01             	and    $0x1,%eax
80101dba:	84 c0                	test   %al,%al
80101dbc:	74 0c                	je     80101dca <iput+0x57>
      panic("iput busy");
80101dbe:	c7 04 24 a0 89 10 80 	movl   $0x801089a0,(%esp)
80101dc5:	e8 73 e7 ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80101dca:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcd:	8b 40 0c             	mov    0xc(%eax),%eax
80101dd0:	89 c2                	mov    %eax,%edx
80101dd2:	83 ca 01             	or     $0x1,%edx
80101dd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd8:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101ddb:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101de2:	e8 6a 34 00 00       	call   80105251 <release>
    itrunc(ip);
80101de7:	8b 45 08             	mov    0x8(%ebp),%eax
80101dea:	89 04 24             	mov    %eax,(%esp)
80101ded:	e8 72 01 00 00       	call   80101f64 <itrunc>
    ip->type = 0;
80101df2:	8b 45 08             	mov    0x8(%ebp),%eax
80101df5:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101dfb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfe:	89 04 24             	mov    %eax,(%esp)
80101e01:	e8 fe fb ff ff       	call   80101a04 <iupdate>
    acquire(&icache.lock);
80101e06:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101e0d:	e8 dd 33 00 00       	call   801051ef <acquire>
    ip->flags = 0;
80101e12:	8b 45 08             	mov    0x8(%ebp),%eax
80101e15:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101e1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1f:	89 04 24             	mov    %eax,(%esp)
80101e22:	e8 3b 31 00 00       	call   80104f62 <wakeup>
  }
  ip->ref--;
80101e27:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2a:	8b 40 08             	mov    0x8(%eax),%eax
80101e2d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101e30:	8b 45 08             	mov    0x8(%ebp),%eax
80101e33:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101e36:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101e3d:	e8 0f 34 00 00       	call   80105251 <release>
}
80101e42:	c9                   	leave  
80101e43:	c3                   	ret    

80101e44 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101e44:	55                   	push   %ebp
80101e45:	89 e5                	mov    %esp,%ebp
80101e47:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101e4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4d:	89 04 24             	mov    %eax,(%esp)
80101e50:	e8 b9 fe ff ff       	call   80101d0e <iunlock>
  iput(ip);
80101e55:	8b 45 08             	mov    0x8(%ebp),%eax
80101e58:	89 04 24             	mov    %eax,(%esp)
80101e5b:	e8 13 ff ff ff       	call   80101d73 <iput>
}
80101e60:	c9                   	leave  
80101e61:	c3                   	ret    

80101e62 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101e62:	55                   	push   %ebp
80101e63:	89 e5                	mov    %esp,%ebp
80101e65:	53                   	push   %ebx
80101e66:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101e69:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101e6d:	77 3e                	ja     80101ead <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101e6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e72:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e75:	83 c2 04             	add    $0x4,%edx
80101e78:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e7f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e83:	75 20                	jne    80101ea5 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101e85:	8b 45 08             	mov    0x8(%ebp),%eax
80101e88:	8b 00                	mov    (%eax),%eax
80101e8a:	89 04 24             	mov    %eax,(%esp)
80101e8d:	e8 49 f8 ff ff       	call   801016db <balloc>
80101e92:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e95:	8b 45 08             	mov    0x8(%ebp),%eax
80101e98:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e9b:	8d 4a 04             	lea    0x4(%edx),%ecx
80101e9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ea1:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ea8:	e9 b1 00 00 00       	jmp    80101f5e <bmap+0xfc>
  }
  bn -= NDIRECT;
80101ead:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101eb1:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101eb5:	0f 87 97 00 00 00    	ja     80101f52 <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101ebb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebe:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ec1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ec4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ec8:	75 19                	jne    80101ee3 <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101eca:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecd:	8b 00                	mov    (%eax),%eax
80101ecf:	89 04 24             	mov    %eax,(%esp)
80101ed2:	e8 04 f8 ff ff       	call   801016db <balloc>
80101ed7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101eda:	8b 45 08             	mov    0x8(%ebp),%eax
80101edd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ee0:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101ee3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee6:	8b 00                	mov    (%eax),%eax
80101ee8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101eeb:	89 54 24 04          	mov    %edx,0x4(%esp)
80101eef:	89 04 24             	mov    %eax,(%esp)
80101ef2:	e8 af e2 ff ff       	call   801001a6 <bread>
80101ef7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101efa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101efd:	83 c0 18             	add    $0x18,%eax
80101f00:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101f03:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f06:	c1 e0 02             	shl    $0x2,%eax
80101f09:	03 45 ec             	add    -0x14(%ebp),%eax
80101f0c:	8b 00                	mov    (%eax),%eax
80101f0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101f15:	75 2b                	jne    80101f42 <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80101f17:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f1a:	c1 e0 02             	shl    $0x2,%eax
80101f1d:	89 c3                	mov    %eax,%ebx
80101f1f:	03 5d ec             	add    -0x14(%ebp),%ebx
80101f22:	8b 45 08             	mov    0x8(%ebp),%eax
80101f25:	8b 00                	mov    (%eax),%eax
80101f27:	89 04 24             	mov    %eax,(%esp)
80101f2a:	e8 ac f7 ff ff       	call   801016db <balloc>
80101f2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f35:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101f37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f3a:	89 04 24             	mov    %eax,(%esp)
80101f3d:	e8 d4 16 00 00       	call   80103616 <log_write>
    }
    brelse(bp);
80101f42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f45:	89 04 24             	mov    %eax,(%esp)
80101f48:	e8 ca e2 ff ff       	call   80100217 <brelse>
    return addr;
80101f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f50:	eb 0c                	jmp    80101f5e <bmap+0xfc>
  }

  panic("bmap: out of range");
80101f52:	c7 04 24 aa 89 10 80 	movl   $0x801089aa,(%esp)
80101f59:	e8 df e5 ff ff       	call   8010053d <panic>
}
80101f5e:	83 c4 24             	add    $0x24,%esp
80101f61:	5b                   	pop    %ebx
80101f62:	5d                   	pop    %ebp
80101f63:	c3                   	ret    

80101f64 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101f64:	55                   	push   %ebp
80101f65:	89 e5                	mov    %esp,%ebp
80101f67:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f71:	eb 44                	jmp    80101fb7 <itrunc+0x53>
    if(ip->addrs[i]){
80101f73:	8b 45 08             	mov    0x8(%ebp),%eax
80101f76:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f79:	83 c2 04             	add    $0x4,%edx
80101f7c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f80:	85 c0                	test   %eax,%eax
80101f82:	74 2f                	je     80101fb3 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101f84:	8b 45 08             	mov    0x8(%ebp),%eax
80101f87:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f8a:	83 c2 04             	add    $0x4,%edx
80101f8d:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101f91:	8b 45 08             	mov    0x8(%ebp),%eax
80101f94:	8b 00                	mov    (%eax),%eax
80101f96:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f9a:	89 04 24             	mov    %eax,(%esp)
80101f9d:	e8 90 f8 ff ff       	call   80101832 <bfree>
      ip->addrs[i] = 0;
80101fa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101fa8:	83 c2 04             	add    $0x4,%edx
80101fab:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101fb2:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101fb3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101fb7:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101fbb:	7e b6                	jle    80101f73 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101fbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc0:	8b 40 4c             	mov    0x4c(%eax),%eax
80101fc3:	85 c0                	test   %eax,%eax
80101fc5:	0f 84 8f 00 00 00    	je     8010205a <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101fcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101fce:	8b 50 4c             	mov    0x4c(%eax),%edx
80101fd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd4:	8b 00                	mov    (%eax),%eax
80101fd6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fda:	89 04 24             	mov    %eax,(%esp)
80101fdd:	e8 c4 e1 ff ff       	call   801001a6 <bread>
80101fe2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101fe5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fe8:	83 c0 18             	add    $0x18,%eax
80101feb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101fee:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ff5:	eb 2f                	jmp    80102026 <itrunc+0xc2>
      if(a[j])
80101ff7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ffa:	c1 e0 02             	shl    $0x2,%eax
80101ffd:	03 45 e8             	add    -0x18(%ebp),%eax
80102000:	8b 00                	mov    (%eax),%eax
80102002:	85 c0                	test   %eax,%eax
80102004:	74 1c                	je     80102022 <itrunc+0xbe>
        bfree(ip->dev, a[j]);
80102006:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102009:	c1 e0 02             	shl    $0x2,%eax
8010200c:	03 45 e8             	add    -0x18(%ebp),%eax
8010200f:	8b 10                	mov    (%eax),%edx
80102011:	8b 45 08             	mov    0x8(%ebp),%eax
80102014:	8b 00                	mov    (%eax),%eax
80102016:	89 54 24 04          	mov    %edx,0x4(%esp)
8010201a:	89 04 24             	mov    %eax,(%esp)
8010201d:	e8 10 f8 ff ff       	call   80101832 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80102022:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80102026:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102029:	83 f8 7f             	cmp    $0x7f,%eax
8010202c:	76 c9                	jbe    80101ff7 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
8010202e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102031:	89 04 24             	mov    %eax,(%esp)
80102034:	e8 de e1 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80102039:	8b 45 08             	mov    0x8(%ebp),%eax
8010203c:	8b 50 4c             	mov    0x4c(%eax),%edx
8010203f:	8b 45 08             	mov    0x8(%ebp),%eax
80102042:	8b 00                	mov    (%eax),%eax
80102044:	89 54 24 04          	mov    %edx,0x4(%esp)
80102048:	89 04 24             	mov    %eax,(%esp)
8010204b:	e8 e2 f7 ff ff       	call   80101832 <bfree>
    ip->addrs[NDIRECT] = 0;
80102050:	8b 45 08             	mov    0x8(%ebp),%eax
80102053:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
8010205a:	8b 45 08             	mov    0x8(%ebp),%eax
8010205d:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80102064:	8b 45 08             	mov    0x8(%ebp),%eax
80102067:	89 04 24             	mov    %eax,(%esp)
8010206a:	e8 95 f9 ff ff       	call   80101a04 <iupdate>
}
8010206f:	c9                   	leave  
80102070:	c3                   	ret    

80102071 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80102071:	55                   	push   %ebp
80102072:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80102074:	8b 45 08             	mov    0x8(%ebp),%eax
80102077:	8b 00                	mov    (%eax),%eax
80102079:	89 c2                	mov    %eax,%edx
8010207b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010207e:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80102081:	8b 45 08             	mov    0x8(%ebp),%eax
80102084:	8b 50 04             	mov    0x4(%eax),%edx
80102087:	8b 45 0c             	mov    0xc(%ebp),%eax
8010208a:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
8010208d:	8b 45 08             	mov    0x8(%ebp),%eax
80102090:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80102094:	8b 45 0c             	mov    0xc(%ebp),%eax
80102097:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
8010209a:	8b 45 08             	mov    0x8(%ebp),%eax
8010209d:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801020a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801020a4:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
801020a8:	8b 45 08             	mov    0x8(%ebp),%eax
801020ab:	8b 50 18             	mov    0x18(%eax),%edx
801020ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801020b1:	89 50 10             	mov    %edx,0x10(%eax)
}
801020b4:	5d                   	pop    %ebp
801020b5:	c3                   	ret    

801020b6 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
801020b6:	55                   	push   %ebp
801020b7:	89 e5                	mov    %esp,%ebp
801020b9:	53                   	push   %ebx
801020ba:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020bd:	8b 45 08             	mov    0x8(%ebp),%eax
801020c0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020c4:	66 83 f8 03          	cmp    $0x3,%ax
801020c8:	75 60                	jne    8010212a <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801020ca:	8b 45 08             	mov    0x8(%ebp),%eax
801020cd:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020d1:	66 85 c0             	test   %ax,%ax
801020d4:	78 20                	js     801020f6 <readi+0x40>
801020d6:	8b 45 08             	mov    0x8(%ebp),%eax
801020d9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020dd:	66 83 f8 09          	cmp    $0x9,%ax
801020e1:	7f 13                	jg     801020f6 <readi+0x40>
801020e3:	8b 45 08             	mov    0x8(%ebp),%eax
801020e6:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020ea:	98                   	cwtl   
801020eb:	8b 04 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%eax
801020f2:	85 c0                	test   %eax,%eax
801020f4:	75 0a                	jne    80102100 <readi+0x4a>
      return -1;
801020f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020fb:	e9 1b 01 00 00       	jmp    8010221b <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
80102100:	8b 45 08             	mov    0x8(%ebp),%eax
80102103:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102107:	98                   	cwtl   
80102108:	8b 14 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%edx
8010210f:	8b 45 14             	mov    0x14(%ebp),%eax
80102112:	89 44 24 08          	mov    %eax,0x8(%esp)
80102116:	8b 45 0c             	mov    0xc(%ebp),%eax
80102119:	89 44 24 04          	mov    %eax,0x4(%esp)
8010211d:	8b 45 08             	mov    0x8(%ebp),%eax
80102120:	89 04 24             	mov    %eax,(%esp)
80102123:	ff d2                	call   *%edx
80102125:	e9 f1 00 00 00       	jmp    8010221b <readi+0x165>
  }

  if(off > ip->size || off + n < off)
8010212a:	8b 45 08             	mov    0x8(%ebp),%eax
8010212d:	8b 40 18             	mov    0x18(%eax),%eax
80102130:	3b 45 10             	cmp    0x10(%ebp),%eax
80102133:	72 0d                	jb     80102142 <readi+0x8c>
80102135:	8b 45 14             	mov    0x14(%ebp),%eax
80102138:	8b 55 10             	mov    0x10(%ebp),%edx
8010213b:	01 d0                	add    %edx,%eax
8010213d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102140:	73 0a                	jae    8010214c <readi+0x96>
    return -1;
80102142:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102147:	e9 cf 00 00 00       	jmp    8010221b <readi+0x165>
  if(off + n > ip->size)
8010214c:	8b 45 14             	mov    0x14(%ebp),%eax
8010214f:	8b 55 10             	mov    0x10(%ebp),%edx
80102152:	01 c2                	add    %eax,%edx
80102154:	8b 45 08             	mov    0x8(%ebp),%eax
80102157:	8b 40 18             	mov    0x18(%eax),%eax
8010215a:	39 c2                	cmp    %eax,%edx
8010215c:	76 0c                	jbe    8010216a <readi+0xb4>
    n = ip->size - off;
8010215e:	8b 45 08             	mov    0x8(%ebp),%eax
80102161:	8b 40 18             	mov    0x18(%eax),%eax
80102164:	2b 45 10             	sub    0x10(%ebp),%eax
80102167:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010216a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102171:	e9 96 00 00 00       	jmp    8010220c <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102176:	8b 45 10             	mov    0x10(%ebp),%eax
80102179:	c1 e8 09             	shr    $0x9,%eax
8010217c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102180:	8b 45 08             	mov    0x8(%ebp),%eax
80102183:	89 04 24             	mov    %eax,(%esp)
80102186:	e8 d7 fc ff ff       	call   80101e62 <bmap>
8010218b:	8b 55 08             	mov    0x8(%ebp),%edx
8010218e:	8b 12                	mov    (%edx),%edx
80102190:	89 44 24 04          	mov    %eax,0x4(%esp)
80102194:	89 14 24             	mov    %edx,(%esp)
80102197:	e8 0a e0 ff ff       	call   801001a6 <bread>
8010219c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010219f:	8b 45 10             	mov    0x10(%ebp),%eax
801021a2:	89 c2                	mov    %eax,%edx
801021a4:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801021aa:	b8 00 02 00 00       	mov    $0x200,%eax
801021af:	89 c1                	mov    %eax,%ecx
801021b1:	29 d1                	sub    %edx,%ecx
801021b3:	89 ca                	mov    %ecx,%edx
801021b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021b8:	8b 4d 14             	mov    0x14(%ebp),%ecx
801021bb:	89 cb                	mov    %ecx,%ebx
801021bd:	29 c3                	sub    %eax,%ebx
801021bf:	89 d8                	mov    %ebx,%eax
801021c1:	39 c2                	cmp    %eax,%edx
801021c3:	0f 46 c2             	cmovbe %edx,%eax
801021c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801021c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021cc:	8d 50 18             	lea    0x18(%eax),%edx
801021cf:	8b 45 10             	mov    0x10(%ebp),%eax
801021d2:	25 ff 01 00 00       	and    $0x1ff,%eax
801021d7:	01 c2                	add    %eax,%edx
801021d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021dc:	89 44 24 08          	mov    %eax,0x8(%esp)
801021e0:	89 54 24 04          	mov    %edx,0x4(%esp)
801021e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801021e7:	89 04 24             	mov    %eax,(%esp)
801021ea:	e8 22 33 00 00       	call   80105511 <memmove>
    brelse(bp);
801021ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021f2:	89 04 24             	mov    %eax,(%esp)
801021f5:	e8 1d e0 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801021fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021fd:	01 45 f4             	add    %eax,-0xc(%ebp)
80102200:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102203:	01 45 10             	add    %eax,0x10(%ebp)
80102206:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102209:	01 45 0c             	add    %eax,0xc(%ebp)
8010220c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010220f:	3b 45 14             	cmp    0x14(%ebp),%eax
80102212:	0f 82 5e ff ff ff    	jb     80102176 <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102218:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010221b:	83 c4 24             	add    $0x24,%esp
8010221e:	5b                   	pop    %ebx
8010221f:	5d                   	pop    %ebp
80102220:	c3                   	ret    

80102221 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102221:	55                   	push   %ebp
80102222:	89 e5                	mov    %esp,%ebp
80102224:	53                   	push   %ebx
80102225:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102228:	8b 45 08             	mov    0x8(%ebp),%eax
8010222b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010222f:	66 83 f8 03          	cmp    $0x3,%ax
80102233:	75 60                	jne    80102295 <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102235:	8b 45 08             	mov    0x8(%ebp),%eax
80102238:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010223c:	66 85 c0             	test   %ax,%ax
8010223f:	78 20                	js     80102261 <writei+0x40>
80102241:	8b 45 08             	mov    0x8(%ebp),%eax
80102244:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102248:	66 83 f8 09          	cmp    $0x9,%ax
8010224c:	7f 13                	jg     80102261 <writei+0x40>
8010224e:	8b 45 08             	mov    0x8(%ebp),%eax
80102251:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102255:	98                   	cwtl   
80102256:	8b 04 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%eax
8010225d:	85 c0                	test   %eax,%eax
8010225f:	75 0a                	jne    8010226b <writei+0x4a>
      return -1;
80102261:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102266:	e9 46 01 00 00       	jmp    801023b1 <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
8010226b:	8b 45 08             	mov    0x8(%ebp),%eax
8010226e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102272:	98                   	cwtl   
80102273:	8b 14 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%edx
8010227a:	8b 45 14             	mov    0x14(%ebp),%eax
8010227d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102281:	8b 45 0c             	mov    0xc(%ebp),%eax
80102284:	89 44 24 04          	mov    %eax,0x4(%esp)
80102288:	8b 45 08             	mov    0x8(%ebp),%eax
8010228b:	89 04 24             	mov    %eax,(%esp)
8010228e:	ff d2                	call   *%edx
80102290:	e9 1c 01 00 00       	jmp    801023b1 <writei+0x190>
  }

  if(off > ip->size || off + n < off)
80102295:	8b 45 08             	mov    0x8(%ebp),%eax
80102298:	8b 40 18             	mov    0x18(%eax),%eax
8010229b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010229e:	72 0d                	jb     801022ad <writei+0x8c>
801022a0:	8b 45 14             	mov    0x14(%ebp),%eax
801022a3:	8b 55 10             	mov    0x10(%ebp),%edx
801022a6:	01 d0                	add    %edx,%eax
801022a8:	3b 45 10             	cmp    0x10(%ebp),%eax
801022ab:	73 0a                	jae    801022b7 <writei+0x96>
    return -1;
801022ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022b2:	e9 fa 00 00 00       	jmp    801023b1 <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
801022b7:	8b 45 14             	mov    0x14(%ebp),%eax
801022ba:	8b 55 10             	mov    0x10(%ebp),%edx
801022bd:	01 d0                	add    %edx,%eax
801022bf:	3d 00 18 01 00       	cmp    $0x11800,%eax
801022c4:	76 0a                	jbe    801022d0 <writei+0xaf>
    return -1;
801022c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022cb:	e9 e1 00 00 00       	jmp    801023b1 <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022d7:	e9 a1 00 00 00       	jmp    8010237d <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801022dc:	8b 45 10             	mov    0x10(%ebp),%eax
801022df:	c1 e8 09             	shr    $0x9,%eax
801022e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801022e6:	8b 45 08             	mov    0x8(%ebp),%eax
801022e9:	89 04 24             	mov    %eax,(%esp)
801022ec:	e8 71 fb ff ff       	call   80101e62 <bmap>
801022f1:	8b 55 08             	mov    0x8(%ebp),%edx
801022f4:	8b 12                	mov    (%edx),%edx
801022f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801022fa:	89 14 24             	mov    %edx,(%esp)
801022fd:	e8 a4 de ff ff       	call   801001a6 <bread>
80102302:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102305:	8b 45 10             	mov    0x10(%ebp),%eax
80102308:	89 c2                	mov    %eax,%edx
8010230a:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102310:	b8 00 02 00 00       	mov    $0x200,%eax
80102315:	89 c1                	mov    %eax,%ecx
80102317:	29 d1                	sub    %edx,%ecx
80102319:	89 ca                	mov    %ecx,%edx
8010231b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010231e:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102321:	89 cb                	mov    %ecx,%ebx
80102323:	29 c3                	sub    %eax,%ebx
80102325:	89 d8                	mov    %ebx,%eax
80102327:	39 c2                	cmp    %eax,%edx
80102329:	0f 46 c2             	cmovbe %edx,%eax
8010232c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010232f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102332:	8d 50 18             	lea    0x18(%eax),%edx
80102335:	8b 45 10             	mov    0x10(%ebp),%eax
80102338:	25 ff 01 00 00       	and    $0x1ff,%eax
8010233d:	01 c2                	add    %eax,%edx
8010233f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102342:	89 44 24 08          	mov    %eax,0x8(%esp)
80102346:	8b 45 0c             	mov    0xc(%ebp),%eax
80102349:	89 44 24 04          	mov    %eax,0x4(%esp)
8010234d:	89 14 24             	mov    %edx,(%esp)
80102350:	e8 bc 31 00 00       	call   80105511 <memmove>
    log_write(bp);
80102355:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102358:	89 04 24             	mov    %eax,(%esp)
8010235b:	e8 b6 12 00 00       	call   80103616 <log_write>
    brelse(bp);
80102360:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102363:	89 04 24             	mov    %eax,(%esp)
80102366:	e8 ac de ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010236b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010236e:	01 45 f4             	add    %eax,-0xc(%ebp)
80102371:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102374:	01 45 10             	add    %eax,0x10(%ebp)
80102377:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010237a:	01 45 0c             	add    %eax,0xc(%ebp)
8010237d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102380:	3b 45 14             	cmp    0x14(%ebp),%eax
80102383:	0f 82 53 ff ff ff    	jb     801022dc <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102389:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010238d:	74 1f                	je     801023ae <writei+0x18d>
8010238f:	8b 45 08             	mov    0x8(%ebp),%eax
80102392:	8b 40 18             	mov    0x18(%eax),%eax
80102395:	3b 45 10             	cmp    0x10(%ebp),%eax
80102398:	73 14                	jae    801023ae <writei+0x18d>
    ip->size = off;
8010239a:	8b 45 08             	mov    0x8(%ebp),%eax
8010239d:	8b 55 10             	mov    0x10(%ebp),%edx
801023a0:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801023a3:	8b 45 08             	mov    0x8(%ebp),%eax
801023a6:	89 04 24             	mov    %eax,(%esp)
801023a9:	e8 56 f6 ff ff       	call   80101a04 <iupdate>
  }
  return n;
801023ae:	8b 45 14             	mov    0x14(%ebp),%eax
}
801023b1:	83 c4 24             	add    $0x24,%esp
801023b4:	5b                   	pop    %ebx
801023b5:	5d                   	pop    %ebp
801023b6:	c3                   	ret    

801023b7 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801023b7:	55                   	push   %ebp
801023b8:	89 e5                	mov    %esp,%ebp
801023ba:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801023bd:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801023c4:	00 
801023c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801023c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801023cc:	8b 45 08             	mov    0x8(%ebp),%eax
801023cf:	89 04 24             	mov    %eax,(%esp)
801023d2:	e8 de 31 00 00       	call   801055b5 <strncmp>
}
801023d7:	c9                   	leave  
801023d8:	c3                   	ret    

801023d9 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801023d9:	55                   	push   %ebp
801023da:	89 e5                	mov    %esp,%ebp
801023dc:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801023df:	8b 45 08             	mov    0x8(%ebp),%eax
801023e2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023e6:	66 83 f8 01          	cmp    $0x1,%ax
801023ea:	74 0c                	je     801023f8 <dirlookup+0x1f>
    panic("dirlookup not DIR");
801023ec:	c7 04 24 bd 89 10 80 	movl   $0x801089bd,(%esp)
801023f3:	e8 45 e1 ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801023f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023ff:	e9 87 00 00 00       	jmp    8010248b <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102404:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010240b:	00 
8010240c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010240f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102413:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102416:	89 44 24 04          	mov    %eax,0x4(%esp)
8010241a:	8b 45 08             	mov    0x8(%ebp),%eax
8010241d:	89 04 24             	mov    %eax,(%esp)
80102420:	e8 91 fc ff ff       	call   801020b6 <readi>
80102425:	83 f8 10             	cmp    $0x10,%eax
80102428:	74 0c                	je     80102436 <dirlookup+0x5d>
      panic("dirlink read");
8010242a:	c7 04 24 cf 89 10 80 	movl   $0x801089cf,(%esp)
80102431:	e8 07 e1 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
80102436:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010243a:	66 85 c0             	test   %ax,%ax
8010243d:	74 47                	je     80102486 <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
8010243f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102442:	83 c0 02             	add    $0x2,%eax
80102445:	89 44 24 04          	mov    %eax,0x4(%esp)
80102449:	8b 45 0c             	mov    0xc(%ebp),%eax
8010244c:	89 04 24             	mov    %eax,(%esp)
8010244f:	e8 63 ff ff ff       	call   801023b7 <namecmp>
80102454:	85 c0                	test   %eax,%eax
80102456:	75 2f                	jne    80102487 <dirlookup+0xae>
      // entry matches path element
      if(poff)
80102458:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010245c:	74 08                	je     80102466 <dirlookup+0x8d>
        *poff = off;
8010245e:	8b 45 10             	mov    0x10(%ebp),%eax
80102461:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102464:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102466:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010246a:	0f b7 c0             	movzwl %ax,%eax
8010246d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102470:	8b 45 08             	mov    0x8(%ebp),%eax
80102473:	8b 00                	mov    (%eax),%eax
80102475:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102478:	89 54 24 04          	mov    %edx,0x4(%esp)
8010247c:	89 04 24             	mov    %eax,(%esp)
8010247f:	e8 38 f6 ff ff       	call   80101abc <iget>
80102484:	eb 19                	jmp    8010249f <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102486:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102487:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010248b:	8b 45 08             	mov    0x8(%ebp),%eax
8010248e:	8b 40 18             	mov    0x18(%eax),%eax
80102491:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102494:	0f 87 6a ff ff ff    	ja     80102404 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010249a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010249f:	c9                   	leave  
801024a0:	c3                   	ret    

801024a1 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801024a1:	55                   	push   %ebp
801024a2:	89 e5                	mov    %esp,%ebp
801024a4:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801024a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801024ae:	00 
801024af:	8b 45 0c             	mov    0xc(%ebp),%eax
801024b2:	89 44 24 04          	mov    %eax,0x4(%esp)
801024b6:	8b 45 08             	mov    0x8(%ebp),%eax
801024b9:	89 04 24             	mov    %eax,(%esp)
801024bc:	e8 18 ff ff ff       	call   801023d9 <dirlookup>
801024c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024c4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024c8:	74 15                	je     801024df <dirlink+0x3e>
    iput(ip);
801024ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024cd:	89 04 24             	mov    %eax,(%esp)
801024d0:	e8 9e f8 ff ff       	call   80101d73 <iput>
    return -1;
801024d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801024da:	e9 b8 00 00 00       	jmp    80102597 <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801024df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801024e6:	eb 44                	jmp    8010252c <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024eb:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801024f2:	00 
801024f3:	89 44 24 08          	mov    %eax,0x8(%esp)
801024f7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801024fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102501:	89 04 24             	mov    %eax,(%esp)
80102504:	e8 ad fb ff ff       	call   801020b6 <readi>
80102509:	83 f8 10             	cmp    $0x10,%eax
8010250c:	74 0c                	je     8010251a <dirlink+0x79>
      panic("dirlink read");
8010250e:	c7 04 24 cf 89 10 80 	movl   $0x801089cf,(%esp)
80102515:	e8 23 e0 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
8010251a:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010251e:	66 85 c0             	test   %ax,%ax
80102521:	74 18                	je     8010253b <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102523:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102526:	83 c0 10             	add    $0x10,%eax
80102529:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010252c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010252f:	8b 45 08             	mov    0x8(%ebp),%eax
80102532:	8b 40 18             	mov    0x18(%eax),%eax
80102535:	39 c2                	cmp    %eax,%edx
80102537:	72 af                	jb     801024e8 <dirlink+0x47>
80102539:	eb 01                	jmp    8010253c <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
8010253b:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010253c:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102543:	00 
80102544:	8b 45 0c             	mov    0xc(%ebp),%eax
80102547:	89 44 24 04          	mov    %eax,0x4(%esp)
8010254b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010254e:	83 c0 02             	add    $0x2,%eax
80102551:	89 04 24             	mov    %eax,(%esp)
80102554:	e8 b4 30 00 00       	call   8010560d <strncpy>
  de.inum = inum;
80102559:	8b 45 10             	mov    0x10(%ebp),%eax
8010255c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102560:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102563:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010256a:	00 
8010256b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010256f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102572:	89 44 24 04          	mov    %eax,0x4(%esp)
80102576:	8b 45 08             	mov    0x8(%ebp),%eax
80102579:	89 04 24             	mov    %eax,(%esp)
8010257c:	e8 a0 fc ff ff       	call   80102221 <writei>
80102581:	83 f8 10             	cmp    $0x10,%eax
80102584:	74 0c                	je     80102592 <dirlink+0xf1>
    panic("dirlink");
80102586:	c7 04 24 dc 89 10 80 	movl   $0x801089dc,(%esp)
8010258d:	e8 ab df ff ff       	call   8010053d <panic>
  
  return 0;
80102592:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102597:	c9                   	leave  
80102598:	c3                   	ret    

80102599 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102599:	55                   	push   %ebp
8010259a:	89 e5                	mov    %esp,%ebp
8010259c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010259f:	eb 04                	jmp    801025a5 <skipelem+0xc>
    path++;
801025a1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801025a5:	8b 45 08             	mov    0x8(%ebp),%eax
801025a8:	0f b6 00             	movzbl (%eax),%eax
801025ab:	3c 2f                	cmp    $0x2f,%al
801025ad:	74 f2                	je     801025a1 <skipelem+0x8>
    path++;
  if(*path == 0)
801025af:	8b 45 08             	mov    0x8(%ebp),%eax
801025b2:	0f b6 00             	movzbl (%eax),%eax
801025b5:	84 c0                	test   %al,%al
801025b7:	75 0a                	jne    801025c3 <skipelem+0x2a>
    return 0;
801025b9:	b8 00 00 00 00       	mov    $0x0,%eax
801025be:	e9 86 00 00 00       	jmp    80102649 <skipelem+0xb0>
  s = path;
801025c3:	8b 45 08             	mov    0x8(%ebp),%eax
801025c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801025c9:	eb 04                	jmp    801025cf <skipelem+0x36>
    path++;
801025cb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801025cf:	8b 45 08             	mov    0x8(%ebp),%eax
801025d2:	0f b6 00             	movzbl (%eax),%eax
801025d5:	3c 2f                	cmp    $0x2f,%al
801025d7:	74 0a                	je     801025e3 <skipelem+0x4a>
801025d9:	8b 45 08             	mov    0x8(%ebp),%eax
801025dc:	0f b6 00             	movzbl (%eax),%eax
801025df:	84 c0                	test   %al,%al
801025e1:	75 e8                	jne    801025cb <skipelem+0x32>
    path++;
  len = path - s;
801025e3:	8b 55 08             	mov    0x8(%ebp),%edx
801025e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e9:	89 d1                	mov    %edx,%ecx
801025eb:	29 c1                	sub    %eax,%ecx
801025ed:	89 c8                	mov    %ecx,%eax
801025ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801025f2:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801025f6:	7e 1c                	jle    80102614 <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
801025f8:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801025ff:	00 
80102600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102603:	89 44 24 04          	mov    %eax,0x4(%esp)
80102607:	8b 45 0c             	mov    0xc(%ebp),%eax
8010260a:	89 04 24             	mov    %eax,(%esp)
8010260d:	e8 ff 2e 00 00       	call   80105511 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102612:	eb 28                	jmp    8010263c <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102614:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102617:	89 44 24 08          	mov    %eax,0x8(%esp)
8010261b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010261e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102622:	8b 45 0c             	mov    0xc(%ebp),%eax
80102625:	89 04 24             	mov    %eax,(%esp)
80102628:	e8 e4 2e 00 00       	call   80105511 <memmove>
    name[len] = 0;
8010262d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102630:	03 45 0c             	add    0xc(%ebp),%eax
80102633:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102636:	eb 04                	jmp    8010263c <skipelem+0xa3>
    path++;
80102638:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010263c:	8b 45 08             	mov    0x8(%ebp),%eax
8010263f:	0f b6 00             	movzbl (%eax),%eax
80102642:	3c 2f                	cmp    $0x2f,%al
80102644:	74 f2                	je     80102638 <skipelem+0x9f>
    path++;
  return path;
80102646:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102649:	c9                   	leave  
8010264a:	c3                   	ret    

8010264b <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010264b:	55                   	push   %ebp
8010264c:	89 e5                	mov    %esp,%ebp
8010264e:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102651:	8b 45 08             	mov    0x8(%ebp),%eax
80102654:	0f b6 00             	movzbl (%eax),%eax
80102657:	3c 2f                	cmp    $0x2f,%al
80102659:	75 1c                	jne    80102677 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
8010265b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102662:	00 
80102663:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010266a:	e8 4d f4 ff ff       	call   80101abc <iget>
8010266f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102672:	e9 af 00 00 00       	jmp    80102726 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102677:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010267d:	8b 40 68             	mov    0x68(%eax),%eax
80102680:	89 04 24             	mov    %eax,(%esp)
80102683:	e8 06 f5 ff ff       	call   80101b8e <idup>
80102688:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010268b:	e9 96 00 00 00       	jmp    80102726 <namex+0xdb>
    ilock(ip);
80102690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102693:	89 04 24             	mov    %eax,(%esp)
80102696:	e8 25 f5 ff ff       	call   80101bc0 <ilock>
    if(ip->type != T_DIR){
8010269b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010269e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801026a2:	66 83 f8 01          	cmp    $0x1,%ax
801026a6:	74 15                	je     801026bd <namex+0x72>
      iunlockput(ip);
801026a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026ab:	89 04 24             	mov    %eax,(%esp)
801026ae:	e8 91 f7 ff ff       	call   80101e44 <iunlockput>
      return 0;
801026b3:	b8 00 00 00 00       	mov    $0x0,%eax
801026b8:	e9 a3 00 00 00       	jmp    80102760 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
801026bd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801026c1:	74 1d                	je     801026e0 <namex+0x95>
801026c3:	8b 45 08             	mov    0x8(%ebp),%eax
801026c6:	0f b6 00             	movzbl (%eax),%eax
801026c9:	84 c0                	test   %al,%al
801026cb:	75 13                	jne    801026e0 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
801026cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d0:	89 04 24             	mov    %eax,(%esp)
801026d3:	e8 36 f6 ff ff       	call   80101d0e <iunlock>
      return ip;
801026d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026db:	e9 80 00 00 00       	jmp    80102760 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801026e0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801026e7:	00 
801026e8:	8b 45 10             	mov    0x10(%ebp),%eax
801026eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801026ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f2:	89 04 24             	mov    %eax,(%esp)
801026f5:	e8 df fc ff ff       	call   801023d9 <dirlookup>
801026fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
801026fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102701:	75 12                	jne    80102715 <namex+0xca>
      iunlockput(ip);
80102703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102706:	89 04 24             	mov    %eax,(%esp)
80102709:	e8 36 f7 ff ff       	call   80101e44 <iunlockput>
      return 0;
8010270e:	b8 00 00 00 00       	mov    $0x0,%eax
80102713:	eb 4b                	jmp    80102760 <namex+0x115>
    }
    iunlockput(ip);
80102715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102718:	89 04 24             	mov    %eax,(%esp)
8010271b:	e8 24 f7 ff ff       	call   80101e44 <iunlockput>
    ip = next;
80102720:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102723:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102726:	8b 45 10             	mov    0x10(%ebp),%eax
80102729:	89 44 24 04          	mov    %eax,0x4(%esp)
8010272d:	8b 45 08             	mov    0x8(%ebp),%eax
80102730:	89 04 24             	mov    %eax,(%esp)
80102733:	e8 61 fe ff ff       	call   80102599 <skipelem>
80102738:	89 45 08             	mov    %eax,0x8(%ebp)
8010273b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010273f:	0f 85 4b ff ff ff    	jne    80102690 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102745:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102749:	74 12                	je     8010275d <namex+0x112>
    iput(ip);
8010274b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010274e:	89 04 24             	mov    %eax,(%esp)
80102751:	e8 1d f6 ff ff       	call   80101d73 <iput>
    return 0;
80102756:	b8 00 00 00 00       	mov    $0x0,%eax
8010275b:	eb 03                	jmp    80102760 <namex+0x115>
  }
  return ip;
8010275d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102760:	c9                   	leave  
80102761:	c3                   	ret    

80102762 <namei>:

struct inode*
namei(char *path)
{
80102762:	55                   	push   %ebp
80102763:	89 e5                	mov    %esp,%ebp
80102765:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102768:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010276b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010276f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102776:	00 
80102777:	8b 45 08             	mov    0x8(%ebp),%eax
8010277a:	89 04 24             	mov    %eax,(%esp)
8010277d:	e8 c9 fe ff ff       	call   8010264b <namex>
}
80102782:	c9                   	leave  
80102783:	c3                   	ret    

80102784 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102784:	55                   	push   %ebp
80102785:	89 e5                	mov    %esp,%ebp
80102787:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010278a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010278d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102791:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102798:	00 
80102799:	8b 45 08             	mov    0x8(%ebp),%eax
8010279c:	89 04 24             	mov    %eax,(%esp)
8010279f:	e8 a7 fe ff ff       	call   8010264b <namex>
}
801027a4:	c9                   	leave  
801027a5:	c3                   	ret    
	...

801027a8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801027a8:	55                   	push   %ebp
801027a9:	89 e5                	mov    %esp,%ebp
801027ab:	53                   	push   %ebx
801027ac:	83 ec 14             	sub    $0x14,%esp
801027af:	8b 45 08             	mov    0x8(%ebp),%eax
801027b2:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801027b6:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801027ba:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801027be:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801027c2:	ec                   	in     (%dx),%al
801027c3:	89 c3                	mov    %eax,%ebx
801027c5:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801027c8:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801027cc:	83 c4 14             	add    $0x14,%esp
801027cf:	5b                   	pop    %ebx
801027d0:	5d                   	pop    %ebp
801027d1:	c3                   	ret    

801027d2 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801027d2:	55                   	push   %ebp
801027d3:	89 e5                	mov    %esp,%ebp
801027d5:	57                   	push   %edi
801027d6:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801027d7:	8b 55 08             	mov    0x8(%ebp),%edx
801027da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801027dd:	8b 45 10             	mov    0x10(%ebp),%eax
801027e0:	89 cb                	mov    %ecx,%ebx
801027e2:	89 df                	mov    %ebx,%edi
801027e4:	89 c1                	mov    %eax,%ecx
801027e6:	fc                   	cld    
801027e7:	f3 6d                	rep insl (%dx),%es:(%edi)
801027e9:	89 c8                	mov    %ecx,%eax
801027eb:	89 fb                	mov    %edi,%ebx
801027ed:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801027f0:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801027f3:	5b                   	pop    %ebx
801027f4:	5f                   	pop    %edi
801027f5:	5d                   	pop    %ebp
801027f6:	c3                   	ret    

801027f7 <outb>:

static inline void
outb(ushort port, uchar data)
{
801027f7:	55                   	push   %ebp
801027f8:	89 e5                	mov    %esp,%ebp
801027fa:	83 ec 08             	sub    $0x8,%esp
801027fd:	8b 55 08             	mov    0x8(%ebp),%edx
80102800:	8b 45 0c             	mov    0xc(%ebp),%eax
80102803:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102807:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010280a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010280e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102812:	ee                   	out    %al,(%dx)
}
80102813:	c9                   	leave  
80102814:	c3                   	ret    

80102815 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102815:	55                   	push   %ebp
80102816:	89 e5                	mov    %esp,%ebp
80102818:	56                   	push   %esi
80102819:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010281a:	8b 55 08             	mov    0x8(%ebp),%edx
8010281d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102820:	8b 45 10             	mov    0x10(%ebp),%eax
80102823:	89 cb                	mov    %ecx,%ebx
80102825:	89 de                	mov    %ebx,%esi
80102827:	89 c1                	mov    %eax,%ecx
80102829:	fc                   	cld    
8010282a:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010282c:	89 c8                	mov    %ecx,%eax
8010282e:	89 f3                	mov    %esi,%ebx
80102830:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102833:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102836:	5b                   	pop    %ebx
80102837:	5e                   	pop    %esi
80102838:	5d                   	pop    %ebp
80102839:	c3                   	ret    

8010283a <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010283a:	55                   	push   %ebp
8010283b:	89 e5                	mov    %esp,%ebp
8010283d:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102840:	90                   	nop
80102841:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102848:	e8 5b ff ff ff       	call   801027a8 <inb>
8010284d:	0f b6 c0             	movzbl %al,%eax
80102850:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102853:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102856:	25 c0 00 00 00       	and    $0xc0,%eax
8010285b:	83 f8 40             	cmp    $0x40,%eax
8010285e:	75 e1                	jne    80102841 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102860:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102864:	74 11                	je     80102877 <idewait+0x3d>
80102866:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102869:	83 e0 21             	and    $0x21,%eax
8010286c:	85 c0                	test   %eax,%eax
8010286e:	74 07                	je     80102877 <idewait+0x3d>
    return -1;
80102870:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102875:	eb 05                	jmp    8010287c <idewait+0x42>
  return 0;
80102877:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010287c:	c9                   	leave  
8010287d:	c3                   	ret    

8010287e <ideinit>:

void
ideinit(void)
{
8010287e:	55                   	push   %ebp
8010287f:	89 e5                	mov    %esp,%ebp
80102881:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102884:	c7 44 24 04 e4 89 10 	movl   $0x801089e4,0x4(%esp)
8010288b:	80 
8010288c:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102893:	e8 36 29 00 00       	call   801051ce <initlock>
  picenable(IRQ_IDE);
80102898:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010289f:	e8 75 15 00 00       	call   80103e19 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
801028a4:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
801028a9:	83 e8 01             	sub    $0x1,%eax
801028ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801028b0:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801028b7:	e8 12 04 00 00       	call   80102cce <ioapicenable>
  idewait(0);
801028bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028c3:	e8 72 ff ff ff       	call   8010283a <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801028c8:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801028cf:	00 
801028d0:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028d7:	e8 1b ff ff ff       	call   801027f7 <outb>
  for(i=0; i<1000; i++){
801028dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801028e3:	eb 20                	jmp    80102905 <ideinit+0x87>
    if(inb(0x1f7) != 0){
801028e5:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801028ec:	e8 b7 fe ff ff       	call   801027a8 <inb>
801028f1:	84 c0                	test   %al,%al
801028f3:	74 0c                	je     80102901 <ideinit+0x83>
      havedisk1 = 1;
801028f5:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
801028fc:	00 00 00 
      break;
801028ff:	eb 0d                	jmp    8010290e <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102901:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102905:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010290c:	7e d7                	jle    801028e5 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010290e:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102915:	00 
80102916:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010291d:	e8 d5 fe ff ff       	call   801027f7 <outb>
}
80102922:	c9                   	leave  
80102923:	c3                   	ret    

80102924 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102924:	55                   	push   %ebp
80102925:	89 e5                	mov    %esp,%ebp
80102927:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
8010292a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010292e:	75 0c                	jne    8010293c <idestart+0x18>
    panic("idestart");
80102930:	c7 04 24 e8 89 10 80 	movl   $0x801089e8,(%esp)
80102937:	e8 01 dc ff ff       	call   8010053d <panic>

  idewait(0);
8010293c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102943:	e8 f2 fe ff ff       	call   8010283a <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102948:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010294f:	00 
80102950:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102957:	e8 9b fe ff ff       	call   801027f7 <outb>
  outb(0x1f2, 1);  // number of sectors
8010295c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102963:	00 
80102964:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
8010296b:	e8 87 fe ff ff       	call   801027f7 <outb>
  outb(0x1f3, b->sector & 0xff);
80102970:	8b 45 08             	mov    0x8(%ebp),%eax
80102973:	8b 40 08             	mov    0x8(%eax),%eax
80102976:	0f b6 c0             	movzbl %al,%eax
80102979:	89 44 24 04          	mov    %eax,0x4(%esp)
8010297d:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102984:	e8 6e fe ff ff       	call   801027f7 <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
80102989:	8b 45 08             	mov    0x8(%ebp),%eax
8010298c:	8b 40 08             	mov    0x8(%eax),%eax
8010298f:	c1 e8 08             	shr    $0x8,%eax
80102992:	0f b6 c0             	movzbl %al,%eax
80102995:	89 44 24 04          	mov    %eax,0x4(%esp)
80102999:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801029a0:	e8 52 fe ff ff       	call   801027f7 <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
801029a5:	8b 45 08             	mov    0x8(%ebp),%eax
801029a8:	8b 40 08             	mov    0x8(%eax),%eax
801029ab:	c1 e8 10             	shr    $0x10,%eax
801029ae:	0f b6 c0             	movzbl %al,%eax
801029b1:	89 44 24 04          	mov    %eax,0x4(%esp)
801029b5:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801029bc:	e8 36 fe ff ff       	call   801027f7 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
801029c1:	8b 45 08             	mov    0x8(%ebp),%eax
801029c4:	8b 40 04             	mov    0x4(%eax),%eax
801029c7:	83 e0 01             	and    $0x1,%eax
801029ca:	89 c2                	mov    %eax,%edx
801029cc:	c1 e2 04             	shl    $0x4,%edx
801029cf:	8b 45 08             	mov    0x8(%ebp),%eax
801029d2:	8b 40 08             	mov    0x8(%eax),%eax
801029d5:	c1 e8 18             	shr    $0x18,%eax
801029d8:	83 e0 0f             	and    $0xf,%eax
801029db:	09 d0                	or     %edx,%eax
801029dd:	83 c8 e0             	or     $0xffffffe0,%eax
801029e0:	0f b6 c0             	movzbl %al,%eax
801029e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801029e7:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801029ee:	e8 04 fe ff ff       	call   801027f7 <outb>
  if(b->flags & B_DIRTY){
801029f3:	8b 45 08             	mov    0x8(%ebp),%eax
801029f6:	8b 00                	mov    (%eax),%eax
801029f8:	83 e0 04             	and    $0x4,%eax
801029fb:	85 c0                	test   %eax,%eax
801029fd:	74 34                	je     80102a33 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
801029ff:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102a06:	00 
80102a07:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a0e:	e8 e4 fd ff ff       	call   801027f7 <outb>
    outsl(0x1f0, b->data, 512/4);
80102a13:	8b 45 08             	mov    0x8(%ebp),%eax
80102a16:	83 c0 18             	add    $0x18,%eax
80102a19:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102a20:	00 
80102a21:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a25:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102a2c:	e8 e4 fd ff ff       	call   80102815 <outsl>
80102a31:	eb 14                	jmp    80102a47 <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102a33:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102a3a:	00 
80102a3b:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a42:	e8 b0 fd ff ff       	call   801027f7 <outb>
  }
}
80102a47:	c9                   	leave  
80102a48:	c3                   	ret    

80102a49 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102a49:	55                   	push   %ebp
80102a4a:	89 e5                	mov    %esp,%ebp
80102a4c:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a4f:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102a56:	e8 94 27 00 00       	call   801051ef <acquire>
  if((b = idequeue) == 0){
80102a5b:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102a60:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a63:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a67:	75 11                	jne    80102a7a <ideintr+0x31>
    release(&idelock);
80102a69:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102a70:	e8 dc 27 00 00       	call   80105251 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102a75:	e9 90 00 00 00       	jmp    80102b0a <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a7d:	8b 40 14             	mov    0x14(%eax),%eax
80102a80:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a88:	8b 00                	mov    (%eax),%eax
80102a8a:	83 e0 04             	and    $0x4,%eax
80102a8d:	85 c0                	test   %eax,%eax
80102a8f:	75 2e                	jne    80102abf <ideintr+0x76>
80102a91:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102a98:	e8 9d fd ff ff       	call   8010283a <idewait>
80102a9d:	85 c0                	test   %eax,%eax
80102a9f:	78 1e                	js     80102abf <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa4:	83 c0 18             	add    $0x18,%eax
80102aa7:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102aae:	00 
80102aaf:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ab3:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102aba:	e8 13 fd ff ff       	call   801027d2 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac2:	8b 00                	mov    (%eax),%eax
80102ac4:	89 c2                	mov    %eax,%edx
80102ac6:	83 ca 02             	or     $0x2,%edx
80102ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102acc:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad1:	8b 00                	mov    (%eax),%eax
80102ad3:	89 c2                	mov    %eax,%edx
80102ad5:	83 e2 fb             	and    $0xfffffffb,%edx
80102ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102adb:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae0:	89 04 24             	mov    %eax,(%esp)
80102ae3:	e8 7a 24 00 00       	call   80104f62 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102ae8:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102aed:	85 c0                	test   %eax,%eax
80102aef:	74 0d                	je     80102afe <ideintr+0xb5>
    idestart(idequeue);
80102af1:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102af6:	89 04 24             	mov    %eax,(%esp)
80102af9:	e8 26 fe ff ff       	call   80102924 <idestart>

  release(&idelock);
80102afe:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102b05:	e8 47 27 00 00       	call   80105251 <release>
}
80102b0a:	c9                   	leave  
80102b0b:	c3                   	ret    

80102b0c <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102b0c:	55                   	push   %ebp
80102b0d:	89 e5                	mov    %esp,%ebp
80102b0f:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102b12:	8b 45 08             	mov    0x8(%ebp),%eax
80102b15:	8b 00                	mov    (%eax),%eax
80102b17:	83 e0 01             	and    $0x1,%eax
80102b1a:	85 c0                	test   %eax,%eax
80102b1c:	75 0c                	jne    80102b2a <iderw+0x1e>
    panic("iderw: buf not busy");
80102b1e:	c7 04 24 f1 89 10 80 	movl   $0x801089f1,(%esp)
80102b25:	e8 13 da ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102b2a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b2d:	8b 00                	mov    (%eax),%eax
80102b2f:	83 e0 06             	and    $0x6,%eax
80102b32:	83 f8 02             	cmp    $0x2,%eax
80102b35:	75 0c                	jne    80102b43 <iderw+0x37>
    panic("iderw: nothing to do");
80102b37:	c7 04 24 05 8a 10 80 	movl   $0x80108a05,(%esp)
80102b3e:	e8 fa d9 ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
80102b43:	8b 45 08             	mov    0x8(%ebp),%eax
80102b46:	8b 40 04             	mov    0x4(%eax),%eax
80102b49:	85 c0                	test   %eax,%eax
80102b4b:	74 15                	je     80102b62 <iderw+0x56>
80102b4d:	a1 38 b6 10 80       	mov    0x8010b638,%eax
80102b52:	85 c0                	test   %eax,%eax
80102b54:	75 0c                	jne    80102b62 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80102b56:	c7 04 24 1a 8a 10 80 	movl   $0x80108a1a,(%esp)
80102b5d:	e8 db d9 ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC: acquire-lock
80102b62:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102b69:	e8 81 26 00 00       	call   801051ef <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102b6e:	8b 45 08             	mov    0x8(%ebp),%eax
80102b71:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC: insert-queue
80102b78:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102b7f:	eb 0b                	jmp    80102b8c <iderw+0x80>
80102b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b84:	8b 00                	mov    (%eax),%eax
80102b86:	83 c0 14             	add    $0x14,%eax
80102b89:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b8f:	8b 00                	mov    (%eax),%eax
80102b91:	85 c0                	test   %eax,%eax
80102b93:	75 ec                	jne    80102b81 <iderw+0x75>
    ;
  *pp = b;
80102b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b98:	8b 55 08             	mov    0x8(%ebp),%edx
80102b9b:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102b9d:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102ba2:	3b 45 08             	cmp    0x8(%ebp),%eax
80102ba5:	75 22                	jne    80102bc9 <iderw+0xbd>
    idestart(b);
80102ba7:	8b 45 08             	mov    0x8(%ebp),%eax
80102baa:	89 04 24             	mov    %eax,(%esp)
80102bad:	e8 72 fd ff ff       	call   80102924 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bb2:	eb 15                	jmp    80102bc9 <iderw+0xbd>
    sleep(b, &idelock);
80102bb4:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
80102bbb:	80 
80102bbc:	8b 45 08             	mov    0x8(%ebp),%eax
80102bbf:	89 04 24             	mov    %eax,(%esp)
80102bc2:	e8 bf 22 00 00       	call   80104e86 <sleep>
80102bc7:	eb 01                	jmp    80102bca <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bc9:	90                   	nop
80102bca:	8b 45 08             	mov    0x8(%ebp),%eax
80102bcd:	8b 00                	mov    (%eax),%eax
80102bcf:	83 e0 06             	and    $0x6,%eax
80102bd2:	83 f8 02             	cmp    $0x2,%eax
80102bd5:	75 dd                	jne    80102bb4 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
80102bd7:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102bde:	e8 6e 26 00 00       	call   80105251 <release>
}
80102be3:	c9                   	leave  
80102be4:	c3                   	ret    
80102be5:	00 00                	add    %al,(%eax)
	...

80102be8 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102be8:	55                   	push   %ebp
80102be9:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102beb:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102bf0:	8b 55 08             	mov    0x8(%ebp),%edx
80102bf3:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102bf5:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102bfa:	8b 40 10             	mov    0x10(%eax),%eax
}
80102bfd:	5d                   	pop    %ebp
80102bfe:	c3                   	ret    

80102bff <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102bff:	55                   	push   %ebp
80102c00:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c02:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102c07:	8b 55 08             	mov    0x8(%ebp),%edx
80102c0a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102c0c:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102c11:	8b 55 0c             	mov    0xc(%ebp),%edx
80102c14:	89 50 10             	mov    %edx,0x10(%eax)
}
80102c17:	5d                   	pop    %ebp
80102c18:	c3                   	ret    

80102c19 <ioapicinit>:

void
ioapicinit(void)
{
80102c19:	55                   	push   %ebp
80102c1a:	89 e5                	mov    %esp,%ebp
80102c1c:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102c1f:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102c24:	85 c0                	test   %eax,%eax
80102c26:	0f 84 9f 00 00 00    	je     80102ccb <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102c2c:	c7 05 54 f8 10 80 00 	movl   $0xfec00000,0x8010f854
80102c33:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c36:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102c3d:	e8 a6 ff ff ff       	call   80102be8 <ioapicread>
80102c42:	c1 e8 10             	shr    $0x10,%eax
80102c45:	25 ff 00 00 00       	and    $0xff,%eax
80102c4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102c54:	e8 8f ff ff ff       	call   80102be8 <ioapicread>
80102c59:	c1 e8 18             	shr    $0x18,%eax
80102c5c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c5f:	0f b6 05 20 f9 10 80 	movzbl 0x8010f920,%eax
80102c66:	0f b6 c0             	movzbl %al,%eax
80102c69:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102c6c:	74 0c                	je     80102c7a <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c6e:	c7 04 24 38 8a 10 80 	movl   $0x80108a38,(%esp)
80102c75:	e8 27 d7 ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c81:	eb 3e                	jmp    80102cc1 <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c86:	83 c0 20             	add    $0x20,%eax
80102c89:	0d 00 00 01 00       	or     $0x10000,%eax
80102c8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102c91:	83 c2 08             	add    $0x8,%edx
80102c94:	01 d2                	add    %edx,%edx
80102c96:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c9a:	89 14 24             	mov    %edx,(%esp)
80102c9d:	e8 5d ff ff ff       	call   80102bff <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ca5:	83 c0 08             	add    $0x8,%eax
80102ca8:	01 c0                	add    %eax,%eax
80102caa:	83 c0 01             	add    $0x1,%eax
80102cad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102cb4:	00 
80102cb5:	89 04 24             	mov    %eax,(%esp)
80102cb8:	e8 42 ff ff ff       	call   80102bff <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102cbd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102cc7:	7e ba                	jle    80102c83 <ioapicinit+0x6a>
80102cc9:	eb 01                	jmp    80102ccc <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102ccb:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102ccc:	c9                   	leave  
80102ccd:	c3                   	ret    

80102cce <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102cce:	55                   	push   %ebp
80102ccf:	89 e5                	mov    %esp,%ebp
80102cd1:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102cd4:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102cd9:	85 c0                	test   %eax,%eax
80102cdb:	74 39                	je     80102d16 <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102cdd:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce0:	83 c0 20             	add    $0x20,%eax
80102ce3:	8b 55 08             	mov    0x8(%ebp),%edx
80102ce6:	83 c2 08             	add    $0x8,%edx
80102ce9:	01 d2                	add    %edx,%edx
80102ceb:	89 44 24 04          	mov    %eax,0x4(%esp)
80102cef:	89 14 24             	mov    %edx,(%esp)
80102cf2:	e8 08 ff ff ff       	call   80102bff <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102cf7:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cfa:	c1 e0 18             	shl    $0x18,%eax
80102cfd:	8b 55 08             	mov    0x8(%ebp),%edx
80102d00:	83 c2 08             	add    $0x8,%edx
80102d03:	01 d2                	add    %edx,%edx
80102d05:	83 c2 01             	add    $0x1,%edx
80102d08:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d0c:	89 14 24             	mov    %edx,(%esp)
80102d0f:	e8 eb fe ff ff       	call   80102bff <ioapicwrite>
80102d14:	eb 01                	jmp    80102d17 <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102d16:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102d17:	c9                   	leave  
80102d18:	c3                   	ret    
80102d19:	00 00                	add    %al,(%eax)
	...

80102d1c <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102d1c:	55                   	push   %ebp
80102d1d:	89 e5                	mov    %esp,%ebp
80102d1f:	8b 45 08             	mov    0x8(%ebp),%eax
80102d22:	05 00 00 00 80       	add    $0x80000000,%eax
80102d27:	5d                   	pop    %ebp
80102d28:	c3                   	ret    

80102d29 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102d29:	55                   	push   %ebp
80102d2a:	89 e5                	mov    %esp,%ebp
80102d2c:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102d2f:	c7 44 24 04 6a 8a 10 	movl   $0x80108a6a,0x4(%esp)
80102d36:	80 
80102d37:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102d3e:	e8 8b 24 00 00       	call   801051ce <initlock>
  kmem.use_lock = 0;
80102d43:	c7 05 94 f8 10 80 00 	movl   $0x0,0x8010f894
80102d4a:	00 00 00 
  freerange(vstart, vend);
80102d4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d50:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d54:	8b 45 08             	mov    0x8(%ebp),%eax
80102d57:	89 04 24             	mov    %eax,(%esp)
80102d5a:	e8 26 00 00 00       	call   80102d85 <freerange>
}
80102d5f:	c9                   	leave  
80102d60:	c3                   	ret    

80102d61 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d61:	55                   	push   %ebp
80102d62:	89 e5                	mov    %esp,%ebp
80102d64:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102d67:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80102d71:	89 04 24             	mov    %eax,(%esp)
80102d74:	e8 0c 00 00 00       	call   80102d85 <freerange>
  kmem.use_lock = 1;
80102d79:	c7 05 94 f8 10 80 01 	movl   $0x1,0x8010f894
80102d80:	00 00 00 
}
80102d83:	c9                   	leave  
80102d84:	c3                   	ret    

80102d85 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d85:	55                   	push   %ebp
80102d86:	89 e5                	mov    %esp,%ebp
80102d88:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d8b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d8e:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d93:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d98:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d9b:	eb 12                	jmp    80102daf <freerange+0x2a>
    kfree(p);
80102d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102da0:	89 04 24             	mov    %eax,(%esp)
80102da3:	e8 16 00 00 00       	call   80102dbe <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102da8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102db2:	05 00 10 00 00       	add    $0x1000,%eax
80102db7:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102dba:	76 e1                	jbe    80102d9d <freerange+0x18>
    kfree(p);
}
80102dbc:	c9                   	leave  
80102dbd:	c3                   	ret    

80102dbe <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102dbe:	55                   	push   %ebp
80102dbf:	89 e5                	mov    %esp,%ebp
80102dc1:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102dc4:	8b 45 08             	mov    0x8(%ebp),%eax
80102dc7:	25 ff 0f 00 00       	and    $0xfff,%eax
80102dcc:	85 c0                	test   %eax,%eax
80102dce:	75 1b                	jne    80102deb <kfree+0x2d>
80102dd0:	81 7d 08 1c 2d 11 80 	cmpl   $0x80112d1c,0x8(%ebp)
80102dd7:	72 12                	jb     80102deb <kfree+0x2d>
80102dd9:	8b 45 08             	mov    0x8(%ebp),%eax
80102ddc:	89 04 24             	mov    %eax,(%esp)
80102ddf:	e8 38 ff ff ff       	call   80102d1c <v2p>
80102de4:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102de9:	76 0c                	jbe    80102df7 <kfree+0x39>
    panic("kfree");
80102deb:	c7 04 24 6f 8a 10 80 	movl   $0x80108a6f,(%esp)
80102df2:	e8 46 d7 ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102df7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102dfe:	00 
80102dff:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102e06:	00 
80102e07:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0a:	89 04 24             	mov    %eax,(%esp)
80102e0d:	e8 2c 26 00 00       	call   8010543e <memset>

  if(kmem.use_lock)
80102e12:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e17:	85 c0                	test   %eax,%eax
80102e19:	74 0c                	je     80102e27 <kfree+0x69>
    acquire(&kmem.lock);
80102e1b:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e22:	e8 c8 23 00 00       	call   801051ef <acquire>
  r = (struct run*)v;
80102e27:	8b 45 08             	mov    0x8(%ebp),%eax
80102e2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102e2d:	8b 15 98 f8 10 80    	mov    0x8010f898,%edx
80102e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e36:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e3b:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102e40:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e45:	85 c0                	test   %eax,%eax
80102e47:	74 0c                	je     80102e55 <kfree+0x97>
    release(&kmem.lock);
80102e49:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e50:	e8 fc 23 00 00       	call   80105251 <release>
}
80102e55:	c9                   	leave  
80102e56:	c3                   	ret    

80102e57 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e57:	55                   	push   %ebp
80102e58:	89 e5                	mov    %esp,%ebp
80102e5a:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102e5d:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e62:	85 c0                	test   %eax,%eax
80102e64:	74 0c                	je     80102e72 <kalloc+0x1b>
    acquire(&kmem.lock);
80102e66:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e6d:	e8 7d 23 00 00       	call   801051ef <acquire>
  r = kmem.freelist;
80102e72:	a1 98 f8 10 80       	mov    0x8010f898,%eax
80102e77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e7a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e7e:	74 0a                	je     80102e8a <kalloc+0x33>
    kmem.freelist = r->next;
80102e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e83:	8b 00                	mov    (%eax),%eax
80102e85:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102e8a:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e8f:	85 c0                	test   %eax,%eax
80102e91:	74 0c                	je     80102e9f <kalloc+0x48>
    release(&kmem.lock);
80102e93:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e9a:	e8 b2 23 00 00       	call   80105251 <release>
  return (char*)r;
80102e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102ea2:	c9                   	leave  
80102ea3:	c3                   	ret    

80102ea4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102ea4:	55                   	push   %ebp
80102ea5:	89 e5                	mov    %esp,%ebp
80102ea7:	53                   	push   %ebx
80102ea8:	83 ec 14             	sub    $0x14,%esp
80102eab:	8b 45 08             	mov    0x8(%ebp),%eax
80102eae:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102eb2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102eb6:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102eba:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102ebe:	ec                   	in     (%dx),%al
80102ebf:	89 c3                	mov    %eax,%ebx
80102ec1:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102ec4:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102ec8:	83 c4 14             	add    $0x14,%esp
80102ecb:	5b                   	pop    %ebx
80102ecc:	5d                   	pop    %ebp
80102ecd:	c3                   	ret    

80102ece <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102ece:	55                   	push   %ebp
80102ecf:	89 e5                	mov    %esp,%ebp
80102ed1:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102ed4:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102edb:	e8 c4 ff ff ff       	call   80102ea4 <inb>
80102ee0:	0f b6 c0             	movzbl %al,%eax
80102ee3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ee9:	83 e0 01             	and    $0x1,%eax
80102eec:	85 c0                	test   %eax,%eax
80102eee:	75 0a                	jne    80102efa <kbdgetc+0x2c>
    return -1;
80102ef0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ef5:	e9 23 01 00 00       	jmp    8010301d <kbdgetc+0x14f>
  data = inb(KBDATAP);
80102efa:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102f01:	e8 9e ff ff ff       	call   80102ea4 <inb>
80102f06:	0f b6 c0             	movzbl %al,%eax
80102f09:	89 45 fc             	mov    %eax,-0x4(%ebp)
    
  if(data == 0xE0){
80102f0c:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102f13:	75 17                	jne    80102f2c <kbdgetc+0x5e>
    shift |= E0ESC;
80102f15:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f1a:	83 c8 40             	or     $0x40,%eax
80102f1d:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102f22:	b8 00 00 00 00       	mov    $0x0,%eax
80102f27:	e9 f1 00 00 00       	jmp    8010301d <kbdgetc+0x14f>
  } else if(data & 0x80){
80102f2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f2f:	25 80 00 00 00       	and    $0x80,%eax
80102f34:	85 c0                	test   %eax,%eax
80102f36:	74 45                	je     80102f7d <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102f38:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f3d:	83 e0 40             	and    $0x40,%eax
80102f40:	85 c0                	test   %eax,%eax
80102f42:	75 08                	jne    80102f4c <kbdgetc+0x7e>
80102f44:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f47:	83 e0 7f             	and    $0x7f,%eax
80102f4a:	eb 03                	jmp    80102f4f <kbdgetc+0x81>
80102f4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f4f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f52:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f55:	05 20 90 10 80       	add    $0x80109020,%eax
80102f5a:	0f b6 00             	movzbl (%eax),%eax
80102f5d:	83 c8 40             	or     $0x40,%eax
80102f60:	0f b6 c0             	movzbl %al,%eax
80102f63:	f7 d0                	not    %eax
80102f65:	89 c2                	mov    %eax,%edx
80102f67:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f6c:	21 d0                	and    %edx,%eax
80102f6e:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102f73:	b8 00 00 00 00       	mov    $0x0,%eax
80102f78:	e9 a0 00 00 00       	jmp    8010301d <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80102f7d:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f82:	83 e0 40             	and    $0x40,%eax
80102f85:	85 c0                	test   %eax,%eax
80102f87:	74 14                	je     80102f9d <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f89:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f90:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f95:	83 e0 bf             	and    $0xffffffbf,%eax
80102f98:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102f9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fa0:	05 20 90 10 80       	add    $0x80109020,%eax
80102fa5:	0f b6 00             	movzbl (%eax),%eax
80102fa8:	0f b6 d0             	movzbl %al,%edx
80102fab:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fb0:	09 d0                	or     %edx,%eax
80102fb2:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102fb7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fba:	05 20 91 10 80       	add    $0x80109120,%eax
80102fbf:	0f b6 00             	movzbl (%eax),%eax
80102fc2:	0f b6 d0             	movzbl %al,%edx
80102fc5:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fca:	31 d0                	xor    %edx,%eax
80102fcc:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102fd1:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fd6:	83 e0 03             	and    $0x3,%eax
80102fd9:	8b 04 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%eax
80102fe0:	03 45 fc             	add    -0x4(%ebp),%eax
80102fe3:	0f b6 00             	movzbl (%eax),%eax
80102fe6:	0f b6 c0             	movzbl %al,%eax
80102fe9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102fec:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102ff1:	83 e0 08             	and    $0x8,%eax
80102ff4:	85 c0                	test   %eax,%eax
80102ff6:	74 22                	je     8010301a <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
80102ff8:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102ffc:	76 0c                	jbe    8010300a <kbdgetc+0x13c>
80102ffe:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80103002:	77 06                	ja     8010300a <kbdgetc+0x13c>
      c += 'A' - 'a';
80103004:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103008:	eb 10                	jmp    8010301a <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
8010300a:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010300e:	76 0a                	jbe    8010301a <kbdgetc+0x14c>
80103010:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103014:	77 04                	ja     8010301a <kbdgetc+0x14c>
      c += 'a' - 'A';
80103016:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010301a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010301d:	c9                   	leave  
8010301e:	c3                   	ret    

8010301f <kbdintr>:

void
kbdintr(void)
{
8010301f:	55                   	push   %ebp
80103020:	89 e5                	mov    %esp,%ebp
80103022:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80103025:	c7 04 24 ce 2e 10 80 	movl   $0x80102ece,(%esp)
8010302c:	e8 94 d8 ff ff       	call   801008c5 <consoleintr>
}
80103031:	c9                   	leave  
80103032:	c3                   	ret    
	...

80103034 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103034:	55                   	push   %ebp
80103035:	89 e5                	mov    %esp,%ebp
80103037:	83 ec 08             	sub    $0x8,%esp
8010303a:	8b 55 08             	mov    0x8(%ebp),%edx
8010303d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103040:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103044:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103047:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010304b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010304f:	ee                   	out    %al,(%dx)
}
80103050:	c9                   	leave  
80103051:	c3                   	ret    

80103052 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103052:	55                   	push   %ebp
80103053:	89 e5                	mov    %esp,%ebp
80103055:	53                   	push   %ebx
80103056:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103059:	9c                   	pushf  
8010305a:	5b                   	pop    %ebx
8010305b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
8010305e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103061:	83 c4 10             	add    $0x10,%esp
80103064:	5b                   	pop    %ebx
80103065:	5d                   	pop    %ebp
80103066:	c3                   	ret    

80103067 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103067:	55                   	push   %ebp
80103068:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010306a:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
8010306f:	8b 55 08             	mov    0x8(%ebp),%edx
80103072:	c1 e2 02             	shl    $0x2,%edx
80103075:	01 c2                	add    %eax,%edx
80103077:	8b 45 0c             	mov    0xc(%ebp),%eax
8010307a:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
8010307c:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103081:	83 c0 20             	add    $0x20,%eax
80103084:	8b 00                	mov    (%eax),%eax
}
80103086:	5d                   	pop    %ebp
80103087:	c3                   	ret    

80103088 <lapicinit>:
//PAGEBREAK!

void
lapicinit(int c)
{
80103088:	55                   	push   %ebp
80103089:	89 e5                	mov    %esp,%ebp
8010308b:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
8010308e:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103093:	85 c0                	test   %eax,%eax
80103095:	0f 84 47 01 00 00    	je     801031e2 <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
8010309b:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
801030a2:	00 
801030a3:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
801030aa:	e8 b8 ff ff ff       	call   80103067 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801030af:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
801030b6:	00 
801030b7:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
801030be:	e8 a4 ff ff ff       	call   80103067 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801030c3:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
801030ca:	00 
801030cb:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030d2:	e8 90 ff ff ff       	call   80103067 <lapicw>
  lapicw(TICR, 10000000); 
801030d7:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
801030de:	00 
801030df:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
801030e6:	e8 7c ff ff ff       	call   80103067 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801030eb:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801030f2:	00 
801030f3:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
801030fa:	e8 68 ff ff ff       	call   80103067 <lapicw>
  lapicw(LINT1, MASKED);
801030ff:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103106:	00 
80103107:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
8010310e:	e8 54 ff ff ff       	call   80103067 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103113:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103118:	83 c0 30             	add    $0x30,%eax
8010311b:	8b 00                	mov    (%eax),%eax
8010311d:	c1 e8 10             	shr    $0x10,%eax
80103120:	25 ff 00 00 00       	and    $0xff,%eax
80103125:	83 f8 03             	cmp    $0x3,%eax
80103128:	76 14                	jbe    8010313e <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
8010312a:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103131:	00 
80103132:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80103139:	e8 29 ff ff ff       	call   80103067 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010313e:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80103145:	00 
80103146:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
8010314d:	e8 15 ff ff ff       	call   80103067 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103152:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103159:	00 
8010315a:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103161:	e8 01 ff ff ff       	call   80103067 <lapicw>
  lapicw(ESR, 0);
80103166:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010316d:	00 
8010316e:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103175:	e8 ed fe ff ff       	call   80103067 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010317a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103181:	00 
80103182:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103189:	e8 d9 fe ff ff       	call   80103067 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010318e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103195:	00 
80103196:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010319d:	e8 c5 fe ff ff       	call   80103067 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801031a2:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
801031a9:	00 
801031aa:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801031b1:	e8 b1 fe ff ff       	call   80103067 <lapicw>
  while(lapic[ICRLO] & DELIVS)
801031b6:	90                   	nop
801031b7:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
801031bc:	05 00 03 00 00       	add    $0x300,%eax
801031c1:	8b 00                	mov    (%eax),%eax
801031c3:	25 00 10 00 00       	and    $0x1000,%eax
801031c8:	85 c0                	test   %eax,%eax
801031ca:	75 eb                	jne    801031b7 <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801031cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031d3:	00 
801031d4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801031db:	e8 87 fe ff ff       	call   80103067 <lapicw>
801031e0:	eb 01                	jmp    801031e3 <lapicinit+0x15b>

void
lapicinit(int c)
{
  if(!lapic) 
    return;
801031e2:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801031e3:	c9                   	leave  
801031e4:	c3                   	ret    

801031e5 <cpunum>:

int
cpunum(void)
{
801031e5:	55                   	push   %ebp
801031e6:	89 e5                	mov    %esp,%ebp
801031e8:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801031eb:	e8 62 fe ff ff       	call   80103052 <readeflags>
801031f0:	25 00 02 00 00       	and    $0x200,%eax
801031f5:	85 c0                	test   %eax,%eax
801031f7:	74 29                	je     80103222 <cpunum+0x3d>
    static int n;
    if(n++ == 0)
801031f9:	a1 40 b6 10 80       	mov    0x8010b640,%eax
801031fe:	85 c0                	test   %eax,%eax
80103200:	0f 94 c2             	sete   %dl
80103203:	83 c0 01             	add    $0x1,%eax
80103206:	a3 40 b6 10 80       	mov    %eax,0x8010b640
8010320b:	84 d2                	test   %dl,%dl
8010320d:	74 13                	je     80103222 <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
8010320f:	8b 45 04             	mov    0x4(%ebp),%eax
80103212:	89 44 24 04          	mov    %eax,0x4(%esp)
80103216:	c7 04 24 78 8a 10 80 	movl   $0x80108a78,(%esp)
8010321d:	e8 7f d1 ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80103222:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103227:	85 c0                	test   %eax,%eax
80103229:	74 0f                	je     8010323a <cpunum+0x55>
    return lapic[ID]>>24;
8010322b:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103230:	83 c0 20             	add    $0x20,%eax
80103233:	8b 00                	mov    (%eax),%eax
80103235:	c1 e8 18             	shr    $0x18,%eax
80103238:	eb 05                	jmp    8010323f <cpunum+0x5a>
  return 0;
8010323a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010323f:	c9                   	leave  
80103240:	c3                   	ret    

80103241 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103241:	55                   	push   %ebp
80103242:	89 e5                	mov    %esp,%ebp
80103244:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103247:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
8010324c:	85 c0                	test   %eax,%eax
8010324e:	74 14                	je     80103264 <lapiceoi+0x23>
    lapicw(EOI, 0);
80103250:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103257:	00 
80103258:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
8010325f:	e8 03 fe ff ff       	call   80103067 <lapicw>
}
80103264:	c9                   	leave  
80103265:	c3                   	ret    

80103266 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103266:	55                   	push   %ebp
80103267:	89 e5                	mov    %esp,%ebp
}
80103269:	5d                   	pop    %ebp
8010326a:	c3                   	ret    

8010326b <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010326b:	55                   	push   %ebp
8010326c:	89 e5                	mov    %esp,%ebp
8010326e:	83 ec 1c             	sub    $0x1c,%esp
80103271:	8b 45 08             	mov    0x8(%ebp),%eax
80103274:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
80103277:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010327e:	00 
8010327f:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103286:	e8 a9 fd ff ff       	call   80103034 <outb>
  outb(IO_RTC+1, 0x0A);
8010328b:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103292:	00 
80103293:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
8010329a:	e8 95 fd ff ff       	call   80103034 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010329f:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801032a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801032a9:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801032ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
801032b1:	8d 50 02             	lea    0x2(%eax),%edx
801032b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801032b7:	c1 e8 04             	shr    $0x4,%eax
801032ba:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801032bd:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801032c1:	c1 e0 18             	shl    $0x18,%eax
801032c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801032c8:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801032cf:	e8 93 fd ff ff       	call   80103067 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801032d4:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801032db:	00 
801032dc:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801032e3:	e8 7f fd ff ff       	call   80103067 <lapicw>
  microdelay(200);
801032e8:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801032ef:	e8 72 ff ff ff       	call   80103266 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
801032f4:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801032fb:	00 
801032fc:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103303:	e8 5f fd ff ff       	call   80103067 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103308:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
8010330f:	e8 52 ff ff ff       	call   80103266 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103314:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010331b:	eb 40                	jmp    8010335d <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
8010331d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103321:	c1 e0 18             	shl    $0x18,%eax
80103324:	89 44 24 04          	mov    %eax,0x4(%esp)
80103328:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010332f:	e8 33 fd ff ff       	call   80103067 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103334:	8b 45 0c             	mov    0xc(%ebp),%eax
80103337:	c1 e8 0c             	shr    $0xc,%eax
8010333a:	80 cc 06             	or     $0x6,%ah
8010333d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103341:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103348:	e8 1a fd ff ff       	call   80103067 <lapicw>
    microdelay(200);
8010334d:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103354:	e8 0d ff ff ff       	call   80103266 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103359:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010335d:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103361:	7e ba                	jle    8010331d <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103363:	c9                   	leave  
80103364:	c3                   	ret    
80103365:	00 00                	add    %al,(%eax)
	...

80103368 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103368:	55                   	push   %ebp
80103369:	89 e5                	mov    %esp,%ebp
8010336b:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010336e:	c7 44 24 04 a4 8a 10 	movl   $0x80108aa4,0x4(%esp)
80103375:	80 
80103376:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010337d:	e8 4c 1e 00 00       	call   801051ce <initlock>
  readsb(ROOTDEV, &sb);
80103382:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103385:	89 44 24 04          	mov    %eax,0x4(%esp)
80103389:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103390:	e8 af e2 ff ff       	call   80101644 <readsb>
  log.start = sb.size - sb.nlog;
80103395:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010339b:	89 d1                	mov    %edx,%ecx
8010339d:	29 c1                	sub    %eax,%ecx
8010339f:	89 c8                	mov    %ecx,%eax
801033a1:	a3 d4 f8 10 80       	mov    %eax,0x8010f8d4
  log.size = sb.nlog;
801033a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033a9:	a3 d8 f8 10 80       	mov    %eax,0x8010f8d8
  log.dev = ROOTDEV;
801033ae:	c7 05 e0 f8 10 80 01 	movl   $0x1,0x8010f8e0
801033b5:	00 00 00 
  recover_from_log();
801033b8:	e8 97 01 00 00       	call   80103554 <recover_from_log>
}
801033bd:	c9                   	leave  
801033be:	c3                   	ret    

801033bf <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801033bf:	55                   	push   %ebp
801033c0:	89 e5                	mov    %esp,%ebp
801033c2:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033cc:	e9 89 00 00 00       	jmp    8010345a <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801033d1:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
801033d6:	03 45 f4             	add    -0xc(%ebp),%eax
801033d9:	83 c0 01             	add    $0x1,%eax
801033dc:	89 c2                	mov    %eax,%edx
801033de:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801033e3:	89 54 24 04          	mov    %edx,0x4(%esp)
801033e7:	89 04 24             	mov    %eax,(%esp)
801033ea:	e8 b7 cd ff ff       	call   801001a6 <bread>
801033ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801033f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033f5:	83 c0 10             	add    $0x10,%eax
801033f8:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
801033ff:	89 c2                	mov    %eax,%edx
80103401:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
80103406:	89 54 24 04          	mov    %edx,0x4(%esp)
8010340a:	89 04 24             	mov    %eax,(%esp)
8010340d:	e8 94 cd ff ff       	call   801001a6 <bread>
80103412:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103415:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103418:	8d 50 18             	lea    0x18(%eax),%edx
8010341b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010341e:	83 c0 18             	add    $0x18,%eax
80103421:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103428:	00 
80103429:	89 54 24 04          	mov    %edx,0x4(%esp)
8010342d:	89 04 24             	mov    %eax,(%esp)
80103430:	e8 dc 20 00 00       	call   80105511 <memmove>
    bwrite(dbuf);  // write dst to disk
80103435:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103438:	89 04 24             	mov    %eax,(%esp)
8010343b:	e8 9d cd ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
80103440:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103443:	89 04 24             	mov    %eax,(%esp)
80103446:	e8 cc cd ff ff       	call   80100217 <brelse>
    brelse(dbuf);
8010344b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010344e:	89 04 24             	mov    %eax,(%esp)
80103451:	e8 c1 cd ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103456:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010345a:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010345f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103462:	0f 8f 69 ff ff ff    	jg     801033d1 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103468:	c9                   	leave  
80103469:	c3                   	ret    

8010346a <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010346a:	55                   	push   %ebp
8010346b:	89 e5                	mov    %esp,%ebp
8010346d:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103470:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
80103475:	89 c2                	mov    %eax,%edx
80103477:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
8010347c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103480:	89 04 24             	mov    %eax,(%esp)
80103483:	e8 1e cd ff ff       	call   801001a6 <bread>
80103488:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010348b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010348e:	83 c0 18             	add    $0x18,%eax
80103491:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103494:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103497:	8b 00                	mov    (%eax),%eax
80103499:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  for (i = 0; i < log.lh.n; i++) {
8010349e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034a5:	eb 1b                	jmp    801034c2 <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
801034a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034ad:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801034b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034b4:	83 c2 10             	add    $0x10,%edx
801034b7:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801034be:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034c2:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801034c7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034ca:	7f db                	jg     801034a7 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
801034cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034cf:	89 04 24             	mov    %eax,(%esp)
801034d2:	e8 40 cd ff ff       	call   80100217 <brelse>
}
801034d7:	c9                   	leave  
801034d8:	c3                   	ret    

801034d9 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034d9:	55                   	push   %ebp
801034da:	89 e5                	mov    %esp,%ebp
801034dc:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801034df:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
801034e4:	89 c2                	mov    %eax,%edx
801034e6:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801034eb:	89 54 24 04          	mov    %edx,0x4(%esp)
801034ef:	89 04 24             	mov    %eax,(%esp)
801034f2:	e8 af cc ff ff       	call   801001a6 <bread>
801034f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034fd:	83 c0 18             	add    $0x18,%eax
80103500:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103503:	8b 15 e4 f8 10 80    	mov    0x8010f8e4,%edx
80103509:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010350c:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010350e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103515:	eb 1b                	jmp    80103532 <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
80103517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010351a:	83 c0 10             	add    $0x10,%eax
8010351d:	8b 0c 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%ecx
80103524:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103527:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010352a:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010352e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103532:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103537:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010353a:	7f db                	jg     80103517 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
8010353c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010353f:	89 04 24             	mov    %eax,(%esp)
80103542:	e8 96 cc ff ff       	call   801001dd <bwrite>
  brelse(buf);
80103547:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010354a:	89 04 24             	mov    %eax,(%esp)
8010354d:	e8 c5 cc ff ff       	call   80100217 <brelse>
}
80103552:	c9                   	leave  
80103553:	c3                   	ret    

80103554 <recover_from_log>:

static void
recover_from_log(void)
{
80103554:	55                   	push   %ebp
80103555:	89 e5                	mov    %esp,%ebp
80103557:	83 ec 08             	sub    $0x8,%esp
  read_head();      
8010355a:	e8 0b ff ff ff       	call   8010346a <read_head>
  install_trans(); // if committed, copy from log to disk
8010355f:	e8 5b fe ff ff       	call   801033bf <install_trans>
  log.lh.n = 0;
80103564:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
8010356b:	00 00 00 
  write_head(); // clear the log
8010356e:	e8 66 ff ff ff       	call   801034d9 <write_head>
}
80103573:	c9                   	leave  
80103574:	c3                   	ret    

80103575 <begin_trans>:

void
begin_trans(void)
{
80103575:	55                   	push   %ebp
80103576:	89 e5                	mov    %esp,%ebp
80103578:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
8010357b:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103582:	e8 68 1c 00 00       	call   801051ef <acquire>
  while (log.busy) {
80103587:	eb 14                	jmp    8010359d <begin_trans+0x28>
    sleep(&log, &log.lock);
80103589:	c7 44 24 04 a0 f8 10 	movl   $0x8010f8a0,0x4(%esp)
80103590:	80 
80103591:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103598:	e8 e9 18 00 00       	call   80104e86 <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
8010359d:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
801035a2:	85 c0                	test   %eax,%eax
801035a4:	75 e3                	jne    80103589 <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
801035a6:	c7 05 dc f8 10 80 01 	movl   $0x1,0x8010f8dc
801035ad:	00 00 00 
  release(&log.lock);
801035b0:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801035b7:	e8 95 1c 00 00       	call   80105251 <release>
}
801035bc:	c9                   	leave  
801035bd:	c3                   	ret    

801035be <commit_trans>:

void
commit_trans(void)
{
801035be:	55                   	push   %ebp
801035bf:	89 e5                	mov    %esp,%ebp
801035c1:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
801035c4:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801035c9:	85 c0                	test   %eax,%eax
801035cb:	7e 19                	jle    801035e6 <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
801035cd:	e8 07 ff ff ff       	call   801034d9 <write_head>
    install_trans(); // Now install writes to home locations
801035d2:	e8 e8 fd ff ff       	call   801033bf <install_trans>
    log.lh.n = 0; 
801035d7:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
801035de:	00 00 00 
    write_head();    // Erase the transaction from the log
801035e1:	e8 f3 fe ff ff       	call   801034d9 <write_head>
  }
  
  acquire(&log.lock);
801035e6:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801035ed:	e8 fd 1b 00 00       	call   801051ef <acquire>
  log.busy = 0;
801035f2:	c7 05 dc f8 10 80 00 	movl   $0x0,0x8010f8dc
801035f9:	00 00 00 
  wakeup(&log);
801035fc:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103603:	e8 5a 19 00 00       	call   80104f62 <wakeup>
  release(&log.lock);
80103608:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010360f:	e8 3d 1c 00 00       	call   80105251 <release>
}
80103614:	c9                   	leave  
80103615:	c3                   	ret    

80103616 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103616:	55                   	push   %ebp
80103617:	89 e5                	mov    %esp,%ebp
80103619:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010361c:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103621:	83 f8 09             	cmp    $0x9,%eax
80103624:	7f 12                	jg     80103638 <log_write+0x22>
80103626:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010362b:	8b 15 d8 f8 10 80    	mov    0x8010f8d8,%edx
80103631:	83 ea 01             	sub    $0x1,%edx
80103634:	39 d0                	cmp    %edx,%eax
80103636:	7c 0c                	jl     80103644 <log_write+0x2e>
    panic("too big a transaction");
80103638:	c7 04 24 a8 8a 10 80 	movl   $0x80108aa8,(%esp)
8010363f:	e8 f9 ce ff ff       	call   8010053d <panic>
  if (!log.busy)
80103644:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
80103649:	85 c0                	test   %eax,%eax
8010364b:	75 0c                	jne    80103659 <log_write+0x43>
    panic("write outside of trans");
8010364d:	c7 04 24 be 8a 10 80 	movl   $0x80108abe,(%esp)
80103654:	e8 e4 ce ff ff       	call   8010053d <panic>

  for (i = 0; i < log.lh.n; i++) {
80103659:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103660:	eb 1d                	jmp    8010367f <log_write+0x69>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
80103662:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103665:	83 c0 10             	add    $0x10,%eax
80103668:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
8010366f:	89 c2                	mov    %eax,%edx
80103671:	8b 45 08             	mov    0x8(%ebp),%eax
80103674:	8b 40 08             	mov    0x8(%eax),%eax
80103677:	39 c2                	cmp    %eax,%edx
80103679:	74 10                	je     8010368b <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
8010367b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010367f:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103684:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103687:	7f d9                	jg     80103662 <log_write+0x4c>
80103689:	eb 01                	jmp    8010368c <log_write+0x76>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
8010368b:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
8010368c:	8b 45 08             	mov    0x8(%ebp),%eax
8010368f:	8b 40 08             	mov    0x8(%eax),%eax
80103692:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103695:	83 c2 10             	add    $0x10,%edx
80103698:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
8010369f:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
801036a4:	03 45 f4             	add    -0xc(%ebp),%eax
801036a7:	83 c0 01             	add    $0x1,%eax
801036aa:	89 c2                	mov    %eax,%edx
801036ac:	8b 45 08             	mov    0x8(%ebp),%eax
801036af:	8b 40 04             	mov    0x4(%eax),%eax
801036b2:	89 54 24 04          	mov    %edx,0x4(%esp)
801036b6:	89 04 24             	mov    %eax,(%esp)
801036b9:	e8 e8 ca ff ff       	call   801001a6 <bread>
801036be:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
801036c1:	8b 45 08             	mov    0x8(%ebp),%eax
801036c4:	8d 50 18             	lea    0x18(%eax),%edx
801036c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036ca:	83 c0 18             	add    $0x18,%eax
801036cd:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801036d4:	00 
801036d5:	89 54 24 04          	mov    %edx,0x4(%esp)
801036d9:	89 04 24             	mov    %eax,(%esp)
801036dc:	e8 30 1e 00 00       	call   80105511 <memmove>
  bwrite(lbuf);
801036e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036e4:	89 04 24             	mov    %eax,(%esp)
801036e7:	e8 f1 ca ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
801036ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036ef:	89 04 24             	mov    %eax,(%esp)
801036f2:	e8 20 cb ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
801036f7:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801036fc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036ff:	75 0d                	jne    8010370e <log_write+0xf8>
    log.lh.n++;
80103701:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103706:	83 c0 01             	add    $0x1,%eax
80103709:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  b->flags |= B_DIRTY; // XXX prevent eviction
8010370e:	8b 45 08             	mov    0x8(%ebp),%eax
80103711:	8b 00                	mov    (%eax),%eax
80103713:	89 c2                	mov    %eax,%edx
80103715:	83 ca 04             	or     $0x4,%edx
80103718:	8b 45 08             	mov    0x8(%ebp),%eax
8010371b:	89 10                	mov    %edx,(%eax)
}
8010371d:	c9                   	leave  
8010371e:	c3                   	ret    
	...

80103720 <v2p>:
80103720:	55                   	push   %ebp
80103721:	89 e5                	mov    %esp,%ebp
80103723:	8b 45 08             	mov    0x8(%ebp),%eax
80103726:	05 00 00 00 80       	add    $0x80000000,%eax
8010372b:	5d                   	pop    %ebp
8010372c:	c3                   	ret    

8010372d <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010372d:	55                   	push   %ebp
8010372e:	89 e5                	mov    %esp,%ebp
80103730:	8b 45 08             	mov    0x8(%ebp),%eax
80103733:	05 00 00 00 80       	add    $0x80000000,%eax
80103738:	5d                   	pop    %ebp
80103739:	c3                   	ret    

8010373a <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010373a:	55                   	push   %ebp
8010373b:	89 e5                	mov    %esp,%ebp
8010373d:	53                   	push   %ebx
8010373e:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80103741:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103744:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80103747:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010374a:	89 c3                	mov    %eax,%ebx
8010374c:	89 d8                	mov    %ebx,%eax
8010374e:	f0 87 02             	lock xchg %eax,(%edx)
80103751:	89 c3                	mov    %eax,%ebx
80103753:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103756:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103759:	83 c4 10             	add    $0x10,%esp
8010375c:	5b                   	pop    %ebx
8010375d:	5d                   	pop    %ebp
8010375e:	c3                   	ret    

8010375f <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010375f:	55                   	push   %ebp
80103760:	89 e5                	mov    %esp,%ebp
80103762:	83 e4 f0             	and    $0xfffffff0,%esp
80103765:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103768:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
8010376f:	80 
80103770:	c7 04 24 1c 2d 11 80 	movl   $0x80112d1c,(%esp)
80103777:	e8 ad f5 ff ff       	call   80102d29 <kinit1>
  kvmalloc();      // kernel page table
8010377c:	e8 81 49 00 00       	call   80108102 <kvmalloc>
  mpinit();        // collect info about this machine
80103781:	e8 63 04 00 00       	call   80103be9 <mpinit>
  lapicinit(mpbcpu());
80103786:	e8 2e 02 00 00       	call   801039b9 <mpbcpu>
8010378b:	89 04 24             	mov    %eax,(%esp)
8010378e:	e8 f5 f8 ff ff       	call   80103088 <lapicinit>
  seginit();       // set up segments
80103793:	e8 0d 43 00 00       	call   80107aa5 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103798:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010379e:	0f b6 00             	movzbl (%eax),%eax
801037a1:	0f b6 c0             	movzbl %al,%eax
801037a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801037a8:	c7 04 24 d5 8a 10 80 	movl   $0x80108ad5,(%esp)
801037af:	e8 ed cb ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
801037b4:	e8 95 06 00 00       	call   80103e4e <picinit>
  ioapicinit();    // another interrupt controller
801037b9:	e8 5b f4 ff ff       	call   80102c19 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801037be:	e8 20 d6 ff ff       	call   80100de3 <consoleinit>
  uartinit();      // serial port
801037c3:	e8 28 36 00 00       	call   80106df0 <uartinit>
  pinit();         // process table
801037c8:	e8 96 0b 00 00       	call   80104363 <pinit>
  tvinit();        // trap vectors
801037cd:	e8 7d 31 00 00       	call   8010694f <tvinit>
  binit();         // buffer cache
801037d2:	e8 5d c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801037d7:	e8 7c da ff ff       	call   80101258 <fileinit>
  iinit();         // inode cache
801037dc:	e8 2a e1 ff ff       	call   8010190b <iinit>
  ideinit();       // disk
801037e1:	e8 98 f0 ff ff       	call   8010287e <ideinit>
  if(!ismp)
801037e6:	a1 24 f9 10 80       	mov    0x8010f924,%eax
801037eb:	85 c0                	test   %eax,%eax
801037ed:	75 05                	jne    801037f4 <main+0x95>
    timerinit();   // uniprocessor timer
801037ef:	e8 9e 30 00 00       	call   80106892 <timerinit>
  startothers();   // start other processors
801037f4:	e8 87 00 00 00       	call   80103880 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037f9:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103800:	8e 
80103801:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103808:	e8 54 f5 ff ff       	call   80102d61 <kinit2>
  userinit();      // first user process
8010380d:	e8 6f 0c 00 00       	call   80104481 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103812:	e8 22 00 00 00       	call   80103839 <mpmain>

80103817 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103817:	55                   	push   %ebp
80103818:	89 e5                	mov    %esp,%ebp
8010381a:	83 ec 18             	sub    $0x18,%esp
  switchkvm(); 
8010381d:	e8 f7 48 00 00       	call   80108119 <switchkvm>
  seginit();
80103822:	e8 7e 42 00 00       	call   80107aa5 <seginit>
  lapicinit(cpunum());
80103827:	e8 b9 f9 ff ff       	call   801031e5 <cpunum>
8010382c:	89 04 24             	mov    %eax,(%esp)
8010382f:	e8 54 f8 ff ff       	call   80103088 <lapicinit>
  mpmain();
80103834:	e8 00 00 00 00       	call   80103839 <mpmain>

80103839 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103839:	55                   	push   %ebp
8010383a:	89 e5                	mov    %esp,%ebp
8010383c:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010383f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103845:	0f b6 00             	movzbl (%eax),%eax
80103848:	0f b6 c0             	movzbl %al,%eax
8010384b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010384f:	c7 04 24 ec 8a 10 80 	movl   $0x80108aec,(%esp)
80103856:	e8 46 cb ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
8010385b:	e8 63 32 00 00       	call   80106ac3 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103860:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103866:	05 a8 00 00 00       	add    $0xa8,%eax
8010386b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103872:	00 
80103873:	89 04 24             	mov    %eax,(%esp)
80103876:	e8 bf fe ff ff       	call   8010373a <xchg>
  scheduler();     // start running processes
8010387b:	e8 ae 13 00 00       	call   80104c2e <scheduler>

80103880 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103880:	55                   	push   %ebp
80103881:	89 e5                	mov    %esp,%ebp
80103883:	53                   	push   %ebx
80103884:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103887:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
8010388e:	e8 9a fe ff ff       	call   8010372d <p2v>
80103893:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103896:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010389b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010389f:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
801038a6:	80 
801038a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038aa:	89 04 24             	mov    %eax,(%esp)
801038ad:	e8 5f 1c 00 00       	call   80105511 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801038b2:	c7 45 f4 40 f9 10 80 	movl   $0x8010f940,-0xc(%ebp)
801038b9:	e9 86 00 00 00       	jmp    80103944 <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
801038be:	e8 22 f9 ff ff       	call   801031e5 <cpunum>
801038c3:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801038c9:	05 40 f9 10 80       	add    $0x8010f940,%eax
801038ce:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038d1:	74 69                	je     8010393c <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801038d3:	e8 7f f5 ff ff       	call   80102e57 <kalloc>
801038d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801038db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038de:	83 e8 04             	sub    $0x4,%eax
801038e1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801038e4:	81 c2 00 10 00 00    	add    $0x1000,%edx
801038ea:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801038ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038ef:	83 e8 08             	sub    $0x8,%eax
801038f2:	c7 00 17 38 10 80    	movl   $0x80103817,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801038f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038fb:	8d 58 f4             	lea    -0xc(%eax),%ebx
801038fe:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
80103905:	e8 16 fe ff ff       	call   80103720 <v2p>
8010390a:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
8010390c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010390f:	89 04 24             	mov    %eax,(%esp)
80103912:	e8 09 fe ff ff       	call   80103720 <v2p>
80103917:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010391a:	0f b6 12             	movzbl (%edx),%edx
8010391d:	0f b6 d2             	movzbl %dl,%edx
80103920:	89 44 24 04          	mov    %eax,0x4(%esp)
80103924:	89 14 24             	mov    %edx,(%esp)
80103927:	e8 3f f9 ff ff       	call   8010326b <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010392c:	90                   	nop
8010392d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103930:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103936:	85 c0                	test   %eax,%eax
80103938:	74 f3                	je     8010392d <startothers+0xad>
8010393a:	eb 01                	jmp    8010393d <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
8010393c:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
8010393d:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103944:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103949:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010394f:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103954:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103957:	0f 87 61 ff ff ff    	ja     801038be <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
8010395d:	83 c4 24             	add    $0x24,%esp
80103960:	5b                   	pop    %ebx
80103961:	5d                   	pop    %ebp
80103962:	c3                   	ret    
	...

80103964 <p2v>:
80103964:	55                   	push   %ebp
80103965:	89 e5                	mov    %esp,%ebp
80103967:	8b 45 08             	mov    0x8(%ebp),%eax
8010396a:	05 00 00 00 80       	add    $0x80000000,%eax
8010396f:	5d                   	pop    %ebp
80103970:	c3                   	ret    

80103971 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103971:	55                   	push   %ebp
80103972:	89 e5                	mov    %esp,%ebp
80103974:	53                   	push   %ebx
80103975:	83 ec 14             	sub    $0x14,%esp
80103978:	8b 45 08             	mov    0x8(%ebp),%eax
8010397b:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010397f:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80103983:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80103987:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
8010398b:	ec                   	in     (%dx),%al
8010398c:	89 c3                	mov    %eax,%ebx
8010398e:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80103991:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80103995:	83 c4 14             	add    $0x14,%esp
80103998:	5b                   	pop    %ebx
80103999:	5d                   	pop    %ebp
8010399a:	c3                   	ret    

8010399b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010399b:	55                   	push   %ebp
8010399c:	89 e5                	mov    %esp,%ebp
8010399e:	83 ec 08             	sub    $0x8,%esp
801039a1:	8b 55 08             	mov    0x8(%ebp),%edx
801039a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801039a7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801039ab:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801039ae:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801039b2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801039b6:	ee                   	out    %al,(%dx)
}
801039b7:	c9                   	leave  
801039b8:	c3                   	ret    

801039b9 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801039b9:	55                   	push   %ebp
801039ba:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801039bc:	a1 44 b6 10 80       	mov    0x8010b644,%eax
801039c1:	89 c2                	mov    %eax,%edx
801039c3:	b8 40 f9 10 80       	mov    $0x8010f940,%eax
801039c8:	89 d1                	mov    %edx,%ecx
801039ca:	29 c1                	sub    %eax,%ecx
801039cc:	89 c8                	mov    %ecx,%eax
801039ce:	c1 f8 02             	sar    $0x2,%eax
801039d1:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801039d7:	5d                   	pop    %ebp
801039d8:	c3                   	ret    

801039d9 <sum>:

static uchar
sum(uchar *addr, int len)
{
801039d9:	55                   	push   %ebp
801039da:	89 e5                	mov    %esp,%ebp
801039dc:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801039df:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801039e6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801039ed:	eb 13                	jmp    80103a02 <sum+0x29>
    sum += addr[i];
801039ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
801039f2:	03 45 08             	add    0x8(%ebp),%eax
801039f5:	0f b6 00             	movzbl (%eax),%eax
801039f8:	0f b6 c0             	movzbl %al,%eax
801039fb:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
801039fe:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a02:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a05:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a08:	7c e5                	jl     801039ef <sum+0x16>
    sum += addr[i];
  return sum;
80103a0a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a0d:	c9                   	leave  
80103a0e:	c3                   	ret    

80103a0f <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a0f:	55                   	push   %ebp
80103a10:	89 e5                	mov    %esp,%ebp
80103a12:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103a15:	8b 45 08             	mov    0x8(%ebp),%eax
80103a18:	89 04 24             	mov    %eax,(%esp)
80103a1b:	e8 44 ff ff ff       	call   80103964 <p2v>
80103a20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a23:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a26:	03 45 f0             	add    -0x10(%ebp),%eax
80103a29:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a32:	eb 3f                	jmp    80103a73 <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a34:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a3b:	00 
80103a3c:	c7 44 24 04 00 8b 10 	movl   $0x80108b00,0x4(%esp)
80103a43:	80 
80103a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a47:	89 04 24             	mov    %eax,(%esp)
80103a4a:	e8 66 1a 00 00       	call   801054b5 <memcmp>
80103a4f:	85 c0                	test   %eax,%eax
80103a51:	75 1c                	jne    80103a6f <mpsearch1+0x60>
80103a53:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a5a:	00 
80103a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a5e:	89 04 24             	mov    %eax,(%esp)
80103a61:	e8 73 ff ff ff       	call   801039d9 <sum>
80103a66:	84 c0                	test   %al,%al
80103a68:	75 05                	jne    80103a6f <mpsearch1+0x60>
      return (struct mp*)p;
80103a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a6d:	eb 11                	jmp    80103a80 <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a6f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a76:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a79:	72 b9                	jb     80103a34 <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a80:	c9                   	leave  
80103a81:	c3                   	ret    

80103a82 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a82:	55                   	push   %ebp
80103a83:	89 e5                	mov    %esp,%ebp
80103a85:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a88:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a92:	83 c0 0f             	add    $0xf,%eax
80103a95:	0f b6 00             	movzbl (%eax),%eax
80103a98:	0f b6 c0             	movzbl %al,%eax
80103a9b:	89 c2                	mov    %eax,%edx
80103a9d:	c1 e2 08             	shl    $0x8,%edx
80103aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa3:	83 c0 0e             	add    $0xe,%eax
80103aa6:	0f b6 00             	movzbl (%eax),%eax
80103aa9:	0f b6 c0             	movzbl %al,%eax
80103aac:	09 d0                	or     %edx,%eax
80103aae:	c1 e0 04             	shl    $0x4,%eax
80103ab1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103ab4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103ab8:	74 21                	je     80103adb <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103aba:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ac1:	00 
80103ac2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ac5:	89 04 24             	mov    %eax,(%esp)
80103ac8:	e8 42 ff ff ff       	call   80103a0f <mpsearch1>
80103acd:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ad0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ad4:	74 50                	je     80103b26 <mpsearch+0xa4>
      return mp;
80103ad6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ad9:	eb 5f                	jmp    80103b3a <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ade:	83 c0 14             	add    $0x14,%eax
80103ae1:	0f b6 00             	movzbl (%eax),%eax
80103ae4:	0f b6 c0             	movzbl %al,%eax
80103ae7:	89 c2                	mov    %eax,%edx
80103ae9:	c1 e2 08             	shl    $0x8,%edx
80103aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aef:	83 c0 13             	add    $0x13,%eax
80103af2:	0f b6 00             	movzbl (%eax),%eax
80103af5:	0f b6 c0             	movzbl %al,%eax
80103af8:	09 d0                	or     %edx,%eax
80103afa:	c1 e0 0a             	shl    $0xa,%eax
80103afd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b03:	2d 00 04 00 00       	sub    $0x400,%eax
80103b08:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b0f:	00 
80103b10:	89 04 24             	mov    %eax,(%esp)
80103b13:	e8 f7 fe ff ff       	call   80103a0f <mpsearch1>
80103b18:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b1b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b1f:	74 05                	je     80103b26 <mpsearch+0xa4>
      return mp;
80103b21:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b24:	eb 14                	jmp    80103b3a <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b26:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b2d:	00 
80103b2e:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b35:	e8 d5 fe ff ff       	call   80103a0f <mpsearch1>
}
80103b3a:	c9                   	leave  
80103b3b:	c3                   	ret    

80103b3c <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b3c:	55                   	push   %ebp
80103b3d:	89 e5                	mov    %esp,%ebp
80103b3f:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b42:	e8 3b ff ff ff       	call   80103a82 <mpsearch>
80103b47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b4e:	74 0a                	je     80103b5a <mpconfig+0x1e>
80103b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b53:	8b 40 04             	mov    0x4(%eax),%eax
80103b56:	85 c0                	test   %eax,%eax
80103b58:	75 0a                	jne    80103b64 <mpconfig+0x28>
    return 0;
80103b5a:	b8 00 00 00 00       	mov    $0x0,%eax
80103b5f:	e9 83 00 00 00       	jmp    80103be7 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b67:	8b 40 04             	mov    0x4(%eax),%eax
80103b6a:	89 04 24             	mov    %eax,(%esp)
80103b6d:	e8 f2 fd ff ff       	call   80103964 <p2v>
80103b72:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b75:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b7c:	00 
80103b7d:	c7 44 24 04 05 8b 10 	movl   $0x80108b05,0x4(%esp)
80103b84:	80 
80103b85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b88:	89 04 24             	mov    %eax,(%esp)
80103b8b:	e8 25 19 00 00       	call   801054b5 <memcmp>
80103b90:	85 c0                	test   %eax,%eax
80103b92:	74 07                	je     80103b9b <mpconfig+0x5f>
    return 0;
80103b94:	b8 00 00 00 00       	mov    $0x0,%eax
80103b99:	eb 4c                	jmp    80103be7 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103b9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b9e:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103ba2:	3c 01                	cmp    $0x1,%al
80103ba4:	74 12                	je     80103bb8 <mpconfig+0x7c>
80103ba6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba9:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bad:	3c 04                	cmp    $0x4,%al
80103baf:	74 07                	je     80103bb8 <mpconfig+0x7c>
    return 0;
80103bb1:	b8 00 00 00 00       	mov    $0x0,%eax
80103bb6:	eb 2f                	jmp    80103be7 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103bb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bbb:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103bbf:	0f b7 c0             	movzwl %ax,%eax
80103bc2:	89 44 24 04          	mov    %eax,0x4(%esp)
80103bc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc9:	89 04 24             	mov    %eax,(%esp)
80103bcc:	e8 08 fe ff ff       	call   801039d9 <sum>
80103bd1:	84 c0                	test   %al,%al
80103bd3:	74 07                	je     80103bdc <mpconfig+0xa0>
    return 0;
80103bd5:	b8 00 00 00 00       	mov    $0x0,%eax
80103bda:	eb 0b                	jmp    80103be7 <mpconfig+0xab>
  *pmp = mp;
80103bdc:	8b 45 08             	mov    0x8(%ebp),%eax
80103bdf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103be2:	89 10                	mov    %edx,(%eax)
  return conf;
80103be4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103be7:	c9                   	leave  
80103be8:	c3                   	ret    

80103be9 <mpinit>:

void
mpinit(void)
{
80103be9:	55                   	push   %ebp
80103bea:	89 e5                	mov    %esp,%ebp
80103bec:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103bef:	c7 05 44 b6 10 80 40 	movl   $0x8010f940,0x8010b644
80103bf6:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
80103bf9:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103bfc:	89 04 24             	mov    %eax,(%esp)
80103bff:	e8 38 ff ff ff       	call   80103b3c <mpconfig>
80103c04:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c07:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c0b:	0f 84 9c 01 00 00    	je     80103dad <mpinit+0x1c4>
    return;
  ismp = 1;
80103c11:	c7 05 24 f9 10 80 01 	movl   $0x1,0x8010f924
80103c18:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c1e:	8b 40 24             	mov    0x24(%eax),%eax
80103c21:	a3 9c f8 10 80       	mov    %eax,0x8010f89c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c29:	83 c0 2c             	add    $0x2c,%eax
80103c2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c32:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c36:	0f b7 c0             	movzwl %ax,%eax
80103c39:	03 45 f0             	add    -0x10(%ebp),%eax
80103c3c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c3f:	e9 f4 00 00 00       	jmp    80103d38 <mpinit+0x14f>
    switch(*p){
80103c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c47:	0f b6 00             	movzbl (%eax),%eax
80103c4a:	0f b6 c0             	movzbl %al,%eax
80103c4d:	83 f8 04             	cmp    $0x4,%eax
80103c50:	0f 87 bf 00 00 00    	ja     80103d15 <mpinit+0x12c>
80103c56:	8b 04 85 48 8b 10 80 	mov    -0x7fef74b8(,%eax,4),%eax
80103c5d:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c62:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c65:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c68:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c6c:	0f b6 d0             	movzbl %al,%edx
80103c6f:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c74:	39 c2                	cmp    %eax,%edx
80103c76:	74 2d                	je     80103ca5 <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c78:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c7b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c7f:	0f b6 d0             	movzbl %al,%edx
80103c82:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c87:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c8f:	c7 04 24 0a 8b 10 80 	movl   $0x80108b0a,(%esp)
80103c96:	e8 06 c7 ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80103c9b:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103ca2:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103ca5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ca8:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103cac:	0f b6 c0             	movzbl %al,%eax
80103caf:	83 e0 02             	and    $0x2,%eax
80103cb2:	85 c0                	test   %eax,%eax
80103cb4:	74 15                	je     80103ccb <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80103cb6:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103cbb:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103cc1:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103cc6:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103ccb:	8b 15 20 ff 10 80    	mov    0x8010ff20,%edx
80103cd1:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103cd6:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103cdc:	81 c2 40 f9 10 80    	add    $0x8010f940,%edx
80103ce2:	88 02                	mov    %al,(%edx)
      ncpu++;
80103ce4:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103ce9:	83 c0 01             	add    $0x1,%eax
80103cec:	a3 20 ff 10 80       	mov    %eax,0x8010ff20
      p += sizeof(struct mpproc);
80103cf1:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103cf5:	eb 41                	jmp    80103d38 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cfa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103cfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d00:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d04:	a2 20 f9 10 80       	mov    %al,0x8010f920
      p += sizeof(struct mpioapic);
80103d09:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d0d:	eb 29                	jmp    80103d38 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d0f:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d13:	eb 23                	jmp    80103d38 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d18:	0f b6 00             	movzbl (%eax),%eax
80103d1b:	0f b6 c0             	movzbl %al,%eax
80103d1e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d22:	c7 04 24 28 8b 10 80 	movl   $0x80108b28,(%esp)
80103d29:	e8 73 c6 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
80103d2e:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103d35:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d3b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d3e:	0f 82 00 ff ff ff    	jb     80103c44 <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103d44:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80103d49:	85 c0                	test   %eax,%eax
80103d4b:	75 1d                	jne    80103d6a <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103d4d:	c7 05 20 ff 10 80 01 	movl   $0x1,0x8010ff20
80103d54:	00 00 00 
    lapic = 0;
80103d57:	c7 05 9c f8 10 80 00 	movl   $0x0,0x8010f89c
80103d5e:	00 00 00 
    ioapicid = 0;
80103d61:	c6 05 20 f9 10 80 00 	movb   $0x0,0x8010f920
    return;
80103d68:	eb 44                	jmp    80103dae <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103d6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d6d:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d71:	84 c0                	test   %al,%al
80103d73:	74 39                	je     80103dae <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d75:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d7c:	00 
80103d7d:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d84:	e8 12 fc ff ff       	call   8010399b <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d89:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d90:	e8 dc fb ff ff       	call   80103971 <inb>
80103d95:	83 c8 01             	or     $0x1,%eax
80103d98:	0f b6 c0             	movzbl %al,%eax
80103d9b:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d9f:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103da6:	e8 f0 fb ff ff       	call   8010399b <outb>
80103dab:	eb 01                	jmp    80103dae <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103dad:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103dae:	c9                   	leave  
80103daf:	c3                   	ret    

80103db0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103db0:	55                   	push   %ebp
80103db1:	89 e5                	mov    %esp,%ebp
80103db3:	83 ec 08             	sub    $0x8,%esp
80103db6:	8b 55 08             	mov    0x8(%ebp),%edx
80103db9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dbc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103dc0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103dc3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103dc7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103dcb:	ee                   	out    %al,(%dx)
}
80103dcc:	c9                   	leave  
80103dcd:	c3                   	ret    

80103dce <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103dce:	55                   	push   %ebp
80103dcf:	89 e5                	mov    %esp,%ebp
80103dd1:	83 ec 0c             	sub    $0xc,%esp
80103dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103ddb:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103ddf:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103de5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103de9:	0f b6 c0             	movzbl %al,%eax
80103dec:	89 44 24 04          	mov    %eax,0x4(%esp)
80103df0:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103df7:	e8 b4 ff ff ff       	call   80103db0 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103dfc:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e00:	66 c1 e8 08          	shr    $0x8,%ax
80103e04:	0f b6 c0             	movzbl %al,%eax
80103e07:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e0b:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e12:	e8 99 ff ff ff       	call   80103db0 <outb>
}
80103e17:	c9                   	leave  
80103e18:	c3                   	ret    

80103e19 <picenable>:

void
picenable(int irq)
{
80103e19:	55                   	push   %ebp
80103e1a:	89 e5                	mov    %esp,%ebp
80103e1c:	53                   	push   %ebx
80103e1d:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103e20:	8b 45 08             	mov    0x8(%ebp),%eax
80103e23:	ba 01 00 00 00       	mov    $0x1,%edx
80103e28:	89 d3                	mov    %edx,%ebx
80103e2a:	89 c1                	mov    %eax,%ecx
80103e2c:	d3 e3                	shl    %cl,%ebx
80103e2e:	89 d8                	mov    %ebx,%eax
80103e30:	89 c2                	mov    %eax,%edx
80103e32:	f7 d2                	not    %edx
80103e34:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103e3b:	21 d0                	and    %edx,%eax
80103e3d:	0f b7 c0             	movzwl %ax,%eax
80103e40:	89 04 24             	mov    %eax,(%esp)
80103e43:	e8 86 ff ff ff       	call   80103dce <picsetmask>
}
80103e48:	83 c4 04             	add    $0x4,%esp
80103e4b:	5b                   	pop    %ebx
80103e4c:	5d                   	pop    %ebp
80103e4d:	c3                   	ret    

80103e4e <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e4e:	55                   	push   %ebp
80103e4f:	89 e5                	mov    %esp,%ebp
80103e51:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e54:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e5b:	00 
80103e5c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e63:	e8 48 ff ff ff       	call   80103db0 <outb>
  outb(IO_PIC2+1, 0xFF);
80103e68:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e6f:	00 
80103e70:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e77:	e8 34 ff ff ff       	call   80103db0 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e7c:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e83:	00 
80103e84:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e8b:	e8 20 ff ff ff       	call   80103db0 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103e90:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103e97:	00 
80103e98:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e9f:	e8 0c ff ff ff       	call   80103db0 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103ea4:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103eab:	00 
80103eac:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103eb3:	e8 f8 fe ff ff       	call   80103db0 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103eb8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103ebf:	00 
80103ec0:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ec7:	e8 e4 fe ff ff       	call   80103db0 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103ecc:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103ed3:	00 
80103ed4:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103edb:	e8 d0 fe ff ff       	call   80103db0 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103ee0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103ee7:	00 
80103ee8:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103eef:	e8 bc fe ff ff       	call   80103db0 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103ef4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103efb:	00 
80103efc:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f03:	e8 a8 fe ff ff       	call   80103db0 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103f08:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103f0f:	00 
80103f10:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f17:	e8 94 fe ff ff       	call   80103db0 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103f1c:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f23:	00 
80103f24:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f2b:	e8 80 fe ff ff       	call   80103db0 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f30:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f37:	00 
80103f38:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f3f:	e8 6c fe ff ff       	call   80103db0 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103f44:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f4b:	00 
80103f4c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f53:	e8 58 fe ff ff       	call   80103db0 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103f58:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f5f:	00 
80103f60:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f67:	e8 44 fe ff ff       	call   80103db0 <outb>

  if(irqmask != 0xFFFF)
80103f6c:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f73:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f77:	74 12                	je     80103f8b <picinit+0x13d>
    picsetmask(irqmask);
80103f79:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f80:	0f b7 c0             	movzwl %ax,%eax
80103f83:	89 04 24             	mov    %eax,(%esp)
80103f86:	e8 43 fe ff ff       	call   80103dce <picsetmask>
}
80103f8b:	c9                   	leave  
80103f8c:	c3                   	ret    
80103f8d:	00 00                	add    %al,(%eax)
	...

80103f90 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103f90:	55                   	push   %ebp
80103f91:	89 e5                	mov    %esp,%ebp
80103f93:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103f96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fa0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fa6:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fa9:	8b 10                	mov    (%eax),%edx
80103fab:	8b 45 08             	mov    0x8(%ebp),%eax
80103fae:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fb0:	e8 bf d2 ff ff       	call   80101274 <filealloc>
80103fb5:	8b 55 08             	mov    0x8(%ebp),%edx
80103fb8:	89 02                	mov    %eax,(%edx)
80103fba:	8b 45 08             	mov    0x8(%ebp),%eax
80103fbd:	8b 00                	mov    (%eax),%eax
80103fbf:	85 c0                	test   %eax,%eax
80103fc1:	0f 84 c8 00 00 00    	je     8010408f <pipealloc+0xff>
80103fc7:	e8 a8 d2 ff ff       	call   80101274 <filealloc>
80103fcc:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fcf:	89 02                	mov    %eax,(%edx)
80103fd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd4:	8b 00                	mov    (%eax),%eax
80103fd6:	85 c0                	test   %eax,%eax
80103fd8:	0f 84 b1 00 00 00    	je     8010408f <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103fde:	e8 74 ee ff ff       	call   80102e57 <kalloc>
80103fe3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103fe6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103fea:	0f 84 9e 00 00 00    	je     8010408e <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80103ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff3:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103ffa:	00 00 00 
  p->writeopen = 1;
80103ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104000:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104007:	00 00 00 
  p->nwrite = 0;
8010400a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010400d:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104014:	00 00 00 
  p->nread = 0;
80104017:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401a:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104021:	00 00 00 
  initlock(&p->lock, "pipe");
80104024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104027:	c7 44 24 04 5c 8b 10 	movl   $0x80108b5c,0x4(%esp)
8010402e:	80 
8010402f:	89 04 24             	mov    %eax,(%esp)
80104032:	e8 97 11 00 00       	call   801051ce <initlock>
  (*f0)->type = FD_PIPE;
80104037:	8b 45 08             	mov    0x8(%ebp),%eax
8010403a:	8b 00                	mov    (%eax),%eax
8010403c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104042:	8b 45 08             	mov    0x8(%ebp),%eax
80104045:	8b 00                	mov    (%eax),%eax
80104047:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010404b:	8b 45 08             	mov    0x8(%ebp),%eax
8010404e:	8b 00                	mov    (%eax),%eax
80104050:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104054:	8b 45 08             	mov    0x8(%ebp),%eax
80104057:	8b 00                	mov    (%eax),%eax
80104059:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010405c:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010405f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104062:	8b 00                	mov    (%eax),%eax
80104064:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010406a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010406d:	8b 00                	mov    (%eax),%eax
8010406f:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104073:	8b 45 0c             	mov    0xc(%ebp),%eax
80104076:	8b 00                	mov    (%eax),%eax
80104078:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010407c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010407f:	8b 00                	mov    (%eax),%eax
80104081:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104084:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104087:	b8 00 00 00 00       	mov    $0x0,%eax
8010408c:	eb 43                	jmp    801040d1 <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
8010408e:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
8010408f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104093:	74 0b                	je     801040a0 <pipealloc+0x110>
    kfree((char*)p);
80104095:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104098:	89 04 24             	mov    %eax,(%esp)
8010409b:	e8 1e ed ff ff       	call   80102dbe <kfree>
  if(*f0)
801040a0:	8b 45 08             	mov    0x8(%ebp),%eax
801040a3:	8b 00                	mov    (%eax),%eax
801040a5:	85 c0                	test   %eax,%eax
801040a7:	74 0d                	je     801040b6 <pipealloc+0x126>
    fileclose(*f0);
801040a9:	8b 45 08             	mov    0x8(%ebp),%eax
801040ac:	8b 00                	mov    (%eax),%eax
801040ae:	89 04 24             	mov    %eax,(%esp)
801040b1:	e8 66 d2 ff ff       	call   8010131c <fileclose>
  if(*f1)
801040b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801040b9:	8b 00                	mov    (%eax),%eax
801040bb:	85 c0                	test   %eax,%eax
801040bd:	74 0d                	je     801040cc <pipealloc+0x13c>
    fileclose(*f1);
801040bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801040c2:	8b 00                	mov    (%eax),%eax
801040c4:	89 04 24             	mov    %eax,(%esp)
801040c7:	e8 50 d2 ff ff       	call   8010131c <fileclose>
  return -1;
801040cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801040d1:	c9                   	leave  
801040d2:	c3                   	ret    

801040d3 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801040d3:	55                   	push   %ebp
801040d4:	89 e5                	mov    %esp,%ebp
801040d6:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
801040d9:	8b 45 08             	mov    0x8(%ebp),%eax
801040dc:	89 04 24             	mov    %eax,(%esp)
801040df:	e8 0b 11 00 00       	call   801051ef <acquire>
  if(writable){
801040e4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801040e8:	74 1f                	je     80104109 <pipeclose+0x36>
    p->writeopen = 0;
801040ea:	8b 45 08             	mov    0x8(%ebp),%eax
801040ed:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801040f4:	00 00 00 
    wakeup(&p->nread);
801040f7:	8b 45 08             	mov    0x8(%ebp),%eax
801040fa:	05 34 02 00 00       	add    $0x234,%eax
801040ff:	89 04 24             	mov    %eax,(%esp)
80104102:	e8 5b 0e 00 00       	call   80104f62 <wakeup>
80104107:	eb 1d                	jmp    80104126 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104109:	8b 45 08             	mov    0x8(%ebp),%eax
8010410c:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104113:	00 00 00 
    wakeup(&p->nwrite);
80104116:	8b 45 08             	mov    0x8(%ebp),%eax
80104119:	05 38 02 00 00       	add    $0x238,%eax
8010411e:	89 04 24             	mov    %eax,(%esp)
80104121:	e8 3c 0e 00 00       	call   80104f62 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104126:	8b 45 08             	mov    0x8(%ebp),%eax
80104129:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010412f:	85 c0                	test   %eax,%eax
80104131:	75 25                	jne    80104158 <pipeclose+0x85>
80104133:	8b 45 08             	mov    0x8(%ebp),%eax
80104136:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010413c:	85 c0                	test   %eax,%eax
8010413e:	75 18                	jne    80104158 <pipeclose+0x85>
    release(&p->lock);
80104140:	8b 45 08             	mov    0x8(%ebp),%eax
80104143:	89 04 24             	mov    %eax,(%esp)
80104146:	e8 06 11 00 00       	call   80105251 <release>
    kfree((char*)p);
8010414b:	8b 45 08             	mov    0x8(%ebp),%eax
8010414e:	89 04 24             	mov    %eax,(%esp)
80104151:	e8 68 ec ff ff       	call   80102dbe <kfree>
80104156:	eb 0b                	jmp    80104163 <pipeclose+0x90>
  } else
    release(&p->lock);
80104158:	8b 45 08             	mov    0x8(%ebp),%eax
8010415b:	89 04 24             	mov    %eax,(%esp)
8010415e:	e8 ee 10 00 00       	call   80105251 <release>
}
80104163:	c9                   	leave  
80104164:	c3                   	ret    

80104165 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104165:	55                   	push   %ebp
80104166:	89 e5                	mov    %esp,%ebp
80104168:	53                   	push   %ebx
80104169:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
8010416c:	8b 45 08             	mov    0x8(%ebp),%eax
8010416f:	89 04 24             	mov    %eax,(%esp)
80104172:	e8 78 10 00 00       	call   801051ef <acquire>
  for(i = 0; i < n; i++){
80104177:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010417e:	e9 a6 00 00 00       	jmp    80104229 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104183:	8b 45 08             	mov    0x8(%ebp),%eax
80104186:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010418c:	85 c0                	test   %eax,%eax
8010418e:	74 0d                	je     8010419d <pipewrite+0x38>
80104190:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104196:	8b 40 24             	mov    0x24(%eax),%eax
80104199:	85 c0                	test   %eax,%eax
8010419b:	74 15                	je     801041b2 <pipewrite+0x4d>
        release(&p->lock);
8010419d:	8b 45 08             	mov    0x8(%ebp),%eax
801041a0:	89 04 24             	mov    %eax,(%esp)
801041a3:	e8 a9 10 00 00       	call   80105251 <release>
        return -1;
801041a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041ad:	e9 9d 00 00 00       	jmp    8010424f <pipewrite+0xea>
      }
      wakeup(&p->nread);
801041b2:	8b 45 08             	mov    0x8(%ebp),%eax
801041b5:	05 34 02 00 00       	add    $0x234,%eax
801041ba:	89 04 24             	mov    %eax,(%esp)
801041bd:	e8 a0 0d 00 00       	call   80104f62 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801041c2:	8b 45 08             	mov    0x8(%ebp),%eax
801041c5:	8b 55 08             	mov    0x8(%ebp),%edx
801041c8:	81 c2 38 02 00 00    	add    $0x238,%edx
801041ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801041d2:	89 14 24             	mov    %edx,(%esp)
801041d5:	e8 ac 0c 00 00       	call   80104e86 <sleep>
801041da:	eb 01                	jmp    801041dd <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801041dc:	90                   	nop
801041dd:	8b 45 08             	mov    0x8(%ebp),%eax
801041e0:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801041e6:	8b 45 08             	mov    0x8(%ebp),%eax
801041e9:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041ef:	05 00 02 00 00       	add    $0x200,%eax
801041f4:	39 c2                	cmp    %eax,%edx
801041f6:	74 8b                	je     80104183 <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801041f8:	8b 45 08             	mov    0x8(%ebp),%eax
801041fb:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104201:	89 c3                	mov    %eax,%ebx
80104203:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80104209:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010420c:	03 55 0c             	add    0xc(%ebp),%edx
8010420f:	0f b6 0a             	movzbl (%edx),%ecx
80104212:	8b 55 08             	mov    0x8(%ebp),%edx
80104215:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
80104219:	8d 50 01             	lea    0x1(%eax),%edx
8010421c:	8b 45 08             	mov    0x8(%ebp),%eax
8010421f:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104225:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104229:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010422c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010422f:	7c ab                	jl     801041dc <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104231:	8b 45 08             	mov    0x8(%ebp),%eax
80104234:	05 34 02 00 00       	add    $0x234,%eax
80104239:	89 04 24             	mov    %eax,(%esp)
8010423c:	e8 21 0d 00 00       	call   80104f62 <wakeup>
  release(&p->lock);
80104241:	8b 45 08             	mov    0x8(%ebp),%eax
80104244:	89 04 24             	mov    %eax,(%esp)
80104247:	e8 05 10 00 00       	call   80105251 <release>
  return n;
8010424c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010424f:	83 c4 24             	add    $0x24,%esp
80104252:	5b                   	pop    %ebx
80104253:	5d                   	pop    %ebp
80104254:	c3                   	ret    

80104255 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104255:	55                   	push   %ebp
80104256:	89 e5                	mov    %esp,%ebp
80104258:	53                   	push   %ebx
80104259:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
8010425c:	8b 45 08             	mov    0x8(%ebp),%eax
8010425f:	89 04 24             	mov    %eax,(%esp)
80104262:	e8 88 0f 00 00       	call   801051ef <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104267:	eb 3a                	jmp    801042a3 <piperead+0x4e>
    if(proc->killed){
80104269:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010426f:	8b 40 24             	mov    0x24(%eax),%eax
80104272:	85 c0                	test   %eax,%eax
80104274:	74 15                	je     8010428b <piperead+0x36>
      release(&p->lock);
80104276:	8b 45 08             	mov    0x8(%ebp),%eax
80104279:	89 04 24             	mov    %eax,(%esp)
8010427c:	e8 d0 0f 00 00       	call   80105251 <release>
      return -1;
80104281:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104286:	e9 b6 00 00 00       	jmp    80104341 <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010428b:	8b 45 08             	mov    0x8(%ebp),%eax
8010428e:	8b 55 08             	mov    0x8(%ebp),%edx
80104291:	81 c2 34 02 00 00    	add    $0x234,%edx
80104297:	89 44 24 04          	mov    %eax,0x4(%esp)
8010429b:	89 14 24             	mov    %edx,(%esp)
8010429e:	e8 e3 0b 00 00       	call   80104e86 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042a3:	8b 45 08             	mov    0x8(%ebp),%eax
801042a6:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042ac:	8b 45 08             	mov    0x8(%ebp),%eax
801042af:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042b5:	39 c2                	cmp    %eax,%edx
801042b7:	75 0d                	jne    801042c6 <piperead+0x71>
801042b9:	8b 45 08             	mov    0x8(%ebp),%eax
801042bc:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042c2:	85 c0                	test   %eax,%eax
801042c4:	75 a3                	jne    80104269 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042cd:	eb 49                	jmp    80104318 <piperead+0xc3>
    if(p->nread == p->nwrite)
801042cf:	8b 45 08             	mov    0x8(%ebp),%eax
801042d2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042d8:	8b 45 08             	mov    0x8(%ebp),%eax
801042db:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042e1:	39 c2                	cmp    %eax,%edx
801042e3:	74 3d                	je     80104322 <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801042e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e8:	89 c2                	mov    %eax,%edx
801042ea:	03 55 0c             	add    0xc(%ebp),%edx
801042ed:	8b 45 08             	mov    0x8(%ebp),%eax
801042f0:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042f6:	89 c3                	mov    %eax,%ebx
801042f8:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
801042fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104301:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
80104306:	88 0a                	mov    %cl,(%edx)
80104308:	8d 50 01             	lea    0x1(%eax),%edx
8010430b:	8b 45 08             	mov    0x8(%ebp),%eax
8010430e:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104314:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010431b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010431e:	7c af                	jl     801042cf <piperead+0x7a>
80104320:	eb 01                	jmp    80104323 <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
80104322:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104323:	8b 45 08             	mov    0x8(%ebp),%eax
80104326:	05 38 02 00 00       	add    $0x238,%eax
8010432b:	89 04 24             	mov    %eax,(%esp)
8010432e:	e8 2f 0c 00 00       	call   80104f62 <wakeup>
  release(&p->lock);
80104333:	8b 45 08             	mov    0x8(%ebp),%eax
80104336:	89 04 24             	mov    %eax,(%esp)
80104339:	e8 13 0f 00 00       	call   80105251 <release>
  return i;
8010433e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104341:	83 c4 24             	add    $0x24,%esp
80104344:	5b                   	pop    %ebx
80104345:	5d                   	pop    %ebp
80104346:	c3                   	ret    
	...

80104348 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104348:	55                   	push   %ebp
80104349:	89 e5                	mov    %esp,%ebp
8010434b:	53                   	push   %ebx
8010434c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010434f:	9c                   	pushf  
80104350:	5b                   	pop    %ebx
80104351:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104354:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104357:	83 c4 10             	add    $0x10,%esp
8010435a:	5b                   	pop    %ebx
8010435b:	5d                   	pop    %ebp
8010435c:	c3                   	ret    

8010435d <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010435d:	55                   	push   %ebp
8010435e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104360:	fb                   	sti    
}
80104361:	5d                   	pop    %ebp
80104362:	c3                   	ret    

80104363 <pinit>:
extern void trapret(void);

static void wakeup1(void *chan);
void
pinit(void)
{
80104363:	55                   	push   %ebp
80104364:	89 e5                	mov    %esp,%ebp
80104366:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104369:	c7 44 24 04 61 8b 10 	movl   $0x80108b61,0x4(%esp)
80104370:	80 
80104371:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104378:	e8 51 0e 00 00       	call   801051ce <initlock>
}
8010437d:	c9                   	leave  
8010437e:	c3                   	ret    

8010437f <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010437f:	55                   	push   %ebp
80104380:	89 e5                	mov    %esp,%ebp
80104382:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104385:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010438c:	e8 5e 0e 00 00       	call   801051ef <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104391:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104398:	eb 11                	jmp    801043ab <allocproc+0x2c>
    if(p->state == UNUSED)
8010439a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010439d:	8b 40 0c             	mov    0xc(%eax),%eax
801043a0:	85 c0                	test   %eax,%eax
801043a2:	74 26                	je     801043ca <allocproc+0x4b>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043a4:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
801043ab:	81 7d f4 74 24 11 80 	cmpl   $0x80112474,-0xc(%ebp)
801043b2:	72 e6                	jb     8010439a <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801043b4:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801043bb:	e8 91 0e 00 00       	call   80105251 <release>
  return 0;
801043c0:	b8 00 00 00 00       	mov    $0x0,%eax
801043c5:	e9 b5 00 00 00       	jmp    8010447f <allocproc+0x100>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801043ca:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801043cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ce:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801043d5:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801043da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043dd:	89 42 10             	mov    %eax,0x10(%edx)
801043e0:	83 c0 01             	add    $0x1,%eax
801043e3:	a3 04 b0 10 80       	mov    %eax,0x8010b004
  release(&ptable.lock);
801043e8:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801043ef:	e8 5d 0e 00 00       	call   80105251 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043f4:	e8 5e ea ff ff       	call   80102e57 <kalloc>
801043f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043fc:	89 42 08             	mov    %eax,0x8(%edx)
801043ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104402:	8b 40 08             	mov    0x8(%eax),%eax
80104405:	85 c0                	test   %eax,%eax
80104407:	75 11                	jne    8010441a <allocproc+0x9b>
    p->state = UNUSED;
80104409:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104413:	b8 00 00 00 00       	mov    $0x0,%eax
80104418:	eb 65                	jmp    8010447f <allocproc+0x100>
  }
  sp = p->kstack + KSTACKSIZE;
8010441a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441d:	8b 40 08             	mov    0x8(%eax),%eax
80104420:	05 00 10 00 00       	add    $0x1000,%eax
80104425:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104428:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010442c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104432:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104435:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104439:	ba 04 69 10 80       	mov    $0x80106904,%edx
8010443e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104441:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104443:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104447:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010444d:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104450:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104453:	8b 40 1c             	mov    0x1c(%eax),%eax
80104456:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010445d:	00 
8010445e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104465:	00 
80104466:	89 04 24             	mov    %eax,(%esp)
80104469:	e8 d0 0f 00 00       	call   8010543e <memset>
  p->context->eip = (uint)forkret;
8010446e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104471:	8b 40 1c             	mov    0x1c(%eax),%eax
80104474:	ba 5a 4e 10 80       	mov    $0x80104e5a,%edx
80104479:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010447c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010447f:	c9                   	leave  
80104480:	c3                   	ret    

80104481 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104481:	55                   	push   %ebp
80104482:	89 e5                	mov    %esp,%ebp
80104484:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104487:	e8 f3 fe ff ff       	call   8010437f <allocproc>
8010448c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
8010448f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104492:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm(kalloc)) == 0)
80104497:	c7 04 24 57 2e 10 80 	movl   $0x80102e57,(%esp)
8010449e:	e8 a2 3b 00 00       	call   80108045 <setupkvm>
801044a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044a6:	89 42 04             	mov    %eax,0x4(%edx)
801044a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ac:	8b 40 04             	mov    0x4(%eax),%eax
801044af:	85 c0                	test   %eax,%eax
801044b1:	75 0c                	jne    801044bf <userinit+0x3e>
    panic("userinit: out of memory?");
801044b3:	c7 04 24 68 8b 10 80 	movl   $0x80108b68,(%esp)
801044ba:	e8 7e c0 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044bf:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c7:	8b 40 04             	mov    0x4(%eax),%eax
801044ca:	89 54 24 08          	mov    %edx,0x8(%esp)
801044ce:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
801044d5:	80 
801044d6:	89 04 24             	mov    %eax,(%esp)
801044d9:	e8 bf 3d 00 00       	call   8010829d <inituvm>
  p->sz = PGSIZE;
801044de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e1:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ea:	8b 40 18             	mov    0x18(%eax),%eax
801044ed:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801044f4:	00 
801044f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801044fc:	00 
801044fd:	89 04 24             	mov    %eax,(%esp)
80104500:	e8 39 0f 00 00       	call   8010543e <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104508:	8b 40 18             	mov    0x18(%eax),%eax
8010450b:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104511:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104514:	8b 40 18             	mov    0x18(%eax),%eax
80104517:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010451d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104520:	8b 40 18             	mov    0x18(%eax),%eax
80104523:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104526:	8b 52 18             	mov    0x18(%edx),%edx
80104529:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010452d:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104534:	8b 40 18             	mov    0x18(%eax),%eax
80104537:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010453a:	8b 52 18             	mov    0x18(%edx),%edx
8010453d:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104541:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104545:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104548:	8b 40 18             	mov    0x18(%eax),%eax
8010454b:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104555:	8b 40 18             	mov    0x18(%eax),%eax
80104558:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010455f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104562:	8b 40 18             	mov    0x18(%eax),%eax
80104565:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010456c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456f:	83 c0 6c             	add    $0x6c,%eax
80104572:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104579:	00 
8010457a:	c7 44 24 04 81 8b 10 	movl   $0x80108b81,0x4(%esp)
80104581:	80 
80104582:	89 04 24             	mov    %eax,(%esp)
80104585:	e8 e4 10 00 00       	call   8010566e <safestrcpy>
  p->cwd = namei("/");
8010458a:	c7 04 24 8a 8b 10 80 	movl   $0x80108b8a,(%esp)
80104591:	e8 cc e1 ff ff       	call   80102762 <namei>
80104596:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104599:	89 42 68             	mov    %eax,0x68(%edx)
  p->state = RUNNABLE;
8010459c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801045a6:	c9                   	leave  
801045a7:	c3                   	ret    

801045a8 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801045a8:	55                   	push   %ebp
801045a9:	89 e5                	mov    %esp,%ebp
801045ab:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801045ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045b4:	8b 00                	mov    (%eax),%eax
801045b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801045b9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045bd:	7e 34                	jle    801045f3 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801045bf:	8b 45 08             	mov    0x8(%ebp),%eax
801045c2:	89 c2                	mov    %eax,%edx
801045c4:	03 55 f4             	add    -0xc(%ebp),%edx
801045c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045cd:	8b 40 04             	mov    0x4(%eax),%eax
801045d0:	89 54 24 08          	mov    %edx,0x8(%esp)
801045d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045d7:	89 54 24 04          	mov    %edx,0x4(%esp)
801045db:	89 04 24             	mov    %eax,(%esp)
801045de:	e8 34 3e 00 00       	call   80108417 <allocuvm>
801045e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045ea:	75 41                	jne    8010462d <growproc+0x85>
      return -1;
801045ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045f1:	eb 58                	jmp    8010464b <growproc+0xa3>
  } else if(n < 0){
801045f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045f7:	79 34                	jns    8010462d <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801045f9:	8b 45 08             	mov    0x8(%ebp),%eax
801045fc:	89 c2                	mov    %eax,%edx
801045fe:	03 55 f4             	add    -0xc(%ebp),%edx
80104601:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104607:	8b 40 04             	mov    0x4(%eax),%eax
8010460a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010460e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104611:	89 54 24 04          	mov    %edx,0x4(%esp)
80104615:	89 04 24             	mov    %eax,(%esp)
80104618:	e8 d4 3e 00 00       	call   801084f1 <deallocuvm>
8010461d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104620:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104624:	75 07                	jne    8010462d <growproc+0x85>
      return -1;
80104626:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010462b:	eb 1e                	jmp    8010464b <growproc+0xa3>
  }
  proc->sz = sz;
8010462d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104633:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104636:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104638:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010463e:	89 04 24             	mov    %eax,(%esp)
80104641:	e8 f0 3a 00 00       	call   80108136 <switchuvm>
  return 0;
80104646:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010464b:	c9                   	leave  
8010464c:	c3                   	ret    

8010464d <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010464d:	55                   	push   %ebp
8010464e:	89 e5                	mov    %esp,%ebp
80104650:	57                   	push   %edi
80104651:	56                   	push   %esi
80104652:	53                   	push   %ebx
80104653:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104656:	e8 24 fd ff ff       	call   8010437f <allocproc>
8010465b:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010465e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104662:	75 0a                	jne    8010466e <fork+0x21>
    return -1;
80104664:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104669:	e9 6c 01 00 00       	jmp    801047da <fork+0x18d>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010466e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104674:	8b 10                	mov    (%eax),%edx
80104676:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010467c:	8b 40 04             	mov    0x4(%eax),%eax
8010467f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104683:	89 04 24             	mov    %eax,(%esp)
80104686:	e8 f6 3f 00 00       	call   80108681 <copyuvm>
8010468b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010468e:	89 42 04             	mov    %eax,0x4(%edx)
80104691:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104694:	8b 40 04             	mov    0x4(%eax),%eax
80104697:	85 c0                	test   %eax,%eax
80104699:	75 2c                	jne    801046c7 <fork+0x7a>
    kfree(np->kstack);
8010469b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010469e:	8b 40 08             	mov    0x8(%eax),%eax
801046a1:	89 04 24             	mov    %eax,(%esp)
801046a4:	e8 15 e7 ff ff       	call   80102dbe <kfree>
    np->kstack = 0;
801046a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ac:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046b6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046c2:	e9 13 01 00 00       	jmp    801047da <fork+0x18d>
  }
  np->sz = proc->sz;
801046c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046cd:	8b 10                	mov    (%eax),%edx
801046cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046d2:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801046d4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046db:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046de:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801046e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e4:	8b 50 18             	mov    0x18(%eax),%edx
801046e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046ed:	8b 40 18             	mov    0x18(%eax),%eax
801046f0:	89 c3                	mov    %eax,%ebx
801046f2:	b8 13 00 00 00       	mov    $0x13,%eax
801046f7:	89 d7                	mov    %edx,%edi
801046f9:	89 de                	mov    %ebx,%esi
801046fb:	89 c1                	mov    %eax,%ecx
801046fd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801046ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104702:	8b 40 18             	mov    0x18(%eax),%eax
80104705:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010470c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104713:	eb 3d                	jmp    80104752 <fork+0x105>
    if(proc->ofile[i])
80104715:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010471b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010471e:	83 c2 08             	add    $0x8,%edx
80104721:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104725:	85 c0                	test   %eax,%eax
80104727:	74 25                	je     8010474e <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
80104729:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010472f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104732:	83 c2 08             	add    $0x8,%edx
80104735:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104739:	89 04 24             	mov    %eax,(%esp)
8010473c:	e8 93 cb ff ff       	call   801012d4 <filedup>
80104741:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104744:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104747:	83 c1 08             	add    $0x8,%ecx
8010474a:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010474e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104752:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104756:	7e bd                	jle    80104715 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104758:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010475e:	8b 40 68             	mov    0x68(%eax),%eax
80104761:	89 04 24             	mov    %eax,(%esp)
80104764:	e8 25 d4 ff ff       	call   80101b8e <idup>
80104769:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010476c:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
8010476f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104772:	8b 40 10             	mov    0x10(%eax),%eax
80104775:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
80104778:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010477b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104782:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104788:	8d 50 6c             	lea    0x6c(%eax),%edx
8010478b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010478e:	83 c0 6c             	add    $0x6c,%eax
80104791:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104798:	00 
80104799:	89 54 24 04          	mov    %edx,0x4(%esp)
8010479d:	89 04 24             	mov    %eax,(%esp)
801047a0:	e8 c9 0e 00 00       	call   8010566e <safestrcpy>
  acquire(&tickslock);
801047a5:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
801047ac:	e8 3e 0a 00 00       	call   801051ef <acquire>
  np->ctime = ticks;
801047b1:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
801047b6:	89 c2                	mov    %eax,%edx
801047b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047bb:	89 50 7c             	mov    %edx,0x7c(%eax)
  release(&tickslock);
801047be:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
801047c5:	e8 87 0a 00 00       	call   80105251 <release>
  np->rtime = 0;
801047ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047cd:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
801047d4:	00 00 00 
    case _3Q:
      np->priority = HIGH;
      np->qvalue = 0;
      break;
  }
  return pid;
801047d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801047da:	83 c4 2c             	add    $0x2c,%esp
801047dd:	5b                   	pop    %ebx
801047de:	5e                   	pop    %esi
801047df:	5f                   	pop    %edi
801047e0:	5d                   	pop    %ebp
801047e1:	c3                   	ret    

801047e2 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801047e2:	55                   	push   %ebp
801047e3:	89 e5                	mov    %esp,%ebp
801047e5:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;
  
  if(proc == initproc)
801047e8:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047ef:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801047f4:	39 c2                	cmp    %eax,%edx
801047f6:	75 0c                	jne    80104804 <exit+0x22>
    panic("init exiting");
801047f8:	c7 04 24 8c 8b 10 80 	movl   $0x80108b8c,(%esp)
801047ff:	e8 39 bd ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104804:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010480b:	eb 44                	jmp    80104851 <exit+0x6f>
    if(proc->ofile[fd]){
8010480d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104813:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104816:	83 c2 08             	add    $0x8,%edx
80104819:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010481d:	85 c0                	test   %eax,%eax
8010481f:	74 2c                	je     8010484d <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104821:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104827:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010482a:	83 c2 08             	add    $0x8,%edx
8010482d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104831:	89 04 24             	mov    %eax,(%esp)
80104834:	e8 e3 ca ff ff       	call   8010131c <fileclose>
      proc->ofile[fd] = 0;
80104839:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010483f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104842:	83 c2 08             	add    $0x8,%edx
80104845:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010484c:	00 
  
  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010484d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104851:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104855:	7e b6                	jle    8010480d <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
80104857:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010485d:	8b 40 68             	mov    0x68(%eax),%eax
80104860:	89 04 24             	mov    %eax,(%esp)
80104863:	e8 0b d5 ff ff       	call   80101d73 <iput>
  proc->cwd = 0;
80104868:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010486e:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104875:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010487c:	e8 6e 09 00 00       	call   801051ef <acquire>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104881:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104887:	8b 40 14             	mov    0x14(%eax),%eax
8010488a:	89 04 24             	mov    %eax,(%esp)
8010488d:	e8 8f 06 00 00       	call   80104f21 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104892:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104899:	eb 3b                	jmp    801048d6 <exit+0xf4>
    if(p->parent == proc){
8010489b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010489e:	8b 50 14             	mov    0x14(%eax),%edx
801048a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048a7:	39 c2                	cmp    %eax,%edx
801048a9:	75 24                	jne    801048cf <exit+0xed>
      p->parent = initproc;
801048ab:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
801048b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b4:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ba:	8b 40 0c             	mov    0xc(%eax),%eax
801048bd:	83 f8 05             	cmp    $0x5,%eax
801048c0:	75 0d                	jne    801048cf <exit+0xed>
        wakeup1(initproc);
801048c2:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801048c7:	89 04 24             	mov    %eax,(%esp)
801048ca:	e8 52 06 00 00       	call   80104f21 <wakeup1>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048cf:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
801048d6:	81 7d f4 74 24 11 80 	cmpl   $0x80112474,-0xc(%ebp)
801048dd:	72 bc                	jb     8010489b <exit+0xb9>
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }
  // Jump into the scheduler, never to return.
  proc->priority = -1;
801048df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048e5:	c7 80 8c 00 00 00 ff 	movl   $0xffffffff,0x8c(%eax)
801048ec:	ff ff ff 
  acquire(&tickslock);
801048ef:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
801048f6:	e8 f4 08 00 00       	call   801051ef <acquire>
  proc->etime = ticks;
801048fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104901:	8b 15 c0 2c 11 80    	mov    0x80112cc0,%edx
80104907:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  release(&tickslock);
8010490d:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80104914:	e8 38 09 00 00       	call   80105251 <release>
  proc->state = ZOMBIE;
80104919:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010491f:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104926:	e8 4b 04 00 00       	call   80104d76 <sched>
  panic("zombie exit");
8010492b:	c7 04 24 99 8b 10 80 	movl   $0x80108b99,(%esp)
80104932:	e8 06 bc ff ff       	call   8010053d <panic>

80104937 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104937:	55                   	push   %ebp
80104938:	89 e5                	mov    %esp,%ebp
8010493a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
8010493d:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104944:	e8 a6 08 00 00       	call   801051ef <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104949:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104950:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104957:	e9 9d 00 00 00       	jmp    801049f9 <wait+0xc2>
      if(p->parent != proc)
8010495c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495f:	8b 50 14             	mov    0x14(%eax),%edx
80104962:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104968:	39 c2                	cmp    %eax,%edx
8010496a:	0f 85 81 00 00 00    	jne    801049f1 <wait+0xba>
        continue;
      havekids = 1;
80104970:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497a:	8b 40 0c             	mov    0xc(%eax),%eax
8010497d:	83 f8 05             	cmp    $0x5,%eax
80104980:	75 70                	jne    801049f2 <wait+0xbb>
        // Found one.
        pid = p->pid;
80104982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104985:	8b 40 10             	mov    0x10(%eax),%eax
80104988:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
8010498b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498e:	8b 40 08             	mov    0x8(%eax),%eax
80104991:	89 04 24             	mov    %eax,(%esp)
80104994:	e8 25 e4 ff ff       	call   80102dbe <kfree>
        p->kstack = 0;
80104999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010499c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801049a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a6:	8b 40 04             	mov    0x4(%eax),%eax
801049a9:	89 04 24             	mov    %eax,(%esp)
801049ac:	e8 fc 3b 00 00       	call   801085ad <freevm>
        p->state = UNUSED;
801049b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801049bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049be:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801049c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c8:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801049cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d2:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801049d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d9:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
801049e0:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801049e7:	e8 65 08 00 00       	call   80105251 <release>
        return pid;
801049ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049ef:	eb 56                	jmp    80104a47 <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801049f1:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049f2:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
801049f9:	81 7d f4 74 24 11 80 	cmpl   $0x80112474,-0xc(%ebp)
80104a00:	0f 82 56 ff ff ff    	jb     8010495c <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104a06:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104a0a:	74 0d                	je     80104a19 <wait+0xe2>
80104a0c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a12:	8b 40 24             	mov    0x24(%eax),%eax
80104a15:	85 c0                	test   %eax,%eax
80104a17:	74 13                	je     80104a2c <wait+0xf5>
      release(&ptable.lock);
80104a19:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104a20:	e8 2c 08 00 00       	call   80105251 <release>
      return -1;
80104a25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a2a:	eb 1b                	jmp    80104a47 <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104a2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a32:	c7 44 24 04 40 ff 10 	movl   $0x8010ff40,0x4(%esp)
80104a39:	80 
80104a3a:	89 04 24             	mov    %eax,(%esp)
80104a3d:	e8 44 04 00 00       	call   80104e86 <sleep>
  }
80104a42:	e9 02 ff ff ff       	jmp    80104949 <wait+0x12>
}
80104a47:	c9                   	leave  
80104a48:	c3                   	ret    

80104a49 <wait2>:

int
wait2(int *wtime, int *rtime)
{
80104a49:	55                   	push   %ebp
80104a4a:	89 e5                	mov    %esp,%ebp
80104a4c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a4f:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104a56:	e8 94 07 00 00       	call   801051ef <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a5b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a62:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104a69:	e9 d0 00 00 00       	jmp    80104b3e <wait2+0xf5>
      if(p->parent != proc)
80104a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a71:	8b 50 14             	mov    0x14(%eax),%edx
80104a74:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a7a:	39 c2                	cmp    %eax,%edx
80104a7c:	0f 85 b4 00 00 00    	jne    80104b36 <wait2+0xed>
        continue;
      havekids = 1;
80104a82:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8c:	8b 40 0c             	mov    0xc(%eax),%eax
80104a8f:	83 f8 05             	cmp    $0x5,%eax
80104a92:	0f 85 9f 00 00 00    	jne    80104b37 <wait2+0xee>
	*rtime = p->rtime;
80104a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9b:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104aa4:	89 10                	mov    %edx,(%eax)
	*wtime = p->etime - p->ctime - p->rtime;
80104aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa9:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab2:	8b 40 7c             	mov    0x7c(%eax),%eax
80104ab5:	29 c2                	sub    %eax,%edx
80104ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aba:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104ac0:	29 c2                	sub    %eax,%edx
80104ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ac5:	89 10                	mov    %edx,(%eax)
	// Found one.
        pid = p->pid;
80104ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aca:	8b 40 10             	mov    0x10(%eax),%eax
80104acd:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad3:	8b 40 08             	mov    0x8(%eax),%eax
80104ad6:	89 04 24             	mov    %eax,(%esp)
80104ad9:	e8 e0 e2 ff ff       	call   80102dbe <kfree>
        p->kstack = 0;
80104ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aeb:	8b 40 04             	mov    0x4(%eax),%eax
80104aee:	89 04 24             	mov    %eax,(%esp)
80104af1:	e8 b7 3a 00 00       	call   801085ad <freevm>
        p->state = UNUSED;
80104af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b03:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b17:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b1e:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104b25:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104b2c:	e8 20 07 00 00       	call   80105251 <release>
        return pid;
80104b31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b34:	eb 56                	jmp    80104b8c <wait2+0x143>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104b36:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b37:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80104b3e:	81 7d f4 74 24 11 80 	cmpl   $0x80112474,-0xc(%ebp)
80104b45:	0f 82 23 ff ff ff    	jb     80104a6e <wait2+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b4b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b4f:	74 0d                	je     80104b5e <wait2+0x115>
80104b51:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b57:	8b 40 24             	mov    0x24(%eax),%eax
80104b5a:	85 c0                	test   %eax,%eax
80104b5c:	74 13                	je     80104b71 <wait2+0x128>
      release(&ptable.lock);
80104b5e:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104b65:	e8 e7 06 00 00       	call   80105251 <release>
      return -1;
80104b6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b6f:	eb 1b                	jmp    80104b8c <wait2+0x143>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b71:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b77:	c7 44 24 04 40 ff 10 	movl   $0x8010ff40,0x4(%esp)
80104b7e:	80 
80104b7f:	89 04 24             	mov    %eax,(%esp)
80104b82:	e8 ff 02 00 00       	call   80104e86 <sleep>
  }
80104b87:	e9 cf fe ff ff       	jmp    80104a5b <wait2+0x12>
  
  
  return proc->pid;
}
80104b8c:	c9                   	leave  
80104b8d:	c3                   	ret    

80104b8e <register_handler>:

void
register_handler(sighandler_t sighandler)
{
80104b8e:	55                   	push   %ebp
80104b8f:	89 e5                	mov    %esp,%ebp
80104b91:	83 ec 28             	sub    $0x28,%esp
  char* addr = uva2ka(proc->pgdir, (char*)proc->tf->esp);
80104b94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b9a:	8b 40 18             	mov    0x18(%eax),%eax
80104b9d:	8b 40 44             	mov    0x44(%eax),%eax
80104ba0:	89 c2                	mov    %eax,%edx
80104ba2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ba8:	8b 40 04             	mov    0x4(%eax),%eax
80104bab:	89 54 24 04          	mov    %edx,0x4(%esp)
80104baf:	89 04 24             	mov    %eax,(%esp)
80104bb2:	e8 db 3b 00 00       	call   80108792 <uva2ka>
80104bb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if ((proc->tf->esp & 0xFFF) == 0)
80104bba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bc0:	8b 40 18             	mov    0x18(%eax),%eax
80104bc3:	8b 40 44             	mov    0x44(%eax),%eax
80104bc6:	25 ff 0f 00 00       	and    $0xfff,%eax
80104bcb:	85 c0                	test   %eax,%eax
80104bcd:	75 0c                	jne    80104bdb <register_handler+0x4d>
    panic("esp_offset == 0");
80104bcf:	c7 04 24 a5 8b 10 80 	movl   $0x80108ba5,(%esp)
80104bd6:	e8 62 b9 ff ff       	call   8010053d <panic>

    /* open a new frame */
  *(int*)(addr + ((proc->tf->esp - 4) & 0xFFF))
80104bdb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104be1:	8b 40 18             	mov    0x18(%eax),%eax
80104be4:	8b 40 44             	mov    0x44(%eax),%eax
80104be7:	83 e8 04             	sub    $0x4,%eax
80104bea:	25 ff 0f 00 00       	and    $0xfff,%eax
80104bef:	03 45 f4             	add    -0xc(%ebp),%eax
          = proc->tf->eip;
80104bf2:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104bf9:	8b 52 18             	mov    0x18(%edx),%edx
80104bfc:	8b 52 38             	mov    0x38(%edx),%edx
80104bff:	89 10                	mov    %edx,(%eax)
  proc->tf->esp -= 4;
80104c01:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c07:	8b 40 18             	mov    0x18(%eax),%eax
80104c0a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104c11:	8b 52 18             	mov    0x18(%edx),%edx
80104c14:	8b 52 44             	mov    0x44(%edx),%edx
80104c17:	83 ea 04             	sub    $0x4,%edx
80104c1a:	89 50 44             	mov    %edx,0x44(%eax)

    /* update eip */
  proc->tf->eip = (uint)sighandler;
80104c1d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c23:	8b 40 18             	mov    0x18(%eax),%eax
80104c26:	8b 55 08             	mov    0x8(%ebp),%edx
80104c29:	89 50 38             	mov    %edx,0x38(%eax)
}
80104c2c:	c9                   	leave  
80104c2d:	c3                   	ret    

80104c2e <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c2e:	55                   	push   %ebp
80104c2f:	89 e5                	mov    %esp,%ebp
80104c31:	83 ec 48             	sub    $0x48,%esp
  struct proc *p;
  struct proc *medium;
  struct proc *high;
  struct proc *head = 0;
80104c34:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  struct proc *t = ptable.proc;
80104c3b:	c7 45 ec 74 ff 10 80 	movl   $0x8010ff74,-0x14(%ebp)
  uint grt_min;
  
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c42:	e8 16 f7 ff ff       	call   8010435d <sti>
    highflag = 0;
80104c47:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    mediumflag = 0;
80104c4e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    lowflag = 0;
80104c55:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    frr_min = 0;
80104c5c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
    grt_min = 0;
80104c63:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    
    if(head && p==head)
80104c6a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c6e:	74 17                	je     80104c87 <scheduler+0x59>
80104c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c73:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104c76:	75 0f                	jne    80104c87 <scheduler+0x59>
      t = ++head;
80104c78:	81 45 f0 94 00 00 00 	addl   $0x94,-0x10(%ebp)
80104c7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c82:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104c85:	eb 0c                	jmp    80104c93 <scheduler+0x65>
    else if(head)
80104c87:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c8b:	74 06                	je     80104c93 <scheduler+0x65>
      t = head;
80104c8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c90:	89 45 ec             	mov    %eax,-0x14(%ebp)
    
    acquire(&tickslock);
80104c93:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80104c9a:	e8 50 05 00 00       	call   801051ef <acquire>
    currentime = ticks;
80104c9f:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
80104ca4:	89 45 d0             	mov    %eax,-0x30(%ebp)
    release(&tickslock);  
80104ca7:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80104cae:	e8 9e 05 00 00       	call   80105251 <release>
    int i=0;
80104cb3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    acquire(&ptable.lock); 
80104cba:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104cc1:	e8 29 05 00 00       	call   801051ef <acquire>
    for(; i<NPROC; i++)			// Loop over process table looking for process to run.
80104cc6:	e9 90 00 00 00       	jmp    80104d5b <scheduler+0x12d>
    {
      if(t >= &ptable.proc[NPROC])
80104ccb:	81 7d ec 74 24 11 80 	cmpl   $0x80112474,-0x14(%ebp)
80104cd2:	72 07                	jb     80104cdb <scheduler+0xad>
	t = ptable.proc;
80104cd4:	c7 45 ec 74 ff 10 80 	movl   $0x8010ff74,-0x14(%ebp)
      if(t->state != RUNNABLE)
80104cdb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cde:	8b 40 0c             	mov    0xc(%eax),%eax
80104ce1:	83 f8 03             	cmp    $0x3,%eax
80104ce4:	74 09                	je     80104cef <scheduler+0xc1>
      {
	t++;
80104ce6:	81 45 ec 94 00 00 00 	addl   $0x94,-0x14(%ebp)
	continue;
80104ced:	eb 68                	jmp    80104d57 <scheduler+0x129>
      }
      switch(SCHEDFLAG)
      {
	default:
	  p = t;
80104cef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cf2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	  proc = p;
80104cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf8:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
	  switchuvm(p);
80104cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d01:	89 04 24             	mov    %eax,(%esp)
80104d04:	e8 2d 34 00 00       	call   80108136 <switchuvm>
	  p->state = RUNNING;
80104d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d0c:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
	  p->quanta = QUANTA;
80104d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d16:	c7 80 88 00 00 00 05 	movl   $0x5,0x88(%eax)
80104d1d:	00 00 00 
	  swtch(&cpu->scheduler, proc->context);
80104d20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d26:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d29:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104d30:	83 c2 04             	add    $0x4,%edx
80104d33:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d37:	89 14 24             	mov    %edx,(%esp)
80104d3a:	e8 a5 09 00 00       	call   801056e4 <swtch>
	  switchkvm();
80104d3f:	e8 d5 33 00 00       	call   80108119 <switchkvm>
	  // Process is done running for now.
	  // It should have changed its p->state before coming back.
	  proc = 0;
80104d44:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104d4b:	00 00 00 00 
	  break;
80104d4f:	90                   	nop
	    lowflag = 1;
	    t->quanta = QUANTA;
	  }
	  break;
      }
      t++;
80104d50:	81 45 ec 94 00 00 00 	addl   $0x94,-0x14(%ebp)
    acquire(&tickslock);
    currentime = ticks;
    release(&tickslock);  
    int i=0;
    acquire(&ptable.lock); 
    for(; i<NPROC; i++)			// Loop over process table looking for process to run.
80104d57:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80104d5b:	83 7d e8 3f          	cmpl   $0x3f,-0x18(%ebp)
80104d5f:	0f 8e 66 ff ff ff    	jle    80104ccb <scheduler+0x9d>
	// Process is done running for now.
	// It should have changed its p->state before coming back.
	proc = 0;
      }
    }
    release(&ptable.lock);
80104d65:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104d6c:	e8 e0 04 00 00       	call   80105251 <release>
    }
80104d71:	e9 cc fe ff ff       	jmp    80104c42 <scheduler+0x14>

80104d76 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104d76:	55                   	push   %ebp
80104d77:	89 e5                	mov    %esp,%ebp
80104d79:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104d7c:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104d83:	e8 85 05 00 00       	call   8010530d <holding>
80104d88:	85 c0                	test   %eax,%eax
80104d8a:	75 0c                	jne    80104d98 <sched+0x22>
    panic("sched ptable.lock");
80104d8c:	c7 04 24 b5 8b 10 80 	movl   $0x80108bb5,(%esp)
80104d93:	e8 a5 b7 ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80104d98:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d9e:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104da4:	83 f8 01             	cmp    $0x1,%eax
80104da7:	74 0c                	je     80104db5 <sched+0x3f>
    panic("sched locks");
80104da9:	c7 04 24 c7 8b 10 80 	movl   $0x80108bc7,(%esp)
80104db0:	e8 88 b7 ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104db5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dbb:	8b 40 0c             	mov    0xc(%eax),%eax
80104dbe:	83 f8 04             	cmp    $0x4,%eax
80104dc1:	75 0c                	jne    80104dcf <sched+0x59>
    panic("sched running");
80104dc3:	c7 04 24 d3 8b 10 80 	movl   $0x80108bd3,(%esp)
80104dca:	e8 6e b7 ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104dcf:	e8 74 f5 ff ff       	call   80104348 <readeflags>
80104dd4:	25 00 02 00 00       	and    $0x200,%eax
80104dd9:	85 c0                	test   %eax,%eax
80104ddb:	74 0c                	je     80104de9 <sched+0x73>
    panic("sched interruptible");
80104ddd:	c7 04 24 e1 8b 10 80 	movl   $0x80108be1,(%esp)
80104de4:	e8 54 b7 ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80104de9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104def:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104df5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104df8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104dfe:	8b 40 04             	mov    0x4(%eax),%eax
80104e01:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104e08:	83 c2 1c             	add    $0x1c,%edx
80104e0b:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e0f:	89 14 24             	mov    %edx,(%esp)
80104e12:	e8 cd 08 00 00       	call   801056e4 <swtch>
  cpu->intena = intena;
80104e17:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104e1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e20:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104e26:	c9                   	leave  
80104e27:	c3                   	ret    

80104e28 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104e28:	55                   	push   %ebp
80104e29:	89 e5                	mov    %esp,%ebp
80104e2b:	83 ec 18             	sub    $0x18,%esp
	proc->qvalue = ticks;
	release(&tickslock);
      }
      break;
  }
  acquire(&ptable.lock);  //DOC: yieldlock
80104e2e:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e35:	e8 b5 03 00 00       	call   801051ef <acquire>
  proc->state = RUNNABLE;
80104e3a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e40:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104e47:	e8 2a ff ff ff       	call   80104d76 <sched>
  release(&ptable.lock);
80104e4c:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e53:	e8 f9 03 00 00       	call   80105251 <release>
  
}
80104e58:	c9                   	leave  
80104e59:	c3                   	ret    

80104e5a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104e5a:	55                   	push   %ebp
80104e5b:	89 e5                	mov    %esp,%ebp
80104e5d:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104e60:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e67:	e8 e5 03 00 00       	call   80105251 <release>

  if (first) {
80104e6c:	a1 20 b0 10 80       	mov    0x8010b020,%eax
80104e71:	85 c0                	test   %eax,%eax
80104e73:	74 0f                	je     80104e84 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104e75:	c7 05 20 b0 10 80 00 	movl   $0x0,0x8010b020
80104e7c:	00 00 00 
    initlog();
80104e7f:	e8 e4 e4 ff ff       	call   80103368 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104e84:	c9                   	leave  
80104e85:	c3                   	ret    

80104e86 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e86:	55                   	push   %ebp
80104e87:	89 e5                	mov    %esp,%ebp
80104e89:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104e8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e92:	85 c0                	test   %eax,%eax
80104e94:	75 0c                	jne    80104ea2 <sleep+0x1c>
    panic("sleep");
80104e96:	c7 04 24 f5 8b 10 80 	movl   $0x80108bf5,(%esp)
80104e9d:	e8 9b b6 ff ff       	call   8010053d <panic>

  if(lk == 0)
80104ea2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104ea6:	75 0c                	jne    80104eb4 <sleep+0x2e>
    panic("sleep without lk");
80104ea8:	c7 04 24 fb 8b 10 80 	movl   $0x80108bfb,(%esp)
80104eaf:	e8 89 b6 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104eb4:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104ebb:	74 17                	je     80104ed4 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104ebd:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104ec4:	e8 26 03 00 00       	call   801051ef <acquire>
    release(lk);
80104ec9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ecc:	89 04 24             	mov    %eax,(%esp)
80104ecf:	e8 7d 03 00 00       	call   80105251 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104ed4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eda:	8b 55 08             	mov    0x8(%ebp),%edx
80104edd:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104ee0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ee6:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104eed:	e8 84 fe ff ff       	call   80104d76 <sched>

  // Tidy up.
  proc->chan = 0;
80104ef2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ef8:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104eff:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104f06:	74 17                	je     80104f1f <sleep+0x99>
    release(&ptable.lock);
80104f08:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f0f:	e8 3d 03 00 00       	call   80105251 <release>
    acquire(lk);
80104f14:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f17:	89 04 24             	mov    %eax,(%esp)
80104f1a:	e8 d0 02 00 00       	call   801051ef <acquire>
  }
}
80104f1f:	c9                   	leave  
80104f20:	c3                   	ret    

80104f21 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104f21:	55                   	push   %ebp
80104f22:	89 e5                	mov    %esp,%ebp
80104f24:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f27:	c7 45 fc 74 ff 10 80 	movl   $0x8010ff74,-0x4(%ebp)
80104f2e:	eb 27                	jmp    80104f57 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104f30:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f33:	8b 40 0c             	mov    0xc(%eax),%eax
80104f36:	83 f8 02             	cmp    $0x2,%eax
80104f39:	75 15                	jne    80104f50 <wakeup1+0x2f>
80104f3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f3e:	8b 40 20             	mov    0x20(%eax),%eax
80104f41:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f44:	75 0a                	jne    80104f50 <wakeup1+0x2f>
    {
      p->state = RUNNABLE;
80104f46:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f49:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f50:	81 45 fc 94 00 00 00 	addl   $0x94,-0x4(%ebp)
80104f57:	81 7d fc 74 24 11 80 	cmpl   $0x80112474,-0x4(%ebp)
80104f5e:	72 d0                	jb     80104f30 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
    {
      p->state = RUNNABLE;
    }
}
80104f60:	c9                   	leave  
80104f61:	c3                   	ret    

80104f62 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f62:	55                   	push   %ebp
80104f63:	89 e5                	mov    %esp,%ebp
80104f65:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104f68:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f6f:	e8 7b 02 00 00       	call   801051ef <acquire>
  wakeup1(chan);
80104f74:	8b 45 08             	mov    0x8(%ebp),%eax
80104f77:	89 04 24             	mov    %eax,(%esp)
80104f7a:	e8 a2 ff ff ff       	call   80104f21 <wakeup1>
  release(&ptable.lock);
80104f7f:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f86:	e8 c6 02 00 00       	call   80105251 <release>
}
80104f8b:	c9                   	leave  
80104f8c:	c3                   	ret    

80104f8d <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f8d:	55                   	push   %ebp
80104f8e:	89 e5                	mov    %esp,%ebp
80104f90:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f93:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f9a:	e8 50 02 00 00       	call   801051ef <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f9f:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104fa6:	eb 44                	jmp    80104fec <kill+0x5f>
    if(p->pid == pid){
80104fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fab:	8b 40 10             	mov    0x10(%eax),%eax
80104fae:	3b 45 08             	cmp    0x8(%ebp),%eax
80104fb1:	75 32                	jne    80104fe5 <kill+0x58>
      p->killed = 1;
80104fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fb6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fc0:	8b 40 0c             	mov    0xc(%eax),%eax
80104fc3:	83 f8 02             	cmp    $0x2,%eax
80104fc6:	75 0a                	jne    80104fd2 <kill+0x45>
        p->state = RUNNABLE;
80104fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fcb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104fd2:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104fd9:	e8 73 02 00 00       	call   80105251 <release>
      return 0;
80104fde:	b8 00 00 00 00       	mov    $0x0,%eax
80104fe3:	eb 21                	jmp    80105006 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fe5:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80104fec:	81 7d f4 74 24 11 80 	cmpl   $0x80112474,-0xc(%ebp)
80104ff3:	72 b3                	jb     80104fa8 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104ff5:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104ffc:	e8 50 02 00 00       	call   80105251 <release>
  return -1;
80105001:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105006:	c9                   	leave  
80105007:	c3                   	ret    

80105008 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105008:	55                   	push   %ebp
80105009:	89 e5                	mov    %esp,%ebp
8010500b:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010500e:	c7 45 f0 74 ff 10 80 	movl   $0x8010ff74,-0x10(%ebp)
80105015:	e9 db 00 00 00       	jmp    801050f5 <procdump+0xed>
    if(p->state == UNUSED)
8010501a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010501d:	8b 40 0c             	mov    0xc(%eax),%eax
80105020:	85 c0                	test   %eax,%eax
80105022:	0f 84 c5 00 00 00    	je     801050ed <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105028:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010502b:	8b 40 0c             	mov    0xc(%eax),%eax
8010502e:	83 f8 05             	cmp    $0x5,%eax
80105031:	77 23                	ja     80105056 <procdump+0x4e>
80105033:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105036:	8b 40 0c             	mov    0xc(%eax),%eax
80105039:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80105040:	85 c0                	test   %eax,%eax
80105042:	74 12                	je     80105056 <procdump+0x4e>
      state = states[p->state];
80105044:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105047:	8b 40 0c             	mov    0xc(%eax),%eax
8010504a:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80105051:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105054:	eb 07                	jmp    8010505d <procdump+0x55>
    else
      state = "???";
80105056:	c7 45 ec 0c 8c 10 80 	movl   $0x80108c0c,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010505d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105060:	8d 50 6c             	lea    0x6c(%eax),%edx
80105063:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105066:	8b 40 10             	mov    0x10(%eax),%eax
80105069:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010506d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105070:	89 54 24 08          	mov    %edx,0x8(%esp)
80105074:	89 44 24 04          	mov    %eax,0x4(%esp)
80105078:	c7 04 24 10 8c 10 80 	movl   $0x80108c10,(%esp)
8010507f:	e8 1d b3 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
80105084:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105087:	8b 40 0c             	mov    0xc(%eax),%eax
8010508a:	83 f8 02             	cmp    $0x2,%eax
8010508d:	75 50                	jne    801050df <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010508f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105092:	8b 40 1c             	mov    0x1c(%eax),%eax
80105095:	8b 40 0c             	mov    0xc(%eax),%eax
80105098:	83 c0 08             	add    $0x8,%eax
8010509b:	8d 55 c4             	lea    -0x3c(%ebp),%edx
8010509e:	89 54 24 04          	mov    %edx,0x4(%esp)
801050a2:	89 04 24             	mov    %eax,(%esp)
801050a5:	e8 f6 01 00 00       	call   801052a0 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801050aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801050b1:	eb 1b                	jmp    801050ce <procdump+0xc6>
        cprintf(" %p", pc[i]);
801050b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b6:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801050be:	c7 04 24 19 8c 10 80 	movl   $0x80108c19,(%esp)
801050c5:	e8 d7 b2 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
801050ca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050ce:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801050d2:	7f 0b                	jg     801050df <procdump+0xd7>
801050d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d7:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050db:	85 c0                	test   %eax,%eax
801050dd:	75 d4                	jne    801050b3 <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801050df:	c7 04 24 1d 8c 10 80 	movl   $0x80108c1d,(%esp)
801050e6:	e8 b6 b2 ff ff       	call   801003a1 <cprintf>
801050eb:	eb 01                	jmp    801050ee <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
801050ed:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050ee:	81 45 f0 94 00 00 00 	addl   $0x94,-0x10(%ebp)
801050f5:	81 7d f0 74 24 11 80 	cmpl   $0x80112474,-0x10(%ebp)
801050fc:	0f 82 18 ff ff ff    	jb     8010501a <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105102:	c9                   	leave  
80105103:	c3                   	ret    

80105104 <nice>:

int
nice(void)
{
80105104:	55                   	push   %ebp
80105105:	89 e5                	mov    %esp,%ebp
  if(proc)
80105107:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010510d:	85 c0                	test   %eax,%eax
8010510f:	74 70                	je     80105181 <nice+0x7d>
  {
    if(proc->priority == HIGH)
80105111:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105117:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
8010511d:	83 f8 03             	cmp    $0x3,%eax
80105120:	75 32                	jne    80105154 <nice+0x50>
    {
      proc->priority--;
80105122:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105128:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
8010512e:	83 ea 01             	sub    $0x1,%edx
80105131:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
      proc->qvalue = proc->ctime;
80105137:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010513d:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105144:	8b 52 7c             	mov    0x7c(%edx),%edx
80105147:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
      return 0;
8010514d:	b8 00 00 00 00       	mov    $0x0,%eax
80105152:	eb 32                	jmp    80105186 <nice+0x82>
    }
    else if(proc->priority == MEDIUM)
80105154:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010515a:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80105160:	83 f8 02             	cmp    $0x2,%eax
80105163:	75 1c                	jne    80105181 <nice+0x7d>
    {
      proc->priority--;
80105165:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010516b:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80105171:	83 ea 01             	sub    $0x1,%edx
80105174:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
      return 0;
8010517a:	b8 00 00 00 00       	mov    $0x0,%eax
8010517f:	eb 05                	jmp    80105186 <nice+0x82>
    }
    
  }
  return -1;
80105181:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105186:	5d                   	pop    %ebp
80105187:	c3                   	ret    

80105188 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105188:	55                   	push   %ebp
80105189:	89 e5                	mov    %esp,%ebp
8010518b:	53                   	push   %ebx
8010518c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010518f:	9c                   	pushf  
80105190:	5b                   	pop    %ebx
80105191:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80105194:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105197:	83 c4 10             	add    $0x10,%esp
8010519a:	5b                   	pop    %ebx
8010519b:	5d                   	pop    %ebp
8010519c:	c3                   	ret    

8010519d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010519d:	55                   	push   %ebp
8010519e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801051a0:	fa                   	cli    
}
801051a1:	5d                   	pop    %ebp
801051a2:	c3                   	ret    

801051a3 <sti>:

static inline void
sti(void)
{
801051a3:	55                   	push   %ebp
801051a4:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801051a6:	fb                   	sti    
}
801051a7:	5d                   	pop    %ebp
801051a8:	c3                   	ret    

801051a9 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801051a9:	55                   	push   %ebp
801051aa:	89 e5                	mov    %esp,%ebp
801051ac:	53                   	push   %ebx
801051ad:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
801051b0:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801051b3:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
801051b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801051b9:	89 c3                	mov    %eax,%ebx
801051bb:	89 d8                	mov    %ebx,%eax
801051bd:	f0 87 02             	lock xchg %eax,(%edx)
801051c0:	89 c3                	mov    %eax,%ebx
801051c2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801051c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801051c8:	83 c4 10             	add    $0x10,%esp
801051cb:	5b                   	pop    %ebx
801051cc:	5d                   	pop    %ebp
801051cd:	c3                   	ret    

801051ce <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801051ce:	55                   	push   %ebp
801051cf:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801051d1:	8b 45 08             	mov    0x8(%ebp),%eax
801051d4:	8b 55 0c             	mov    0xc(%ebp),%edx
801051d7:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801051da:	8b 45 08             	mov    0x8(%ebp),%eax
801051dd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801051e3:	8b 45 08             	mov    0x8(%ebp),%eax
801051e6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801051ed:	5d                   	pop    %ebp
801051ee:	c3                   	ret    

801051ef <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801051ef:	55                   	push   %ebp
801051f0:	89 e5                	mov    %esp,%ebp
801051f2:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801051f5:	e8 3d 01 00 00       	call   80105337 <pushcli>
  if(holding(lk))
801051fa:	8b 45 08             	mov    0x8(%ebp),%eax
801051fd:	89 04 24             	mov    %eax,(%esp)
80105200:	e8 08 01 00 00       	call   8010530d <holding>
80105205:	85 c0                	test   %eax,%eax
80105207:	74 0c                	je     80105215 <acquire+0x26>
    panic("acquire");
80105209:	c7 04 24 49 8c 10 80 	movl   $0x80108c49,(%esp)
80105210:	e8 28 b3 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105215:	90                   	nop
80105216:	8b 45 08             	mov    0x8(%ebp),%eax
80105219:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105220:	00 
80105221:	89 04 24             	mov    %eax,(%esp)
80105224:	e8 80 ff ff ff       	call   801051a9 <xchg>
80105229:	85 c0                	test   %eax,%eax
8010522b:	75 e9                	jne    80105216 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
8010522d:	8b 45 08             	mov    0x8(%ebp),%eax
80105230:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105237:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
8010523a:	8b 45 08             	mov    0x8(%ebp),%eax
8010523d:	83 c0 0c             	add    $0xc,%eax
80105240:	89 44 24 04          	mov    %eax,0x4(%esp)
80105244:	8d 45 08             	lea    0x8(%ebp),%eax
80105247:	89 04 24             	mov    %eax,(%esp)
8010524a:	e8 51 00 00 00       	call   801052a0 <getcallerpcs>
}
8010524f:	c9                   	leave  
80105250:	c3                   	ret    

80105251 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105251:	55                   	push   %ebp
80105252:	89 e5                	mov    %esp,%ebp
80105254:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105257:	8b 45 08             	mov    0x8(%ebp),%eax
8010525a:	89 04 24             	mov    %eax,(%esp)
8010525d:	e8 ab 00 00 00       	call   8010530d <holding>
80105262:	85 c0                	test   %eax,%eax
80105264:	75 0c                	jne    80105272 <release+0x21>
    panic("release");
80105266:	c7 04 24 51 8c 10 80 	movl   $0x80108c51,(%esp)
8010526d:	e8 cb b2 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
80105272:	8b 45 08             	mov    0x8(%ebp),%eax
80105275:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010527c:	8b 45 08             	mov    0x8(%ebp),%eax
8010527f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105286:	8b 45 08             	mov    0x8(%ebp),%eax
80105289:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105290:	00 
80105291:	89 04 24             	mov    %eax,(%esp)
80105294:	e8 10 ff ff ff       	call   801051a9 <xchg>

  popcli();
80105299:	e8 e1 00 00 00       	call   8010537f <popcli>
}
8010529e:	c9                   	leave  
8010529f:	c3                   	ret    

801052a0 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801052a0:	55                   	push   %ebp
801052a1:	89 e5                	mov    %esp,%ebp
801052a3:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801052a6:	8b 45 08             	mov    0x8(%ebp),%eax
801052a9:	83 e8 08             	sub    $0x8,%eax
801052ac:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801052af:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801052b6:	eb 32                	jmp    801052ea <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801052b8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801052bc:	74 47                	je     80105305 <getcallerpcs+0x65>
801052be:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801052c5:	76 3e                	jbe    80105305 <getcallerpcs+0x65>
801052c7:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801052cb:	74 38                	je     80105305 <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
801052cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052d0:	c1 e0 02             	shl    $0x2,%eax
801052d3:	03 45 0c             	add    0xc(%ebp),%eax
801052d6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052d9:	8b 52 04             	mov    0x4(%edx),%edx
801052dc:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
801052de:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052e1:	8b 00                	mov    (%eax),%eax
801052e3:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801052e6:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801052ea:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801052ee:	7e c8                	jle    801052b8 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801052f0:	eb 13                	jmp    80105305 <getcallerpcs+0x65>
    pcs[i] = 0;
801052f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052f5:	c1 e0 02             	shl    $0x2,%eax
801052f8:	03 45 0c             	add    0xc(%ebp),%eax
801052fb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105301:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105305:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105309:	7e e7                	jle    801052f2 <getcallerpcs+0x52>
    pcs[i] = 0;
}
8010530b:	c9                   	leave  
8010530c:	c3                   	ret    

8010530d <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010530d:	55                   	push   %ebp
8010530e:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105310:	8b 45 08             	mov    0x8(%ebp),%eax
80105313:	8b 00                	mov    (%eax),%eax
80105315:	85 c0                	test   %eax,%eax
80105317:	74 17                	je     80105330 <holding+0x23>
80105319:	8b 45 08             	mov    0x8(%ebp),%eax
8010531c:	8b 50 08             	mov    0x8(%eax),%edx
8010531f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105325:	39 c2                	cmp    %eax,%edx
80105327:	75 07                	jne    80105330 <holding+0x23>
80105329:	b8 01 00 00 00       	mov    $0x1,%eax
8010532e:	eb 05                	jmp    80105335 <holding+0x28>
80105330:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105335:	5d                   	pop    %ebp
80105336:	c3                   	ret    

80105337 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105337:	55                   	push   %ebp
80105338:	89 e5                	mov    %esp,%ebp
8010533a:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
8010533d:	e8 46 fe ff ff       	call   80105188 <readeflags>
80105342:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105345:	e8 53 fe ff ff       	call   8010519d <cli>
  if(cpu->ncli++ == 0)
8010534a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105350:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105356:	85 d2                	test   %edx,%edx
80105358:	0f 94 c1             	sete   %cl
8010535b:	83 c2 01             	add    $0x1,%edx
8010535e:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105364:	84 c9                	test   %cl,%cl
80105366:	74 15                	je     8010537d <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80105368:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010536e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105371:	81 e2 00 02 00 00    	and    $0x200,%edx
80105377:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010537d:	c9                   	leave  
8010537e:	c3                   	ret    

8010537f <popcli>:

void
popcli(void)
{
8010537f:	55                   	push   %ebp
80105380:	89 e5                	mov    %esp,%ebp
80105382:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105385:	e8 fe fd ff ff       	call   80105188 <readeflags>
8010538a:	25 00 02 00 00       	and    $0x200,%eax
8010538f:	85 c0                	test   %eax,%eax
80105391:	74 0c                	je     8010539f <popcli+0x20>
    panic("popcli - interruptible");
80105393:	c7 04 24 59 8c 10 80 	movl   $0x80108c59,(%esp)
8010539a:	e8 9e b1 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
8010539f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053a5:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801053ab:	83 ea 01             	sub    $0x1,%edx
801053ae:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801053b4:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801053ba:	85 c0                	test   %eax,%eax
801053bc:	79 0c                	jns    801053ca <popcli+0x4b>
    panic("popcli");
801053be:	c7 04 24 70 8c 10 80 	movl   $0x80108c70,(%esp)
801053c5:	e8 73 b1 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
801053ca:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053d0:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801053d6:	85 c0                	test   %eax,%eax
801053d8:	75 15                	jne    801053ef <popcli+0x70>
801053da:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053e0:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801053e6:	85 c0                	test   %eax,%eax
801053e8:	74 05                	je     801053ef <popcli+0x70>
    sti();
801053ea:	e8 b4 fd ff ff       	call   801051a3 <sti>
}
801053ef:	c9                   	leave  
801053f0:	c3                   	ret    
801053f1:	00 00                	add    %al,(%eax)
	...

801053f4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801053f4:	55                   	push   %ebp
801053f5:	89 e5                	mov    %esp,%ebp
801053f7:	57                   	push   %edi
801053f8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801053f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053fc:	8b 55 10             	mov    0x10(%ebp),%edx
801053ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105402:	89 cb                	mov    %ecx,%ebx
80105404:	89 df                	mov    %ebx,%edi
80105406:	89 d1                	mov    %edx,%ecx
80105408:	fc                   	cld    
80105409:	f3 aa                	rep stos %al,%es:(%edi)
8010540b:	89 ca                	mov    %ecx,%edx
8010540d:	89 fb                	mov    %edi,%ebx
8010540f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105412:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105415:	5b                   	pop    %ebx
80105416:	5f                   	pop    %edi
80105417:	5d                   	pop    %ebp
80105418:	c3                   	ret    

80105419 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105419:	55                   	push   %ebp
8010541a:	89 e5                	mov    %esp,%ebp
8010541c:	57                   	push   %edi
8010541d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010541e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105421:	8b 55 10             	mov    0x10(%ebp),%edx
80105424:	8b 45 0c             	mov    0xc(%ebp),%eax
80105427:	89 cb                	mov    %ecx,%ebx
80105429:	89 df                	mov    %ebx,%edi
8010542b:	89 d1                	mov    %edx,%ecx
8010542d:	fc                   	cld    
8010542e:	f3 ab                	rep stos %eax,%es:(%edi)
80105430:	89 ca                	mov    %ecx,%edx
80105432:	89 fb                	mov    %edi,%ebx
80105434:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105437:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010543a:	5b                   	pop    %ebx
8010543b:	5f                   	pop    %edi
8010543c:	5d                   	pop    %ebp
8010543d:	c3                   	ret    

8010543e <memset>:
#include "x86.h"
#include "string.h"

void*
memset(void *dst, int c, uint n)
{
8010543e:	55                   	push   %ebp
8010543f:	89 e5                	mov    %esp,%ebp
80105441:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105444:	8b 45 08             	mov    0x8(%ebp),%eax
80105447:	83 e0 03             	and    $0x3,%eax
8010544a:	85 c0                	test   %eax,%eax
8010544c:	75 49                	jne    80105497 <memset+0x59>
8010544e:	8b 45 10             	mov    0x10(%ebp),%eax
80105451:	83 e0 03             	and    $0x3,%eax
80105454:	85 c0                	test   %eax,%eax
80105456:	75 3f                	jne    80105497 <memset+0x59>
    c &= 0xFF;
80105458:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010545f:	8b 45 10             	mov    0x10(%ebp),%eax
80105462:	c1 e8 02             	shr    $0x2,%eax
80105465:	89 c2                	mov    %eax,%edx
80105467:	8b 45 0c             	mov    0xc(%ebp),%eax
8010546a:	89 c1                	mov    %eax,%ecx
8010546c:	c1 e1 18             	shl    $0x18,%ecx
8010546f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105472:	c1 e0 10             	shl    $0x10,%eax
80105475:	09 c1                	or     %eax,%ecx
80105477:	8b 45 0c             	mov    0xc(%ebp),%eax
8010547a:	c1 e0 08             	shl    $0x8,%eax
8010547d:	09 c8                	or     %ecx,%eax
8010547f:	0b 45 0c             	or     0xc(%ebp),%eax
80105482:	89 54 24 08          	mov    %edx,0x8(%esp)
80105486:	89 44 24 04          	mov    %eax,0x4(%esp)
8010548a:	8b 45 08             	mov    0x8(%ebp),%eax
8010548d:	89 04 24             	mov    %eax,(%esp)
80105490:	e8 84 ff ff ff       	call   80105419 <stosl>
80105495:	eb 19                	jmp    801054b0 <memset+0x72>
  } else
    stosb(dst, c, n);
80105497:	8b 45 10             	mov    0x10(%ebp),%eax
8010549a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010549e:	8b 45 0c             	mov    0xc(%ebp),%eax
801054a1:	89 44 24 04          	mov    %eax,0x4(%esp)
801054a5:	8b 45 08             	mov    0x8(%ebp),%eax
801054a8:	89 04 24             	mov    %eax,(%esp)
801054ab:	e8 44 ff ff ff       	call   801053f4 <stosb>
  return dst;
801054b0:	8b 45 08             	mov    0x8(%ebp),%eax
}
801054b3:	c9                   	leave  
801054b4:	c3                   	ret    

801054b5 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801054b5:	55                   	push   %ebp
801054b6:	89 e5                	mov    %esp,%ebp
801054b8:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801054bb:	8b 45 08             	mov    0x8(%ebp),%eax
801054be:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801054c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801054c4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801054c7:	eb 32                	jmp    801054fb <memcmp+0x46>
    if(*s1 != *s2)
801054c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054cc:	0f b6 10             	movzbl (%eax),%edx
801054cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054d2:	0f b6 00             	movzbl (%eax),%eax
801054d5:	38 c2                	cmp    %al,%dl
801054d7:	74 1a                	je     801054f3 <memcmp+0x3e>
      return *s1 - *s2;
801054d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054dc:	0f b6 00             	movzbl (%eax),%eax
801054df:	0f b6 d0             	movzbl %al,%edx
801054e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054e5:	0f b6 00             	movzbl (%eax),%eax
801054e8:	0f b6 c0             	movzbl %al,%eax
801054eb:	89 d1                	mov    %edx,%ecx
801054ed:	29 c1                	sub    %eax,%ecx
801054ef:	89 c8                	mov    %ecx,%eax
801054f1:	eb 1c                	jmp    8010550f <memcmp+0x5a>
    s1++, s2++;
801054f3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054f7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801054fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054ff:	0f 95 c0             	setne  %al
80105502:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105506:	84 c0                	test   %al,%al
80105508:	75 bf                	jne    801054c9 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010550a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010550f:	c9                   	leave  
80105510:	c3                   	ret    

80105511 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105511:	55                   	push   %ebp
80105512:	89 e5                	mov    %esp,%ebp
80105514:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105517:	8b 45 0c             	mov    0xc(%ebp),%eax
8010551a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010551d:	8b 45 08             	mov    0x8(%ebp),%eax
80105520:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105523:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105526:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105529:	73 54                	jae    8010557f <memmove+0x6e>
8010552b:	8b 45 10             	mov    0x10(%ebp),%eax
8010552e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105531:	01 d0                	add    %edx,%eax
80105533:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105536:	76 47                	jbe    8010557f <memmove+0x6e>
    s += n;
80105538:	8b 45 10             	mov    0x10(%ebp),%eax
8010553b:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010553e:	8b 45 10             	mov    0x10(%ebp),%eax
80105541:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105544:	eb 13                	jmp    80105559 <memmove+0x48>
      *--d = *--s;
80105546:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010554a:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010554e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105551:	0f b6 10             	movzbl (%eax),%edx
80105554:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105557:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105559:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010555d:	0f 95 c0             	setne  %al
80105560:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105564:	84 c0                	test   %al,%al
80105566:	75 de                	jne    80105546 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105568:	eb 25                	jmp    8010558f <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
8010556a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010556d:	0f b6 10             	movzbl (%eax),%edx
80105570:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105573:	88 10                	mov    %dl,(%eax)
80105575:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105579:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010557d:	eb 01                	jmp    80105580 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010557f:	90                   	nop
80105580:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105584:	0f 95 c0             	setne  %al
80105587:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010558b:	84 c0                	test   %al,%al
8010558d:	75 db                	jne    8010556a <memmove+0x59>
      *d++ = *s++;

  return dst;
8010558f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105592:	c9                   	leave  
80105593:	c3                   	ret    

80105594 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105594:	55                   	push   %ebp
80105595:	89 e5                	mov    %esp,%ebp
80105597:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010559a:	8b 45 10             	mov    0x10(%ebp),%eax
8010559d:	89 44 24 08          	mov    %eax,0x8(%esp)
801055a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801055a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801055a8:	8b 45 08             	mov    0x8(%ebp),%eax
801055ab:	89 04 24             	mov    %eax,(%esp)
801055ae:	e8 5e ff ff ff       	call   80105511 <memmove>
}
801055b3:	c9                   	leave  
801055b4:	c3                   	ret    

801055b5 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801055b5:	55                   	push   %ebp
801055b6:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801055b8:	eb 0c                	jmp    801055c6 <strncmp+0x11>
    n--, p++, q++;
801055ba:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801055be:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801055c2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801055c6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055ca:	74 1a                	je     801055e6 <strncmp+0x31>
801055cc:	8b 45 08             	mov    0x8(%ebp),%eax
801055cf:	0f b6 00             	movzbl (%eax),%eax
801055d2:	84 c0                	test   %al,%al
801055d4:	74 10                	je     801055e6 <strncmp+0x31>
801055d6:	8b 45 08             	mov    0x8(%ebp),%eax
801055d9:	0f b6 10             	movzbl (%eax),%edx
801055dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801055df:	0f b6 00             	movzbl (%eax),%eax
801055e2:	38 c2                	cmp    %al,%dl
801055e4:	74 d4                	je     801055ba <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801055e6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055ea:	75 07                	jne    801055f3 <strncmp+0x3e>
    return 0;
801055ec:	b8 00 00 00 00       	mov    $0x0,%eax
801055f1:	eb 18                	jmp    8010560b <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
801055f3:	8b 45 08             	mov    0x8(%ebp),%eax
801055f6:	0f b6 00             	movzbl (%eax),%eax
801055f9:	0f b6 d0             	movzbl %al,%edx
801055fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ff:	0f b6 00             	movzbl (%eax),%eax
80105602:	0f b6 c0             	movzbl %al,%eax
80105605:	89 d1                	mov    %edx,%ecx
80105607:	29 c1                	sub    %eax,%ecx
80105609:	89 c8                	mov    %ecx,%eax
}
8010560b:	5d                   	pop    %ebp
8010560c:	c3                   	ret    

8010560d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010560d:	55                   	push   %ebp
8010560e:	89 e5                	mov    %esp,%ebp
80105610:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105613:	8b 45 08             	mov    0x8(%ebp),%eax
80105616:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105619:	90                   	nop
8010561a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010561e:	0f 9f c0             	setg   %al
80105621:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105625:	84 c0                	test   %al,%al
80105627:	74 30                	je     80105659 <strncpy+0x4c>
80105629:	8b 45 0c             	mov    0xc(%ebp),%eax
8010562c:	0f b6 10             	movzbl (%eax),%edx
8010562f:	8b 45 08             	mov    0x8(%ebp),%eax
80105632:	88 10                	mov    %dl,(%eax)
80105634:	8b 45 08             	mov    0x8(%ebp),%eax
80105637:	0f b6 00             	movzbl (%eax),%eax
8010563a:	84 c0                	test   %al,%al
8010563c:	0f 95 c0             	setne  %al
8010563f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105643:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105647:	84 c0                	test   %al,%al
80105649:	75 cf                	jne    8010561a <strncpy+0xd>
    ;
  while(n-- > 0)
8010564b:	eb 0c                	jmp    80105659 <strncpy+0x4c>
    *s++ = 0;
8010564d:	8b 45 08             	mov    0x8(%ebp),%eax
80105650:	c6 00 00             	movb   $0x0,(%eax)
80105653:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105657:	eb 01                	jmp    8010565a <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105659:	90                   	nop
8010565a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010565e:	0f 9f c0             	setg   %al
80105661:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105665:	84 c0                	test   %al,%al
80105667:	75 e4                	jne    8010564d <strncpy+0x40>
    *s++ = 0;
  return os;
80105669:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010566c:	c9                   	leave  
8010566d:	c3                   	ret    

8010566e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010566e:	55                   	push   %ebp
8010566f:	89 e5                	mov    %esp,%ebp
80105671:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105674:	8b 45 08             	mov    0x8(%ebp),%eax
80105677:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010567a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010567e:	7f 05                	jg     80105685 <safestrcpy+0x17>
    return os;
80105680:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105683:	eb 35                	jmp    801056ba <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105685:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105689:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010568d:	7e 22                	jle    801056b1 <safestrcpy+0x43>
8010568f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105692:	0f b6 10             	movzbl (%eax),%edx
80105695:	8b 45 08             	mov    0x8(%ebp),%eax
80105698:	88 10                	mov    %dl,(%eax)
8010569a:	8b 45 08             	mov    0x8(%ebp),%eax
8010569d:	0f b6 00             	movzbl (%eax),%eax
801056a0:	84 c0                	test   %al,%al
801056a2:	0f 95 c0             	setne  %al
801056a5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801056a9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
801056ad:	84 c0                	test   %al,%al
801056af:	75 d4                	jne    80105685 <safestrcpy+0x17>
    ;
  *s = 0;
801056b1:	8b 45 08             	mov    0x8(%ebp),%eax
801056b4:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801056b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801056ba:	c9                   	leave  
801056bb:	c3                   	ret    

801056bc <strlen>:

int
strlen(const char *s)
{
801056bc:	55                   	push   %ebp
801056bd:	89 e5                	mov    %esp,%ebp
801056bf:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801056c2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801056c9:	eb 04                	jmp    801056cf <strlen+0x13>
801056cb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801056cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056d2:	03 45 08             	add    0x8(%ebp),%eax
801056d5:	0f b6 00             	movzbl (%eax),%eax
801056d8:	84 c0                	test   %al,%al
801056da:	75 ef                	jne    801056cb <strlen+0xf>
    ;
  return n;
801056dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801056df:	c9                   	leave  
801056e0:	c3                   	ret    
801056e1:	00 00                	add    %al,(%eax)
	...

801056e4 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801056e4:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801056e8:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801056ec:	55                   	push   %ebp
  pushl %ebx
801056ed:	53                   	push   %ebx
  pushl %esi
801056ee:	56                   	push   %esi
  pushl %edi
801056ef:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801056f0:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801056f2:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801056f4:	5f                   	pop    %edi
  popl %esi
801056f5:	5e                   	pop    %esi
  popl %ebx
801056f6:	5b                   	pop    %ebx
  popl %ebp
801056f7:	5d                   	pop    %ebp
  ret
801056f8:	c3                   	ret    
801056f9:	00 00                	add    %al,(%eax)
	...

801056fc <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
801056fc:	55                   	push   %ebp
801056fd:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
801056ff:	8b 45 08             	mov    0x8(%ebp),%eax
80105702:	8b 00                	mov    (%eax),%eax
80105704:	3b 45 0c             	cmp    0xc(%ebp),%eax
80105707:	76 0f                	jbe    80105718 <fetchint+0x1c>
80105709:	8b 45 0c             	mov    0xc(%ebp),%eax
8010570c:	8d 50 04             	lea    0x4(%eax),%edx
8010570f:	8b 45 08             	mov    0x8(%ebp),%eax
80105712:	8b 00                	mov    (%eax),%eax
80105714:	39 c2                	cmp    %eax,%edx
80105716:	76 07                	jbe    8010571f <fetchint+0x23>
    return -1;
80105718:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010571d:	eb 0f                	jmp    8010572e <fetchint+0x32>
  *ip = *(int*)(addr);
8010571f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105722:	8b 10                	mov    (%eax),%edx
80105724:	8b 45 10             	mov    0x10(%ebp),%eax
80105727:	89 10                	mov    %edx,(%eax)
  return 0;
80105729:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010572e:	5d                   	pop    %ebp
8010572f:	c3                   	ret    

80105730 <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
80105730:	55                   	push   %ebp
80105731:	89 e5                	mov    %esp,%ebp
80105733:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= p->sz)
80105736:	8b 45 08             	mov    0x8(%ebp),%eax
80105739:	8b 00                	mov    (%eax),%eax
8010573b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010573e:	77 07                	ja     80105747 <fetchstr+0x17>
    return -1;
80105740:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105745:	eb 45                	jmp    8010578c <fetchstr+0x5c>
  *pp = (char*)addr;
80105747:	8b 55 0c             	mov    0xc(%ebp),%edx
8010574a:	8b 45 10             	mov    0x10(%ebp),%eax
8010574d:	89 10                	mov    %edx,(%eax)
  ep = (char*)p->sz;
8010574f:	8b 45 08             	mov    0x8(%ebp),%eax
80105752:	8b 00                	mov    (%eax),%eax
80105754:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105757:	8b 45 10             	mov    0x10(%ebp),%eax
8010575a:	8b 00                	mov    (%eax),%eax
8010575c:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010575f:	eb 1e                	jmp    8010577f <fetchstr+0x4f>
    if(*s == 0)
80105761:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105764:	0f b6 00             	movzbl (%eax),%eax
80105767:	84 c0                	test   %al,%al
80105769:	75 10                	jne    8010577b <fetchstr+0x4b>
      return s - *pp;
8010576b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010576e:	8b 45 10             	mov    0x10(%ebp),%eax
80105771:	8b 00                	mov    (%eax),%eax
80105773:	89 d1                	mov    %edx,%ecx
80105775:	29 c1                	sub    %eax,%ecx
80105777:	89 c8                	mov    %ecx,%eax
80105779:	eb 11                	jmp    8010578c <fetchstr+0x5c>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
8010577b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010577f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105782:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105785:	72 da                	jb     80105761 <fetchstr+0x31>
    if(*s == 0)
      return s - *pp;
  return -1;
80105787:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010578c:	c9                   	leave  
8010578d:	c3                   	ret    

8010578e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010578e:	55                   	push   %ebp
8010578f:	89 e5                	mov    %esp,%ebp
80105791:	83 ec 0c             	sub    $0xc,%esp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
80105794:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010579a:	8b 40 18             	mov    0x18(%eax),%eax
8010579d:	8b 50 44             	mov    0x44(%eax),%edx
801057a0:	8b 45 08             	mov    0x8(%ebp),%eax
801057a3:	c1 e0 02             	shl    $0x2,%eax
801057a6:	01 d0                	add    %edx,%eax
801057a8:	8d 48 04             	lea    0x4(%eax),%ecx
801057ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057b1:	8b 55 0c             	mov    0xc(%ebp),%edx
801057b4:	89 54 24 08          	mov    %edx,0x8(%esp)
801057b8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
801057bc:	89 04 24             	mov    %eax,(%esp)
801057bf:	e8 38 ff ff ff       	call   801056fc <fetchint>
}
801057c4:	c9                   	leave  
801057c5:	c3                   	ret    

801057c6 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801057c6:	55                   	push   %ebp
801057c7:	89 e5                	mov    %esp,%ebp
801057c9:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
801057cc:	8d 45 fc             	lea    -0x4(%ebp),%eax
801057cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801057d3:	8b 45 08             	mov    0x8(%ebp),%eax
801057d6:	89 04 24             	mov    %eax,(%esp)
801057d9:	e8 b0 ff ff ff       	call   8010578e <argint>
801057de:	85 c0                	test   %eax,%eax
801057e0:	79 07                	jns    801057e9 <argptr+0x23>
    return -1;
801057e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057e7:	eb 3d                	jmp    80105826 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801057e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057ec:	89 c2                	mov    %eax,%edx
801057ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057f4:	8b 00                	mov    (%eax),%eax
801057f6:	39 c2                	cmp    %eax,%edx
801057f8:	73 16                	jae    80105810 <argptr+0x4a>
801057fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057fd:	89 c2                	mov    %eax,%edx
801057ff:	8b 45 10             	mov    0x10(%ebp),%eax
80105802:	01 c2                	add    %eax,%edx
80105804:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010580a:	8b 00                	mov    (%eax),%eax
8010580c:	39 c2                	cmp    %eax,%edx
8010580e:	76 07                	jbe    80105817 <argptr+0x51>
    return -1;
80105810:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105815:	eb 0f                	jmp    80105826 <argptr+0x60>
  *pp = (char*)i;
80105817:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010581a:	89 c2                	mov    %eax,%edx
8010581c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010581f:	89 10                	mov    %edx,(%eax)
  return 0;
80105821:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105826:	c9                   	leave  
80105827:	c3                   	ret    

80105828 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105828:	55                   	push   %ebp
80105829:	89 e5                	mov    %esp,%ebp
8010582b:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010582e:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105831:	89 44 24 04          	mov    %eax,0x4(%esp)
80105835:	8b 45 08             	mov    0x8(%ebp),%eax
80105838:	89 04 24             	mov    %eax,(%esp)
8010583b:	e8 4e ff ff ff       	call   8010578e <argint>
80105840:	85 c0                	test   %eax,%eax
80105842:	79 07                	jns    8010584b <argstr+0x23>
    return -1;
80105844:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105849:	eb 1e                	jmp    80105869 <argstr+0x41>
  return fetchstr(proc, addr, pp);
8010584b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010584e:	89 c2                	mov    %eax,%edx
80105850:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105856:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105859:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010585d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105861:	89 04 24             	mov    %eax,(%esp)
80105864:	e8 c7 fe ff ff       	call   80105730 <fetchstr>
}
80105869:	c9                   	leave  
8010586a:	c3                   	ret    

8010586b <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
8010586b:	55                   	push   %ebp
8010586c:	89 e5                	mov    %esp,%ebp
8010586e:	53                   	push   %ebx
8010586f:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105872:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105878:	8b 40 18             	mov    0x18(%eax),%eax
8010587b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010587e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num >= 0 && num < SYS_open && syscalls[num]) {
80105881:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105885:	78 2e                	js     801058b5 <syscall+0x4a>
80105887:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
8010588b:	7f 28                	jg     801058b5 <syscall+0x4a>
8010588d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105890:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105897:	85 c0                	test   %eax,%eax
80105899:	74 1a                	je     801058b5 <syscall+0x4a>
    proc->tf->eax = syscalls[num]();
8010589b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058a1:	8b 58 18             	mov    0x18(%eax),%ebx
801058a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a7:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801058ae:	ff d0                	call   *%eax
801058b0:	89 43 1c             	mov    %eax,0x1c(%ebx)
801058b3:	eb 73                	jmp    80105928 <syscall+0xbd>
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
801058b5:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
801058b9:	7e 30                	jle    801058eb <syscall+0x80>
801058bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058be:	83 f8 17             	cmp    $0x17,%eax
801058c1:	77 28                	ja     801058eb <syscall+0x80>
801058c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c6:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801058cd:	85 c0                	test   %eax,%eax
801058cf:	74 1a                	je     801058eb <syscall+0x80>
    proc->tf->eax = syscalls[num]();
801058d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058d7:	8b 58 18             	mov    0x18(%eax),%ebx
801058da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058dd:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801058e4:	ff d0                	call   *%eax
801058e6:	89 43 1c             	mov    %eax,0x1c(%ebx)
801058e9:	eb 3d                	jmp    80105928 <syscall+0xbd>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801058eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058f1:	8d 48 6c             	lea    0x6c(%eax),%ecx
801058f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(num >= 0 && num < SYS_open && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801058fa:	8b 40 10             	mov    0x10(%eax),%eax
801058fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105900:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105904:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105908:	89 44 24 04          	mov    %eax,0x4(%esp)
8010590c:	c7 04 24 77 8c 10 80 	movl   $0x80108c77,(%esp)
80105913:	e8 89 aa ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105918:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010591e:	8b 40 18             	mov    0x18(%eax),%eax
80105921:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105928:	83 c4 24             	add    $0x24,%esp
8010592b:	5b                   	pop    %ebx
8010592c:	5d                   	pop    %ebp
8010592d:	c3                   	ret    
	...

80105930 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105930:	55                   	push   %ebp
80105931:	89 e5                	mov    %esp,%ebp
80105933:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105936:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105939:	89 44 24 04          	mov    %eax,0x4(%esp)
8010593d:	8b 45 08             	mov    0x8(%ebp),%eax
80105940:	89 04 24             	mov    %eax,(%esp)
80105943:	e8 46 fe ff ff       	call   8010578e <argint>
80105948:	85 c0                	test   %eax,%eax
8010594a:	79 07                	jns    80105953 <argfd+0x23>
    return -1;
8010594c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105951:	eb 50                	jmp    801059a3 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105956:	85 c0                	test   %eax,%eax
80105958:	78 21                	js     8010597b <argfd+0x4b>
8010595a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010595d:	83 f8 0f             	cmp    $0xf,%eax
80105960:	7f 19                	jg     8010597b <argfd+0x4b>
80105962:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105968:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010596b:	83 c2 08             	add    $0x8,%edx
8010596e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105972:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105975:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105979:	75 07                	jne    80105982 <argfd+0x52>
    return -1;
8010597b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105980:	eb 21                	jmp    801059a3 <argfd+0x73>
  if(pfd)
80105982:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105986:	74 08                	je     80105990 <argfd+0x60>
    *pfd = fd;
80105988:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010598b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010598e:	89 10                	mov    %edx,(%eax)
  if(pf)
80105990:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105994:	74 08                	je     8010599e <argfd+0x6e>
    *pf = f;
80105996:	8b 45 10             	mov    0x10(%ebp),%eax
80105999:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010599c:	89 10                	mov    %edx,(%eax)
  return 0;
8010599e:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059a3:	c9                   	leave  
801059a4:	c3                   	ret    

801059a5 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801059a5:	55                   	push   %ebp
801059a6:	89 e5                	mov    %esp,%ebp
801059a8:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801059ab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801059b2:	eb 30                	jmp    801059e4 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801059b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059ba:	8b 55 fc             	mov    -0x4(%ebp),%edx
801059bd:	83 c2 08             	add    $0x8,%edx
801059c0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801059c4:	85 c0                	test   %eax,%eax
801059c6:	75 18                	jne    801059e0 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801059c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059ce:	8b 55 fc             	mov    -0x4(%ebp),%edx
801059d1:	8d 4a 08             	lea    0x8(%edx),%ecx
801059d4:	8b 55 08             	mov    0x8(%ebp),%edx
801059d7:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801059db:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059de:	eb 0f                	jmp    801059ef <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801059e0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801059e4:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801059e8:	7e ca                	jle    801059b4 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801059ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059ef:	c9                   	leave  
801059f0:	c3                   	ret    

801059f1 <sys_dup>:

int
sys_dup(void)
{
801059f1:	55                   	push   %ebp
801059f2:	89 e5                	mov    %esp,%ebp
801059f4:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801059f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059fa:	89 44 24 08          	mov    %eax,0x8(%esp)
801059fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a05:	00 
80105a06:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a0d:	e8 1e ff ff ff       	call   80105930 <argfd>
80105a12:	85 c0                	test   %eax,%eax
80105a14:	79 07                	jns    80105a1d <sys_dup+0x2c>
    return -1;
80105a16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a1b:	eb 29                	jmp    80105a46 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105a1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a20:	89 04 24             	mov    %eax,(%esp)
80105a23:	e8 7d ff ff ff       	call   801059a5 <fdalloc>
80105a28:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a2b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a2f:	79 07                	jns    80105a38 <sys_dup+0x47>
    return -1;
80105a31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a36:	eb 0e                	jmp    80105a46 <sys_dup+0x55>
  filedup(f);
80105a38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a3b:	89 04 24             	mov    %eax,(%esp)
80105a3e:	e8 91 b8 ff ff       	call   801012d4 <filedup>
  return fd;
80105a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105a46:	c9                   	leave  
80105a47:	c3                   	ret    

80105a48 <sys_read>:

int
sys_read(void)
{
80105a48:	55                   	push   %ebp
80105a49:	89 e5                	mov    %esp,%ebp
80105a4b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105a4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a51:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a55:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a5c:	00 
80105a5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a64:	e8 c7 fe ff ff       	call   80105930 <argfd>
80105a69:	85 c0                	test   %eax,%eax
80105a6b:	78 35                	js     80105aa2 <sys_read+0x5a>
80105a6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a70:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a74:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105a7b:	e8 0e fd ff ff       	call   8010578e <argint>
80105a80:	85 c0                	test   %eax,%eax
80105a82:	78 1e                	js     80105aa2 <sys_read+0x5a>
80105a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a87:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a8b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a92:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a99:	e8 28 fd ff ff       	call   801057c6 <argptr>
80105a9e:	85 c0                	test   %eax,%eax
80105aa0:	79 07                	jns    80105aa9 <sys_read+0x61>
    return -1;
80105aa2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aa7:	eb 19                	jmp    80105ac2 <sys_read+0x7a>
  return fileread(f, p, n);
80105aa9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105aac:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105ab6:	89 54 24 04          	mov    %edx,0x4(%esp)
80105aba:	89 04 24             	mov    %eax,(%esp)
80105abd:	e8 7f b9 ff ff       	call   80101441 <fileread>
}
80105ac2:	c9                   	leave  
80105ac3:	c3                   	ret    

80105ac4 <sys_write>:

int
sys_write(void)
{
80105ac4:	55                   	push   %ebp
80105ac5:	89 e5                	mov    %esp,%ebp
80105ac7:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105aca:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105acd:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ad1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ad8:	00 
80105ad9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ae0:	e8 4b fe ff ff       	call   80105930 <argfd>
80105ae5:	85 c0                	test   %eax,%eax
80105ae7:	78 35                	js     80105b1e <sys_write+0x5a>
80105ae9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105aec:	89 44 24 04          	mov    %eax,0x4(%esp)
80105af0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105af7:	e8 92 fc ff ff       	call   8010578e <argint>
80105afc:	85 c0                	test   %eax,%eax
80105afe:	78 1e                	js     80105b1e <sys_write+0x5a>
80105b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b03:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b07:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b0e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b15:	e8 ac fc ff ff       	call   801057c6 <argptr>
80105b1a:	85 c0                	test   %eax,%eax
80105b1c:	79 07                	jns    80105b25 <sys_write+0x61>
    return -1;
80105b1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b23:	eb 19                	jmp    80105b3e <sys_write+0x7a>
  return filewrite(f, p, n);
80105b25:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105b28:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b2e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105b32:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b36:	89 04 24             	mov    %eax,(%esp)
80105b39:	e8 bf b9 ff ff       	call   801014fd <filewrite>
}
80105b3e:	c9                   	leave  
80105b3f:	c3                   	ret    

80105b40 <sys_close>:

int
sys_close(void)
{
80105b40:	55                   	push   %ebp
80105b41:	89 e5                	mov    %esp,%ebp
80105b43:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105b46:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b49:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b50:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b5b:	e8 d0 fd ff ff       	call   80105930 <argfd>
80105b60:	85 c0                	test   %eax,%eax
80105b62:	79 07                	jns    80105b6b <sys_close+0x2b>
    return -1;
80105b64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b69:	eb 24                	jmp    80105b8f <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105b6b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b71:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b74:	83 c2 08             	add    $0x8,%edx
80105b77:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105b7e:	00 
  fileclose(f);
80105b7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b82:	89 04 24             	mov    %eax,(%esp)
80105b85:	e8 92 b7 ff ff       	call   8010131c <fileclose>
  return 0;
80105b8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b8f:	c9                   	leave  
80105b90:	c3                   	ret    

80105b91 <sys_fstat>:

int
sys_fstat(void)
{
80105b91:	55                   	push   %ebp
80105b92:	89 e5                	mov    %esp,%ebp
80105b94:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105b97:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b9a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b9e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ba5:	00 
80105ba6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105bad:	e8 7e fd ff ff       	call   80105930 <argfd>
80105bb2:	85 c0                	test   %eax,%eax
80105bb4:	78 1f                	js     80105bd5 <sys_fstat+0x44>
80105bb6:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105bbd:	00 
80105bbe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bc5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105bcc:	e8 f5 fb ff ff       	call   801057c6 <argptr>
80105bd1:	85 c0                	test   %eax,%eax
80105bd3:	79 07                	jns    80105bdc <sys_fstat+0x4b>
    return -1;
80105bd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bda:	eb 12                	jmp    80105bee <sys_fstat+0x5d>
  return filestat(f, st);
80105bdc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be2:	89 54 24 04          	mov    %edx,0x4(%esp)
80105be6:	89 04 24             	mov    %eax,(%esp)
80105be9:	e8 04 b8 ff ff       	call   801013f2 <filestat>
}
80105bee:	c9                   	leave  
80105bef:	c3                   	ret    

80105bf0 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105bf0:	55                   	push   %ebp
80105bf1:	89 e5                	mov    %esp,%ebp
80105bf3:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105bf6:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105bf9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bfd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c04:	e8 1f fc ff ff       	call   80105828 <argstr>
80105c09:	85 c0                	test   %eax,%eax
80105c0b:	78 17                	js     80105c24 <sys_link+0x34>
80105c0d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105c10:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c14:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105c1b:	e8 08 fc ff ff       	call   80105828 <argstr>
80105c20:	85 c0                	test   %eax,%eax
80105c22:	79 0a                	jns    80105c2e <sys_link+0x3e>
    return -1;
80105c24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c29:	e9 3c 01 00 00       	jmp    80105d6a <sys_link+0x17a>
  if((ip = namei(old)) == 0)
80105c2e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105c31:	89 04 24             	mov    %eax,(%esp)
80105c34:	e8 29 cb ff ff       	call   80102762 <namei>
80105c39:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c3c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c40:	75 0a                	jne    80105c4c <sys_link+0x5c>
    return -1;
80105c42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c47:	e9 1e 01 00 00       	jmp    80105d6a <sys_link+0x17a>

  begin_trans();
80105c4c:	e8 24 d9 ff ff       	call   80103575 <begin_trans>

  ilock(ip);
80105c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c54:	89 04 24             	mov    %eax,(%esp)
80105c57:	e8 64 bf ff ff       	call   80101bc0 <ilock>
  if(ip->type == T_DIR){
80105c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c5f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105c63:	66 83 f8 01          	cmp    $0x1,%ax
80105c67:	75 1a                	jne    80105c83 <sys_link+0x93>
    iunlockput(ip);
80105c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c6c:	89 04 24             	mov    %eax,(%esp)
80105c6f:	e8 d0 c1 ff ff       	call   80101e44 <iunlockput>
    commit_trans();
80105c74:	e8 45 d9 ff ff       	call   801035be <commit_trans>
    return -1;
80105c79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c7e:	e9 e7 00 00 00       	jmp    80105d6a <sys_link+0x17a>
  }

  ip->nlink++;
80105c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c86:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c8a:	8d 50 01             	lea    0x1(%eax),%edx
80105c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c90:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c97:	89 04 24             	mov    %eax,(%esp)
80105c9a:	e8 65 bd ff ff       	call   80101a04 <iupdate>
  iunlock(ip);
80105c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca2:	89 04 24             	mov    %eax,(%esp)
80105ca5:	e8 64 c0 ff ff       	call   80101d0e <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105caa:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105cad:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105cb0:	89 54 24 04          	mov    %edx,0x4(%esp)
80105cb4:	89 04 24             	mov    %eax,(%esp)
80105cb7:	e8 c8 ca ff ff       	call   80102784 <nameiparent>
80105cbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105cbf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105cc3:	74 68                	je     80105d2d <sys_link+0x13d>
    goto bad;
  ilock(dp);
80105cc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc8:	89 04 24             	mov    %eax,(%esp)
80105ccb:	e8 f0 be ff ff       	call   80101bc0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105cd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd3:	8b 10                	mov    (%eax),%edx
80105cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd8:	8b 00                	mov    (%eax),%eax
80105cda:	39 c2                	cmp    %eax,%edx
80105cdc:	75 20                	jne    80105cfe <sys_link+0x10e>
80105cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce1:	8b 40 04             	mov    0x4(%eax),%eax
80105ce4:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ce8:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105ceb:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cf2:	89 04 24             	mov    %eax,(%esp)
80105cf5:	e8 a7 c7 ff ff       	call   801024a1 <dirlink>
80105cfa:	85 c0                	test   %eax,%eax
80105cfc:	79 0d                	jns    80105d0b <sys_link+0x11b>
    iunlockput(dp);
80105cfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d01:	89 04 24             	mov    %eax,(%esp)
80105d04:	e8 3b c1 ff ff       	call   80101e44 <iunlockput>
    goto bad;
80105d09:	eb 23                	jmp    80105d2e <sys_link+0x13e>
  }
  iunlockput(dp);
80105d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d0e:	89 04 24             	mov    %eax,(%esp)
80105d11:	e8 2e c1 ff ff       	call   80101e44 <iunlockput>
  iput(ip);
80105d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d19:	89 04 24             	mov    %eax,(%esp)
80105d1c:	e8 52 c0 ff ff       	call   80101d73 <iput>

  commit_trans();
80105d21:	e8 98 d8 ff ff       	call   801035be <commit_trans>

  return 0;
80105d26:	b8 00 00 00 00       	mov    $0x0,%eax
80105d2b:	eb 3d                	jmp    80105d6a <sys_link+0x17a>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105d2d:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
80105d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d31:	89 04 24             	mov    %eax,(%esp)
80105d34:	e8 87 be ff ff       	call   80101bc0 <ilock>
  ip->nlink--;
80105d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d3c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d40:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d46:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4d:	89 04 24             	mov    %eax,(%esp)
80105d50:	e8 af bc ff ff       	call   80101a04 <iupdate>
  iunlockput(ip);
80105d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d58:	89 04 24             	mov    %eax,(%esp)
80105d5b:	e8 e4 c0 ff ff       	call   80101e44 <iunlockput>
  commit_trans();
80105d60:	e8 59 d8 ff ff       	call   801035be <commit_trans>
  return -1;
80105d65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d6a:	c9                   	leave  
80105d6b:	c3                   	ret    

80105d6c <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105d6c:	55                   	push   %ebp
80105d6d:	89 e5                	mov    %esp,%ebp
80105d6f:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d72:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105d79:	eb 4b                	jmp    80105dc6 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105d85:	00 
80105d86:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d8a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d8d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d91:	8b 45 08             	mov    0x8(%ebp),%eax
80105d94:	89 04 24             	mov    %eax,(%esp)
80105d97:	e8 1a c3 ff ff       	call   801020b6 <readi>
80105d9c:	83 f8 10             	cmp    $0x10,%eax
80105d9f:	74 0c                	je     80105dad <isdirempty+0x41>
      panic("isdirempty: readi");
80105da1:	c7 04 24 93 8c 10 80 	movl   $0x80108c93,(%esp)
80105da8:	e8 90 a7 ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80105dad:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105db1:	66 85 c0             	test   %ax,%ax
80105db4:	74 07                	je     80105dbd <isdirempty+0x51>
      return 0;
80105db6:	b8 00 00 00 00       	mov    $0x0,%eax
80105dbb:	eb 1b                	jmp    80105dd8 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc0:	83 c0 10             	add    $0x10,%eax
80105dc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105dc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80105dcc:	8b 40 18             	mov    0x18(%eax),%eax
80105dcf:	39 c2                	cmp    %eax,%edx
80105dd1:	72 a8                	jb     80105d7b <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105dd3:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105dd8:	c9                   	leave  
80105dd9:	c3                   	ret    

80105dda <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105dda:	55                   	push   %ebp
80105ddb:	89 e5                	mov    %esp,%ebp
80105ddd:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105de0:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105de3:	89 44 24 04          	mov    %eax,0x4(%esp)
80105de7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105dee:	e8 35 fa ff ff       	call   80105828 <argstr>
80105df3:	85 c0                	test   %eax,%eax
80105df5:	79 0a                	jns    80105e01 <sys_unlink+0x27>
    return -1;
80105df7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dfc:	e9 aa 01 00 00       	jmp    80105fab <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
80105e01:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105e04:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105e07:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e0b:	89 04 24             	mov    %eax,(%esp)
80105e0e:	e8 71 c9 ff ff       	call   80102784 <nameiparent>
80105e13:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e16:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e1a:	75 0a                	jne    80105e26 <sys_unlink+0x4c>
    return -1;
80105e1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e21:	e9 85 01 00 00       	jmp    80105fab <sys_unlink+0x1d1>

  begin_trans();
80105e26:	e8 4a d7 ff ff       	call   80103575 <begin_trans>

  ilock(dp);
80105e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e2e:	89 04 24             	mov    %eax,(%esp)
80105e31:	e8 8a bd ff ff       	call   80101bc0 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105e36:	c7 44 24 04 a5 8c 10 	movl   $0x80108ca5,0x4(%esp)
80105e3d:	80 
80105e3e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e41:	89 04 24             	mov    %eax,(%esp)
80105e44:	e8 6e c5 ff ff       	call   801023b7 <namecmp>
80105e49:	85 c0                	test   %eax,%eax
80105e4b:	0f 84 45 01 00 00    	je     80105f96 <sys_unlink+0x1bc>
80105e51:	c7 44 24 04 a7 8c 10 	movl   $0x80108ca7,0x4(%esp)
80105e58:	80 
80105e59:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e5c:	89 04 24             	mov    %eax,(%esp)
80105e5f:	e8 53 c5 ff ff       	call   801023b7 <namecmp>
80105e64:	85 c0                	test   %eax,%eax
80105e66:	0f 84 2a 01 00 00    	je     80105f96 <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105e6c:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105e6f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e73:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e76:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7d:	89 04 24             	mov    %eax,(%esp)
80105e80:	e8 54 c5 ff ff       	call   801023d9 <dirlookup>
80105e85:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e88:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e8c:	0f 84 03 01 00 00    	je     80105f95 <sys_unlink+0x1bb>
    goto bad;
  ilock(ip);
80105e92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e95:	89 04 24             	mov    %eax,(%esp)
80105e98:	e8 23 bd ff ff       	call   80101bc0 <ilock>

  if(ip->nlink < 1)
80105e9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ea4:	66 85 c0             	test   %ax,%ax
80105ea7:	7f 0c                	jg     80105eb5 <sys_unlink+0xdb>
    panic("unlink: nlink < 1");
80105ea9:	c7 04 24 aa 8c 10 80 	movl   $0x80108caa,(%esp)
80105eb0:	e8 88 a6 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ebc:	66 83 f8 01          	cmp    $0x1,%ax
80105ec0:	75 1f                	jne    80105ee1 <sys_unlink+0x107>
80105ec2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec5:	89 04 24             	mov    %eax,(%esp)
80105ec8:	e8 9f fe ff ff       	call   80105d6c <isdirempty>
80105ecd:	85 c0                	test   %eax,%eax
80105ecf:	75 10                	jne    80105ee1 <sys_unlink+0x107>
    iunlockput(ip);
80105ed1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed4:	89 04 24             	mov    %eax,(%esp)
80105ed7:	e8 68 bf ff ff       	call   80101e44 <iunlockput>
    goto bad;
80105edc:	e9 b5 00 00 00       	jmp    80105f96 <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
80105ee1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105ee8:	00 
80105ee9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ef0:	00 
80105ef1:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ef4:	89 04 24             	mov    %eax,(%esp)
80105ef7:	e8 42 f5 ff ff       	call   8010543e <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105efc:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105eff:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105f06:	00 
80105f07:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f0b:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105f0e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f15:	89 04 24             	mov    %eax,(%esp)
80105f18:	e8 04 c3 ff ff       	call   80102221 <writei>
80105f1d:	83 f8 10             	cmp    $0x10,%eax
80105f20:	74 0c                	je     80105f2e <sys_unlink+0x154>
    panic("unlink: writei");
80105f22:	c7 04 24 bc 8c 10 80 	movl   $0x80108cbc,(%esp)
80105f29:	e8 0f a6 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80105f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f31:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105f35:	66 83 f8 01          	cmp    $0x1,%ax
80105f39:	75 1c                	jne    80105f57 <sys_unlink+0x17d>
    dp->nlink--;
80105f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f3e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f42:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f48:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4f:	89 04 24             	mov    %eax,(%esp)
80105f52:	e8 ad ba ff ff       	call   80101a04 <iupdate>
  }
  iunlockput(dp);
80105f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f5a:	89 04 24             	mov    %eax,(%esp)
80105f5d:	e8 e2 be ff ff       	call   80101e44 <iunlockput>

  ip->nlink--;
80105f62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f65:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f69:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f6f:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105f73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f76:	89 04 24             	mov    %eax,(%esp)
80105f79:	e8 86 ba ff ff       	call   80101a04 <iupdate>
  iunlockput(ip);
80105f7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f81:	89 04 24             	mov    %eax,(%esp)
80105f84:	e8 bb be ff ff       	call   80101e44 <iunlockput>

  commit_trans();
80105f89:	e8 30 d6 ff ff       	call   801035be <commit_trans>

  return 0;
80105f8e:	b8 00 00 00 00       	mov    $0x0,%eax
80105f93:	eb 16                	jmp    80105fab <sys_unlink+0x1d1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105f95:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
80105f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f99:	89 04 24             	mov    %eax,(%esp)
80105f9c:	e8 a3 be ff ff       	call   80101e44 <iunlockput>
  commit_trans();
80105fa1:	e8 18 d6 ff ff       	call   801035be <commit_trans>
  return -1;
80105fa6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105fab:	c9                   	leave  
80105fac:	c3                   	ret    

80105fad <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105fad:	55                   	push   %ebp
80105fae:	89 e5                	mov    %esp,%ebp
80105fb0:	83 ec 48             	sub    $0x48,%esp
80105fb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105fb6:	8b 55 10             	mov    0x10(%ebp),%edx
80105fb9:	8b 45 14             	mov    0x14(%ebp),%eax
80105fbc:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105fc0:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105fc4:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105fc8:	8d 45 de             	lea    -0x22(%ebp),%eax
80105fcb:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fcf:	8b 45 08             	mov    0x8(%ebp),%eax
80105fd2:	89 04 24             	mov    %eax,(%esp)
80105fd5:	e8 aa c7 ff ff       	call   80102784 <nameiparent>
80105fda:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fdd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fe1:	75 0a                	jne    80105fed <create+0x40>
    return 0;
80105fe3:	b8 00 00 00 00       	mov    $0x0,%eax
80105fe8:	e9 7e 01 00 00       	jmp    8010616b <create+0x1be>
  ilock(dp);
80105fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ff0:	89 04 24             	mov    %eax,(%esp)
80105ff3:	e8 c8 bb ff ff       	call   80101bc0 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105ff8:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ffb:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fff:	8d 45 de             	lea    -0x22(%ebp),%eax
80106002:	89 44 24 04          	mov    %eax,0x4(%esp)
80106006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106009:	89 04 24             	mov    %eax,(%esp)
8010600c:	e8 c8 c3 ff ff       	call   801023d9 <dirlookup>
80106011:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106014:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106018:	74 47                	je     80106061 <create+0xb4>
    iunlockput(dp);
8010601a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010601d:	89 04 24             	mov    %eax,(%esp)
80106020:	e8 1f be ff ff       	call   80101e44 <iunlockput>
    ilock(ip);
80106025:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106028:	89 04 24             	mov    %eax,(%esp)
8010602b:	e8 90 bb ff ff       	call   80101bc0 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80106030:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106035:	75 15                	jne    8010604c <create+0x9f>
80106037:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010603e:	66 83 f8 02          	cmp    $0x2,%ax
80106042:	75 08                	jne    8010604c <create+0x9f>
      return ip;
80106044:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106047:	e9 1f 01 00 00       	jmp    8010616b <create+0x1be>
    iunlockput(ip);
8010604c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010604f:	89 04 24             	mov    %eax,(%esp)
80106052:	e8 ed bd ff ff       	call   80101e44 <iunlockput>
    return 0;
80106057:	b8 00 00 00 00       	mov    $0x0,%eax
8010605c:	e9 0a 01 00 00       	jmp    8010616b <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106061:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106065:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106068:	8b 00                	mov    (%eax),%eax
8010606a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010606e:	89 04 24             	mov    %eax,(%esp)
80106071:	e8 b1 b8 ff ff       	call   80101927 <ialloc>
80106076:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106079:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010607d:	75 0c                	jne    8010608b <create+0xde>
    panic("create: ialloc");
8010607f:	c7 04 24 cb 8c 10 80 	movl   $0x80108ccb,(%esp)
80106086:	e8 b2 a4 ff ff       	call   8010053d <panic>

  ilock(ip);
8010608b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010608e:	89 04 24             	mov    %eax,(%esp)
80106091:	e8 2a bb ff ff       	call   80101bc0 <ilock>
  ip->major = major;
80106096:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106099:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010609d:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
801060a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060a4:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801060a8:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
801060ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060af:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
801060b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b8:	89 04 24             	mov    %eax,(%esp)
801060bb:	e8 44 b9 ff ff       	call   80101a04 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
801060c0:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801060c5:	75 6a                	jne    80106131 <create+0x184>
    dp->nlink++;  // for ".."
801060c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ca:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801060ce:	8d 50 01             	lea    0x1(%eax),%edx
801060d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060d4:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801060d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060db:	89 04 24             	mov    %eax,(%esp)
801060de:	e8 21 b9 ff ff       	call   80101a04 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801060e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e6:	8b 40 04             	mov    0x4(%eax),%eax
801060e9:	89 44 24 08          	mov    %eax,0x8(%esp)
801060ed:	c7 44 24 04 a5 8c 10 	movl   $0x80108ca5,0x4(%esp)
801060f4:	80 
801060f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f8:	89 04 24             	mov    %eax,(%esp)
801060fb:	e8 a1 c3 ff ff       	call   801024a1 <dirlink>
80106100:	85 c0                	test   %eax,%eax
80106102:	78 21                	js     80106125 <create+0x178>
80106104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106107:	8b 40 04             	mov    0x4(%eax),%eax
8010610a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010610e:	c7 44 24 04 a7 8c 10 	movl   $0x80108ca7,0x4(%esp)
80106115:	80 
80106116:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106119:	89 04 24             	mov    %eax,(%esp)
8010611c:	e8 80 c3 ff ff       	call   801024a1 <dirlink>
80106121:	85 c0                	test   %eax,%eax
80106123:	79 0c                	jns    80106131 <create+0x184>
      panic("create dots");
80106125:	c7 04 24 da 8c 10 80 	movl   $0x80108cda,(%esp)
8010612c:	e8 0c a4 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106131:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106134:	8b 40 04             	mov    0x4(%eax),%eax
80106137:	89 44 24 08          	mov    %eax,0x8(%esp)
8010613b:	8d 45 de             	lea    -0x22(%ebp),%eax
8010613e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106145:	89 04 24             	mov    %eax,(%esp)
80106148:	e8 54 c3 ff ff       	call   801024a1 <dirlink>
8010614d:	85 c0                	test   %eax,%eax
8010614f:	79 0c                	jns    8010615d <create+0x1b0>
    panic("create: dirlink");
80106151:	c7 04 24 e6 8c 10 80 	movl   $0x80108ce6,(%esp)
80106158:	e8 e0 a3 ff ff       	call   8010053d <panic>

  iunlockput(dp);
8010615d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106160:	89 04 24             	mov    %eax,(%esp)
80106163:	e8 dc bc ff ff       	call   80101e44 <iunlockput>

  return ip;
80106168:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010616b:	c9                   	leave  
8010616c:	c3                   	ret    

8010616d <sys_open>:

int
sys_open(void)
{
8010616d:	55                   	push   %ebp
8010616e:	89 e5                	mov    %esp,%ebp
80106170:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106173:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106176:	89 44 24 04          	mov    %eax,0x4(%esp)
8010617a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106181:	e8 a2 f6 ff ff       	call   80105828 <argstr>
80106186:	85 c0                	test   %eax,%eax
80106188:	78 17                	js     801061a1 <sys_open+0x34>
8010618a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010618d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106191:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106198:	e8 f1 f5 ff ff       	call   8010578e <argint>
8010619d:	85 c0                	test   %eax,%eax
8010619f:	79 0a                	jns    801061ab <sys_open+0x3e>
    return -1;
801061a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061a6:	e9 46 01 00 00       	jmp    801062f1 <sys_open+0x184>
  if(omode & O_CREATE){
801061ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061ae:	25 00 02 00 00       	and    $0x200,%eax
801061b3:	85 c0                	test   %eax,%eax
801061b5:	74 40                	je     801061f7 <sys_open+0x8a>
    begin_trans();
801061b7:	e8 b9 d3 ff ff       	call   80103575 <begin_trans>
    ip = create(path, T_FILE, 0, 0);
801061bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061bf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801061c6:	00 
801061c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801061ce:	00 
801061cf:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801061d6:	00 
801061d7:	89 04 24             	mov    %eax,(%esp)
801061da:	e8 ce fd ff ff       	call   80105fad <create>
801061df:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
801061e2:	e8 d7 d3 ff ff       	call   801035be <commit_trans>
    if(ip == 0)
801061e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061eb:	75 5c                	jne    80106249 <sys_open+0xdc>
      return -1;
801061ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f2:	e9 fa 00 00 00       	jmp    801062f1 <sys_open+0x184>
  } else {
    if((ip = namei(path)) == 0)
801061f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061fa:	89 04 24             	mov    %eax,(%esp)
801061fd:	e8 60 c5 ff ff       	call   80102762 <namei>
80106202:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106205:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106209:	75 0a                	jne    80106215 <sys_open+0xa8>
      return -1;
8010620b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106210:	e9 dc 00 00 00       	jmp    801062f1 <sys_open+0x184>
    ilock(ip);
80106215:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106218:	89 04 24             	mov    %eax,(%esp)
8010621b:	e8 a0 b9 ff ff       	call   80101bc0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80106220:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106223:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106227:	66 83 f8 01          	cmp    $0x1,%ax
8010622b:	75 1c                	jne    80106249 <sys_open+0xdc>
8010622d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106230:	85 c0                	test   %eax,%eax
80106232:	74 15                	je     80106249 <sys_open+0xdc>
      iunlockput(ip);
80106234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106237:	89 04 24             	mov    %eax,(%esp)
8010623a:	e8 05 bc ff ff       	call   80101e44 <iunlockput>
      return -1;
8010623f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106244:	e9 a8 00 00 00       	jmp    801062f1 <sys_open+0x184>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106249:	e8 26 b0 ff ff       	call   80101274 <filealloc>
8010624e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106251:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106255:	74 14                	je     8010626b <sys_open+0xfe>
80106257:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010625a:	89 04 24             	mov    %eax,(%esp)
8010625d:	e8 43 f7 ff ff       	call   801059a5 <fdalloc>
80106262:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106265:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106269:	79 23                	jns    8010628e <sys_open+0x121>
    if(f)
8010626b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010626f:	74 0b                	je     8010627c <sys_open+0x10f>
      fileclose(f);
80106271:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106274:	89 04 24             	mov    %eax,(%esp)
80106277:	e8 a0 b0 ff ff       	call   8010131c <fileclose>
    iunlockput(ip);
8010627c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010627f:	89 04 24             	mov    %eax,(%esp)
80106282:	e8 bd bb ff ff       	call   80101e44 <iunlockput>
    return -1;
80106287:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010628c:	eb 63                	jmp    801062f1 <sys_open+0x184>
  }
  iunlock(ip);
8010628e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106291:	89 04 24             	mov    %eax,(%esp)
80106294:	e8 75 ba ff ff       	call   80101d0e <iunlock>

  f->type = FD_INODE;
80106299:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010629c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801062a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062a8:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801062ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ae:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801062b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062b8:	83 e0 01             	and    $0x1,%eax
801062bb:	85 c0                	test   %eax,%eax
801062bd:	0f 94 c2             	sete   %dl
801062c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062c3:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801062c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062c9:	83 e0 01             	and    $0x1,%eax
801062cc:	84 c0                	test   %al,%al
801062ce:	75 0a                	jne    801062da <sys_open+0x16d>
801062d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062d3:	83 e0 02             	and    $0x2,%eax
801062d6:	85 c0                	test   %eax,%eax
801062d8:	74 07                	je     801062e1 <sys_open+0x174>
801062da:	b8 01 00 00 00       	mov    $0x1,%eax
801062df:	eb 05                	jmp    801062e6 <sys_open+0x179>
801062e1:	b8 00 00 00 00       	mov    $0x0,%eax
801062e6:	89 c2                	mov    %eax,%edx
801062e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062eb:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801062ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801062f1:	c9                   	leave  
801062f2:	c3                   	ret    

801062f3 <sys_mkdir>:

int
sys_mkdir(void)
{
801062f3:	55                   	push   %ebp
801062f4:	89 e5                	mov    %esp,%ebp
801062f6:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
801062f9:	e8 77 d2 ff ff       	call   80103575 <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801062fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106301:	89 44 24 04          	mov    %eax,0x4(%esp)
80106305:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010630c:	e8 17 f5 ff ff       	call   80105828 <argstr>
80106311:	85 c0                	test   %eax,%eax
80106313:	78 2c                	js     80106341 <sys_mkdir+0x4e>
80106315:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106318:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010631f:	00 
80106320:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106327:	00 
80106328:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010632f:	00 
80106330:	89 04 24             	mov    %eax,(%esp)
80106333:	e8 75 fc ff ff       	call   80105fad <create>
80106338:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010633b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010633f:	75 0c                	jne    8010634d <sys_mkdir+0x5a>
    commit_trans();
80106341:	e8 78 d2 ff ff       	call   801035be <commit_trans>
    return -1;
80106346:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010634b:	eb 15                	jmp    80106362 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
8010634d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106350:	89 04 24             	mov    %eax,(%esp)
80106353:	e8 ec ba ff ff       	call   80101e44 <iunlockput>
  commit_trans();
80106358:	e8 61 d2 ff ff       	call   801035be <commit_trans>
  return 0;
8010635d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106362:	c9                   	leave  
80106363:	c3                   	ret    

80106364 <sys_mknod>:

int
sys_mknod(void)
{
80106364:	55                   	push   %ebp
80106365:	89 e5                	mov    %esp,%ebp
80106367:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
8010636a:	e8 06 d2 ff ff       	call   80103575 <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
8010636f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106372:	89 44 24 04          	mov    %eax,0x4(%esp)
80106376:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010637d:	e8 a6 f4 ff ff       	call   80105828 <argstr>
80106382:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106385:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106389:	78 5e                	js     801063e9 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
8010638b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010638e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106392:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106399:	e8 f0 f3 ff ff       	call   8010578e <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
8010639e:	85 c0                	test   %eax,%eax
801063a0:	78 47                	js     801063e9 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801063a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801063a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801063a9:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801063b0:	e8 d9 f3 ff ff       	call   8010578e <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801063b5:	85 c0                	test   %eax,%eax
801063b7:	78 30                	js     801063e9 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801063b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063bc:	0f bf c8             	movswl %ax,%ecx
801063bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063c2:	0f bf d0             	movswl %ax,%edx
801063c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801063c8:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801063cc:	89 54 24 08          	mov    %edx,0x8(%esp)
801063d0:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801063d7:	00 
801063d8:	89 04 24             	mov    %eax,(%esp)
801063db:	e8 cd fb ff ff       	call   80105fad <create>
801063e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063e7:	75 0c                	jne    801063f5 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
801063e9:	e8 d0 d1 ff ff       	call   801035be <commit_trans>
    return -1;
801063ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f3:	eb 15                	jmp    8010640a <sys_mknod+0xa6>
  }
  iunlockput(ip);
801063f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063f8:	89 04 24             	mov    %eax,(%esp)
801063fb:	e8 44 ba ff ff       	call   80101e44 <iunlockput>
  commit_trans();
80106400:	e8 b9 d1 ff ff       	call   801035be <commit_trans>
  return 0;
80106405:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010640a:	c9                   	leave  
8010640b:	c3                   	ret    

8010640c <sys_chdir>:

int
sys_chdir(void)
{
8010640c:	55                   	push   %ebp
8010640d:	89 e5                	mov    %esp,%ebp
8010640f:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
80106412:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106415:	89 44 24 04          	mov    %eax,0x4(%esp)
80106419:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106420:	e8 03 f4 ff ff       	call   80105828 <argstr>
80106425:	85 c0                	test   %eax,%eax
80106427:	78 14                	js     8010643d <sys_chdir+0x31>
80106429:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010642c:	89 04 24             	mov    %eax,(%esp)
8010642f:	e8 2e c3 ff ff       	call   80102762 <namei>
80106434:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106437:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010643b:	75 07                	jne    80106444 <sys_chdir+0x38>
    return -1;
8010643d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106442:	eb 57                	jmp    8010649b <sys_chdir+0x8f>
  ilock(ip);
80106444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106447:	89 04 24             	mov    %eax,(%esp)
8010644a:	e8 71 b7 ff ff       	call   80101bc0 <ilock>
  if(ip->type != T_DIR){
8010644f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106452:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106456:	66 83 f8 01          	cmp    $0x1,%ax
8010645a:	74 12                	je     8010646e <sys_chdir+0x62>
    iunlockput(ip);
8010645c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010645f:	89 04 24             	mov    %eax,(%esp)
80106462:	e8 dd b9 ff ff       	call   80101e44 <iunlockput>
    return -1;
80106467:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010646c:	eb 2d                	jmp    8010649b <sys_chdir+0x8f>
  }
  iunlock(ip);
8010646e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106471:	89 04 24             	mov    %eax,(%esp)
80106474:	e8 95 b8 ff ff       	call   80101d0e <iunlock>
  iput(proc->cwd);
80106479:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010647f:	8b 40 68             	mov    0x68(%eax),%eax
80106482:	89 04 24             	mov    %eax,(%esp)
80106485:	e8 e9 b8 ff ff       	call   80101d73 <iput>
  proc->cwd = ip;
8010648a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106490:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106493:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106496:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010649b:	c9                   	leave  
8010649c:	c3                   	ret    

8010649d <sys_exec>:

int
sys_exec(void)
{
8010649d:	55                   	push   %ebp
8010649e:	89 e5                	mov    %esp,%ebp
801064a0:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801064a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801064ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064b4:	e8 6f f3 ff ff       	call   80105828 <argstr>
801064b9:	85 c0                	test   %eax,%eax
801064bb:	78 1a                	js     801064d7 <sys_exec+0x3a>
801064bd:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801064c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801064c7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801064ce:	e8 bb f2 ff ff       	call   8010578e <argint>
801064d3:	85 c0                	test   %eax,%eax
801064d5:	79 0a                	jns    801064e1 <sys_exec+0x44>
    return -1;
801064d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064dc:	e9 e2 00 00 00       	jmp    801065c3 <sys_exec+0x126>
  }
  memset(argv, 0, sizeof(argv));
801064e1:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801064e8:	00 
801064e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801064f0:	00 
801064f1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801064f7:	89 04 24             	mov    %eax,(%esp)
801064fa:	e8 3f ef ff ff       	call   8010543e <memset>
  for(i=0;; i++){
801064ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106506:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106509:	83 f8 1f             	cmp    $0x1f,%eax
8010650c:	76 0a                	jbe    80106518 <sys_exec+0x7b>
      return -1;
8010650e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106513:	e9 ab 00 00 00       	jmp    801065c3 <sys_exec+0x126>
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
80106518:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010651b:	c1 e0 02             	shl    $0x2,%eax
8010651e:	89 c2                	mov    %eax,%edx
80106520:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106526:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80106529:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010652f:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
80106535:	89 54 24 08          	mov    %edx,0x8(%esp)
80106539:	89 4c 24 04          	mov    %ecx,0x4(%esp)
8010653d:	89 04 24             	mov    %eax,(%esp)
80106540:	e8 b7 f1 ff ff       	call   801056fc <fetchint>
80106545:	85 c0                	test   %eax,%eax
80106547:	79 07                	jns    80106550 <sys_exec+0xb3>
      return -1;
80106549:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010654e:	eb 73                	jmp    801065c3 <sys_exec+0x126>
    if(uarg == 0){
80106550:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106556:	85 c0                	test   %eax,%eax
80106558:	75 26                	jne    80106580 <sys_exec+0xe3>
      argv[i] = 0;
8010655a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010655d:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106564:	00 00 00 00 
      break;
80106568:	90                   	nop
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106569:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010656c:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106572:	89 54 24 04          	mov    %edx,0x4(%esp)
80106576:	89 04 24             	mov    %eax,(%esp)
80106579:	e8 d6 a8 ff ff       	call   80100e54 <exec>
8010657e:	eb 43                	jmp    801065c3 <sys_exec+0x126>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
80106580:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106583:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010658a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106590:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
80106593:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
80106599:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010659f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801065a3:	89 54 24 04          	mov    %edx,0x4(%esp)
801065a7:	89 04 24             	mov    %eax,(%esp)
801065aa:	e8 81 f1 ff ff       	call   80105730 <fetchstr>
801065af:	85 c0                	test   %eax,%eax
801065b1:	79 07                	jns    801065ba <sys_exec+0x11d>
      return -1;
801065b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065b8:	eb 09                	jmp    801065c3 <sys_exec+0x126>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801065ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
801065be:	e9 43 ff ff ff       	jmp    80106506 <sys_exec+0x69>
  return exec(path, argv);
}
801065c3:	c9                   	leave  
801065c4:	c3                   	ret    

801065c5 <sys_pipe>:

int
sys_pipe(void)
{
801065c5:	55                   	push   %ebp
801065c6:	89 e5                	mov    %esp,%ebp
801065c8:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801065cb:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801065d2:	00 
801065d3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801065d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801065da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065e1:	e8 e0 f1 ff ff       	call   801057c6 <argptr>
801065e6:	85 c0                	test   %eax,%eax
801065e8:	79 0a                	jns    801065f4 <sys_pipe+0x2f>
    return -1;
801065ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065ef:	e9 9b 00 00 00       	jmp    8010668f <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801065f4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801065f7:	89 44 24 04          	mov    %eax,0x4(%esp)
801065fb:	8d 45 e8             	lea    -0x18(%ebp),%eax
801065fe:	89 04 24             	mov    %eax,(%esp)
80106601:	e8 8a d9 ff ff       	call   80103f90 <pipealloc>
80106606:	85 c0                	test   %eax,%eax
80106608:	79 07                	jns    80106611 <sys_pipe+0x4c>
    return -1;
8010660a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010660f:	eb 7e                	jmp    8010668f <sys_pipe+0xca>
  fd0 = -1;
80106611:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106618:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010661b:	89 04 24             	mov    %eax,(%esp)
8010661e:	e8 82 f3 ff ff       	call   801059a5 <fdalloc>
80106623:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106626:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010662a:	78 14                	js     80106640 <sys_pipe+0x7b>
8010662c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010662f:	89 04 24             	mov    %eax,(%esp)
80106632:	e8 6e f3 ff ff       	call   801059a5 <fdalloc>
80106637:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010663a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010663e:	79 37                	jns    80106677 <sys_pipe+0xb2>
    if(fd0 >= 0)
80106640:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106644:	78 14                	js     8010665a <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80106646:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010664c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010664f:	83 c2 08             	add    $0x8,%edx
80106652:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106659:	00 
    fileclose(rf);
8010665a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010665d:	89 04 24             	mov    %eax,(%esp)
80106660:	e8 b7 ac ff ff       	call   8010131c <fileclose>
    fileclose(wf);
80106665:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106668:	89 04 24             	mov    %eax,(%esp)
8010666b:	e8 ac ac ff ff       	call   8010131c <fileclose>
    return -1;
80106670:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106675:	eb 18                	jmp    8010668f <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106677:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010667a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010667d:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010667f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106682:	8d 50 04             	lea    0x4(%eax),%edx
80106685:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106688:	89 02                	mov    %eax,(%edx)
  return 0;
8010668a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010668f:	c9                   	leave  
80106690:	c3                   	ret    
80106691:	00 00                	add    %al,(%eax)
	...

80106694 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106694:	55                   	push   %ebp
80106695:	89 e5                	mov    %esp,%ebp
80106697:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010669a:	e8 ae df ff ff       	call   8010464d <fork>
}
8010669f:	c9                   	leave  
801066a0:	c3                   	ret    

801066a1 <sys_exit>:

int
sys_exit(void)
{
801066a1:	55                   	push   %ebp
801066a2:	89 e5                	mov    %esp,%ebp
801066a4:	83 ec 08             	sub    $0x8,%esp
  exit();
801066a7:	e8 36 e1 ff ff       	call   801047e2 <exit>
  return 0;  // not reached
801066ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066b1:	c9                   	leave  
801066b2:	c3                   	ret    

801066b3 <sys_wait>:

int
sys_wait(void)
{
801066b3:	55                   	push   %ebp
801066b4:	89 e5                	mov    %esp,%ebp
801066b6:	83 ec 08             	sub    $0x8,%esp
  return wait();
801066b9:	e8 79 e2 ff ff       	call   80104937 <wait>
}
801066be:	c9                   	leave  
801066bf:	c3                   	ret    

801066c0 <sys_wait2>:

int
sys_wait2(void)
{
801066c0:	55                   	push   %ebp
801066c1:	89 e5                	mov    %esp,%ebp
801066c3:	83 ec 28             	sub    $0x28,%esp
  char *rtime=0;
801066c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  char *wtime=0;
801066cd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  argptr(1,&rtime,sizeof(rtime));
801066d4:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801066db:	00 
801066dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066df:	89 44 24 04          	mov    %eax,0x4(%esp)
801066e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801066ea:	e8 d7 f0 ff ff       	call   801057c6 <argptr>
  argptr(0,&wtime,sizeof(wtime));
801066ef:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801066f6:	00 
801066f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801066fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106705:	e8 bc f0 ff ff       	call   801057c6 <argptr>
  return wait2((int*)wtime, (int*)rtime);
8010670a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010670d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106710:	89 54 24 04          	mov    %edx,0x4(%esp)
80106714:	89 04 24             	mov    %eax,(%esp)
80106717:	e8 2d e3 ff ff       	call   80104a49 <wait2>
}
8010671c:	c9                   	leave  
8010671d:	c3                   	ret    

8010671e <sys_nice>:

int
sys_nice(void)
{
8010671e:	55                   	push   %ebp
8010671f:	89 e5                	mov    %esp,%ebp
80106721:	83 ec 08             	sub    $0x8,%esp
  return nice();
80106724:	e8 db e9 ff ff       	call   80105104 <nice>
}
80106729:	c9                   	leave  
8010672a:	c3                   	ret    

8010672b <sys_kill>:
int
sys_kill(void)
{
8010672b:	55                   	push   %ebp
8010672c:	89 e5                	mov    %esp,%ebp
8010672e:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106731:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106734:	89 44 24 04          	mov    %eax,0x4(%esp)
80106738:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010673f:	e8 4a f0 ff ff       	call   8010578e <argint>
80106744:	85 c0                	test   %eax,%eax
80106746:	79 07                	jns    8010674f <sys_kill+0x24>
    return -1;
80106748:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010674d:	eb 0b                	jmp    8010675a <sys_kill+0x2f>
  return kill(pid);
8010674f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106752:	89 04 24             	mov    %eax,(%esp)
80106755:	e8 33 e8 ff ff       	call   80104f8d <kill>
}
8010675a:	c9                   	leave  
8010675b:	c3                   	ret    

8010675c <sys_getpid>:

int
sys_getpid(void)
{
8010675c:	55                   	push   %ebp
8010675d:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010675f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106765:	8b 40 10             	mov    0x10(%eax),%eax
}
80106768:	5d                   	pop    %ebp
80106769:	c3                   	ret    

8010676a <sys_sbrk>:

int
sys_sbrk(void)
{
8010676a:	55                   	push   %ebp
8010676b:	89 e5                	mov    %esp,%ebp
8010676d:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106770:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106773:	89 44 24 04          	mov    %eax,0x4(%esp)
80106777:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010677e:	e8 0b f0 ff ff       	call   8010578e <argint>
80106783:	85 c0                	test   %eax,%eax
80106785:	79 07                	jns    8010678e <sys_sbrk+0x24>
    return -1;
80106787:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010678c:	eb 24                	jmp    801067b2 <sys_sbrk+0x48>
  addr = proc->sz;
8010678e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106794:	8b 00                	mov    (%eax),%eax
80106796:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106799:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010679c:	89 04 24             	mov    %eax,(%esp)
8010679f:	e8 04 de ff ff       	call   801045a8 <growproc>
801067a4:	85 c0                	test   %eax,%eax
801067a6:	79 07                	jns    801067af <sys_sbrk+0x45>
    return -1;
801067a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067ad:	eb 03                	jmp    801067b2 <sys_sbrk+0x48>
  return addr;
801067af:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801067b2:	c9                   	leave  
801067b3:	c3                   	ret    

801067b4 <sys_sleep>:

int
sys_sleep(void)
{
801067b4:	55                   	push   %ebp
801067b5:	89 e5                	mov    %esp,%ebp
801067b7:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801067ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801067c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067c8:	e8 c1 ef ff ff       	call   8010578e <argint>
801067cd:	85 c0                	test   %eax,%eax
801067cf:	79 07                	jns    801067d8 <sys_sleep+0x24>
    return -1;
801067d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067d6:	eb 6c                	jmp    80106844 <sys_sleep+0x90>
  acquire(&tickslock);
801067d8:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
801067df:	e8 0b ea ff ff       	call   801051ef <acquire>
  ticks0 = ticks;
801067e4:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
801067e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801067ec:	eb 34                	jmp    80106822 <sys_sleep+0x6e>
    if(proc->killed){
801067ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067f4:	8b 40 24             	mov    0x24(%eax),%eax
801067f7:	85 c0                	test   %eax,%eax
801067f9:	74 13                	je     8010680e <sys_sleep+0x5a>
      release(&tickslock);
801067fb:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80106802:	e8 4a ea ff ff       	call   80105251 <release>
      return -1;
80106807:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010680c:	eb 36                	jmp    80106844 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
8010680e:	c7 44 24 04 80 24 11 	movl   $0x80112480,0x4(%esp)
80106815:	80 
80106816:	c7 04 24 c0 2c 11 80 	movl   $0x80112cc0,(%esp)
8010681d:	e8 64 e6 ff ff       	call   80104e86 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106822:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
80106827:	89 c2                	mov    %eax,%edx
80106829:	2b 55 f4             	sub    -0xc(%ebp),%edx
8010682c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010682f:	39 c2                	cmp    %eax,%edx
80106831:	72 bb                	jb     801067ee <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106833:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
8010683a:	e8 12 ea ff ff       	call   80105251 <release>
  return 0;
8010683f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106844:	c9                   	leave  
80106845:	c3                   	ret    

80106846 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106846:	55                   	push   %ebp
80106847:	89 e5                	mov    %esp,%ebp
80106849:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
8010684c:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80106853:	e8 97 e9 ff ff       	call   801051ef <acquire>
  xticks = ticks;
80106858:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
8010685d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106860:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80106867:	e8 e5 e9 ff ff       	call   80105251 <release>
  return xticks;
8010686c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010686f:	c9                   	leave  
80106870:	c3                   	ret    
80106871:	00 00                	add    %al,(%eax)
	...

80106874 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106874:	55                   	push   %ebp
80106875:	89 e5                	mov    %esp,%ebp
80106877:	83 ec 08             	sub    $0x8,%esp
8010687a:	8b 55 08             	mov    0x8(%ebp),%edx
8010687d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106880:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106884:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106887:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010688b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010688f:	ee                   	out    %al,(%dx)
}
80106890:	c9                   	leave  
80106891:	c3                   	ret    

80106892 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106892:	55                   	push   %ebp
80106893:	89 e5                	mov    %esp,%ebp
80106895:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106898:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
8010689f:	00 
801068a0:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
801068a7:	e8 c8 ff ff ff       	call   80106874 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801068ac:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801068b3:	00 
801068b4:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801068bb:	e8 b4 ff ff ff       	call   80106874 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801068c0:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
801068c7:	00 
801068c8:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801068cf:	e8 a0 ff ff ff       	call   80106874 <outb>
  picenable(IRQ_TIMER);
801068d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068db:	e8 39 d5 ff ff       	call   80103e19 <picenable>
}
801068e0:	c9                   	leave  
801068e1:	c3                   	ret    
	...

801068e4 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801068e4:	1e                   	push   %ds
  pushl %es
801068e5:	06                   	push   %es
  pushl %fs
801068e6:	0f a0                	push   %fs
  pushl %gs
801068e8:	0f a8                	push   %gs
  pushal
801068ea:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801068eb:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801068ef:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801068f1:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801068f3:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801068f7:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801068f9:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801068fb:	54                   	push   %esp
  call trap
801068fc:	e8 de 01 00 00       	call   80106adf <trap>
  addl $4, %esp
80106901:	83 c4 04             	add    $0x4,%esp

80106904 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106904:	61                   	popa   
  popl %gs
80106905:	0f a9                	pop    %gs
  popl %fs
80106907:	0f a1                	pop    %fs
  popl %es
80106909:	07                   	pop    %es
  popl %ds
8010690a:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010690b:	83 c4 08             	add    $0x8,%esp
  iret
8010690e:	cf                   	iret   
	...

80106910 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106910:	55                   	push   %ebp
80106911:	89 e5                	mov    %esp,%ebp
80106913:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106916:	8b 45 0c             	mov    0xc(%ebp),%eax
80106919:	83 e8 01             	sub    $0x1,%eax
8010691c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106920:	8b 45 08             	mov    0x8(%ebp),%eax
80106923:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106927:	8b 45 08             	mov    0x8(%ebp),%eax
8010692a:	c1 e8 10             	shr    $0x10,%eax
8010692d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106931:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106934:	0f 01 18             	lidtl  (%eax)
}
80106937:	c9                   	leave  
80106938:	c3                   	ret    

80106939 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106939:	55                   	push   %ebp
8010693a:	89 e5                	mov    %esp,%ebp
8010693c:	53                   	push   %ebx
8010693d:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106940:	0f 20 d3             	mov    %cr2,%ebx
80106943:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
80106946:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80106949:	83 c4 10             	add    $0x10,%esp
8010694c:	5b                   	pop    %ebx
8010694d:	5d                   	pop    %ebp
8010694e:	c3                   	ret    

8010694f <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010694f:	55                   	push   %ebp
80106950:	89 e5                	mov    %esp,%ebp
80106952:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106955:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010695c:	e9 c3 00 00 00       	jmp    80106a24 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106961:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106964:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
8010696b:	89 c2                	mov    %eax,%edx
8010696d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106970:	66 89 14 c5 c0 24 11 	mov    %dx,-0x7feedb40(,%eax,8)
80106977:	80 
80106978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010697b:	66 c7 04 c5 c2 24 11 	movw   $0x8,-0x7feedb3e(,%eax,8)
80106982:	80 08 00 
80106985:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106988:	0f b6 14 c5 c4 24 11 	movzbl -0x7feedb3c(,%eax,8),%edx
8010698f:	80 
80106990:	83 e2 e0             	and    $0xffffffe0,%edx
80106993:	88 14 c5 c4 24 11 80 	mov    %dl,-0x7feedb3c(,%eax,8)
8010699a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010699d:	0f b6 14 c5 c4 24 11 	movzbl -0x7feedb3c(,%eax,8),%edx
801069a4:	80 
801069a5:	83 e2 1f             	and    $0x1f,%edx
801069a8:	88 14 c5 c4 24 11 80 	mov    %dl,-0x7feedb3c(,%eax,8)
801069af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069b2:	0f b6 14 c5 c5 24 11 	movzbl -0x7feedb3b(,%eax,8),%edx
801069b9:	80 
801069ba:	83 e2 f0             	and    $0xfffffff0,%edx
801069bd:	83 ca 0e             	or     $0xe,%edx
801069c0:	88 14 c5 c5 24 11 80 	mov    %dl,-0x7feedb3b(,%eax,8)
801069c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ca:	0f b6 14 c5 c5 24 11 	movzbl -0x7feedb3b(,%eax,8),%edx
801069d1:	80 
801069d2:	83 e2 ef             	and    $0xffffffef,%edx
801069d5:	88 14 c5 c5 24 11 80 	mov    %dl,-0x7feedb3b(,%eax,8)
801069dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069df:	0f b6 14 c5 c5 24 11 	movzbl -0x7feedb3b(,%eax,8),%edx
801069e6:	80 
801069e7:	83 e2 9f             	and    $0xffffff9f,%edx
801069ea:	88 14 c5 c5 24 11 80 	mov    %dl,-0x7feedb3b(,%eax,8)
801069f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069f4:	0f b6 14 c5 c5 24 11 	movzbl -0x7feedb3b(,%eax,8),%edx
801069fb:	80 
801069fc:	83 ca 80             	or     $0xffffff80,%edx
801069ff:	88 14 c5 c5 24 11 80 	mov    %dl,-0x7feedb3b(,%eax,8)
80106a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a09:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
80106a10:	c1 e8 10             	shr    $0x10,%eax
80106a13:	89 c2                	mov    %eax,%edx
80106a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a18:	66 89 14 c5 c6 24 11 	mov    %dx,-0x7feedb3a(,%eax,8)
80106a1f:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106a20:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a24:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106a2b:	0f 8e 30 ff ff ff    	jle    80106961 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106a31:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
80106a36:	66 a3 c0 26 11 80    	mov    %ax,0x801126c0
80106a3c:	66 c7 05 c2 26 11 80 	movw   $0x8,0x801126c2
80106a43:	08 00 
80106a45:	0f b6 05 c4 26 11 80 	movzbl 0x801126c4,%eax
80106a4c:	83 e0 e0             	and    $0xffffffe0,%eax
80106a4f:	a2 c4 26 11 80       	mov    %al,0x801126c4
80106a54:	0f b6 05 c4 26 11 80 	movzbl 0x801126c4,%eax
80106a5b:	83 e0 1f             	and    $0x1f,%eax
80106a5e:	a2 c4 26 11 80       	mov    %al,0x801126c4
80106a63:	0f b6 05 c5 26 11 80 	movzbl 0x801126c5,%eax
80106a6a:	83 c8 0f             	or     $0xf,%eax
80106a6d:	a2 c5 26 11 80       	mov    %al,0x801126c5
80106a72:	0f b6 05 c5 26 11 80 	movzbl 0x801126c5,%eax
80106a79:	83 e0 ef             	and    $0xffffffef,%eax
80106a7c:	a2 c5 26 11 80       	mov    %al,0x801126c5
80106a81:	0f b6 05 c5 26 11 80 	movzbl 0x801126c5,%eax
80106a88:	83 c8 60             	or     $0x60,%eax
80106a8b:	a2 c5 26 11 80       	mov    %al,0x801126c5
80106a90:	0f b6 05 c5 26 11 80 	movzbl 0x801126c5,%eax
80106a97:	83 c8 80             	or     $0xffffff80,%eax
80106a9a:	a2 c5 26 11 80       	mov    %al,0x801126c5
80106a9f:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
80106aa4:	c1 e8 10             	shr    $0x10,%eax
80106aa7:	66 a3 c6 26 11 80    	mov    %ax,0x801126c6
  
  initlock(&tickslock, "time");
80106aad:	c7 44 24 04 f8 8c 10 	movl   $0x80108cf8,0x4(%esp)
80106ab4:	80 
80106ab5:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80106abc:	e8 0d e7 ff ff       	call   801051ce <initlock>
}
80106ac1:	c9                   	leave  
80106ac2:	c3                   	ret    

80106ac3 <idtinit>:

void
idtinit(void)
{
80106ac3:	55                   	push   %ebp
80106ac4:	89 e5                	mov    %esp,%ebp
80106ac6:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106ac9:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106ad0:	00 
80106ad1:	c7 04 24 c0 24 11 80 	movl   $0x801124c0,(%esp)
80106ad8:	e8 33 fe ff ff       	call   80106910 <lidt>
}
80106add:	c9                   	leave  
80106ade:	c3                   	ret    

80106adf <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106adf:	55                   	push   %ebp
80106ae0:	89 e5                	mov    %esp,%ebp
80106ae2:	57                   	push   %edi
80106ae3:	56                   	push   %esi
80106ae4:	53                   	push   %ebx
80106ae5:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106ae8:	8b 45 08             	mov    0x8(%ebp),%eax
80106aeb:	8b 40 30             	mov    0x30(%eax),%eax
80106aee:	83 f8 40             	cmp    $0x40,%eax
80106af1:	75 3e                	jne    80106b31 <trap+0x52>
    if(proc->killed)
80106af3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106af9:	8b 40 24             	mov    0x24(%eax),%eax
80106afc:	85 c0                	test   %eax,%eax
80106afe:	74 05                	je     80106b05 <trap+0x26>
      exit();
80106b00:	e8 dd dc ff ff       	call   801047e2 <exit>
    proc->tf = tf;
80106b05:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b0b:	8b 55 08             	mov    0x8(%ebp),%edx
80106b0e:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106b11:	e8 55 ed ff ff       	call   8010586b <syscall>
    if(proc->killed)
80106b16:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b1c:	8b 40 24             	mov    0x24(%eax),%eax
80106b1f:	85 c0                	test   %eax,%eax
80106b21:	0f 84 78 02 00 00    	je     80106d9f <trap+0x2c0>
      exit();
80106b27:	e8 b6 dc ff ff       	call   801047e2 <exit>
    return;
80106b2c:	e9 6e 02 00 00       	jmp    80106d9f <trap+0x2c0>
  }

  switch(tf->trapno){
80106b31:	8b 45 08             	mov    0x8(%ebp),%eax
80106b34:	8b 40 30             	mov    0x30(%eax),%eax
80106b37:	83 e8 20             	sub    $0x20,%eax
80106b3a:	83 f8 1f             	cmp    $0x1f,%eax
80106b3d:	0f 87 f0 00 00 00    	ja     80106c33 <trap+0x154>
80106b43:	8b 04 85 a0 8d 10 80 	mov    -0x7fef7260(,%eax,4),%eax
80106b4a:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106b4c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b52:	0f b6 00             	movzbl (%eax),%eax
80106b55:	84 c0                	test   %al,%al
80106b57:	75 65                	jne    80106bbe <trap+0xdf>
      acquire(&tickslock);
80106b59:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80106b60:	e8 8a e6 ff ff       	call   801051ef <acquire>
      ticks++;
80106b65:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
80106b6a:	83 c0 01             	add    $0x1,%eax
80106b6d:	a3 c0 2c 11 80       	mov    %eax,0x80112cc0
      if(proc)
80106b72:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b78:	85 c0                	test   %eax,%eax
80106b7a:	74 2a                	je     80106ba6 <trap+0xc7>
      {
	proc->rtime++;
80106b7c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b82:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80106b88:	83 c2 01             	add    $0x1,%edx
80106b8b:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
	proc->quanta--;
80106b91:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b97:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
80106b9d:	83 ea 01             	sub    $0x1,%edx
80106ba0:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
      }
      wakeup(&ticks);
80106ba6:	c7 04 24 c0 2c 11 80 	movl   $0x80112cc0,(%esp)
80106bad:	e8 b0 e3 ff ff       	call   80104f62 <wakeup>
      release(&tickslock);
80106bb2:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80106bb9:	e8 93 e6 ff ff       	call   80105251 <release>
    }
    lapiceoi();
80106bbe:	e8 7e c6 ff ff       	call   80103241 <lapiceoi>
    break;
80106bc3:	e9 41 01 00 00       	jmp    80106d09 <trap+0x22a>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106bc8:	e8 7c be ff ff       	call   80102a49 <ideintr>
    lapiceoi();
80106bcd:	e8 6f c6 ff ff       	call   80103241 <lapiceoi>
    break;
80106bd2:	e9 32 01 00 00       	jmp    80106d09 <trap+0x22a>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106bd7:	e8 43 c4 ff ff       	call   8010301f <kbdintr>
    lapiceoi();
80106bdc:	e8 60 c6 ff ff       	call   80103241 <lapiceoi>
    break;
80106be1:	e9 23 01 00 00       	jmp    80106d09 <trap+0x22a>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106be6:	e8 b9 03 00 00       	call   80106fa4 <uartintr>
    lapiceoi();
80106beb:	e8 51 c6 ff ff       	call   80103241 <lapiceoi>
    break;
80106bf0:	e9 14 01 00 00       	jmp    80106d09 <trap+0x22a>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106bf5:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bf8:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106bfb:	8b 45 08             	mov    0x8(%ebp),%eax
80106bfe:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c02:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106c05:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c0b:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c0e:	0f b6 c0             	movzbl %al,%eax
80106c11:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106c15:	89 54 24 08          	mov    %edx,0x8(%esp)
80106c19:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c1d:	c7 04 24 00 8d 10 80 	movl   $0x80108d00,(%esp)
80106c24:	e8 78 97 ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106c29:	e8 13 c6 ff ff       	call   80103241 <lapiceoi>
    break;
80106c2e:	e9 d6 00 00 00       	jmp    80106d09 <trap+0x22a>
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106c33:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c39:	85 c0                	test   %eax,%eax
80106c3b:	74 11                	je     80106c4e <trap+0x16f>
80106c3d:	8b 45 08             	mov    0x8(%ebp),%eax
80106c40:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c44:	0f b7 c0             	movzwl %ax,%eax
80106c47:	83 e0 03             	and    $0x3,%eax
80106c4a:	85 c0                	test   %eax,%eax
80106c4c:	75 46                	jne    80106c94 <trap+0x1b5>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c4e:	e8 e6 fc ff ff       	call   80106939 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c53:	8b 55 08             	mov    0x8(%ebp),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c56:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c59:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106c60:	0f b6 12             	movzbl (%edx),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c63:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c66:	8b 55 08             	mov    0x8(%ebp),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c69:	8b 52 30             	mov    0x30(%edx),%edx
80106c6c:	89 44 24 10          	mov    %eax,0x10(%esp)
80106c70:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106c74:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106c78:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c7c:	c7 04 24 24 8d 10 80 	movl   $0x80108d24,(%esp)
80106c83:	e8 19 97 ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106c88:	c7 04 24 56 8d 10 80 	movl   $0x80108d56,(%esp)
80106c8f:	e8 a9 98 ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c94:	e8 a0 fc ff ff       	call   80106939 <rcr2>
80106c99:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c9b:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c9e:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106ca1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106ca7:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106caa:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106cad:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106cb0:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106cb3:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106cb6:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106cb9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cbf:	83 c0 6c             	add    $0x6c,%eax
80106cc2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106cc5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106ccb:	8b 40 10             	mov    0x10(%eax),%eax
80106cce:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106cd2:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106cd6:	89 74 24 14          	mov    %esi,0x14(%esp)
80106cda:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106cde:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106ce2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106ce5:	89 54 24 08          	mov    %edx,0x8(%esp)
80106ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ced:	c7 04 24 5c 8d 10 80 	movl   $0x80108d5c,(%esp)
80106cf4:	e8 a8 96 ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106cf9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cff:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106d06:	eb 01                	jmp    80106d09 <trap+0x22a>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106d08:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106d09:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d0f:	85 c0                	test   %eax,%eax
80106d11:	74 24                	je     80106d37 <trap+0x258>
80106d13:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d19:	8b 40 24             	mov    0x24(%eax),%eax
80106d1c:	85 c0                	test   %eax,%eax
80106d1e:	74 17                	je     80106d37 <trap+0x258>
80106d20:	8b 45 08             	mov    0x8(%ebp),%eax
80106d23:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d27:	0f b7 c0             	movzwl %ax,%eax
80106d2a:	83 e0 03             	and    $0x3,%eax
80106d2d:	83 f8 03             	cmp    $0x3,%eax
80106d30:	75 05                	jne    80106d37 <trap+0x258>
    exit();
80106d32:	e8 ab da ff ff       	call   801047e2 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER && proc->quanta <= 0)
80106d37:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d3d:	85 c0                	test   %eax,%eax
80106d3f:	74 2e                	je     80106d6f <trap+0x290>
80106d41:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d47:	8b 40 0c             	mov    0xc(%eax),%eax
80106d4a:	83 f8 04             	cmp    $0x4,%eax
80106d4d:	75 20                	jne    80106d6f <trap+0x290>
80106d4f:	8b 45 08             	mov    0x8(%ebp),%eax
80106d52:	8b 40 30             	mov    0x30(%eax),%eax
80106d55:	83 f8 20             	cmp    $0x20,%eax
80106d58:	75 15                	jne    80106d6f <trap+0x290>
80106d5a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d60:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80106d66:	85 c0                	test   %eax,%eax
80106d68:	7f 05                	jg     80106d6f <trap+0x290>
    yield();
80106d6a:	e8 b9 e0 ff ff       	call   80104e28 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106d6f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d75:	85 c0                	test   %eax,%eax
80106d77:	74 27                	je     80106da0 <trap+0x2c1>
80106d79:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d7f:	8b 40 24             	mov    0x24(%eax),%eax
80106d82:	85 c0                	test   %eax,%eax
80106d84:	74 1a                	je     80106da0 <trap+0x2c1>
80106d86:	8b 45 08             	mov    0x8(%ebp),%eax
80106d89:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d8d:	0f b7 c0             	movzwl %ax,%eax
80106d90:	83 e0 03             	and    $0x3,%eax
80106d93:	83 f8 03             	cmp    $0x3,%eax
80106d96:	75 08                	jne    80106da0 <trap+0x2c1>
    exit();
80106d98:	e8 45 da ff ff       	call   801047e2 <exit>
80106d9d:	eb 01                	jmp    80106da0 <trap+0x2c1>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106d9f:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106da0:	83 c4 3c             	add    $0x3c,%esp
80106da3:	5b                   	pop    %ebx
80106da4:	5e                   	pop    %esi
80106da5:	5f                   	pop    %edi
80106da6:	5d                   	pop    %ebp
80106da7:	c3                   	ret    

80106da8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106da8:	55                   	push   %ebp
80106da9:	89 e5                	mov    %esp,%ebp
80106dab:	53                   	push   %ebx
80106dac:	83 ec 14             	sub    $0x14,%esp
80106daf:	8b 45 08             	mov    0x8(%ebp),%eax
80106db2:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106db6:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80106dba:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80106dbe:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80106dc2:	ec                   	in     (%dx),%al
80106dc3:	89 c3                	mov    %eax,%ebx
80106dc5:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80106dc8:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80106dcc:	83 c4 14             	add    $0x14,%esp
80106dcf:	5b                   	pop    %ebx
80106dd0:	5d                   	pop    %ebp
80106dd1:	c3                   	ret    

80106dd2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106dd2:	55                   	push   %ebp
80106dd3:	89 e5                	mov    %esp,%ebp
80106dd5:	83 ec 08             	sub    $0x8,%esp
80106dd8:	8b 55 08             	mov    0x8(%ebp),%edx
80106ddb:	8b 45 0c             	mov    0xc(%ebp),%eax
80106dde:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106de2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106de5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106de9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106ded:	ee                   	out    %al,(%dx)
}
80106dee:	c9                   	leave  
80106def:	c3                   	ret    

80106df0 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106df0:	55                   	push   %ebp
80106df1:	89 e5                	mov    %esp,%ebp
80106df3:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106df6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106dfd:	00 
80106dfe:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106e05:	e8 c8 ff ff ff       	call   80106dd2 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106e0a:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106e11:	00 
80106e12:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106e19:	e8 b4 ff ff ff       	call   80106dd2 <outb>
  outb(COM1+0, 115200/9600);
80106e1e:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106e25:	00 
80106e26:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e2d:	e8 a0 ff ff ff       	call   80106dd2 <outb>
  outb(COM1+1, 0);
80106e32:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e39:	00 
80106e3a:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106e41:	e8 8c ff ff ff       	call   80106dd2 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106e46:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106e4d:	00 
80106e4e:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106e55:	e8 78 ff ff ff       	call   80106dd2 <outb>
  outb(COM1+4, 0);
80106e5a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e61:	00 
80106e62:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106e69:	e8 64 ff ff ff       	call   80106dd2 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106e6e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106e75:	00 
80106e76:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106e7d:	e8 50 ff ff ff       	call   80106dd2 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106e82:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106e89:	e8 1a ff ff ff       	call   80106da8 <inb>
80106e8e:	3c ff                	cmp    $0xff,%al
80106e90:	74 6c                	je     80106efe <uartinit+0x10e>
    return;
  uart = 1;
80106e92:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106e99:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106e9c:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106ea3:	e8 00 ff ff ff       	call   80106da8 <inb>
  inb(COM1+0);
80106ea8:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106eaf:	e8 f4 fe ff ff       	call   80106da8 <inb>
  picenable(IRQ_COM1);
80106eb4:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106ebb:	e8 59 cf ff ff       	call   80103e19 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106ec0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106ec7:	00 
80106ec8:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106ecf:	e8 fa bd ff ff       	call   80102cce <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106ed4:	c7 45 f4 20 8e 10 80 	movl   $0x80108e20,-0xc(%ebp)
80106edb:	eb 15                	jmp    80106ef2 <uartinit+0x102>
    uartputc(*p);
80106edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ee0:	0f b6 00             	movzbl (%eax),%eax
80106ee3:	0f be c0             	movsbl %al,%eax
80106ee6:	89 04 24             	mov    %eax,(%esp)
80106ee9:	e8 13 00 00 00       	call   80106f01 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106eee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ef5:	0f b6 00             	movzbl (%eax),%eax
80106ef8:	84 c0                	test   %al,%al
80106efa:	75 e1                	jne    80106edd <uartinit+0xed>
80106efc:	eb 01                	jmp    80106eff <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106efe:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106eff:	c9                   	leave  
80106f00:	c3                   	ret    

80106f01 <uartputc>:

void
uartputc(int c)
{
80106f01:	55                   	push   %ebp
80106f02:	89 e5                	mov    %esp,%ebp
80106f04:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106f07:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106f0c:	85 c0                	test   %eax,%eax
80106f0e:	74 4d                	je     80106f5d <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106f10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106f17:	eb 10                	jmp    80106f29 <uartputc+0x28>
    microdelay(10);
80106f19:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106f20:	e8 41 c3 ff ff       	call   80103266 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106f25:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106f29:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106f2d:	7f 16                	jg     80106f45 <uartputc+0x44>
80106f2f:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106f36:	e8 6d fe ff ff       	call   80106da8 <inb>
80106f3b:	0f b6 c0             	movzbl %al,%eax
80106f3e:	83 e0 20             	and    $0x20,%eax
80106f41:	85 c0                	test   %eax,%eax
80106f43:	74 d4                	je     80106f19 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106f45:	8b 45 08             	mov    0x8(%ebp),%eax
80106f48:	0f b6 c0             	movzbl %al,%eax
80106f4b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f4f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106f56:	e8 77 fe ff ff       	call   80106dd2 <outb>
80106f5b:	eb 01                	jmp    80106f5e <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106f5d:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106f5e:	c9                   	leave  
80106f5f:	c3                   	ret    

80106f60 <uartgetc>:

static int
uartgetc(void)
{
80106f60:	55                   	push   %ebp
80106f61:	89 e5                	mov    %esp,%ebp
80106f63:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106f66:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106f6b:	85 c0                	test   %eax,%eax
80106f6d:	75 07                	jne    80106f76 <uartgetc+0x16>
    return -1;
80106f6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f74:	eb 2c                	jmp    80106fa2 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106f76:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106f7d:	e8 26 fe ff ff       	call   80106da8 <inb>
80106f82:	0f b6 c0             	movzbl %al,%eax
80106f85:	83 e0 01             	and    $0x1,%eax
80106f88:	85 c0                	test   %eax,%eax
80106f8a:	75 07                	jne    80106f93 <uartgetc+0x33>
    return -1;
80106f8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f91:	eb 0f                	jmp    80106fa2 <uartgetc+0x42>
  return inb(COM1+0);
80106f93:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106f9a:	e8 09 fe ff ff       	call   80106da8 <inb>
80106f9f:	0f b6 c0             	movzbl %al,%eax
}
80106fa2:	c9                   	leave  
80106fa3:	c3                   	ret    

80106fa4 <uartintr>:

void
uartintr(void)
{
80106fa4:	55                   	push   %ebp
80106fa5:	89 e5                	mov    %esp,%ebp
80106fa7:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106faa:	c7 04 24 60 6f 10 80 	movl   $0x80106f60,(%esp)
80106fb1:	e8 0f 99 ff ff       	call   801008c5 <consoleintr>
}
80106fb6:	c9                   	leave  
80106fb7:	c3                   	ret    

80106fb8 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106fb8:	6a 00                	push   $0x0
  pushl $0
80106fba:	6a 00                	push   $0x0
  jmp alltraps
80106fbc:	e9 23 f9 ff ff       	jmp    801068e4 <alltraps>

80106fc1 <vector1>:
.globl vector1
vector1:
  pushl $0
80106fc1:	6a 00                	push   $0x0
  pushl $1
80106fc3:	6a 01                	push   $0x1
  jmp alltraps
80106fc5:	e9 1a f9 ff ff       	jmp    801068e4 <alltraps>

80106fca <vector2>:
.globl vector2
vector2:
  pushl $0
80106fca:	6a 00                	push   $0x0
  pushl $2
80106fcc:	6a 02                	push   $0x2
  jmp alltraps
80106fce:	e9 11 f9 ff ff       	jmp    801068e4 <alltraps>

80106fd3 <vector3>:
.globl vector3
vector3:
  pushl $0
80106fd3:	6a 00                	push   $0x0
  pushl $3
80106fd5:	6a 03                	push   $0x3
  jmp alltraps
80106fd7:	e9 08 f9 ff ff       	jmp    801068e4 <alltraps>

80106fdc <vector4>:
.globl vector4
vector4:
  pushl $0
80106fdc:	6a 00                	push   $0x0
  pushl $4
80106fde:	6a 04                	push   $0x4
  jmp alltraps
80106fe0:	e9 ff f8 ff ff       	jmp    801068e4 <alltraps>

80106fe5 <vector5>:
.globl vector5
vector5:
  pushl $0
80106fe5:	6a 00                	push   $0x0
  pushl $5
80106fe7:	6a 05                	push   $0x5
  jmp alltraps
80106fe9:	e9 f6 f8 ff ff       	jmp    801068e4 <alltraps>

80106fee <vector6>:
.globl vector6
vector6:
  pushl $0
80106fee:	6a 00                	push   $0x0
  pushl $6
80106ff0:	6a 06                	push   $0x6
  jmp alltraps
80106ff2:	e9 ed f8 ff ff       	jmp    801068e4 <alltraps>

80106ff7 <vector7>:
.globl vector7
vector7:
  pushl $0
80106ff7:	6a 00                	push   $0x0
  pushl $7
80106ff9:	6a 07                	push   $0x7
  jmp alltraps
80106ffb:	e9 e4 f8 ff ff       	jmp    801068e4 <alltraps>

80107000 <vector8>:
.globl vector8
vector8:
  pushl $8
80107000:	6a 08                	push   $0x8
  jmp alltraps
80107002:	e9 dd f8 ff ff       	jmp    801068e4 <alltraps>

80107007 <vector9>:
.globl vector9
vector9:
  pushl $0
80107007:	6a 00                	push   $0x0
  pushl $9
80107009:	6a 09                	push   $0x9
  jmp alltraps
8010700b:	e9 d4 f8 ff ff       	jmp    801068e4 <alltraps>

80107010 <vector10>:
.globl vector10
vector10:
  pushl $10
80107010:	6a 0a                	push   $0xa
  jmp alltraps
80107012:	e9 cd f8 ff ff       	jmp    801068e4 <alltraps>

80107017 <vector11>:
.globl vector11
vector11:
  pushl $11
80107017:	6a 0b                	push   $0xb
  jmp alltraps
80107019:	e9 c6 f8 ff ff       	jmp    801068e4 <alltraps>

8010701e <vector12>:
.globl vector12
vector12:
  pushl $12
8010701e:	6a 0c                	push   $0xc
  jmp alltraps
80107020:	e9 bf f8 ff ff       	jmp    801068e4 <alltraps>

80107025 <vector13>:
.globl vector13
vector13:
  pushl $13
80107025:	6a 0d                	push   $0xd
  jmp alltraps
80107027:	e9 b8 f8 ff ff       	jmp    801068e4 <alltraps>

8010702c <vector14>:
.globl vector14
vector14:
  pushl $14
8010702c:	6a 0e                	push   $0xe
  jmp alltraps
8010702e:	e9 b1 f8 ff ff       	jmp    801068e4 <alltraps>

80107033 <vector15>:
.globl vector15
vector15:
  pushl $0
80107033:	6a 00                	push   $0x0
  pushl $15
80107035:	6a 0f                	push   $0xf
  jmp alltraps
80107037:	e9 a8 f8 ff ff       	jmp    801068e4 <alltraps>

8010703c <vector16>:
.globl vector16
vector16:
  pushl $0
8010703c:	6a 00                	push   $0x0
  pushl $16
8010703e:	6a 10                	push   $0x10
  jmp alltraps
80107040:	e9 9f f8 ff ff       	jmp    801068e4 <alltraps>

80107045 <vector17>:
.globl vector17
vector17:
  pushl $17
80107045:	6a 11                	push   $0x11
  jmp alltraps
80107047:	e9 98 f8 ff ff       	jmp    801068e4 <alltraps>

8010704c <vector18>:
.globl vector18
vector18:
  pushl $0
8010704c:	6a 00                	push   $0x0
  pushl $18
8010704e:	6a 12                	push   $0x12
  jmp alltraps
80107050:	e9 8f f8 ff ff       	jmp    801068e4 <alltraps>

80107055 <vector19>:
.globl vector19
vector19:
  pushl $0
80107055:	6a 00                	push   $0x0
  pushl $19
80107057:	6a 13                	push   $0x13
  jmp alltraps
80107059:	e9 86 f8 ff ff       	jmp    801068e4 <alltraps>

8010705e <vector20>:
.globl vector20
vector20:
  pushl $0
8010705e:	6a 00                	push   $0x0
  pushl $20
80107060:	6a 14                	push   $0x14
  jmp alltraps
80107062:	e9 7d f8 ff ff       	jmp    801068e4 <alltraps>

80107067 <vector21>:
.globl vector21
vector21:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $21
80107069:	6a 15                	push   $0x15
  jmp alltraps
8010706b:	e9 74 f8 ff ff       	jmp    801068e4 <alltraps>

80107070 <vector22>:
.globl vector22
vector22:
  pushl $0
80107070:	6a 00                	push   $0x0
  pushl $22
80107072:	6a 16                	push   $0x16
  jmp alltraps
80107074:	e9 6b f8 ff ff       	jmp    801068e4 <alltraps>

80107079 <vector23>:
.globl vector23
vector23:
  pushl $0
80107079:	6a 00                	push   $0x0
  pushl $23
8010707b:	6a 17                	push   $0x17
  jmp alltraps
8010707d:	e9 62 f8 ff ff       	jmp    801068e4 <alltraps>

80107082 <vector24>:
.globl vector24
vector24:
  pushl $0
80107082:	6a 00                	push   $0x0
  pushl $24
80107084:	6a 18                	push   $0x18
  jmp alltraps
80107086:	e9 59 f8 ff ff       	jmp    801068e4 <alltraps>

8010708b <vector25>:
.globl vector25
vector25:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $25
8010708d:	6a 19                	push   $0x19
  jmp alltraps
8010708f:	e9 50 f8 ff ff       	jmp    801068e4 <alltraps>

80107094 <vector26>:
.globl vector26
vector26:
  pushl $0
80107094:	6a 00                	push   $0x0
  pushl $26
80107096:	6a 1a                	push   $0x1a
  jmp alltraps
80107098:	e9 47 f8 ff ff       	jmp    801068e4 <alltraps>

8010709d <vector27>:
.globl vector27
vector27:
  pushl $0
8010709d:	6a 00                	push   $0x0
  pushl $27
8010709f:	6a 1b                	push   $0x1b
  jmp alltraps
801070a1:	e9 3e f8 ff ff       	jmp    801068e4 <alltraps>

801070a6 <vector28>:
.globl vector28
vector28:
  pushl $0
801070a6:	6a 00                	push   $0x0
  pushl $28
801070a8:	6a 1c                	push   $0x1c
  jmp alltraps
801070aa:	e9 35 f8 ff ff       	jmp    801068e4 <alltraps>

801070af <vector29>:
.globl vector29
vector29:
  pushl $0
801070af:	6a 00                	push   $0x0
  pushl $29
801070b1:	6a 1d                	push   $0x1d
  jmp alltraps
801070b3:	e9 2c f8 ff ff       	jmp    801068e4 <alltraps>

801070b8 <vector30>:
.globl vector30
vector30:
  pushl $0
801070b8:	6a 00                	push   $0x0
  pushl $30
801070ba:	6a 1e                	push   $0x1e
  jmp alltraps
801070bc:	e9 23 f8 ff ff       	jmp    801068e4 <alltraps>

801070c1 <vector31>:
.globl vector31
vector31:
  pushl $0
801070c1:	6a 00                	push   $0x0
  pushl $31
801070c3:	6a 1f                	push   $0x1f
  jmp alltraps
801070c5:	e9 1a f8 ff ff       	jmp    801068e4 <alltraps>

801070ca <vector32>:
.globl vector32
vector32:
  pushl $0
801070ca:	6a 00                	push   $0x0
  pushl $32
801070cc:	6a 20                	push   $0x20
  jmp alltraps
801070ce:	e9 11 f8 ff ff       	jmp    801068e4 <alltraps>

801070d3 <vector33>:
.globl vector33
vector33:
  pushl $0
801070d3:	6a 00                	push   $0x0
  pushl $33
801070d5:	6a 21                	push   $0x21
  jmp alltraps
801070d7:	e9 08 f8 ff ff       	jmp    801068e4 <alltraps>

801070dc <vector34>:
.globl vector34
vector34:
  pushl $0
801070dc:	6a 00                	push   $0x0
  pushl $34
801070de:	6a 22                	push   $0x22
  jmp alltraps
801070e0:	e9 ff f7 ff ff       	jmp    801068e4 <alltraps>

801070e5 <vector35>:
.globl vector35
vector35:
  pushl $0
801070e5:	6a 00                	push   $0x0
  pushl $35
801070e7:	6a 23                	push   $0x23
  jmp alltraps
801070e9:	e9 f6 f7 ff ff       	jmp    801068e4 <alltraps>

801070ee <vector36>:
.globl vector36
vector36:
  pushl $0
801070ee:	6a 00                	push   $0x0
  pushl $36
801070f0:	6a 24                	push   $0x24
  jmp alltraps
801070f2:	e9 ed f7 ff ff       	jmp    801068e4 <alltraps>

801070f7 <vector37>:
.globl vector37
vector37:
  pushl $0
801070f7:	6a 00                	push   $0x0
  pushl $37
801070f9:	6a 25                	push   $0x25
  jmp alltraps
801070fb:	e9 e4 f7 ff ff       	jmp    801068e4 <alltraps>

80107100 <vector38>:
.globl vector38
vector38:
  pushl $0
80107100:	6a 00                	push   $0x0
  pushl $38
80107102:	6a 26                	push   $0x26
  jmp alltraps
80107104:	e9 db f7 ff ff       	jmp    801068e4 <alltraps>

80107109 <vector39>:
.globl vector39
vector39:
  pushl $0
80107109:	6a 00                	push   $0x0
  pushl $39
8010710b:	6a 27                	push   $0x27
  jmp alltraps
8010710d:	e9 d2 f7 ff ff       	jmp    801068e4 <alltraps>

80107112 <vector40>:
.globl vector40
vector40:
  pushl $0
80107112:	6a 00                	push   $0x0
  pushl $40
80107114:	6a 28                	push   $0x28
  jmp alltraps
80107116:	e9 c9 f7 ff ff       	jmp    801068e4 <alltraps>

8010711b <vector41>:
.globl vector41
vector41:
  pushl $0
8010711b:	6a 00                	push   $0x0
  pushl $41
8010711d:	6a 29                	push   $0x29
  jmp alltraps
8010711f:	e9 c0 f7 ff ff       	jmp    801068e4 <alltraps>

80107124 <vector42>:
.globl vector42
vector42:
  pushl $0
80107124:	6a 00                	push   $0x0
  pushl $42
80107126:	6a 2a                	push   $0x2a
  jmp alltraps
80107128:	e9 b7 f7 ff ff       	jmp    801068e4 <alltraps>

8010712d <vector43>:
.globl vector43
vector43:
  pushl $0
8010712d:	6a 00                	push   $0x0
  pushl $43
8010712f:	6a 2b                	push   $0x2b
  jmp alltraps
80107131:	e9 ae f7 ff ff       	jmp    801068e4 <alltraps>

80107136 <vector44>:
.globl vector44
vector44:
  pushl $0
80107136:	6a 00                	push   $0x0
  pushl $44
80107138:	6a 2c                	push   $0x2c
  jmp alltraps
8010713a:	e9 a5 f7 ff ff       	jmp    801068e4 <alltraps>

8010713f <vector45>:
.globl vector45
vector45:
  pushl $0
8010713f:	6a 00                	push   $0x0
  pushl $45
80107141:	6a 2d                	push   $0x2d
  jmp alltraps
80107143:	e9 9c f7 ff ff       	jmp    801068e4 <alltraps>

80107148 <vector46>:
.globl vector46
vector46:
  pushl $0
80107148:	6a 00                	push   $0x0
  pushl $46
8010714a:	6a 2e                	push   $0x2e
  jmp alltraps
8010714c:	e9 93 f7 ff ff       	jmp    801068e4 <alltraps>

80107151 <vector47>:
.globl vector47
vector47:
  pushl $0
80107151:	6a 00                	push   $0x0
  pushl $47
80107153:	6a 2f                	push   $0x2f
  jmp alltraps
80107155:	e9 8a f7 ff ff       	jmp    801068e4 <alltraps>

8010715a <vector48>:
.globl vector48
vector48:
  pushl $0
8010715a:	6a 00                	push   $0x0
  pushl $48
8010715c:	6a 30                	push   $0x30
  jmp alltraps
8010715e:	e9 81 f7 ff ff       	jmp    801068e4 <alltraps>

80107163 <vector49>:
.globl vector49
vector49:
  pushl $0
80107163:	6a 00                	push   $0x0
  pushl $49
80107165:	6a 31                	push   $0x31
  jmp alltraps
80107167:	e9 78 f7 ff ff       	jmp    801068e4 <alltraps>

8010716c <vector50>:
.globl vector50
vector50:
  pushl $0
8010716c:	6a 00                	push   $0x0
  pushl $50
8010716e:	6a 32                	push   $0x32
  jmp alltraps
80107170:	e9 6f f7 ff ff       	jmp    801068e4 <alltraps>

80107175 <vector51>:
.globl vector51
vector51:
  pushl $0
80107175:	6a 00                	push   $0x0
  pushl $51
80107177:	6a 33                	push   $0x33
  jmp alltraps
80107179:	e9 66 f7 ff ff       	jmp    801068e4 <alltraps>

8010717e <vector52>:
.globl vector52
vector52:
  pushl $0
8010717e:	6a 00                	push   $0x0
  pushl $52
80107180:	6a 34                	push   $0x34
  jmp alltraps
80107182:	e9 5d f7 ff ff       	jmp    801068e4 <alltraps>

80107187 <vector53>:
.globl vector53
vector53:
  pushl $0
80107187:	6a 00                	push   $0x0
  pushl $53
80107189:	6a 35                	push   $0x35
  jmp alltraps
8010718b:	e9 54 f7 ff ff       	jmp    801068e4 <alltraps>

80107190 <vector54>:
.globl vector54
vector54:
  pushl $0
80107190:	6a 00                	push   $0x0
  pushl $54
80107192:	6a 36                	push   $0x36
  jmp alltraps
80107194:	e9 4b f7 ff ff       	jmp    801068e4 <alltraps>

80107199 <vector55>:
.globl vector55
vector55:
  pushl $0
80107199:	6a 00                	push   $0x0
  pushl $55
8010719b:	6a 37                	push   $0x37
  jmp alltraps
8010719d:	e9 42 f7 ff ff       	jmp    801068e4 <alltraps>

801071a2 <vector56>:
.globl vector56
vector56:
  pushl $0
801071a2:	6a 00                	push   $0x0
  pushl $56
801071a4:	6a 38                	push   $0x38
  jmp alltraps
801071a6:	e9 39 f7 ff ff       	jmp    801068e4 <alltraps>

801071ab <vector57>:
.globl vector57
vector57:
  pushl $0
801071ab:	6a 00                	push   $0x0
  pushl $57
801071ad:	6a 39                	push   $0x39
  jmp alltraps
801071af:	e9 30 f7 ff ff       	jmp    801068e4 <alltraps>

801071b4 <vector58>:
.globl vector58
vector58:
  pushl $0
801071b4:	6a 00                	push   $0x0
  pushl $58
801071b6:	6a 3a                	push   $0x3a
  jmp alltraps
801071b8:	e9 27 f7 ff ff       	jmp    801068e4 <alltraps>

801071bd <vector59>:
.globl vector59
vector59:
  pushl $0
801071bd:	6a 00                	push   $0x0
  pushl $59
801071bf:	6a 3b                	push   $0x3b
  jmp alltraps
801071c1:	e9 1e f7 ff ff       	jmp    801068e4 <alltraps>

801071c6 <vector60>:
.globl vector60
vector60:
  pushl $0
801071c6:	6a 00                	push   $0x0
  pushl $60
801071c8:	6a 3c                	push   $0x3c
  jmp alltraps
801071ca:	e9 15 f7 ff ff       	jmp    801068e4 <alltraps>

801071cf <vector61>:
.globl vector61
vector61:
  pushl $0
801071cf:	6a 00                	push   $0x0
  pushl $61
801071d1:	6a 3d                	push   $0x3d
  jmp alltraps
801071d3:	e9 0c f7 ff ff       	jmp    801068e4 <alltraps>

801071d8 <vector62>:
.globl vector62
vector62:
  pushl $0
801071d8:	6a 00                	push   $0x0
  pushl $62
801071da:	6a 3e                	push   $0x3e
  jmp alltraps
801071dc:	e9 03 f7 ff ff       	jmp    801068e4 <alltraps>

801071e1 <vector63>:
.globl vector63
vector63:
  pushl $0
801071e1:	6a 00                	push   $0x0
  pushl $63
801071e3:	6a 3f                	push   $0x3f
  jmp alltraps
801071e5:	e9 fa f6 ff ff       	jmp    801068e4 <alltraps>

801071ea <vector64>:
.globl vector64
vector64:
  pushl $0
801071ea:	6a 00                	push   $0x0
  pushl $64
801071ec:	6a 40                	push   $0x40
  jmp alltraps
801071ee:	e9 f1 f6 ff ff       	jmp    801068e4 <alltraps>

801071f3 <vector65>:
.globl vector65
vector65:
  pushl $0
801071f3:	6a 00                	push   $0x0
  pushl $65
801071f5:	6a 41                	push   $0x41
  jmp alltraps
801071f7:	e9 e8 f6 ff ff       	jmp    801068e4 <alltraps>

801071fc <vector66>:
.globl vector66
vector66:
  pushl $0
801071fc:	6a 00                	push   $0x0
  pushl $66
801071fe:	6a 42                	push   $0x42
  jmp alltraps
80107200:	e9 df f6 ff ff       	jmp    801068e4 <alltraps>

80107205 <vector67>:
.globl vector67
vector67:
  pushl $0
80107205:	6a 00                	push   $0x0
  pushl $67
80107207:	6a 43                	push   $0x43
  jmp alltraps
80107209:	e9 d6 f6 ff ff       	jmp    801068e4 <alltraps>

8010720e <vector68>:
.globl vector68
vector68:
  pushl $0
8010720e:	6a 00                	push   $0x0
  pushl $68
80107210:	6a 44                	push   $0x44
  jmp alltraps
80107212:	e9 cd f6 ff ff       	jmp    801068e4 <alltraps>

80107217 <vector69>:
.globl vector69
vector69:
  pushl $0
80107217:	6a 00                	push   $0x0
  pushl $69
80107219:	6a 45                	push   $0x45
  jmp alltraps
8010721b:	e9 c4 f6 ff ff       	jmp    801068e4 <alltraps>

80107220 <vector70>:
.globl vector70
vector70:
  pushl $0
80107220:	6a 00                	push   $0x0
  pushl $70
80107222:	6a 46                	push   $0x46
  jmp alltraps
80107224:	e9 bb f6 ff ff       	jmp    801068e4 <alltraps>

80107229 <vector71>:
.globl vector71
vector71:
  pushl $0
80107229:	6a 00                	push   $0x0
  pushl $71
8010722b:	6a 47                	push   $0x47
  jmp alltraps
8010722d:	e9 b2 f6 ff ff       	jmp    801068e4 <alltraps>

80107232 <vector72>:
.globl vector72
vector72:
  pushl $0
80107232:	6a 00                	push   $0x0
  pushl $72
80107234:	6a 48                	push   $0x48
  jmp alltraps
80107236:	e9 a9 f6 ff ff       	jmp    801068e4 <alltraps>

8010723b <vector73>:
.globl vector73
vector73:
  pushl $0
8010723b:	6a 00                	push   $0x0
  pushl $73
8010723d:	6a 49                	push   $0x49
  jmp alltraps
8010723f:	e9 a0 f6 ff ff       	jmp    801068e4 <alltraps>

80107244 <vector74>:
.globl vector74
vector74:
  pushl $0
80107244:	6a 00                	push   $0x0
  pushl $74
80107246:	6a 4a                	push   $0x4a
  jmp alltraps
80107248:	e9 97 f6 ff ff       	jmp    801068e4 <alltraps>

8010724d <vector75>:
.globl vector75
vector75:
  pushl $0
8010724d:	6a 00                	push   $0x0
  pushl $75
8010724f:	6a 4b                	push   $0x4b
  jmp alltraps
80107251:	e9 8e f6 ff ff       	jmp    801068e4 <alltraps>

80107256 <vector76>:
.globl vector76
vector76:
  pushl $0
80107256:	6a 00                	push   $0x0
  pushl $76
80107258:	6a 4c                	push   $0x4c
  jmp alltraps
8010725a:	e9 85 f6 ff ff       	jmp    801068e4 <alltraps>

8010725f <vector77>:
.globl vector77
vector77:
  pushl $0
8010725f:	6a 00                	push   $0x0
  pushl $77
80107261:	6a 4d                	push   $0x4d
  jmp alltraps
80107263:	e9 7c f6 ff ff       	jmp    801068e4 <alltraps>

80107268 <vector78>:
.globl vector78
vector78:
  pushl $0
80107268:	6a 00                	push   $0x0
  pushl $78
8010726a:	6a 4e                	push   $0x4e
  jmp alltraps
8010726c:	e9 73 f6 ff ff       	jmp    801068e4 <alltraps>

80107271 <vector79>:
.globl vector79
vector79:
  pushl $0
80107271:	6a 00                	push   $0x0
  pushl $79
80107273:	6a 4f                	push   $0x4f
  jmp alltraps
80107275:	e9 6a f6 ff ff       	jmp    801068e4 <alltraps>

8010727a <vector80>:
.globl vector80
vector80:
  pushl $0
8010727a:	6a 00                	push   $0x0
  pushl $80
8010727c:	6a 50                	push   $0x50
  jmp alltraps
8010727e:	e9 61 f6 ff ff       	jmp    801068e4 <alltraps>

80107283 <vector81>:
.globl vector81
vector81:
  pushl $0
80107283:	6a 00                	push   $0x0
  pushl $81
80107285:	6a 51                	push   $0x51
  jmp alltraps
80107287:	e9 58 f6 ff ff       	jmp    801068e4 <alltraps>

8010728c <vector82>:
.globl vector82
vector82:
  pushl $0
8010728c:	6a 00                	push   $0x0
  pushl $82
8010728e:	6a 52                	push   $0x52
  jmp alltraps
80107290:	e9 4f f6 ff ff       	jmp    801068e4 <alltraps>

80107295 <vector83>:
.globl vector83
vector83:
  pushl $0
80107295:	6a 00                	push   $0x0
  pushl $83
80107297:	6a 53                	push   $0x53
  jmp alltraps
80107299:	e9 46 f6 ff ff       	jmp    801068e4 <alltraps>

8010729e <vector84>:
.globl vector84
vector84:
  pushl $0
8010729e:	6a 00                	push   $0x0
  pushl $84
801072a0:	6a 54                	push   $0x54
  jmp alltraps
801072a2:	e9 3d f6 ff ff       	jmp    801068e4 <alltraps>

801072a7 <vector85>:
.globl vector85
vector85:
  pushl $0
801072a7:	6a 00                	push   $0x0
  pushl $85
801072a9:	6a 55                	push   $0x55
  jmp alltraps
801072ab:	e9 34 f6 ff ff       	jmp    801068e4 <alltraps>

801072b0 <vector86>:
.globl vector86
vector86:
  pushl $0
801072b0:	6a 00                	push   $0x0
  pushl $86
801072b2:	6a 56                	push   $0x56
  jmp alltraps
801072b4:	e9 2b f6 ff ff       	jmp    801068e4 <alltraps>

801072b9 <vector87>:
.globl vector87
vector87:
  pushl $0
801072b9:	6a 00                	push   $0x0
  pushl $87
801072bb:	6a 57                	push   $0x57
  jmp alltraps
801072bd:	e9 22 f6 ff ff       	jmp    801068e4 <alltraps>

801072c2 <vector88>:
.globl vector88
vector88:
  pushl $0
801072c2:	6a 00                	push   $0x0
  pushl $88
801072c4:	6a 58                	push   $0x58
  jmp alltraps
801072c6:	e9 19 f6 ff ff       	jmp    801068e4 <alltraps>

801072cb <vector89>:
.globl vector89
vector89:
  pushl $0
801072cb:	6a 00                	push   $0x0
  pushl $89
801072cd:	6a 59                	push   $0x59
  jmp alltraps
801072cf:	e9 10 f6 ff ff       	jmp    801068e4 <alltraps>

801072d4 <vector90>:
.globl vector90
vector90:
  pushl $0
801072d4:	6a 00                	push   $0x0
  pushl $90
801072d6:	6a 5a                	push   $0x5a
  jmp alltraps
801072d8:	e9 07 f6 ff ff       	jmp    801068e4 <alltraps>

801072dd <vector91>:
.globl vector91
vector91:
  pushl $0
801072dd:	6a 00                	push   $0x0
  pushl $91
801072df:	6a 5b                	push   $0x5b
  jmp alltraps
801072e1:	e9 fe f5 ff ff       	jmp    801068e4 <alltraps>

801072e6 <vector92>:
.globl vector92
vector92:
  pushl $0
801072e6:	6a 00                	push   $0x0
  pushl $92
801072e8:	6a 5c                	push   $0x5c
  jmp alltraps
801072ea:	e9 f5 f5 ff ff       	jmp    801068e4 <alltraps>

801072ef <vector93>:
.globl vector93
vector93:
  pushl $0
801072ef:	6a 00                	push   $0x0
  pushl $93
801072f1:	6a 5d                	push   $0x5d
  jmp alltraps
801072f3:	e9 ec f5 ff ff       	jmp    801068e4 <alltraps>

801072f8 <vector94>:
.globl vector94
vector94:
  pushl $0
801072f8:	6a 00                	push   $0x0
  pushl $94
801072fa:	6a 5e                	push   $0x5e
  jmp alltraps
801072fc:	e9 e3 f5 ff ff       	jmp    801068e4 <alltraps>

80107301 <vector95>:
.globl vector95
vector95:
  pushl $0
80107301:	6a 00                	push   $0x0
  pushl $95
80107303:	6a 5f                	push   $0x5f
  jmp alltraps
80107305:	e9 da f5 ff ff       	jmp    801068e4 <alltraps>

8010730a <vector96>:
.globl vector96
vector96:
  pushl $0
8010730a:	6a 00                	push   $0x0
  pushl $96
8010730c:	6a 60                	push   $0x60
  jmp alltraps
8010730e:	e9 d1 f5 ff ff       	jmp    801068e4 <alltraps>

80107313 <vector97>:
.globl vector97
vector97:
  pushl $0
80107313:	6a 00                	push   $0x0
  pushl $97
80107315:	6a 61                	push   $0x61
  jmp alltraps
80107317:	e9 c8 f5 ff ff       	jmp    801068e4 <alltraps>

8010731c <vector98>:
.globl vector98
vector98:
  pushl $0
8010731c:	6a 00                	push   $0x0
  pushl $98
8010731e:	6a 62                	push   $0x62
  jmp alltraps
80107320:	e9 bf f5 ff ff       	jmp    801068e4 <alltraps>

80107325 <vector99>:
.globl vector99
vector99:
  pushl $0
80107325:	6a 00                	push   $0x0
  pushl $99
80107327:	6a 63                	push   $0x63
  jmp alltraps
80107329:	e9 b6 f5 ff ff       	jmp    801068e4 <alltraps>

8010732e <vector100>:
.globl vector100
vector100:
  pushl $0
8010732e:	6a 00                	push   $0x0
  pushl $100
80107330:	6a 64                	push   $0x64
  jmp alltraps
80107332:	e9 ad f5 ff ff       	jmp    801068e4 <alltraps>

80107337 <vector101>:
.globl vector101
vector101:
  pushl $0
80107337:	6a 00                	push   $0x0
  pushl $101
80107339:	6a 65                	push   $0x65
  jmp alltraps
8010733b:	e9 a4 f5 ff ff       	jmp    801068e4 <alltraps>

80107340 <vector102>:
.globl vector102
vector102:
  pushl $0
80107340:	6a 00                	push   $0x0
  pushl $102
80107342:	6a 66                	push   $0x66
  jmp alltraps
80107344:	e9 9b f5 ff ff       	jmp    801068e4 <alltraps>

80107349 <vector103>:
.globl vector103
vector103:
  pushl $0
80107349:	6a 00                	push   $0x0
  pushl $103
8010734b:	6a 67                	push   $0x67
  jmp alltraps
8010734d:	e9 92 f5 ff ff       	jmp    801068e4 <alltraps>

80107352 <vector104>:
.globl vector104
vector104:
  pushl $0
80107352:	6a 00                	push   $0x0
  pushl $104
80107354:	6a 68                	push   $0x68
  jmp alltraps
80107356:	e9 89 f5 ff ff       	jmp    801068e4 <alltraps>

8010735b <vector105>:
.globl vector105
vector105:
  pushl $0
8010735b:	6a 00                	push   $0x0
  pushl $105
8010735d:	6a 69                	push   $0x69
  jmp alltraps
8010735f:	e9 80 f5 ff ff       	jmp    801068e4 <alltraps>

80107364 <vector106>:
.globl vector106
vector106:
  pushl $0
80107364:	6a 00                	push   $0x0
  pushl $106
80107366:	6a 6a                	push   $0x6a
  jmp alltraps
80107368:	e9 77 f5 ff ff       	jmp    801068e4 <alltraps>

8010736d <vector107>:
.globl vector107
vector107:
  pushl $0
8010736d:	6a 00                	push   $0x0
  pushl $107
8010736f:	6a 6b                	push   $0x6b
  jmp alltraps
80107371:	e9 6e f5 ff ff       	jmp    801068e4 <alltraps>

80107376 <vector108>:
.globl vector108
vector108:
  pushl $0
80107376:	6a 00                	push   $0x0
  pushl $108
80107378:	6a 6c                	push   $0x6c
  jmp alltraps
8010737a:	e9 65 f5 ff ff       	jmp    801068e4 <alltraps>

8010737f <vector109>:
.globl vector109
vector109:
  pushl $0
8010737f:	6a 00                	push   $0x0
  pushl $109
80107381:	6a 6d                	push   $0x6d
  jmp alltraps
80107383:	e9 5c f5 ff ff       	jmp    801068e4 <alltraps>

80107388 <vector110>:
.globl vector110
vector110:
  pushl $0
80107388:	6a 00                	push   $0x0
  pushl $110
8010738a:	6a 6e                	push   $0x6e
  jmp alltraps
8010738c:	e9 53 f5 ff ff       	jmp    801068e4 <alltraps>

80107391 <vector111>:
.globl vector111
vector111:
  pushl $0
80107391:	6a 00                	push   $0x0
  pushl $111
80107393:	6a 6f                	push   $0x6f
  jmp alltraps
80107395:	e9 4a f5 ff ff       	jmp    801068e4 <alltraps>

8010739a <vector112>:
.globl vector112
vector112:
  pushl $0
8010739a:	6a 00                	push   $0x0
  pushl $112
8010739c:	6a 70                	push   $0x70
  jmp alltraps
8010739e:	e9 41 f5 ff ff       	jmp    801068e4 <alltraps>

801073a3 <vector113>:
.globl vector113
vector113:
  pushl $0
801073a3:	6a 00                	push   $0x0
  pushl $113
801073a5:	6a 71                	push   $0x71
  jmp alltraps
801073a7:	e9 38 f5 ff ff       	jmp    801068e4 <alltraps>

801073ac <vector114>:
.globl vector114
vector114:
  pushl $0
801073ac:	6a 00                	push   $0x0
  pushl $114
801073ae:	6a 72                	push   $0x72
  jmp alltraps
801073b0:	e9 2f f5 ff ff       	jmp    801068e4 <alltraps>

801073b5 <vector115>:
.globl vector115
vector115:
  pushl $0
801073b5:	6a 00                	push   $0x0
  pushl $115
801073b7:	6a 73                	push   $0x73
  jmp alltraps
801073b9:	e9 26 f5 ff ff       	jmp    801068e4 <alltraps>

801073be <vector116>:
.globl vector116
vector116:
  pushl $0
801073be:	6a 00                	push   $0x0
  pushl $116
801073c0:	6a 74                	push   $0x74
  jmp alltraps
801073c2:	e9 1d f5 ff ff       	jmp    801068e4 <alltraps>

801073c7 <vector117>:
.globl vector117
vector117:
  pushl $0
801073c7:	6a 00                	push   $0x0
  pushl $117
801073c9:	6a 75                	push   $0x75
  jmp alltraps
801073cb:	e9 14 f5 ff ff       	jmp    801068e4 <alltraps>

801073d0 <vector118>:
.globl vector118
vector118:
  pushl $0
801073d0:	6a 00                	push   $0x0
  pushl $118
801073d2:	6a 76                	push   $0x76
  jmp alltraps
801073d4:	e9 0b f5 ff ff       	jmp    801068e4 <alltraps>

801073d9 <vector119>:
.globl vector119
vector119:
  pushl $0
801073d9:	6a 00                	push   $0x0
  pushl $119
801073db:	6a 77                	push   $0x77
  jmp alltraps
801073dd:	e9 02 f5 ff ff       	jmp    801068e4 <alltraps>

801073e2 <vector120>:
.globl vector120
vector120:
  pushl $0
801073e2:	6a 00                	push   $0x0
  pushl $120
801073e4:	6a 78                	push   $0x78
  jmp alltraps
801073e6:	e9 f9 f4 ff ff       	jmp    801068e4 <alltraps>

801073eb <vector121>:
.globl vector121
vector121:
  pushl $0
801073eb:	6a 00                	push   $0x0
  pushl $121
801073ed:	6a 79                	push   $0x79
  jmp alltraps
801073ef:	e9 f0 f4 ff ff       	jmp    801068e4 <alltraps>

801073f4 <vector122>:
.globl vector122
vector122:
  pushl $0
801073f4:	6a 00                	push   $0x0
  pushl $122
801073f6:	6a 7a                	push   $0x7a
  jmp alltraps
801073f8:	e9 e7 f4 ff ff       	jmp    801068e4 <alltraps>

801073fd <vector123>:
.globl vector123
vector123:
  pushl $0
801073fd:	6a 00                	push   $0x0
  pushl $123
801073ff:	6a 7b                	push   $0x7b
  jmp alltraps
80107401:	e9 de f4 ff ff       	jmp    801068e4 <alltraps>

80107406 <vector124>:
.globl vector124
vector124:
  pushl $0
80107406:	6a 00                	push   $0x0
  pushl $124
80107408:	6a 7c                	push   $0x7c
  jmp alltraps
8010740a:	e9 d5 f4 ff ff       	jmp    801068e4 <alltraps>

8010740f <vector125>:
.globl vector125
vector125:
  pushl $0
8010740f:	6a 00                	push   $0x0
  pushl $125
80107411:	6a 7d                	push   $0x7d
  jmp alltraps
80107413:	e9 cc f4 ff ff       	jmp    801068e4 <alltraps>

80107418 <vector126>:
.globl vector126
vector126:
  pushl $0
80107418:	6a 00                	push   $0x0
  pushl $126
8010741a:	6a 7e                	push   $0x7e
  jmp alltraps
8010741c:	e9 c3 f4 ff ff       	jmp    801068e4 <alltraps>

80107421 <vector127>:
.globl vector127
vector127:
  pushl $0
80107421:	6a 00                	push   $0x0
  pushl $127
80107423:	6a 7f                	push   $0x7f
  jmp alltraps
80107425:	e9 ba f4 ff ff       	jmp    801068e4 <alltraps>

8010742a <vector128>:
.globl vector128
vector128:
  pushl $0
8010742a:	6a 00                	push   $0x0
  pushl $128
8010742c:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107431:	e9 ae f4 ff ff       	jmp    801068e4 <alltraps>

80107436 <vector129>:
.globl vector129
vector129:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $129
80107438:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010743d:	e9 a2 f4 ff ff       	jmp    801068e4 <alltraps>

80107442 <vector130>:
.globl vector130
vector130:
  pushl $0
80107442:	6a 00                	push   $0x0
  pushl $130
80107444:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107449:	e9 96 f4 ff ff       	jmp    801068e4 <alltraps>

8010744e <vector131>:
.globl vector131
vector131:
  pushl $0
8010744e:	6a 00                	push   $0x0
  pushl $131
80107450:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107455:	e9 8a f4 ff ff       	jmp    801068e4 <alltraps>

8010745a <vector132>:
.globl vector132
vector132:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $132
8010745c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107461:	e9 7e f4 ff ff       	jmp    801068e4 <alltraps>

80107466 <vector133>:
.globl vector133
vector133:
  pushl $0
80107466:	6a 00                	push   $0x0
  pushl $133
80107468:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010746d:	e9 72 f4 ff ff       	jmp    801068e4 <alltraps>

80107472 <vector134>:
.globl vector134
vector134:
  pushl $0
80107472:	6a 00                	push   $0x0
  pushl $134
80107474:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107479:	e9 66 f4 ff ff       	jmp    801068e4 <alltraps>

8010747e <vector135>:
.globl vector135
vector135:
  pushl $0
8010747e:	6a 00                	push   $0x0
  pushl $135
80107480:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107485:	e9 5a f4 ff ff       	jmp    801068e4 <alltraps>

8010748a <vector136>:
.globl vector136
vector136:
  pushl $0
8010748a:	6a 00                	push   $0x0
  pushl $136
8010748c:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107491:	e9 4e f4 ff ff       	jmp    801068e4 <alltraps>

80107496 <vector137>:
.globl vector137
vector137:
  pushl $0
80107496:	6a 00                	push   $0x0
  pushl $137
80107498:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010749d:	e9 42 f4 ff ff       	jmp    801068e4 <alltraps>

801074a2 <vector138>:
.globl vector138
vector138:
  pushl $0
801074a2:	6a 00                	push   $0x0
  pushl $138
801074a4:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801074a9:	e9 36 f4 ff ff       	jmp    801068e4 <alltraps>

801074ae <vector139>:
.globl vector139
vector139:
  pushl $0
801074ae:	6a 00                	push   $0x0
  pushl $139
801074b0:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801074b5:	e9 2a f4 ff ff       	jmp    801068e4 <alltraps>

801074ba <vector140>:
.globl vector140
vector140:
  pushl $0
801074ba:	6a 00                	push   $0x0
  pushl $140
801074bc:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801074c1:	e9 1e f4 ff ff       	jmp    801068e4 <alltraps>

801074c6 <vector141>:
.globl vector141
vector141:
  pushl $0
801074c6:	6a 00                	push   $0x0
  pushl $141
801074c8:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801074cd:	e9 12 f4 ff ff       	jmp    801068e4 <alltraps>

801074d2 <vector142>:
.globl vector142
vector142:
  pushl $0
801074d2:	6a 00                	push   $0x0
  pushl $142
801074d4:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801074d9:	e9 06 f4 ff ff       	jmp    801068e4 <alltraps>

801074de <vector143>:
.globl vector143
vector143:
  pushl $0
801074de:	6a 00                	push   $0x0
  pushl $143
801074e0:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801074e5:	e9 fa f3 ff ff       	jmp    801068e4 <alltraps>

801074ea <vector144>:
.globl vector144
vector144:
  pushl $0
801074ea:	6a 00                	push   $0x0
  pushl $144
801074ec:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801074f1:	e9 ee f3 ff ff       	jmp    801068e4 <alltraps>

801074f6 <vector145>:
.globl vector145
vector145:
  pushl $0
801074f6:	6a 00                	push   $0x0
  pushl $145
801074f8:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801074fd:	e9 e2 f3 ff ff       	jmp    801068e4 <alltraps>

80107502 <vector146>:
.globl vector146
vector146:
  pushl $0
80107502:	6a 00                	push   $0x0
  pushl $146
80107504:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107509:	e9 d6 f3 ff ff       	jmp    801068e4 <alltraps>

8010750e <vector147>:
.globl vector147
vector147:
  pushl $0
8010750e:	6a 00                	push   $0x0
  pushl $147
80107510:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107515:	e9 ca f3 ff ff       	jmp    801068e4 <alltraps>

8010751a <vector148>:
.globl vector148
vector148:
  pushl $0
8010751a:	6a 00                	push   $0x0
  pushl $148
8010751c:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107521:	e9 be f3 ff ff       	jmp    801068e4 <alltraps>

80107526 <vector149>:
.globl vector149
vector149:
  pushl $0
80107526:	6a 00                	push   $0x0
  pushl $149
80107528:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010752d:	e9 b2 f3 ff ff       	jmp    801068e4 <alltraps>

80107532 <vector150>:
.globl vector150
vector150:
  pushl $0
80107532:	6a 00                	push   $0x0
  pushl $150
80107534:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107539:	e9 a6 f3 ff ff       	jmp    801068e4 <alltraps>

8010753e <vector151>:
.globl vector151
vector151:
  pushl $0
8010753e:	6a 00                	push   $0x0
  pushl $151
80107540:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107545:	e9 9a f3 ff ff       	jmp    801068e4 <alltraps>

8010754a <vector152>:
.globl vector152
vector152:
  pushl $0
8010754a:	6a 00                	push   $0x0
  pushl $152
8010754c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107551:	e9 8e f3 ff ff       	jmp    801068e4 <alltraps>

80107556 <vector153>:
.globl vector153
vector153:
  pushl $0
80107556:	6a 00                	push   $0x0
  pushl $153
80107558:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010755d:	e9 82 f3 ff ff       	jmp    801068e4 <alltraps>

80107562 <vector154>:
.globl vector154
vector154:
  pushl $0
80107562:	6a 00                	push   $0x0
  pushl $154
80107564:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107569:	e9 76 f3 ff ff       	jmp    801068e4 <alltraps>

8010756e <vector155>:
.globl vector155
vector155:
  pushl $0
8010756e:	6a 00                	push   $0x0
  pushl $155
80107570:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107575:	e9 6a f3 ff ff       	jmp    801068e4 <alltraps>

8010757a <vector156>:
.globl vector156
vector156:
  pushl $0
8010757a:	6a 00                	push   $0x0
  pushl $156
8010757c:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107581:	e9 5e f3 ff ff       	jmp    801068e4 <alltraps>

80107586 <vector157>:
.globl vector157
vector157:
  pushl $0
80107586:	6a 00                	push   $0x0
  pushl $157
80107588:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010758d:	e9 52 f3 ff ff       	jmp    801068e4 <alltraps>

80107592 <vector158>:
.globl vector158
vector158:
  pushl $0
80107592:	6a 00                	push   $0x0
  pushl $158
80107594:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107599:	e9 46 f3 ff ff       	jmp    801068e4 <alltraps>

8010759e <vector159>:
.globl vector159
vector159:
  pushl $0
8010759e:	6a 00                	push   $0x0
  pushl $159
801075a0:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801075a5:	e9 3a f3 ff ff       	jmp    801068e4 <alltraps>

801075aa <vector160>:
.globl vector160
vector160:
  pushl $0
801075aa:	6a 00                	push   $0x0
  pushl $160
801075ac:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801075b1:	e9 2e f3 ff ff       	jmp    801068e4 <alltraps>

801075b6 <vector161>:
.globl vector161
vector161:
  pushl $0
801075b6:	6a 00                	push   $0x0
  pushl $161
801075b8:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801075bd:	e9 22 f3 ff ff       	jmp    801068e4 <alltraps>

801075c2 <vector162>:
.globl vector162
vector162:
  pushl $0
801075c2:	6a 00                	push   $0x0
  pushl $162
801075c4:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801075c9:	e9 16 f3 ff ff       	jmp    801068e4 <alltraps>

801075ce <vector163>:
.globl vector163
vector163:
  pushl $0
801075ce:	6a 00                	push   $0x0
  pushl $163
801075d0:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801075d5:	e9 0a f3 ff ff       	jmp    801068e4 <alltraps>

801075da <vector164>:
.globl vector164
vector164:
  pushl $0
801075da:	6a 00                	push   $0x0
  pushl $164
801075dc:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801075e1:	e9 fe f2 ff ff       	jmp    801068e4 <alltraps>

801075e6 <vector165>:
.globl vector165
vector165:
  pushl $0
801075e6:	6a 00                	push   $0x0
  pushl $165
801075e8:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801075ed:	e9 f2 f2 ff ff       	jmp    801068e4 <alltraps>

801075f2 <vector166>:
.globl vector166
vector166:
  pushl $0
801075f2:	6a 00                	push   $0x0
  pushl $166
801075f4:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801075f9:	e9 e6 f2 ff ff       	jmp    801068e4 <alltraps>

801075fe <vector167>:
.globl vector167
vector167:
  pushl $0
801075fe:	6a 00                	push   $0x0
  pushl $167
80107600:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107605:	e9 da f2 ff ff       	jmp    801068e4 <alltraps>

8010760a <vector168>:
.globl vector168
vector168:
  pushl $0
8010760a:	6a 00                	push   $0x0
  pushl $168
8010760c:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107611:	e9 ce f2 ff ff       	jmp    801068e4 <alltraps>

80107616 <vector169>:
.globl vector169
vector169:
  pushl $0
80107616:	6a 00                	push   $0x0
  pushl $169
80107618:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010761d:	e9 c2 f2 ff ff       	jmp    801068e4 <alltraps>

80107622 <vector170>:
.globl vector170
vector170:
  pushl $0
80107622:	6a 00                	push   $0x0
  pushl $170
80107624:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107629:	e9 b6 f2 ff ff       	jmp    801068e4 <alltraps>

8010762e <vector171>:
.globl vector171
vector171:
  pushl $0
8010762e:	6a 00                	push   $0x0
  pushl $171
80107630:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107635:	e9 aa f2 ff ff       	jmp    801068e4 <alltraps>

8010763a <vector172>:
.globl vector172
vector172:
  pushl $0
8010763a:	6a 00                	push   $0x0
  pushl $172
8010763c:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107641:	e9 9e f2 ff ff       	jmp    801068e4 <alltraps>

80107646 <vector173>:
.globl vector173
vector173:
  pushl $0
80107646:	6a 00                	push   $0x0
  pushl $173
80107648:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010764d:	e9 92 f2 ff ff       	jmp    801068e4 <alltraps>

80107652 <vector174>:
.globl vector174
vector174:
  pushl $0
80107652:	6a 00                	push   $0x0
  pushl $174
80107654:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107659:	e9 86 f2 ff ff       	jmp    801068e4 <alltraps>

8010765e <vector175>:
.globl vector175
vector175:
  pushl $0
8010765e:	6a 00                	push   $0x0
  pushl $175
80107660:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107665:	e9 7a f2 ff ff       	jmp    801068e4 <alltraps>

8010766a <vector176>:
.globl vector176
vector176:
  pushl $0
8010766a:	6a 00                	push   $0x0
  pushl $176
8010766c:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107671:	e9 6e f2 ff ff       	jmp    801068e4 <alltraps>

80107676 <vector177>:
.globl vector177
vector177:
  pushl $0
80107676:	6a 00                	push   $0x0
  pushl $177
80107678:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010767d:	e9 62 f2 ff ff       	jmp    801068e4 <alltraps>

80107682 <vector178>:
.globl vector178
vector178:
  pushl $0
80107682:	6a 00                	push   $0x0
  pushl $178
80107684:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107689:	e9 56 f2 ff ff       	jmp    801068e4 <alltraps>

8010768e <vector179>:
.globl vector179
vector179:
  pushl $0
8010768e:	6a 00                	push   $0x0
  pushl $179
80107690:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107695:	e9 4a f2 ff ff       	jmp    801068e4 <alltraps>

8010769a <vector180>:
.globl vector180
vector180:
  pushl $0
8010769a:	6a 00                	push   $0x0
  pushl $180
8010769c:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801076a1:	e9 3e f2 ff ff       	jmp    801068e4 <alltraps>

801076a6 <vector181>:
.globl vector181
vector181:
  pushl $0
801076a6:	6a 00                	push   $0x0
  pushl $181
801076a8:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801076ad:	e9 32 f2 ff ff       	jmp    801068e4 <alltraps>

801076b2 <vector182>:
.globl vector182
vector182:
  pushl $0
801076b2:	6a 00                	push   $0x0
  pushl $182
801076b4:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801076b9:	e9 26 f2 ff ff       	jmp    801068e4 <alltraps>

801076be <vector183>:
.globl vector183
vector183:
  pushl $0
801076be:	6a 00                	push   $0x0
  pushl $183
801076c0:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801076c5:	e9 1a f2 ff ff       	jmp    801068e4 <alltraps>

801076ca <vector184>:
.globl vector184
vector184:
  pushl $0
801076ca:	6a 00                	push   $0x0
  pushl $184
801076cc:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801076d1:	e9 0e f2 ff ff       	jmp    801068e4 <alltraps>

801076d6 <vector185>:
.globl vector185
vector185:
  pushl $0
801076d6:	6a 00                	push   $0x0
  pushl $185
801076d8:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801076dd:	e9 02 f2 ff ff       	jmp    801068e4 <alltraps>

801076e2 <vector186>:
.globl vector186
vector186:
  pushl $0
801076e2:	6a 00                	push   $0x0
  pushl $186
801076e4:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801076e9:	e9 f6 f1 ff ff       	jmp    801068e4 <alltraps>

801076ee <vector187>:
.globl vector187
vector187:
  pushl $0
801076ee:	6a 00                	push   $0x0
  pushl $187
801076f0:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801076f5:	e9 ea f1 ff ff       	jmp    801068e4 <alltraps>

801076fa <vector188>:
.globl vector188
vector188:
  pushl $0
801076fa:	6a 00                	push   $0x0
  pushl $188
801076fc:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107701:	e9 de f1 ff ff       	jmp    801068e4 <alltraps>

80107706 <vector189>:
.globl vector189
vector189:
  pushl $0
80107706:	6a 00                	push   $0x0
  pushl $189
80107708:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010770d:	e9 d2 f1 ff ff       	jmp    801068e4 <alltraps>

80107712 <vector190>:
.globl vector190
vector190:
  pushl $0
80107712:	6a 00                	push   $0x0
  pushl $190
80107714:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107719:	e9 c6 f1 ff ff       	jmp    801068e4 <alltraps>

8010771e <vector191>:
.globl vector191
vector191:
  pushl $0
8010771e:	6a 00                	push   $0x0
  pushl $191
80107720:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107725:	e9 ba f1 ff ff       	jmp    801068e4 <alltraps>

8010772a <vector192>:
.globl vector192
vector192:
  pushl $0
8010772a:	6a 00                	push   $0x0
  pushl $192
8010772c:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107731:	e9 ae f1 ff ff       	jmp    801068e4 <alltraps>

80107736 <vector193>:
.globl vector193
vector193:
  pushl $0
80107736:	6a 00                	push   $0x0
  pushl $193
80107738:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010773d:	e9 a2 f1 ff ff       	jmp    801068e4 <alltraps>

80107742 <vector194>:
.globl vector194
vector194:
  pushl $0
80107742:	6a 00                	push   $0x0
  pushl $194
80107744:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107749:	e9 96 f1 ff ff       	jmp    801068e4 <alltraps>

8010774e <vector195>:
.globl vector195
vector195:
  pushl $0
8010774e:	6a 00                	push   $0x0
  pushl $195
80107750:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107755:	e9 8a f1 ff ff       	jmp    801068e4 <alltraps>

8010775a <vector196>:
.globl vector196
vector196:
  pushl $0
8010775a:	6a 00                	push   $0x0
  pushl $196
8010775c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107761:	e9 7e f1 ff ff       	jmp    801068e4 <alltraps>

80107766 <vector197>:
.globl vector197
vector197:
  pushl $0
80107766:	6a 00                	push   $0x0
  pushl $197
80107768:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010776d:	e9 72 f1 ff ff       	jmp    801068e4 <alltraps>

80107772 <vector198>:
.globl vector198
vector198:
  pushl $0
80107772:	6a 00                	push   $0x0
  pushl $198
80107774:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107779:	e9 66 f1 ff ff       	jmp    801068e4 <alltraps>

8010777e <vector199>:
.globl vector199
vector199:
  pushl $0
8010777e:	6a 00                	push   $0x0
  pushl $199
80107780:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107785:	e9 5a f1 ff ff       	jmp    801068e4 <alltraps>

8010778a <vector200>:
.globl vector200
vector200:
  pushl $0
8010778a:	6a 00                	push   $0x0
  pushl $200
8010778c:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107791:	e9 4e f1 ff ff       	jmp    801068e4 <alltraps>

80107796 <vector201>:
.globl vector201
vector201:
  pushl $0
80107796:	6a 00                	push   $0x0
  pushl $201
80107798:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010779d:	e9 42 f1 ff ff       	jmp    801068e4 <alltraps>

801077a2 <vector202>:
.globl vector202
vector202:
  pushl $0
801077a2:	6a 00                	push   $0x0
  pushl $202
801077a4:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801077a9:	e9 36 f1 ff ff       	jmp    801068e4 <alltraps>

801077ae <vector203>:
.globl vector203
vector203:
  pushl $0
801077ae:	6a 00                	push   $0x0
  pushl $203
801077b0:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801077b5:	e9 2a f1 ff ff       	jmp    801068e4 <alltraps>

801077ba <vector204>:
.globl vector204
vector204:
  pushl $0
801077ba:	6a 00                	push   $0x0
  pushl $204
801077bc:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801077c1:	e9 1e f1 ff ff       	jmp    801068e4 <alltraps>

801077c6 <vector205>:
.globl vector205
vector205:
  pushl $0
801077c6:	6a 00                	push   $0x0
  pushl $205
801077c8:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801077cd:	e9 12 f1 ff ff       	jmp    801068e4 <alltraps>

801077d2 <vector206>:
.globl vector206
vector206:
  pushl $0
801077d2:	6a 00                	push   $0x0
  pushl $206
801077d4:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801077d9:	e9 06 f1 ff ff       	jmp    801068e4 <alltraps>

801077de <vector207>:
.globl vector207
vector207:
  pushl $0
801077de:	6a 00                	push   $0x0
  pushl $207
801077e0:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801077e5:	e9 fa f0 ff ff       	jmp    801068e4 <alltraps>

801077ea <vector208>:
.globl vector208
vector208:
  pushl $0
801077ea:	6a 00                	push   $0x0
  pushl $208
801077ec:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801077f1:	e9 ee f0 ff ff       	jmp    801068e4 <alltraps>

801077f6 <vector209>:
.globl vector209
vector209:
  pushl $0
801077f6:	6a 00                	push   $0x0
  pushl $209
801077f8:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801077fd:	e9 e2 f0 ff ff       	jmp    801068e4 <alltraps>

80107802 <vector210>:
.globl vector210
vector210:
  pushl $0
80107802:	6a 00                	push   $0x0
  pushl $210
80107804:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107809:	e9 d6 f0 ff ff       	jmp    801068e4 <alltraps>

8010780e <vector211>:
.globl vector211
vector211:
  pushl $0
8010780e:	6a 00                	push   $0x0
  pushl $211
80107810:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107815:	e9 ca f0 ff ff       	jmp    801068e4 <alltraps>

8010781a <vector212>:
.globl vector212
vector212:
  pushl $0
8010781a:	6a 00                	push   $0x0
  pushl $212
8010781c:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107821:	e9 be f0 ff ff       	jmp    801068e4 <alltraps>

80107826 <vector213>:
.globl vector213
vector213:
  pushl $0
80107826:	6a 00                	push   $0x0
  pushl $213
80107828:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010782d:	e9 b2 f0 ff ff       	jmp    801068e4 <alltraps>

80107832 <vector214>:
.globl vector214
vector214:
  pushl $0
80107832:	6a 00                	push   $0x0
  pushl $214
80107834:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107839:	e9 a6 f0 ff ff       	jmp    801068e4 <alltraps>

8010783e <vector215>:
.globl vector215
vector215:
  pushl $0
8010783e:	6a 00                	push   $0x0
  pushl $215
80107840:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107845:	e9 9a f0 ff ff       	jmp    801068e4 <alltraps>

8010784a <vector216>:
.globl vector216
vector216:
  pushl $0
8010784a:	6a 00                	push   $0x0
  pushl $216
8010784c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107851:	e9 8e f0 ff ff       	jmp    801068e4 <alltraps>

80107856 <vector217>:
.globl vector217
vector217:
  pushl $0
80107856:	6a 00                	push   $0x0
  pushl $217
80107858:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010785d:	e9 82 f0 ff ff       	jmp    801068e4 <alltraps>

80107862 <vector218>:
.globl vector218
vector218:
  pushl $0
80107862:	6a 00                	push   $0x0
  pushl $218
80107864:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107869:	e9 76 f0 ff ff       	jmp    801068e4 <alltraps>

8010786e <vector219>:
.globl vector219
vector219:
  pushl $0
8010786e:	6a 00                	push   $0x0
  pushl $219
80107870:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107875:	e9 6a f0 ff ff       	jmp    801068e4 <alltraps>

8010787a <vector220>:
.globl vector220
vector220:
  pushl $0
8010787a:	6a 00                	push   $0x0
  pushl $220
8010787c:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107881:	e9 5e f0 ff ff       	jmp    801068e4 <alltraps>

80107886 <vector221>:
.globl vector221
vector221:
  pushl $0
80107886:	6a 00                	push   $0x0
  pushl $221
80107888:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010788d:	e9 52 f0 ff ff       	jmp    801068e4 <alltraps>

80107892 <vector222>:
.globl vector222
vector222:
  pushl $0
80107892:	6a 00                	push   $0x0
  pushl $222
80107894:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107899:	e9 46 f0 ff ff       	jmp    801068e4 <alltraps>

8010789e <vector223>:
.globl vector223
vector223:
  pushl $0
8010789e:	6a 00                	push   $0x0
  pushl $223
801078a0:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801078a5:	e9 3a f0 ff ff       	jmp    801068e4 <alltraps>

801078aa <vector224>:
.globl vector224
vector224:
  pushl $0
801078aa:	6a 00                	push   $0x0
  pushl $224
801078ac:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801078b1:	e9 2e f0 ff ff       	jmp    801068e4 <alltraps>

801078b6 <vector225>:
.globl vector225
vector225:
  pushl $0
801078b6:	6a 00                	push   $0x0
  pushl $225
801078b8:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801078bd:	e9 22 f0 ff ff       	jmp    801068e4 <alltraps>

801078c2 <vector226>:
.globl vector226
vector226:
  pushl $0
801078c2:	6a 00                	push   $0x0
  pushl $226
801078c4:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801078c9:	e9 16 f0 ff ff       	jmp    801068e4 <alltraps>

801078ce <vector227>:
.globl vector227
vector227:
  pushl $0
801078ce:	6a 00                	push   $0x0
  pushl $227
801078d0:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801078d5:	e9 0a f0 ff ff       	jmp    801068e4 <alltraps>

801078da <vector228>:
.globl vector228
vector228:
  pushl $0
801078da:	6a 00                	push   $0x0
  pushl $228
801078dc:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801078e1:	e9 fe ef ff ff       	jmp    801068e4 <alltraps>

801078e6 <vector229>:
.globl vector229
vector229:
  pushl $0
801078e6:	6a 00                	push   $0x0
  pushl $229
801078e8:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801078ed:	e9 f2 ef ff ff       	jmp    801068e4 <alltraps>

801078f2 <vector230>:
.globl vector230
vector230:
  pushl $0
801078f2:	6a 00                	push   $0x0
  pushl $230
801078f4:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801078f9:	e9 e6 ef ff ff       	jmp    801068e4 <alltraps>

801078fe <vector231>:
.globl vector231
vector231:
  pushl $0
801078fe:	6a 00                	push   $0x0
  pushl $231
80107900:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107905:	e9 da ef ff ff       	jmp    801068e4 <alltraps>

8010790a <vector232>:
.globl vector232
vector232:
  pushl $0
8010790a:	6a 00                	push   $0x0
  pushl $232
8010790c:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107911:	e9 ce ef ff ff       	jmp    801068e4 <alltraps>

80107916 <vector233>:
.globl vector233
vector233:
  pushl $0
80107916:	6a 00                	push   $0x0
  pushl $233
80107918:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010791d:	e9 c2 ef ff ff       	jmp    801068e4 <alltraps>

80107922 <vector234>:
.globl vector234
vector234:
  pushl $0
80107922:	6a 00                	push   $0x0
  pushl $234
80107924:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107929:	e9 b6 ef ff ff       	jmp    801068e4 <alltraps>

8010792e <vector235>:
.globl vector235
vector235:
  pushl $0
8010792e:	6a 00                	push   $0x0
  pushl $235
80107930:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107935:	e9 aa ef ff ff       	jmp    801068e4 <alltraps>

8010793a <vector236>:
.globl vector236
vector236:
  pushl $0
8010793a:	6a 00                	push   $0x0
  pushl $236
8010793c:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107941:	e9 9e ef ff ff       	jmp    801068e4 <alltraps>

80107946 <vector237>:
.globl vector237
vector237:
  pushl $0
80107946:	6a 00                	push   $0x0
  pushl $237
80107948:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010794d:	e9 92 ef ff ff       	jmp    801068e4 <alltraps>

80107952 <vector238>:
.globl vector238
vector238:
  pushl $0
80107952:	6a 00                	push   $0x0
  pushl $238
80107954:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107959:	e9 86 ef ff ff       	jmp    801068e4 <alltraps>

8010795e <vector239>:
.globl vector239
vector239:
  pushl $0
8010795e:	6a 00                	push   $0x0
  pushl $239
80107960:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107965:	e9 7a ef ff ff       	jmp    801068e4 <alltraps>

8010796a <vector240>:
.globl vector240
vector240:
  pushl $0
8010796a:	6a 00                	push   $0x0
  pushl $240
8010796c:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107971:	e9 6e ef ff ff       	jmp    801068e4 <alltraps>

80107976 <vector241>:
.globl vector241
vector241:
  pushl $0
80107976:	6a 00                	push   $0x0
  pushl $241
80107978:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010797d:	e9 62 ef ff ff       	jmp    801068e4 <alltraps>

80107982 <vector242>:
.globl vector242
vector242:
  pushl $0
80107982:	6a 00                	push   $0x0
  pushl $242
80107984:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107989:	e9 56 ef ff ff       	jmp    801068e4 <alltraps>

8010798e <vector243>:
.globl vector243
vector243:
  pushl $0
8010798e:	6a 00                	push   $0x0
  pushl $243
80107990:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107995:	e9 4a ef ff ff       	jmp    801068e4 <alltraps>

8010799a <vector244>:
.globl vector244
vector244:
  pushl $0
8010799a:	6a 00                	push   $0x0
  pushl $244
8010799c:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801079a1:	e9 3e ef ff ff       	jmp    801068e4 <alltraps>

801079a6 <vector245>:
.globl vector245
vector245:
  pushl $0
801079a6:	6a 00                	push   $0x0
  pushl $245
801079a8:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801079ad:	e9 32 ef ff ff       	jmp    801068e4 <alltraps>

801079b2 <vector246>:
.globl vector246
vector246:
  pushl $0
801079b2:	6a 00                	push   $0x0
  pushl $246
801079b4:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801079b9:	e9 26 ef ff ff       	jmp    801068e4 <alltraps>

801079be <vector247>:
.globl vector247
vector247:
  pushl $0
801079be:	6a 00                	push   $0x0
  pushl $247
801079c0:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801079c5:	e9 1a ef ff ff       	jmp    801068e4 <alltraps>

801079ca <vector248>:
.globl vector248
vector248:
  pushl $0
801079ca:	6a 00                	push   $0x0
  pushl $248
801079cc:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801079d1:	e9 0e ef ff ff       	jmp    801068e4 <alltraps>

801079d6 <vector249>:
.globl vector249
vector249:
  pushl $0
801079d6:	6a 00                	push   $0x0
  pushl $249
801079d8:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801079dd:	e9 02 ef ff ff       	jmp    801068e4 <alltraps>

801079e2 <vector250>:
.globl vector250
vector250:
  pushl $0
801079e2:	6a 00                	push   $0x0
  pushl $250
801079e4:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801079e9:	e9 f6 ee ff ff       	jmp    801068e4 <alltraps>

801079ee <vector251>:
.globl vector251
vector251:
  pushl $0
801079ee:	6a 00                	push   $0x0
  pushl $251
801079f0:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801079f5:	e9 ea ee ff ff       	jmp    801068e4 <alltraps>

801079fa <vector252>:
.globl vector252
vector252:
  pushl $0
801079fa:	6a 00                	push   $0x0
  pushl $252
801079fc:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107a01:	e9 de ee ff ff       	jmp    801068e4 <alltraps>

80107a06 <vector253>:
.globl vector253
vector253:
  pushl $0
80107a06:	6a 00                	push   $0x0
  pushl $253
80107a08:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107a0d:	e9 d2 ee ff ff       	jmp    801068e4 <alltraps>

80107a12 <vector254>:
.globl vector254
vector254:
  pushl $0
80107a12:	6a 00                	push   $0x0
  pushl $254
80107a14:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107a19:	e9 c6 ee ff ff       	jmp    801068e4 <alltraps>

80107a1e <vector255>:
.globl vector255
vector255:
  pushl $0
80107a1e:	6a 00                	push   $0x0
  pushl $255
80107a20:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107a25:	e9 ba ee ff ff       	jmp    801068e4 <alltraps>
	...

80107a2c <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107a2c:	55                   	push   %ebp
80107a2d:	89 e5                	mov    %esp,%ebp
80107a2f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107a32:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a35:	83 e8 01             	sub    $0x1,%eax
80107a38:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107a3c:	8b 45 08             	mov    0x8(%ebp),%eax
80107a3f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107a43:	8b 45 08             	mov    0x8(%ebp),%eax
80107a46:	c1 e8 10             	shr    $0x10,%eax
80107a49:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107a4d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107a50:	0f 01 10             	lgdtl  (%eax)
}
80107a53:	c9                   	leave  
80107a54:	c3                   	ret    

80107a55 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107a55:	55                   	push   %ebp
80107a56:	89 e5                	mov    %esp,%ebp
80107a58:	83 ec 04             	sub    $0x4,%esp
80107a5b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a5e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107a62:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a66:	0f 00 d8             	ltr    %ax
}
80107a69:	c9                   	leave  
80107a6a:	c3                   	ret    

80107a6b <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107a6b:	55                   	push   %ebp
80107a6c:	89 e5                	mov    %esp,%ebp
80107a6e:	83 ec 04             	sub    $0x4,%esp
80107a71:	8b 45 08             	mov    0x8(%ebp),%eax
80107a74:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107a78:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a7c:	8e e8                	mov    %eax,%gs
}
80107a7e:	c9                   	leave  
80107a7f:	c3                   	ret    

80107a80 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107a80:	55                   	push   %ebp
80107a81:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107a83:	8b 45 08             	mov    0x8(%ebp),%eax
80107a86:	0f 22 d8             	mov    %eax,%cr3
}
80107a89:	5d                   	pop    %ebp
80107a8a:	c3                   	ret    

80107a8b <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107a8b:	55                   	push   %ebp
80107a8c:	89 e5                	mov    %esp,%ebp
80107a8e:	8b 45 08             	mov    0x8(%ebp),%eax
80107a91:	05 00 00 00 80       	add    $0x80000000,%eax
80107a96:	5d                   	pop    %ebp
80107a97:	c3                   	ret    

80107a98 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107a98:	55                   	push   %ebp
80107a99:	89 e5                	mov    %esp,%ebp
80107a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a9e:	05 00 00 00 80       	add    $0x80000000,%eax
80107aa3:	5d                   	pop    %ebp
80107aa4:	c3                   	ret    

80107aa5 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107aa5:	55                   	push   %ebp
80107aa6:	89 e5                	mov    %esp,%ebp
80107aa8:	53                   	push   %ebx
80107aa9:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107aac:	e8 34 b7 ff ff       	call   801031e5 <cpunum>
80107ab1:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107ab7:	05 40 f9 10 80       	add    $0x8010f940,%eax
80107abc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac2:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107acb:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad4:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107adb:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107adf:	83 e2 f0             	and    $0xfffffff0,%edx
80107ae2:	83 ca 0a             	or     $0xa,%edx
80107ae5:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aeb:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107aef:	83 ca 10             	or     $0x10,%edx
80107af2:	88 50 7d             	mov    %dl,0x7d(%eax)
80107af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107afc:	83 e2 9f             	and    $0xffffff9f,%edx
80107aff:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b05:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b09:	83 ca 80             	or     $0xffffff80,%edx
80107b0c:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b12:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b16:	83 ca 0f             	or     $0xf,%edx
80107b19:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b23:	83 e2 ef             	and    $0xffffffef,%edx
80107b26:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b30:	83 e2 df             	and    $0xffffffdf,%edx
80107b33:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b39:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b3d:	83 ca 40             	or     $0x40,%edx
80107b40:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b46:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b4a:	83 ca 80             	or     $0xffffff80,%edx
80107b4d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b53:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5a:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107b61:	ff ff 
80107b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b66:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107b6d:	00 00 
80107b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b72:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b83:	83 e2 f0             	and    $0xfffffff0,%edx
80107b86:	83 ca 02             	or     $0x2,%edx
80107b89:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b92:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b99:	83 ca 10             	or     $0x10,%edx
80107b9c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107bac:	83 e2 9f             	and    $0xffffff9f,%edx
80107baf:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107bbf:	83 ca 80             	or     $0xffffff80,%edx
80107bc2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcb:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bd2:	83 ca 0f             	or     $0xf,%edx
80107bd5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bde:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107be5:	83 e2 ef             	and    $0xffffffef,%edx
80107be8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bf8:	83 e2 df             	and    $0xffffffdf,%edx
80107bfb:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c04:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c0b:	83 ca 40             	or     $0x40,%edx
80107c0e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c17:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c1e:	83 ca 80             	or     $0xffffff80,%edx
80107c21:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2a:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c34:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107c3b:	ff ff 
80107c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c40:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107c47:	00 00 
80107c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4c:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c56:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c5d:	83 e2 f0             	and    $0xfffffff0,%edx
80107c60:	83 ca 0a             	or     $0xa,%edx
80107c63:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c73:	83 ca 10             	or     $0x10,%edx
80107c76:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c86:	83 ca 60             	or     $0x60,%edx
80107c89:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c92:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c99:	83 ca 80             	or     $0xffffff80,%edx
80107c9c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cac:	83 ca 0f             	or     $0xf,%edx
80107caf:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cbf:	83 e2 ef             	and    $0xffffffef,%edx
80107cc2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ccb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cd2:	83 e2 df             	and    $0xffffffdf,%edx
80107cd5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cde:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ce5:	83 ca 40             	or     $0x40,%edx
80107ce8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cf8:	83 ca 80             	or     $0xffffff80,%edx
80107cfb:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d04:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0e:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107d15:	ff ff 
80107d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1a:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107d21:	00 00 
80107d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d26:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107d2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d30:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d37:	83 e2 f0             	and    $0xfffffff0,%edx
80107d3a:	83 ca 02             	or     $0x2,%edx
80107d3d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d46:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d4d:	83 ca 10             	or     $0x10,%edx
80107d50:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d59:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d60:	83 ca 60             	or     $0x60,%edx
80107d63:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d73:	83 ca 80             	or     $0xffffff80,%edx
80107d76:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d86:	83 ca 0f             	or     $0xf,%edx
80107d89:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d92:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d99:	83 e2 ef             	and    $0xffffffef,%edx
80107d9c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da5:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107dac:	83 e2 df             	and    $0xffffffdf,%edx
80107daf:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db8:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107dbf:	83 ca 40             	or     $0x40,%edx
80107dc2:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dcb:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107dd2:	83 ca 80             	or     $0xffffff80,%edx
80107dd5:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dde:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de8:	05 b4 00 00 00       	add    $0xb4,%eax
80107ded:	89 c3                	mov    %eax,%ebx
80107def:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df2:	05 b4 00 00 00       	add    $0xb4,%eax
80107df7:	c1 e8 10             	shr    $0x10,%eax
80107dfa:	89 c1                	mov    %eax,%ecx
80107dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dff:	05 b4 00 00 00       	add    $0xb4,%eax
80107e04:	c1 e8 18             	shr    $0x18,%eax
80107e07:	89 c2                	mov    %eax,%edx
80107e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0c:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107e13:	00 00 
80107e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e18:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e22:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2b:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e32:	83 e1 f0             	and    $0xfffffff0,%ecx
80107e35:	83 c9 02             	or     $0x2,%ecx
80107e38:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e41:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e48:	83 c9 10             	or     $0x10,%ecx
80107e4b:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e54:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e5b:	83 e1 9f             	and    $0xffffff9f,%ecx
80107e5e:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e67:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e6e:	83 c9 80             	or     $0xffffff80,%ecx
80107e71:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7a:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e81:	83 e1 f0             	and    $0xfffffff0,%ecx
80107e84:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8d:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e94:	83 e1 ef             	and    $0xffffffef,%ecx
80107e97:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea0:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107ea7:	83 e1 df             	and    $0xffffffdf,%ecx
80107eaa:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb3:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107eba:	83 c9 40             	or     $0x40,%ecx
80107ebd:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec6:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107ecd:	83 c9 80             	or     $0xffffff80,%ecx
80107ed0:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed9:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee2:	83 c0 70             	add    $0x70,%eax
80107ee5:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107eec:	00 
80107eed:	89 04 24             	mov    %eax,(%esp)
80107ef0:	e8 37 fb ff ff       	call   80107a2c <lgdt>
  loadgs(SEG_KCPU << 3);
80107ef5:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107efc:	e8 6a fb ff ff       	call   80107a6b <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f04:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107f0a:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107f11:	00 00 00 00 
}
80107f15:	83 c4 24             	add    $0x24,%esp
80107f18:	5b                   	pop    %ebx
80107f19:	5d                   	pop    %ebp
80107f1a:	c3                   	ret    

80107f1b <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107f1b:	55                   	push   %ebp
80107f1c:	89 e5                	mov    %esp,%ebp
80107f1e:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107f21:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f24:	c1 e8 16             	shr    $0x16,%eax
80107f27:	c1 e0 02             	shl    $0x2,%eax
80107f2a:	03 45 08             	add    0x8(%ebp),%eax
80107f2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107f30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f33:	8b 00                	mov    (%eax),%eax
80107f35:	83 e0 01             	and    $0x1,%eax
80107f38:	84 c0                	test   %al,%al
80107f3a:	74 17                	je     80107f53 <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107f3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f3f:	8b 00                	mov    (%eax),%eax
80107f41:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f46:	89 04 24             	mov    %eax,(%esp)
80107f49:	e8 4a fb ff ff       	call   80107a98 <p2v>
80107f4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f51:	eb 4b                	jmp    80107f9e <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107f53:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107f57:	74 0e                	je     80107f67 <walkpgdir+0x4c>
80107f59:	e8 f9 ae ff ff       	call   80102e57 <kalloc>
80107f5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f61:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f65:	75 07                	jne    80107f6e <walkpgdir+0x53>
      return 0;
80107f67:	b8 00 00 00 00       	mov    $0x0,%eax
80107f6c:	eb 41                	jmp    80107faf <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107f6e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f75:	00 
80107f76:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f7d:	00 
80107f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f81:	89 04 24             	mov    %eax,(%esp)
80107f84:	e8 b5 d4 ff ff       	call   8010543e <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107f89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8c:	89 04 24             	mov    %eax,(%esp)
80107f8f:	e8 f7 fa ff ff       	call   80107a8b <v2p>
80107f94:	89 c2                	mov    %eax,%edx
80107f96:	83 ca 07             	or     $0x7,%edx
80107f99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f9c:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107f9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fa1:	c1 e8 0c             	shr    $0xc,%eax
80107fa4:	25 ff 03 00 00       	and    $0x3ff,%eax
80107fa9:	c1 e0 02             	shl    $0x2,%eax
80107fac:	03 45 f4             	add    -0xc(%ebp),%eax
}
80107faf:	c9                   	leave  
80107fb0:	c3                   	ret    

80107fb1 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107fb1:	55                   	push   %ebp
80107fb2:	89 e5                	mov    %esp,%ebp
80107fb4:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107fb7:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fc5:	03 45 10             	add    0x10(%ebp),%eax
80107fc8:	83 e8 01             	sub    $0x1,%eax
80107fcb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fd0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107fd3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107fda:	00 
80107fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fde:	89 44 24 04          	mov    %eax,0x4(%esp)
80107fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80107fe5:	89 04 24             	mov    %eax,(%esp)
80107fe8:	e8 2e ff ff ff       	call   80107f1b <walkpgdir>
80107fed:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ff0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ff4:	75 07                	jne    80107ffd <mappages+0x4c>
      return -1;
80107ff6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ffb:	eb 46                	jmp    80108043 <mappages+0x92>
    if(*pte & PTE_P)
80107ffd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108000:	8b 00                	mov    (%eax),%eax
80108002:	83 e0 01             	and    $0x1,%eax
80108005:	84 c0                	test   %al,%al
80108007:	74 0c                	je     80108015 <mappages+0x64>
      panic("remap");
80108009:	c7 04 24 28 8e 10 80 	movl   $0x80108e28,(%esp)
80108010:	e8 28 85 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80108015:	8b 45 18             	mov    0x18(%ebp),%eax
80108018:	0b 45 14             	or     0x14(%ebp),%eax
8010801b:	89 c2                	mov    %eax,%edx
8010801d:	83 ca 01             	or     $0x1,%edx
80108020:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108023:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108025:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108028:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010802b:	74 10                	je     8010803d <mappages+0x8c>
      break;
    a += PGSIZE;
8010802d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108034:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
8010803b:	eb 96                	jmp    80107fd3 <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
8010803d:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
8010803e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108043:	c9                   	leave  
80108044:	c3                   	ret    

80108045 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm()
{
80108045:	55                   	push   %ebp
80108046:	89 e5                	mov    %esp,%ebp
80108048:	53                   	push   %ebx
80108049:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
8010804c:	e8 06 ae ff ff       	call   80102e57 <kalloc>
80108051:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108054:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108058:	75 0a                	jne    80108064 <setupkvm+0x1f>
    return 0;
8010805a:	b8 00 00 00 00       	mov    $0x0,%eax
8010805f:	e9 98 00 00 00       	jmp    801080fc <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80108064:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010806b:	00 
8010806c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108073:	00 
80108074:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108077:	89 04 24             	mov    %eax,(%esp)
8010807a:	e8 bf d3 ff ff       	call   8010543e <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
8010807f:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80108086:	e8 0d fa ff ff       	call   80107a98 <p2v>
8010808b:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108090:	76 0c                	jbe    8010809e <setupkvm+0x59>
    panic("PHYSTOP too high");
80108092:	c7 04 24 2e 8e 10 80 	movl   $0x80108e2e,(%esp)
80108099:	e8 9f 84 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010809e:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
801080a5:	eb 49                	jmp    801080f0 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
801080a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801080aa:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
801080ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801080b0:	8b 50 04             	mov    0x4(%eax),%edx
801080b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b6:	8b 58 08             	mov    0x8(%eax),%ebx
801080b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080bc:	8b 40 04             	mov    0x4(%eax),%eax
801080bf:	29 c3                	sub    %eax,%ebx
801080c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c4:	8b 00                	mov    (%eax),%eax
801080c6:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801080ca:	89 54 24 0c          	mov    %edx,0xc(%esp)
801080ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801080d2:	89 44 24 04          	mov    %eax,0x4(%esp)
801080d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080d9:	89 04 24             	mov    %eax,(%esp)
801080dc:	e8 d0 fe ff ff       	call   80107fb1 <mappages>
801080e1:	85 c0                	test   %eax,%eax
801080e3:	79 07                	jns    801080ec <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
801080e5:	b8 00 00 00 00       	mov    $0x0,%eax
801080ea:	eb 10                	jmp    801080fc <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801080ec:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801080f0:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
801080f7:	72 ae                	jb     801080a7 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801080f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801080fc:	83 c4 34             	add    $0x34,%esp
801080ff:	5b                   	pop    %ebx
80108100:	5d                   	pop    %ebp
80108101:	c3                   	ret    

80108102 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108102:	55                   	push   %ebp
80108103:	89 e5                	mov    %esp,%ebp
80108105:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108108:	e8 38 ff ff ff       	call   80108045 <setupkvm>
8010810d:	a3 18 2d 11 80       	mov    %eax,0x80112d18
  switchkvm();
80108112:	e8 02 00 00 00       	call   80108119 <switchkvm>
}
80108117:	c9                   	leave  
80108118:	c3                   	ret    

80108119 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108119:	55                   	push   %ebp
8010811a:	89 e5                	mov    %esp,%ebp
8010811c:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
8010811f:	a1 18 2d 11 80       	mov    0x80112d18,%eax
80108124:	89 04 24             	mov    %eax,(%esp)
80108127:	e8 5f f9 ff ff       	call   80107a8b <v2p>
8010812c:	89 04 24             	mov    %eax,(%esp)
8010812f:	e8 4c f9 ff ff       	call   80107a80 <lcr3>
}
80108134:	c9                   	leave  
80108135:	c3                   	ret    

80108136 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108136:	55                   	push   %ebp
80108137:	89 e5                	mov    %esp,%ebp
80108139:	53                   	push   %ebx
8010813a:	83 ec 14             	sub    $0x14,%esp
  pushcli();
8010813d:	e8 f5 d1 ff ff       	call   80105337 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108142:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108148:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010814f:	83 c2 08             	add    $0x8,%edx
80108152:	89 d3                	mov    %edx,%ebx
80108154:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010815b:	83 c2 08             	add    $0x8,%edx
8010815e:	c1 ea 10             	shr    $0x10,%edx
80108161:	89 d1                	mov    %edx,%ecx
80108163:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010816a:	83 c2 08             	add    $0x8,%edx
8010816d:	c1 ea 18             	shr    $0x18,%edx
80108170:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108177:	67 00 
80108179:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80108180:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80108186:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010818d:	83 e1 f0             	and    $0xfffffff0,%ecx
80108190:	83 c9 09             	or     $0x9,%ecx
80108193:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108199:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801081a0:	83 c9 10             	or     $0x10,%ecx
801081a3:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801081a9:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801081b0:	83 e1 9f             	and    $0xffffff9f,%ecx
801081b3:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801081b9:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801081c0:	83 c9 80             	or     $0xffffff80,%ecx
801081c3:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801081c9:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081d0:	83 e1 f0             	and    $0xfffffff0,%ecx
801081d3:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081d9:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081e0:	83 e1 ef             	and    $0xffffffef,%ecx
801081e3:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081e9:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081f0:	83 e1 df             	and    $0xffffffdf,%ecx
801081f3:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081f9:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108200:	83 c9 40             	or     $0x40,%ecx
80108203:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108209:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108210:	83 e1 7f             	and    $0x7f,%ecx
80108213:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108219:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
8010821f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108225:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010822c:	83 e2 ef             	and    $0xffffffef,%edx
8010822f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108235:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010823b:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108241:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108247:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010824e:	8b 52 08             	mov    0x8(%edx),%edx
80108251:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108257:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
8010825a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80108261:	e8 ef f7 ff ff       	call   80107a55 <ltr>
  if(p->pgdir == 0)
80108266:	8b 45 08             	mov    0x8(%ebp),%eax
80108269:	8b 40 04             	mov    0x4(%eax),%eax
8010826c:	85 c0                	test   %eax,%eax
8010826e:	75 0c                	jne    8010827c <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80108270:	c7 04 24 3f 8e 10 80 	movl   $0x80108e3f,(%esp)
80108277:	e8 c1 82 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
8010827c:	8b 45 08             	mov    0x8(%ebp),%eax
8010827f:	8b 40 04             	mov    0x4(%eax),%eax
80108282:	89 04 24             	mov    %eax,(%esp)
80108285:	e8 01 f8 ff ff       	call   80107a8b <v2p>
8010828a:	89 04 24             	mov    %eax,(%esp)
8010828d:	e8 ee f7 ff ff       	call   80107a80 <lcr3>
  popcli();
80108292:	e8 e8 d0 ff ff       	call   8010537f <popcli>
}
80108297:	83 c4 14             	add    $0x14,%esp
8010829a:	5b                   	pop    %ebx
8010829b:	5d                   	pop    %ebp
8010829c:	c3                   	ret    

8010829d <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010829d:	55                   	push   %ebp
8010829e:	89 e5                	mov    %esp,%ebp
801082a0:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801082a3:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801082aa:	76 0c                	jbe    801082b8 <inituvm+0x1b>
    panic("inituvm: more than a page");
801082ac:	c7 04 24 53 8e 10 80 	movl   $0x80108e53,(%esp)
801082b3:	e8 85 82 ff ff       	call   8010053d <panic>
  mem = kalloc();
801082b8:	e8 9a ab ff ff       	call   80102e57 <kalloc>
801082bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801082c0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082c7:	00 
801082c8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082cf:	00 
801082d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d3:	89 04 24             	mov    %eax,(%esp)
801082d6:	e8 63 d1 ff ff       	call   8010543e <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
801082db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082de:	89 04 24             	mov    %eax,(%esp)
801082e1:	e8 a5 f7 ff ff       	call   80107a8b <v2p>
801082e6:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801082ed:	00 
801082ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
801082f2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082f9:	00 
801082fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108301:	00 
80108302:	8b 45 08             	mov    0x8(%ebp),%eax
80108305:	89 04 24             	mov    %eax,(%esp)
80108308:	e8 a4 fc ff ff       	call   80107fb1 <mappages>
  memmove(mem, init, sz);
8010830d:	8b 45 10             	mov    0x10(%ebp),%eax
80108310:	89 44 24 08          	mov    %eax,0x8(%esp)
80108314:	8b 45 0c             	mov    0xc(%ebp),%eax
80108317:	89 44 24 04          	mov    %eax,0x4(%esp)
8010831b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010831e:	89 04 24             	mov    %eax,(%esp)
80108321:	e8 eb d1 ff ff       	call   80105511 <memmove>
}
80108326:	c9                   	leave  
80108327:	c3                   	ret    

80108328 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108328:	55                   	push   %ebp
80108329:	89 e5                	mov    %esp,%ebp
8010832b:	53                   	push   %ebx
8010832c:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010832f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108332:	25 ff 0f 00 00       	and    $0xfff,%eax
80108337:	85 c0                	test   %eax,%eax
80108339:	74 0c                	je     80108347 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
8010833b:	c7 04 24 70 8e 10 80 	movl   $0x80108e70,(%esp)
80108342:	e8 f6 81 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108347:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010834e:	e9 ad 00 00 00       	jmp    80108400 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108353:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108356:	8b 55 0c             	mov    0xc(%ebp),%edx
80108359:	01 d0                	add    %edx,%eax
8010835b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108362:	00 
80108363:	89 44 24 04          	mov    %eax,0x4(%esp)
80108367:	8b 45 08             	mov    0x8(%ebp),%eax
8010836a:	89 04 24             	mov    %eax,(%esp)
8010836d:	e8 a9 fb ff ff       	call   80107f1b <walkpgdir>
80108372:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108375:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108379:	75 0c                	jne    80108387 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
8010837b:	c7 04 24 93 8e 10 80 	movl   $0x80108e93,(%esp)
80108382:	e8 b6 81 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80108387:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010838a:	8b 00                	mov    (%eax),%eax
8010838c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108391:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108397:	8b 55 18             	mov    0x18(%ebp),%edx
8010839a:	89 d1                	mov    %edx,%ecx
8010839c:	29 c1                	sub    %eax,%ecx
8010839e:	89 c8                	mov    %ecx,%eax
801083a0:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801083a5:	77 11                	ja     801083b8 <loaduvm+0x90>
      n = sz - i;
801083a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083aa:	8b 55 18             	mov    0x18(%ebp),%edx
801083ad:	89 d1                	mov    %edx,%ecx
801083af:	29 c1                	sub    %eax,%ecx
801083b1:	89 c8                	mov    %ecx,%eax
801083b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801083b6:	eb 07                	jmp    801083bf <loaduvm+0x97>
    else
      n = PGSIZE;
801083b8:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801083bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c2:	8b 55 14             	mov    0x14(%ebp),%edx
801083c5:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801083c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083cb:	89 04 24             	mov    %eax,(%esp)
801083ce:	e8 c5 f6 ff ff       	call   80107a98 <p2v>
801083d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801083d6:	89 54 24 0c          	mov    %edx,0xc(%esp)
801083da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801083de:	89 44 24 04          	mov    %eax,0x4(%esp)
801083e2:	8b 45 10             	mov    0x10(%ebp),%eax
801083e5:	89 04 24             	mov    %eax,(%esp)
801083e8:	e8 c9 9c ff ff       	call   801020b6 <readi>
801083ed:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801083f0:	74 07                	je     801083f9 <loaduvm+0xd1>
      return -1;
801083f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801083f7:	eb 18                	jmp    80108411 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801083f9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108400:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108403:	3b 45 18             	cmp    0x18(%ebp),%eax
80108406:	0f 82 47 ff ff ff    	jb     80108353 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010840c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108411:	83 c4 24             	add    $0x24,%esp
80108414:	5b                   	pop    %ebx
80108415:	5d                   	pop    %ebp
80108416:	c3                   	ret    

80108417 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108417:	55                   	push   %ebp
80108418:	89 e5                	mov    %esp,%ebp
8010841a:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010841d:	8b 45 10             	mov    0x10(%ebp),%eax
80108420:	85 c0                	test   %eax,%eax
80108422:	79 0a                	jns    8010842e <allocuvm+0x17>
    return 0;
80108424:	b8 00 00 00 00       	mov    $0x0,%eax
80108429:	e9 c1 00 00 00       	jmp    801084ef <allocuvm+0xd8>
  if(newsz < oldsz)
8010842e:	8b 45 10             	mov    0x10(%ebp),%eax
80108431:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108434:	73 08                	jae    8010843e <allocuvm+0x27>
    return oldsz;
80108436:	8b 45 0c             	mov    0xc(%ebp),%eax
80108439:	e9 b1 00 00 00       	jmp    801084ef <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
8010843e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108441:	05 ff 0f 00 00       	add    $0xfff,%eax
80108446:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010844b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010844e:	e9 8d 00 00 00       	jmp    801084e0 <allocuvm+0xc9>
    mem = kalloc();
80108453:	e8 ff a9 ff ff       	call   80102e57 <kalloc>
80108458:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010845b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010845f:	75 2c                	jne    8010848d <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108461:	c7 04 24 b1 8e 10 80 	movl   $0x80108eb1,(%esp)
80108468:	e8 34 7f ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010846d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108470:	89 44 24 08          	mov    %eax,0x8(%esp)
80108474:	8b 45 10             	mov    0x10(%ebp),%eax
80108477:	89 44 24 04          	mov    %eax,0x4(%esp)
8010847b:	8b 45 08             	mov    0x8(%ebp),%eax
8010847e:	89 04 24             	mov    %eax,(%esp)
80108481:	e8 6b 00 00 00       	call   801084f1 <deallocuvm>
      return 0;
80108486:	b8 00 00 00 00       	mov    $0x0,%eax
8010848b:	eb 62                	jmp    801084ef <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
8010848d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108494:	00 
80108495:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010849c:	00 
8010849d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084a0:	89 04 24             	mov    %eax,(%esp)
801084a3:	e8 96 cf ff ff       	call   8010543e <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801084a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084ab:	89 04 24             	mov    %eax,(%esp)
801084ae:	e8 d8 f5 ff ff       	call   80107a8b <v2p>
801084b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084b6:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801084bd:	00 
801084be:	89 44 24 0c          	mov    %eax,0xc(%esp)
801084c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084c9:	00 
801084ca:	89 54 24 04          	mov    %edx,0x4(%esp)
801084ce:	8b 45 08             	mov    0x8(%ebp),%eax
801084d1:	89 04 24             	mov    %eax,(%esp)
801084d4:	e8 d8 fa ff ff       	call   80107fb1 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801084d9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e3:	3b 45 10             	cmp    0x10(%ebp),%eax
801084e6:	0f 82 67 ff ff ff    	jb     80108453 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801084ec:	8b 45 10             	mov    0x10(%ebp),%eax
}
801084ef:	c9                   	leave  
801084f0:	c3                   	ret    

801084f1 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801084f1:	55                   	push   %ebp
801084f2:	89 e5                	mov    %esp,%ebp
801084f4:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801084f7:	8b 45 10             	mov    0x10(%ebp),%eax
801084fa:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084fd:	72 08                	jb     80108507 <deallocuvm+0x16>
    return oldsz;
801084ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80108502:	e9 a4 00 00 00       	jmp    801085ab <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108507:	8b 45 10             	mov    0x10(%ebp),%eax
8010850a:	05 ff 0f 00 00       	add    $0xfff,%eax
8010850f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108514:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108517:	e9 80 00 00 00       	jmp    8010859c <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010851c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108526:	00 
80108527:	89 44 24 04          	mov    %eax,0x4(%esp)
8010852b:	8b 45 08             	mov    0x8(%ebp),%eax
8010852e:	89 04 24             	mov    %eax,(%esp)
80108531:	e8 e5 f9 ff ff       	call   80107f1b <walkpgdir>
80108536:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108539:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010853d:	75 09                	jne    80108548 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
8010853f:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108546:	eb 4d                	jmp    80108595 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108548:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010854b:	8b 00                	mov    (%eax),%eax
8010854d:	83 e0 01             	and    $0x1,%eax
80108550:	84 c0                	test   %al,%al
80108552:	74 41                	je     80108595 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108554:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108557:	8b 00                	mov    (%eax),%eax
80108559:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010855e:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108561:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108565:	75 0c                	jne    80108573 <deallocuvm+0x82>
        panic("kfree");
80108567:	c7 04 24 c9 8e 10 80 	movl   $0x80108ec9,(%esp)
8010856e:	e8 ca 7f ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
80108573:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108576:	89 04 24             	mov    %eax,(%esp)
80108579:	e8 1a f5 ff ff       	call   80107a98 <p2v>
8010857e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108581:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108584:	89 04 24             	mov    %eax,(%esp)
80108587:	e8 32 a8 ff ff       	call   80102dbe <kfree>
      *pte = 0;
8010858c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010858f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108595:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010859c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010859f:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085a2:	0f 82 74 ff ff ff    	jb     8010851c <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801085a8:	8b 45 10             	mov    0x10(%ebp),%eax
}
801085ab:	c9                   	leave  
801085ac:	c3                   	ret    

801085ad <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801085ad:	55                   	push   %ebp
801085ae:	89 e5                	mov    %esp,%ebp
801085b0:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
801085b3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801085b7:	75 0c                	jne    801085c5 <freevm+0x18>
    panic("freevm: no pgdir");
801085b9:	c7 04 24 cf 8e 10 80 	movl   $0x80108ecf,(%esp)
801085c0:	e8 78 7f ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801085c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801085cc:	00 
801085cd:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801085d4:	80 
801085d5:	8b 45 08             	mov    0x8(%ebp),%eax
801085d8:	89 04 24             	mov    %eax,(%esp)
801085db:	e8 11 ff ff ff       	call   801084f1 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801085e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085e7:	eb 3c                	jmp    80108625 <freevm+0x78>
    if(pgdir[i] & PTE_P){
801085e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ec:	c1 e0 02             	shl    $0x2,%eax
801085ef:	03 45 08             	add    0x8(%ebp),%eax
801085f2:	8b 00                	mov    (%eax),%eax
801085f4:	83 e0 01             	and    $0x1,%eax
801085f7:	84 c0                	test   %al,%al
801085f9:	74 26                	je     80108621 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801085fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085fe:	c1 e0 02             	shl    $0x2,%eax
80108601:	03 45 08             	add    0x8(%ebp),%eax
80108604:	8b 00                	mov    (%eax),%eax
80108606:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010860b:	89 04 24             	mov    %eax,(%esp)
8010860e:	e8 85 f4 ff ff       	call   80107a98 <p2v>
80108613:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108616:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108619:	89 04 24             	mov    %eax,(%esp)
8010861c:	e8 9d a7 ff ff       	call   80102dbe <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108621:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108625:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010862c:	76 bb                	jbe    801085e9 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010862e:	8b 45 08             	mov    0x8(%ebp),%eax
80108631:	89 04 24             	mov    %eax,(%esp)
80108634:	e8 85 a7 ff ff       	call   80102dbe <kfree>
}
80108639:	c9                   	leave  
8010863a:	c3                   	ret    

8010863b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010863b:	55                   	push   %ebp
8010863c:	89 e5                	mov    %esp,%ebp
8010863e:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108641:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108648:	00 
80108649:	8b 45 0c             	mov    0xc(%ebp),%eax
8010864c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108650:	8b 45 08             	mov    0x8(%ebp),%eax
80108653:	89 04 24             	mov    %eax,(%esp)
80108656:	e8 c0 f8 ff ff       	call   80107f1b <walkpgdir>
8010865b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010865e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108662:	75 0c                	jne    80108670 <clearpteu+0x35>
    panic("clearpteu");
80108664:	c7 04 24 e0 8e 10 80 	movl   $0x80108ee0,(%esp)
8010866b:	e8 cd 7e ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
80108670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108673:	8b 00                	mov    (%eax),%eax
80108675:	89 c2                	mov    %eax,%edx
80108677:	83 e2 fb             	and    $0xfffffffb,%edx
8010867a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867d:	89 10                	mov    %edx,(%eax)
}
8010867f:	c9                   	leave  
80108680:	c3                   	ret    

80108681 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108681:	55                   	push   %ebp
80108682:	89 e5                	mov    %esp,%ebp
80108684:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
80108687:	e8 b9 f9 ff ff       	call   80108045 <setupkvm>
8010868c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010868f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108693:	75 0a                	jne    8010869f <copyuvm+0x1e>
    return 0;
80108695:	b8 00 00 00 00       	mov    $0x0,%eax
8010869a:	e9 f1 00 00 00       	jmp    80108790 <copyuvm+0x10f>
  for(i = 0; i < sz; i += PGSIZE){
8010869f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086a6:	e9 c0 00 00 00       	jmp    8010876b <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801086ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801086b5:	00 
801086b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801086ba:	8b 45 08             	mov    0x8(%ebp),%eax
801086bd:	89 04 24             	mov    %eax,(%esp)
801086c0:	e8 56 f8 ff ff       	call   80107f1b <walkpgdir>
801086c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
801086c8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086cc:	75 0c                	jne    801086da <copyuvm+0x59>
      panic("copyuvm: pte should exist");
801086ce:	c7 04 24 ea 8e 10 80 	movl   $0x80108eea,(%esp)
801086d5:	e8 63 7e ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
801086da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086dd:	8b 00                	mov    (%eax),%eax
801086df:	83 e0 01             	and    $0x1,%eax
801086e2:	85 c0                	test   %eax,%eax
801086e4:	75 0c                	jne    801086f2 <copyuvm+0x71>
      panic("copyuvm: page not present");
801086e6:	c7 04 24 04 8f 10 80 	movl   $0x80108f04,(%esp)
801086ed:	e8 4b 7e ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
801086f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086f5:	8b 00                	mov    (%eax),%eax
801086f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((mem = kalloc()) == 0)
801086ff:	e8 53 a7 ff ff       	call   80102e57 <kalloc>
80108704:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80108707:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010870b:	74 6f                	je     8010877c <copyuvm+0xfb>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010870d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108710:	89 04 24             	mov    %eax,(%esp)
80108713:	e8 80 f3 ff ff       	call   80107a98 <p2v>
80108718:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010871f:	00 
80108720:	89 44 24 04          	mov    %eax,0x4(%esp)
80108724:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108727:	89 04 24             	mov    %eax,(%esp)
8010872a:	e8 e2 cd ff ff       	call   80105511 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
8010872f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108732:	89 04 24             	mov    %eax,(%esp)
80108735:	e8 51 f3 ff ff       	call   80107a8b <v2p>
8010873a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010873d:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108744:	00 
80108745:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108749:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108750:	00 
80108751:	89 54 24 04          	mov    %edx,0x4(%esp)
80108755:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108758:	89 04 24             	mov    %eax,(%esp)
8010875b:	e8 51 f8 ff ff       	call   80107fb1 <mappages>
80108760:	85 c0                	test   %eax,%eax
80108762:	78 1b                	js     8010877f <copyuvm+0xfe>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108764:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010876b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010876e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108771:	0f 82 34 ff ff ff    	jb     801086ab <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
  }
  return d;
80108777:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010877a:	eb 14                	jmp    80108790 <copyuvm+0x10f>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010877c:	90                   	nop
8010877d:	eb 01                	jmp    80108780 <copyuvm+0xff>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
8010877f:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108780:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108783:	89 04 24             	mov    %eax,(%esp)
80108786:	e8 22 fe ff ff       	call   801085ad <freevm>
  return 0;
8010878b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108790:	c9                   	leave  
80108791:	c3                   	ret    

80108792 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108792:	55                   	push   %ebp
80108793:	89 e5                	mov    %esp,%ebp
80108795:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108798:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010879f:	00 
801087a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801087a3:	89 44 24 04          	mov    %eax,0x4(%esp)
801087a7:	8b 45 08             	mov    0x8(%ebp),%eax
801087aa:	89 04 24             	mov    %eax,(%esp)
801087ad:	e8 69 f7 ff ff       	call   80107f1b <walkpgdir>
801087b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801087b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b8:	8b 00                	mov    (%eax),%eax
801087ba:	83 e0 01             	and    $0x1,%eax
801087bd:	85 c0                	test   %eax,%eax
801087bf:	75 07                	jne    801087c8 <uva2ka+0x36>
    return 0;
801087c1:	b8 00 00 00 00       	mov    $0x0,%eax
801087c6:	eb 25                	jmp    801087ed <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
801087c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087cb:	8b 00                	mov    (%eax),%eax
801087cd:	83 e0 04             	and    $0x4,%eax
801087d0:	85 c0                	test   %eax,%eax
801087d2:	75 07                	jne    801087db <uva2ka+0x49>
    return 0;
801087d4:	b8 00 00 00 00       	mov    $0x0,%eax
801087d9:	eb 12                	jmp    801087ed <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
801087db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087de:	8b 00                	mov    (%eax),%eax
801087e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087e5:	89 04 24             	mov    %eax,(%esp)
801087e8:	e8 ab f2 ff ff       	call   80107a98 <p2v>
}
801087ed:	c9                   	leave  
801087ee:	c3                   	ret    

801087ef <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801087ef:	55                   	push   %ebp
801087f0:	89 e5                	mov    %esp,%ebp
801087f2:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801087f5:	8b 45 10             	mov    0x10(%ebp),%eax
801087f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801087fb:	e9 8b 00 00 00       	jmp    8010888b <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
80108800:	8b 45 0c             	mov    0xc(%ebp),%eax
80108803:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108808:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010880b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010880e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108812:	8b 45 08             	mov    0x8(%ebp),%eax
80108815:	89 04 24             	mov    %eax,(%esp)
80108818:	e8 75 ff ff ff       	call   80108792 <uva2ka>
8010881d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108820:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108824:	75 07                	jne    8010882d <copyout+0x3e>
      return -1;
80108826:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010882b:	eb 6d                	jmp    8010889a <copyout+0xab>
    n = PGSIZE - (va - va0);
8010882d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108830:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108833:	89 d1                	mov    %edx,%ecx
80108835:	29 c1                	sub    %eax,%ecx
80108837:	89 c8                	mov    %ecx,%eax
80108839:	05 00 10 00 00       	add    $0x1000,%eax
8010883e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108841:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108844:	3b 45 14             	cmp    0x14(%ebp),%eax
80108847:	76 06                	jbe    8010884f <copyout+0x60>
      n = len;
80108849:	8b 45 14             	mov    0x14(%ebp),%eax
8010884c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010884f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108852:	8b 55 0c             	mov    0xc(%ebp),%edx
80108855:	89 d1                	mov    %edx,%ecx
80108857:	29 c1                	sub    %eax,%ecx
80108859:	89 c8                	mov    %ecx,%eax
8010885b:	03 45 e8             	add    -0x18(%ebp),%eax
8010885e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108861:	89 54 24 08          	mov    %edx,0x8(%esp)
80108865:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108868:	89 54 24 04          	mov    %edx,0x4(%esp)
8010886c:	89 04 24             	mov    %eax,(%esp)
8010886f:	e8 9d cc ff ff       	call   80105511 <memmove>
    len -= n;
80108874:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108877:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010887a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010887d:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108880:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108883:	05 00 10 00 00       	add    $0x1000,%eax
80108888:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010888b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010888f:	0f 85 6b ff ff ff    	jne    80108800 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108895:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010889a:	c9                   	leave  
8010889b:	c3                   	ret    

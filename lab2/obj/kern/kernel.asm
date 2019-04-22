
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 30 11 00       	mov    $0x113000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 10 11 f0       	mov    $0xf0111000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
	cprintf("entering test_backtrace %d\n", x);
	if (x > 0)
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 08             	sub    $0x8,%esp
f0100047:	e8 03 01 00 00       	call   f010014f <__x86.get_pc_thunk.bx>
f010004c:	81 c3 bc 22 01 00    	add    $0x122bc,%ebx
		test_backtrace(x-1);
	else
		backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
}

f0100052:	c7 c2 60 40 11 f0    	mov    $0xf0114060,%edx
f0100058:	c7 c0 a0 46 11 f0    	mov    $0xf01146a0,%eax
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 ec 18 00 00       	call   f0101955 <memset>
void
i386_init(void)
{
	extern char edata[], end[];
f0100069:	e8 36 05 00 00       	call   f01005a4 <cons_init>

	// Before doing anything else, complete the ELF loading process.
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 98 fa fe ff    	lea    -0x10568(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 84 0c 00 00       	call   f0100d06 <cprintf>
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100082:	e8 b0 0a 00 00       	call   f0100b37 <mem_init>
f0100087:	83 c4 10             	add    $0x10,%esp

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010008a:	83 ec 0c             	sub    $0xc,%esp
f010008d:	6a 00                	push   $0x0
f010008f:	e8 0e 09 00 00       	call   f01009a2 <monitor>
f0100094:	83 c4 10             	add    $0x10,%esp
f0100097:	eb f1                	jmp    f010008a <i386_init+0x4a>

f0100099 <_panic>:


/*
 * Variable panicstr contains argument to first call to panic; used as flag
 * to indicate that the kernel has already called panic.
 */
f0100099:	55                   	push   %ebp
f010009a:	89 e5                	mov    %esp,%ebp
f010009c:	57                   	push   %edi
f010009d:	56                   	push   %esi
f010009e:	53                   	push   %ebx
f010009f:	83 ec 0c             	sub    $0xc,%esp
f01000a2:	e8 a8 00 00 00       	call   f010014f <__x86.get_pc_thunk.bx>
f01000a7:	81 c3 61 22 01 00    	add    $0x12261,%ebx
f01000ad:	8b 7d 10             	mov    0x10(%ebp),%edi
const char *panicstr;

/*
f01000b0:	c7 c0 a4 46 11 f0    	mov    $0xf01146a4,%eax
f01000b6:	83 38 00             	cmpl   $0x0,(%eax)
f01000b9:	74 0f                	je     f01000ca <_panic+0x31>
	panicstr = fmt;

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");

	va_start(ap, fmt);
f01000bb:	83 ec 0c             	sub    $0xc,%esp
f01000be:	6a 00                	push   $0x0
f01000c0:	e8 dd 08 00 00       	call   f01009a2 <monitor>
f01000c5:	83 c4 10             	add    $0x10,%esp
f01000c8:	eb f1                	jmp    f01000bb <_panic+0x22>
 * It prints "panic: mesg", and then enters the kernel monitor.
f01000ca:	89 38                	mov    %edi,(%eax)
_panic(const char *file, int line, const char *fmt,...)
f01000cc:	fa                   	cli    
f01000cd:	fc                   	cld    
	va_list ap;
f01000ce:	8d 75 14             	lea    0x14(%ebp),%esi

f01000d1:	83 ec 04             	sub    $0x4,%esp
f01000d4:	ff 75 0c             	pushl  0xc(%ebp)
f01000d7:	ff 75 08             	pushl  0x8(%ebp)
f01000da:	8d 83 b3 fa fe ff    	lea    -0x1054d(%ebx),%eax
f01000e0:	50                   	push   %eax
f01000e1:	e8 20 0c 00 00       	call   f0100d06 <cprintf>
	if (panicstr)
f01000e6:	83 c4 08             	add    $0x8,%esp
f01000e9:	56                   	push   %esi
f01000ea:	57                   	push   %edi
f01000eb:	e8 df 0b 00 00       	call   f0100ccf <vcprintf>
		goto dead;
f01000f0:	8d 83 ef fa fe ff    	lea    -0x10511(%ebx),%eax
f01000f6:	89 04 24             	mov    %eax,(%esp)
f01000f9:	e8 08 0c 00 00       	call   f0100d06 <cprintf>
f01000fe:	83 c4 10             	add    $0x10,%esp
f0100101:	eb b8                	jmp    f01000bb <_panic+0x22>

f0100103 <_warn>:
	cprintf("kernel panic at %s:%d: ", file, line);
	vcprintf(fmt, ap);
	cprintf("\n");
	va_end(ap);

dead:
f0100103:	55                   	push   %ebp
f0100104:	89 e5                	mov    %esp,%ebp
f0100106:	56                   	push   %esi
f0100107:	53                   	push   %ebx
f0100108:	e8 42 00 00 00       	call   f010014f <__x86.get_pc_thunk.bx>
f010010d:	81 c3 fb 21 01 00    	add    $0x121fb,%ebx
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100113:	8d 75 14             	lea    0x14(%ebp),%esi
}
f0100116:	83 ec 04             	sub    $0x4,%esp
f0100119:	ff 75 0c             	pushl  0xc(%ebp)
f010011c:	ff 75 08             	pushl  0x8(%ebp)
f010011f:	8d 83 cb fa fe ff    	lea    -0x10535(%ebx),%eax
f0100125:	50                   	push   %eax
f0100126:	e8 db 0b 00 00       	call   f0100d06 <cprintf>

f010012b:	83 c4 08             	add    $0x8,%esp
f010012e:	56                   	push   %esi
f010012f:	ff 75 10             	pushl  0x10(%ebp)
f0100132:	e8 98 0b 00 00       	call   f0100ccf <vcprintf>
/* like panic, but don't */
f0100137:	8d 83 ef fa fe ff    	lea    -0x10511(%ebx),%eax
f010013d:	89 04 24             	mov    %eax,(%esp)
f0100140:	e8 c1 0b 00 00       	call   f0100d06 <cprintf>
void
_warn(const char *file, int line, const char *fmt,...)
f0100145:	83 c4 10             	add    $0x10,%esp
f0100148:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010014b:	5b                   	pop    %ebx
f010014c:	5e                   	pop    %esi
f010014d:	5d                   	pop    %ebp
f010014e:	c3                   	ret    

f010014f <__x86.get_pc_thunk.bx>:
f010014f:	8b 1c 24             	mov    (%esp),%ebx
f0100152:	c3                   	ret    

f0100153 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100153:	55                   	push   %ebp
f0100154:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100156:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010015b:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010015c:	a8 01                	test   $0x1,%al
f010015e:	74 0b                	je     f010016b <serial_proc_data+0x18>
f0100160:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100165:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100166:	0f b6 c0             	movzbl %al,%eax
}
f0100169:	5d                   	pop    %ebp
f010016a:	c3                   	ret    
		return -1;
f010016b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100170:	eb f7                	jmp    f0100169 <serial_proc_data+0x16>

f0100172 <cons_intr>:
} cons;

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
f0100172:	55                   	push   %ebp
f0100173:	89 e5                	mov    %esp,%ebp
f0100175:	56                   	push   %esi
f0100176:	53                   	push   %ebx
f0100177:	e8 d3 ff ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f010017c:	81 c3 8c 21 01 00    	add    $0x1218c,%ebx
f0100182:	89 c6                	mov    %eax,%esi
{
	int c;

f0100184:	ff d6                	call   *%esi
f0100186:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100189:	74 2e                	je     f01001b9 <cons_intr+0x47>
	while ((c = (*proc)()) != -1) {
f010018b:	85 c0                	test   %eax,%eax
f010018d:	74 f5                	je     f0100184 <cons_intr+0x12>
		if (c == 0)
			continue;
f010018f:	8b 8b 7c 1f 00 00    	mov    0x1f7c(%ebx),%ecx
f0100195:	8d 51 01             	lea    0x1(%ecx),%edx
f0100198:	89 93 7c 1f 00 00    	mov    %edx,0x1f7c(%ebx)
f010019e:	88 84 0b 78 1d 00 00 	mov    %al,0x1d78(%ebx,%ecx,1)
		cons.buf[cons.wpos++] = c;
f01001a5:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001ab:	75 d7                	jne    f0100184 <cons_intr+0x12>
		if (cons.wpos == CONSBUFSIZE)
f01001ad:	c7 83 7c 1f 00 00 00 	movl   $0x0,0x1f7c(%ebx)
f01001b4:	00 00 00 
f01001b7:	eb cb                	jmp    f0100184 <cons_intr+0x12>
			cons.wpos = 0;
	}
f01001b9:	5b                   	pop    %ebx
f01001ba:	5e                   	pop    %esi
f01001bb:	5d                   	pop    %ebp
f01001bc:	c3                   	ret    

f01001bd <kbd_proc_data>:
kbd_proc_data(void)
f01001bd:	55                   	push   %ebp
f01001be:	89 e5                	mov    %esp,%ebp
f01001c0:	56                   	push   %esi
f01001c1:	53                   	push   %ebx
f01001c2:	e8 88 ff ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01001c7:	81 c3 41 21 01 00    	add    $0x12141,%ebx
f01001cd:	ba 64 00 00 00       	mov    $0x64,%edx
f01001d2:	ec                   	in     (%dx),%al
	stat = inb(KBSTATP);
f01001d3:	a8 01                	test   $0x1,%al
f01001d5:	0f 84 06 01 00 00    	je     f01002e1 <kbd_proc_data+0x124>
	// Ignore data from mouse.
f01001db:	a8 20                	test   $0x20,%al
f01001dd:	0f 85 05 01 00 00    	jne    f01002e8 <kbd_proc_data+0x12b>
f01001e3:	ba 60 00 00 00       	mov    $0x60,%edx
f01001e8:	ec                   	in     (%dx),%al
f01001e9:	89 c2                	mov    %eax,%edx

f01001eb:	3c e0                	cmp    $0xe0,%al
f01001ed:	0f 84 93 00 00 00    	je     f0100286 <kbd_proc_data+0xc9>
		return 0;
f01001f3:	84 c0                	test   %al,%al
f01001f5:	0f 88 a0 00 00 00    	js     f010029b <kbd_proc_data+0xde>
		return 0;
f01001fb:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f0100201:	f6 c1 40             	test   $0x40,%cl
f0100204:	74 0e                	je     f0100214 <kbd_proc_data+0x57>
		// Last character was an E0 escape; or with 0x80
f0100206:	83 c8 80             	or     $0xffffff80,%eax
f0100209:	89 c2                	mov    %eax,%edx
		data |= 0x80;
f010020b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010020e:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)

f0100214:	0f b6 d2             	movzbl %dl,%edx
f0100217:	0f b6 84 13 18 fc fe 	movzbl -0x103e8(%ebx,%edx,1),%eax
f010021e:	ff 
f010021f:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift |= shiftcode[data];
f0100225:	0f b6 8c 13 18 fb fe 	movzbl -0x104e8(%ebx,%edx,1),%ecx
f010022c:	ff 
f010022d:	31 c8                	xor    %ecx,%eax
f010022f:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)

f0100235:	89 c1                	mov    %eax,%ecx
f0100237:	83 e1 03             	and    $0x3,%ecx
f010023a:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f0100241:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100245:	0f b6 f2             	movzbl %dl,%esi
	c = charcode[shift & (CTL | SHIFT)][data];
f0100248:	a8 08                	test   $0x8,%al
f010024a:	74 0d                	je     f0100259 <kbd_proc_data+0x9c>
	if (shift & CAPSLOCK) {
f010024c:	89 f2                	mov    %esi,%edx
f010024e:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f0100251:	83 f9 19             	cmp    $0x19,%ecx
f0100254:	77 7a                	ja     f01002d0 <kbd_proc_data+0x113>
		if ('a' <= c && c <= 'z')
f0100256:	83 ee 20             	sub    $0x20,%esi
	// Ctrl-Alt-Del: reboot
f0100259:	f7 d0                	not    %eax
f010025b:	a8 06                	test   $0x6,%al
f010025d:	75 33                	jne    f0100292 <kbd_proc_data+0xd5>
f010025f:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f0100265:	75 2b                	jne    f0100292 <kbd_proc_data+0xd5>
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100267:	83 ec 0c             	sub    $0xc,%esp
f010026a:	8d 83 e5 fa fe ff    	lea    -0x1051b(%ebx),%eax
f0100270:	50                   	push   %eax
f0100271:	e8 90 0a 00 00       	call   f0100d06 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100276:	b8 03 00 00 00       	mov    $0x3,%eax
f010027b:	ba 92 00 00 00       	mov    $0x92,%edx
f0100280:	ee                   	out    %al,(%dx)
f0100281:	83 c4 10             	add    $0x10,%esp
f0100284:	eb 0c                	jmp    f0100292 <kbd_proc_data+0xd5>
		// E0 escape character
f0100286:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		shift |= E0ESC;
f010028d:	be 00 00 00 00       	mov    $0x0,%esi
	return c;
f0100292:	89 f0                	mov    %esi,%eax
f0100294:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100297:	5b                   	pop    %ebx
f0100298:	5e                   	pop    %esi
f0100299:	5d                   	pop    %ebp
f010029a:	c3                   	ret    
		// Key released
f010029b:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f01002a1:	89 ce                	mov    %ecx,%esi
f01002a3:	83 e6 40             	and    $0x40,%esi
f01002a6:	83 e0 7f             	and    $0x7f,%eax
f01002a9:	85 f6                	test   %esi,%esi
f01002ab:	0f 44 d0             	cmove  %eax,%edx
		data = (shift & E0ESC ? data : data & 0x7F);
f01002ae:	0f b6 d2             	movzbl %dl,%edx
f01002b1:	0f b6 84 13 18 fc fe 	movzbl -0x103e8(%ebx,%edx,1),%eax
f01002b8:	ff 
f01002b9:	83 c8 40             	or     $0x40,%eax
f01002bc:	0f b6 c0             	movzbl %al,%eax
f01002bf:	f7 d0                	not    %eax
f01002c1:	21 c8                	and    %ecx,%eax
f01002c3:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		shift &= ~(shiftcode[data] | E0ESC);
f01002c9:	be 00 00 00 00       	mov    $0x0,%esi
f01002ce:	eb c2                	jmp    f0100292 <kbd_proc_data+0xd5>
			c += 'A' - 'a';
f01002d0:	83 ea 41             	sub    $0x41,%edx
		else if ('A' <= c && c <= 'Z')
f01002d3:	8d 4e 20             	lea    0x20(%esi),%ecx
f01002d6:	83 fa 1a             	cmp    $0x1a,%edx
f01002d9:	0f 42 f1             	cmovb  %ecx,%esi
f01002dc:	e9 78 ff ff ff       	jmp    f0100259 <kbd_proc_data+0x9c>
	if ((stat & KBS_DIB) == 0)
f01002e1:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01002e6:	eb aa                	jmp    f0100292 <kbd_proc_data+0xd5>
	if (stat & KBS_TERR)
f01002e8:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01002ed:	eb a3                	jmp    f0100292 <kbd_proc_data+0xd5>

f01002ef <cons_putc>:
	return 0;
}

// output a character to the console
static void
cons_putc(int c)
f01002ef:	55                   	push   %ebp
f01002f0:	89 e5                	mov    %esp,%ebp
f01002f2:	57                   	push   %edi
f01002f3:	56                   	push   %esi
f01002f4:	53                   	push   %ebx
f01002f5:	83 ec 1c             	sub    $0x1c,%esp
f01002f8:	e8 52 fe ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01002fd:	81 c3 0b 20 01 00    	add    $0x1200b,%ebx
f0100303:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100306:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010030b:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100310:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100315:	eb 09                	jmp    f0100320 <cons_putc+0x31>
f0100317:	89 ca                	mov    %ecx,%edx
f0100319:	ec                   	in     (%dx),%al
f010031a:	ec                   	in     (%dx),%al
f010031b:	ec                   	in     (%dx),%al
f010031c:	ec                   	in     (%dx),%al
	     i++)
f010031d:	83 c6 01             	add    $0x1,%esi
f0100320:	89 fa                	mov    %edi,%edx
f0100322:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100323:	a8 20                	test   $0x20,%al
f0100325:	75 08                	jne    f010032f <cons_putc+0x40>
f0100327:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010032d:	7e e8                	jle    f0100317 <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f010032f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100332:	89 f8                	mov    %edi,%eax
f0100334:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100337:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010033c:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010033d:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100342:	bf 79 03 00 00       	mov    $0x379,%edi
f0100347:	b9 84 00 00 00       	mov    $0x84,%ecx
f010034c:	eb 09                	jmp    f0100357 <cons_putc+0x68>
f010034e:	89 ca                	mov    %ecx,%edx
f0100350:	ec                   	in     (%dx),%al
f0100351:	ec                   	in     (%dx),%al
f0100352:	ec                   	in     (%dx),%al
f0100353:	ec                   	in     (%dx),%al
f0100354:	83 c6 01             	add    $0x1,%esi
f0100357:	89 fa                	mov    %edi,%edx
f0100359:	ec                   	in     (%dx),%al
f010035a:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100360:	7f 04                	jg     f0100366 <cons_putc+0x77>
f0100362:	84 c0                	test   %al,%al
f0100364:	79 e8                	jns    f010034e <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100366:	ba 78 03 00 00       	mov    $0x378,%edx
f010036b:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f010036f:	ee                   	out    %al,(%dx)
f0100370:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100375:	b8 0d 00 00 00       	mov    $0xd,%eax
f010037a:	ee                   	out    %al,(%dx)
f010037b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100380:	ee                   	out    %al,(%dx)
	if (!color_flag) color_flag = 0x0700;
f0100381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100384:	89 fa                	mov    %edi,%edx
f0100386:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
	if (!(c & ~0xFF))
f010038c:	89 f8                	mov    %edi,%eax
f010038e:	80 cc 07             	or     $0x7,%ah
f0100391:	85 d2                	test   %edx,%edx
f0100393:	0f 45 c7             	cmovne %edi,%eax
f0100396:	89 45 e4             	mov    %eax,-0x1c(%ebp)

f0100399:	0f b6 c0             	movzbl %al,%eax
f010039c:	83 f8 09             	cmp    $0x9,%eax
f010039f:	0f 84 b9 00 00 00    	je     f010045e <cons_putc+0x16f>
f01003a5:	83 f8 09             	cmp    $0x9,%eax
f01003a8:	7e 74                	jle    f010041e <cons_putc+0x12f>
f01003aa:	83 f8 0a             	cmp    $0xa,%eax
f01003ad:	0f 84 9e 00 00 00    	je     f0100451 <cons_putc+0x162>
f01003b3:	83 f8 0d             	cmp    $0xd,%eax
f01003b6:	0f 85 d9 00 00 00    	jne    f0100495 <cons_putc+0x1a6>
	case '\r':
f01003bc:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f01003c3:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003c9:	c1 e8 16             	shr    $0x16,%eax
f01003cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003cf:	c1 e0 04             	shl    $0x4,%eax
f01003d2:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	// What is the purpose of this?
f01003d9:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f01003e0:	cf 07 
f01003e2:	0f 87 d4 00 00 00    	ja     f01004bc <cons_putc+0x1cd>
	/* move that little blinky thing */
f01003e8:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f01003ee:	b8 0e 00 00 00       	mov    $0xe,%eax
f01003f3:	89 ca                	mov    %ecx,%edx
f01003f5:	ee                   	out    %al,(%dx)
	outb(addr_6845, 14);
f01003f6:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f01003fd:	8d 71 01             	lea    0x1(%ecx),%esi
f0100400:	89 d8                	mov    %ebx,%eax
f0100402:	66 c1 e8 08          	shr    $0x8,%ax
f0100406:	89 f2                	mov    %esi,%edx
f0100408:	ee                   	out    %al,(%dx)
f0100409:	b8 0f 00 00 00       	mov    $0xf,%eax
f010040e:	89 ca                	mov    %ecx,%edx
f0100410:	ee                   	out    %al,(%dx)
f0100411:	89 d8                	mov    %ebx,%eax
f0100413:	89 f2                	mov    %esi,%edx
f0100415:	ee                   	out    %al,(%dx)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
f0100416:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100419:	5b                   	pop    %ebx
f010041a:	5e                   	pop    %esi
f010041b:	5f                   	pop    %edi
f010041c:	5d                   	pop    %ebp
f010041d:	c3                   	ret    

f010041e:	83 f8 08             	cmp    $0x8,%eax
f0100421:	75 72                	jne    f0100495 <cons_putc+0x1a6>
	case '\b':
f0100423:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f010042a:	66 85 c0             	test   %ax,%ax
f010042d:	74 b9                	je     f01003e8 <cons_putc+0xf9>
		if (crt_pos > 0) {
f010042f:	83 e8 01             	sub    $0x1,%eax
f0100432:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_pos--;
f0100439:	0f b7 c0             	movzwl %ax,%eax
f010043c:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f0100440:	b2 00                	mov    $0x0,%dl
f0100442:	83 ca 20             	or     $0x20,%edx
f0100445:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f010044b:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f010044f:	eb 88                	jmp    f01003d9 <cons_putc+0xea>
	case '\n':
f0100451:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f0100458:	50 
f0100459:	e9 5e ff ff ff       	jmp    f01003bc <cons_putc+0xcd>
	case '\t':
f010045e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100463:	e8 87 fe ff ff       	call   f01002ef <cons_putc>
		cons_putc(' ');
f0100468:	b8 20 00 00 00       	mov    $0x20,%eax
f010046d:	e8 7d fe ff ff       	call   f01002ef <cons_putc>
		cons_putc(' ');
f0100472:	b8 20 00 00 00       	mov    $0x20,%eax
f0100477:	e8 73 fe ff ff       	call   f01002ef <cons_putc>
		cons_putc(' ');
f010047c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100481:	e8 69 fe ff ff       	call   f01002ef <cons_putc>
		cons_putc(' ');
f0100486:	b8 20 00 00 00       	mov    $0x20,%eax
f010048b:	e8 5f fe ff ff       	call   f01002ef <cons_putc>
f0100490:	e9 44 ff ff ff       	jmp    f01003d9 <cons_putc+0xea>
	default:
f0100495:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f010049c:	8d 50 01             	lea    0x1(%eax),%edx
f010049f:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f01004a6:	0f b7 c0             	movzwl %ax,%eax
f01004a9:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f01004af:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f01004b3:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004b7:	e9 1d ff ff ff       	jmp    f01003d9 <cons_putc+0xea>

f01004bc:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f01004c2:	83 ec 04             	sub    $0x4,%esp
f01004c5:	68 00 0f 00 00       	push   $0xf00
f01004ca:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004d0:	52                   	push   %edx
f01004d1:	50                   	push   %eax
f01004d2:	e8 cb 14 00 00       	call   f01019a2 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004d7:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f01004dd:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004e3:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004e9:	83 c4 10             	add    $0x10,%esp
f01004ec:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01004f1:	83 c0 02             	add    $0x2,%eax
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004f4:	39 d0                	cmp    %edx,%eax
f01004f6:	75 f4                	jne    f01004ec <cons_putc+0x1fd>
			crt_buf[i] = 0x0700 | ' ';
f01004f8:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f01004ff:	50 
f0100500:	e9 e3 fe ff ff       	jmp    f01003e8 <cons_putc+0xf9>

f0100505 <serial_intr>:
{
f0100505:	e8 e7 01 00 00       	call   f01006f1 <__x86.get_pc_thunk.ax>
f010050a:	05 fe 1d 01 00       	add    $0x11dfe,%eax
	if (serial_exists)
f010050f:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100516:	75 02                	jne    f010051a <serial_intr+0x15>
f0100518:	f3 c3                	repz ret 
{
f010051a:	55                   	push   %ebp
f010051b:	89 e5                	mov    %esp,%ebp
f010051d:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100520:	8d 80 4b de fe ff    	lea    -0x121b5(%eax),%eax
f0100526:	e8 47 fc ff ff       	call   f0100172 <cons_intr>
}
f010052b:	c9                   	leave  
f010052c:	c3                   	ret    

f010052d <kbd_intr>:
kbd_intr(void)
f010052d:	55                   	push   %ebp
f010052e:	89 e5                	mov    %esp,%ebp
f0100530:	83 ec 08             	sub    $0x8,%esp
f0100533:	e8 b9 01 00 00       	call   f01006f1 <__x86.get_pc_thunk.ax>
f0100538:	05 d0 1d 01 00       	add    $0x11dd0,%eax
{
f010053d:	8d 80 b5 de fe ff    	lea    -0x1214b(%eax),%eax
f0100543:	e8 2a fc ff ff       	call   f0100172 <cons_intr>
	cons_intr(kbd_proc_data);
f0100548:	c9                   	leave  
f0100549:	c3                   	ret    

f010054a <cons_getc>:
cons_getc(void)
f010054a:	55                   	push   %ebp
f010054b:	89 e5                	mov    %esp,%ebp
f010054d:	53                   	push   %ebx
f010054e:	83 ec 04             	sub    $0x4,%esp
f0100551:	e8 f9 fb ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100556:	81 c3 b2 1d 01 00    	add    $0x11db2,%ebx
	// (e.g., when called from the kernel monitor).
f010055c:	e8 a4 ff ff ff       	call   f0100505 <serial_intr>
	serial_intr();
f0100561:	e8 c7 ff ff ff       	call   f010052d <kbd_intr>
	// grab the next character from the input buffer.
f0100566:	8b 93 78 1f 00 00    	mov    0x1f78(%ebx),%edx
	}
f010056c:	b8 00 00 00 00       	mov    $0x0,%eax
	// grab the next character from the input buffer.
f0100571:	3b 93 7c 1f 00 00    	cmp    0x1f7c(%ebx),%edx
f0100577:	74 19                	je     f0100592 <cons_getc+0x48>
	if (cons.rpos != cons.wpos) {
f0100579:	8d 4a 01             	lea    0x1(%edx),%ecx
f010057c:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
f0100582:	0f b6 84 13 78 1d 00 	movzbl 0x1d78(%ebx,%edx,1),%eax
f0100589:	00 
		c = cons.buf[cons.rpos++];
f010058a:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100590:	74 06                	je     f0100598 <cons_getc+0x4e>
	return 0;
f0100592:	83 c4 04             	add    $0x4,%esp
f0100595:	5b                   	pop    %ebx
f0100596:	5d                   	pop    %ebp
f0100597:	c3                   	ret    
		if (cons.rpos == CONSBUFSIZE)
f0100598:	c7 83 78 1f 00 00 00 	movl   $0x0,0x1f78(%ebx)
f010059f:	00 00 00 
f01005a2:	eb ee                	jmp    f0100592 <cons_getc+0x48>

f01005a4 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
f01005a4:	55                   	push   %ebp
f01005a5:	89 e5                	mov    %esp,%ebp
f01005a7:	57                   	push   %edi
f01005a8:	56                   	push   %esi
f01005a9:	53                   	push   %ebx
f01005aa:	83 ec 1c             	sub    $0x1c,%esp
f01005ad:	e8 9d fb ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01005b2:	81 c3 56 1d 01 00    	add    $0x11d56,%ebx
	was = *cp;
f01005b8:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01005bf:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005c6:	5a a5 
	if (*cp != 0xA55A) {
f01005c8:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005cf:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005d3:	0f 84 bc 00 00 00    	je     f0100695 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f01005d9:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f01005e0:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005e3:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f01005ea:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f01005f0:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005f5:	89 fa                	mov    %edi,%edx
f01005f7:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005f8:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005fb:	89 ca                	mov    %ecx,%edx
f01005fd:	ec                   	in     (%dx),%al
f01005fe:	0f b6 f0             	movzbl %al,%esi
f0100601:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100604:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100609:	89 fa                	mov    %edi,%edx
f010060b:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010060c:	89 ca                	mov    %ecx,%edx
f010060e:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010060f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100612:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f0100618:	0f b6 c0             	movzbl %al,%eax
f010061b:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010061d:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100624:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100629:	89 c8                	mov    %ecx,%eax
f010062b:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100630:	ee                   	out    %al,(%dx)
f0100631:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100636:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010063b:	89 fa                	mov    %edi,%edx
f010063d:	ee                   	out    %al,(%dx)
f010063e:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100643:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100648:	ee                   	out    %al,(%dx)
f0100649:	be f9 03 00 00       	mov    $0x3f9,%esi
f010064e:	89 c8                	mov    %ecx,%eax
f0100650:	89 f2                	mov    %esi,%edx
f0100652:	ee                   	out    %al,(%dx)
f0100653:	b8 03 00 00 00       	mov    $0x3,%eax
f0100658:	89 fa                	mov    %edi,%edx
f010065a:	ee                   	out    %al,(%dx)
f010065b:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100660:	89 c8                	mov    %ecx,%eax
f0100662:	ee                   	out    %al,(%dx)
f0100663:	b8 01 00 00 00       	mov    $0x1,%eax
f0100668:	89 f2                	mov    %esi,%edx
f010066a:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010066b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100670:	ec                   	in     (%dx),%al
f0100671:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100673:	3c ff                	cmp    $0xff,%al
f0100675:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f010067c:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100681:	ec                   	in     (%dx),%al
f0100682:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100687:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

f0100688:	80 f9 ff             	cmp    $0xff,%cl
f010068b:	74 25                	je     f01006b2 <cons_init+0x10e>
	if (!serial_exists)
		cprintf("Serial port does not exist!\n");
f010068d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100690:	5b                   	pop    %ebx
f0100691:	5e                   	pop    %esi
f0100692:	5f                   	pop    %edi
f0100693:	5d                   	pop    %ebp
f0100694:	c3                   	ret    
		*cp = was;
f0100695:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010069c:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f01006a3:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006a6:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f01006ad:	e9 38 ff ff ff       	jmp    f01005ea <cons_init+0x46>
	if (!serial_exists)
f01006b2:	83 ec 0c             	sub    $0xc,%esp
f01006b5:	8d 83 f1 fa fe ff    	lea    -0x1050f(%ebx),%eax
f01006bb:	50                   	push   %eax
f01006bc:	e8 45 06 00 00       	call   f0100d06 <cprintf>
f01006c1:	83 c4 10             	add    $0x10,%esp
		cprintf("Serial port does not exist!\n");
f01006c4:	eb c7                	jmp    f010068d <cons_init+0xe9>

f01006c6 <cputchar>:


// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
f01006c6:	55                   	push   %ebp
f01006c7:	89 e5                	mov    %esp,%ebp
f01006c9:	83 ec 08             	sub    $0x8,%esp
{
f01006cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01006cf:	e8 1b fc ff ff       	call   f01002ef <cons_putc>
	cons_putc(c);
f01006d4:	c9                   	leave  
f01006d5:	c3                   	ret    

f01006d6 <getchar>:
}

int
getchar(void)
f01006d6:	55                   	push   %ebp
f01006d7:	89 e5                	mov    %esp,%ebp
f01006d9:	83 ec 08             	sub    $0x8,%esp
{
	int c;

f01006dc:	e8 69 fe ff ff       	call   f010054a <cons_getc>
f01006e1:	85 c0                	test   %eax,%eax
f01006e3:	74 f7                	je     f01006dc <getchar+0x6>
	while ((c = cons_getc()) == 0)
		/* do nothing */;
	return c;
f01006e5:	c9                   	leave  
f01006e6:	c3                   	ret    

f01006e7 <iscons>:
}

int
iscons(int fdnum)
f01006e7:	55                   	push   %ebp
f01006e8:	89 e5                	mov    %esp,%ebp
{
	// used by readline
	return 1;
f01006ea:	b8 01 00 00 00       	mov    $0x1,%eax
f01006ef:	5d                   	pop    %ebp
f01006f0:	c3                   	ret    

f01006f1 <__x86.get_pc_thunk.ax>:
f01006f1:	8b 04 24             	mov    (%esp),%eax
f01006f4:	c3                   	ret    

f01006f5 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006f5:	55                   	push   %ebp
f01006f6:	89 e5                	mov    %esp,%ebp
f01006f8:	56                   	push   %esi
f01006f9:	53                   	push   %ebx
f01006fa:	e8 50 fa ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01006ff:	81 c3 09 1c 01 00    	add    $0x11c09,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100705:	83 ec 04             	sub    $0x4,%esp
f0100708:	8d 83 18 fd fe ff    	lea    -0x102e8(%ebx),%eax
f010070e:	50                   	push   %eax
f010070f:	8d 83 36 fd fe ff    	lea    -0x102ca(%ebx),%eax
f0100715:	50                   	push   %eax
f0100716:	8d b3 3b fd fe ff    	lea    -0x102c5(%ebx),%esi
f010071c:	56                   	push   %esi
f010071d:	e8 e4 05 00 00       	call   f0100d06 <cprintf>
f0100722:	83 c4 0c             	add    $0xc,%esp
f0100725:	8d 83 14 fe fe ff    	lea    -0x101ec(%ebx),%eax
f010072b:	50                   	push   %eax
f010072c:	8d 83 44 fd fe ff    	lea    -0x102bc(%ebx),%eax
f0100732:	50                   	push   %eax
f0100733:	56                   	push   %esi
f0100734:	e8 cd 05 00 00       	call   f0100d06 <cprintf>
f0100739:	83 c4 0c             	add    $0xc,%esp
f010073c:	8d 83 4d fd fe ff    	lea    -0x102b3(%ebx),%eax
f0100742:	50                   	push   %eax
f0100743:	8d 83 6b fd fe ff    	lea    -0x10295(%ebx),%eax
f0100749:	50                   	push   %eax
f010074a:	56                   	push   %esi
f010074b:	e8 b6 05 00 00       	call   f0100d06 <cprintf>
	return 0;
}
f0100750:	b8 00 00 00 00       	mov    $0x0,%eax
f0100755:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100758:	5b                   	pop    %ebx
f0100759:	5e                   	pop    %esi
f010075a:	5d                   	pop    %ebp
f010075b:	c3                   	ret    

f010075c <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010075c:	55                   	push   %ebp
f010075d:	89 e5                	mov    %esp,%ebp
f010075f:	57                   	push   %edi
f0100760:	56                   	push   %esi
f0100761:	53                   	push   %ebx
f0100762:	83 ec 18             	sub    $0x18,%esp
f0100765:	e8 e5 f9 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f010076a:	81 c3 9e 1b 01 00    	add    $0x11b9e,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100770:	8d 83 75 fd fe ff    	lea    -0x1028b(%ebx),%eax
f0100776:	50                   	push   %eax
f0100777:	e8 8a 05 00 00       	call   f0100d06 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010077c:	83 c4 08             	add    $0x8,%esp
f010077f:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f0100785:	8d 83 3c fe fe ff    	lea    -0x101c4(%ebx),%eax
f010078b:	50                   	push   %eax
f010078c:	e8 75 05 00 00       	call   f0100d06 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100791:	83 c4 0c             	add    $0xc,%esp
f0100794:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f010079a:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007a0:	50                   	push   %eax
f01007a1:	57                   	push   %edi
f01007a2:	8d 83 64 fe fe ff    	lea    -0x1019c(%ebx),%eax
f01007a8:	50                   	push   %eax
f01007a9:	e8 58 05 00 00       	call   f0100d06 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007ae:	83 c4 0c             	add    $0xc,%esp
f01007b1:	c7 c0 99 1d 10 f0    	mov    $0xf0101d99,%eax
f01007b7:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007bd:	52                   	push   %edx
f01007be:	50                   	push   %eax
f01007bf:	8d 83 88 fe fe ff    	lea    -0x10178(%ebx),%eax
f01007c5:	50                   	push   %eax
f01007c6:	e8 3b 05 00 00       	call   f0100d06 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007cb:	83 c4 0c             	add    $0xc,%esp
f01007ce:	c7 c0 60 40 11 f0    	mov    $0xf0114060,%eax
f01007d4:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007da:	52                   	push   %edx
f01007db:	50                   	push   %eax
f01007dc:	8d 83 ac fe fe ff    	lea    -0x10154(%ebx),%eax
f01007e2:	50                   	push   %eax
f01007e3:	e8 1e 05 00 00       	call   f0100d06 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007e8:	83 c4 0c             	add    $0xc,%esp
f01007eb:	c7 c6 a0 46 11 f0    	mov    $0xf01146a0,%esi
f01007f1:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01007f7:	50                   	push   %eax
f01007f8:	56                   	push   %esi
f01007f9:	8d 83 d0 fe fe ff    	lea    -0x10130(%ebx),%eax
f01007ff:	50                   	push   %eax
f0100800:	e8 01 05 00 00       	call   f0100d06 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100805:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100808:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f010080e:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100810:	c1 fe 0a             	sar    $0xa,%esi
f0100813:	56                   	push   %esi
f0100814:	8d 83 f4 fe fe ff    	lea    -0x1010c(%ebx),%eax
f010081a:	50                   	push   %eax
f010081b:	e8 e6 04 00 00       	call   f0100d06 <cprintf>
	return 0;
}
f0100820:	b8 00 00 00 00       	mov    $0x0,%eax
f0100825:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100828:	5b                   	pop    %ebx
f0100829:	5e                   	pop    %esi
f010082a:	5f                   	pop    %edi
f010082b:	5d                   	pop    %ebp
f010082c:	c3                   	ret    

f010082d <backtrace>:
	return 0;
}

int
backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010082d:	55                   	push   %ebp
f010082e:	89 e5                	mov    %esp,%ebp
f0100830:	57                   	push   %edi
f0100831:	56                   	push   %esi
f0100832:	53                   	push   %ebx
f0100833:	83 ec 58             	sub    $0x58,%esp
f0100836:	e8 14 f9 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f010083b:	81 c3 cd 1a 01 00    	add    $0x11acd,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100841:	89 e8                	mov    %ebp,%eax
  uint32_t* ebp = (uint32_t*) read_ebp();
f0100843:	89 c7                	mov    %eax,%edi
  cprintf("Stack backtrace:\n");
f0100845:	8d 83 8e fd fe ff    	lea    -0x10272(%ebx),%eax
f010084b:	50                   	push   %eax
f010084c:	e8 b5 04 00 00       	call   f0100d06 <cprintf>
  while (ebp) {
f0100851:	83 c4 10             	add    $0x10,%esp
    uint32_t eip = ebp[1];
    cprintf("ebp %x  eip %x  args", ebp, eip);
f0100854:	8d 83 a0 fd fe ff    	lea    -0x10260(%ebx),%eax
f010085a:	89 45 b8             	mov    %eax,-0x48(%ebp)
    int i;
    for (i = 2; i <= 6; ++i)
      cprintf(" %08.x", ebp[i]);
f010085d:	8d 83 b5 fd fe ff    	lea    -0x1024b(%ebx),%eax
f0100863:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  while (ebp) {
f0100866:	e9 83 00 00 00       	jmp    f01008ee <backtrace+0xc1>
    uint32_t eip = ebp[1];
f010086b:	8b 47 04             	mov    0x4(%edi),%eax
f010086e:	89 45 c0             	mov    %eax,-0x40(%ebp)
    cprintf("ebp %x  eip %x  args", ebp, eip);
f0100871:	83 ec 04             	sub    $0x4,%esp
f0100874:	50                   	push   %eax
f0100875:	57                   	push   %edi
f0100876:	ff 75 b8             	pushl  -0x48(%ebp)
f0100879:	e8 88 04 00 00       	call   f0100d06 <cprintf>
f010087e:	8d 77 08             	lea    0x8(%edi),%esi
f0100881:	8d 47 1c             	lea    0x1c(%edi),%eax
f0100884:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100887:	83 c4 10             	add    $0x10,%esp
f010088a:	89 7d bc             	mov    %edi,-0x44(%ebp)
f010088d:	8b 7d b4             	mov    -0x4c(%ebp),%edi
      cprintf(" %08.x", ebp[i]);
f0100890:	83 ec 08             	sub    $0x8,%esp
f0100893:	ff 36                	pushl  (%esi)
f0100895:	57                   	push   %edi
f0100896:	e8 6b 04 00 00       	call   f0100d06 <cprintf>
f010089b:	83 c6 04             	add    $0x4,%esi
    for (i = 2; i <= 6; ++i)
f010089e:	83 c4 10             	add    $0x10,%esp
f01008a1:	3b 75 c4             	cmp    -0x3c(%ebp),%esi
f01008a4:	75 ea                	jne    f0100890 <backtrace+0x63>
f01008a6:	8b 7d bc             	mov    -0x44(%ebp),%edi
    cprintf("\n");
f01008a9:	83 ec 0c             	sub    $0xc,%esp
f01008ac:	8d 83 ef fa fe ff    	lea    -0x10511(%ebx),%eax
f01008b2:	50                   	push   %eax
f01008b3:	e8 4e 04 00 00       	call   f0100d06 <cprintf>
    struct Eipdebuginfo info;
    debuginfo_eip(eip, &info);
f01008b8:	83 c4 08             	add    $0x8,%esp
f01008bb:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008be:	50                   	push   %eax
f01008bf:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01008c2:	56                   	push   %esi
f01008c3:	e8 42 05 00 00       	call   f0100e0a <debuginfo_eip>
    cprintf("\t%s:%d: %.*s+%d\n", 
f01008c8:	83 c4 08             	add    $0x8,%esp
f01008cb:	89 f0                	mov    %esi,%eax
f01008cd:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01008d0:	50                   	push   %eax
f01008d1:	ff 75 d8             	pushl  -0x28(%ebp)
f01008d4:	ff 75 dc             	pushl  -0x24(%ebp)
f01008d7:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008da:	ff 75 d0             	pushl  -0x30(%ebp)
f01008dd:	8d 83 bc fd fe ff    	lea    -0x10244(%ebx),%eax
f01008e3:	50                   	push   %eax
f01008e4:	e8 1d 04 00 00       	call   f0100d06 <cprintf>
      info.eip_file, info.eip_line,
      info.eip_fn_namelen, info.eip_fn_name,
      eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
    ebp = (uint32_t*) *ebp;
f01008e9:	8b 3f                	mov    (%edi),%edi
f01008eb:	83 c4 20             	add    $0x20,%esp
  while (ebp) {
f01008ee:	85 ff                	test   %edi,%edi
f01008f0:	0f 85 75 ff ff ff    	jne    f010086b <backtrace+0x3e>
  }
  return 0;
}
f01008f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01008fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008fe:	5b                   	pop    %ebx
f01008ff:	5e                   	pop    %esi
f0100900:	5f                   	pop    %edi
f0100901:	5d                   	pop    %ebp
f0100902:	c3                   	ret    

f0100903 <mon_backtrace>:
{
f0100903:	55                   	push   %ebp
f0100904:	89 e5                	mov    %esp,%ebp
f0100906:	57                   	push   %edi
f0100907:	56                   	push   %esi
f0100908:	53                   	push   %ebx
f0100909:	83 ec 28             	sub    $0x28,%esp
f010090c:	e8 3e f8 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100911:	81 c3 f7 19 01 00    	add    $0x119f7,%ebx
f0100917:	89 e8                	mov    %ebp,%eax
	uint32_t* ebp = (uint32_t *) read_ebp();
f0100919:	89 c7                	mov    %eax,%edi
	cprintf("Stack backtrace:\n");
f010091b:	8d 83 8e fd fe ff    	lea    -0x10272(%ebx),%eax
f0100921:	50                   	push   %eax
f0100922:	e8 df 03 00 00       	call   f0100d06 <cprintf>
	while (ebp) {
f0100927:	83 c4 10             	add    $0x10,%esp
		cprintf("ebp %x  eip %x  args", ebp, *(ebp+1));
f010092a:	8d 83 a0 fd fe ff    	lea    -0x10260(%ebx),%eax
f0100930:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		cprintf(" %x", *(ebp+2));
f0100933:	8d b3 cd fd fe ff    	lea    -0x10233(%ebx),%esi
	while (ebp) {
f0100939:	eb 56                	jmp    f0100991 <mon_backtrace+0x8e>
		cprintf("ebp %x  eip %x  args", ebp, *(ebp+1));
f010093b:	83 ec 04             	sub    $0x4,%esp
f010093e:	ff 77 04             	pushl  0x4(%edi)
f0100941:	57                   	push   %edi
f0100942:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100945:	e8 bc 03 00 00       	call   f0100d06 <cprintf>
		cprintf(" %x", *(ebp+2));
f010094a:	83 c4 08             	add    $0x8,%esp
f010094d:	ff 77 08             	pushl  0x8(%edi)
f0100950:	56                   	push   %esi
f0100951:	e8 b0 03 00 00       	call   f0100d06 <cprintf>
		cprintf(" %x", *(ebp+3));
f0100956:	83 c4 08             	add    $0x8,%esp
f0100959:	ff 77 0c             	pushl  0xc(%edi)
f010095c:	56                   	push   %esi
f010095d:	e8 a4 03 00 00       	call   f0100d06 <cprintf>
		cprintf(" %x", *(ebp+4));
f0100962:	83 c4 08             	add    $0x8,%esp
f0100965:	ff 77 10             	pushl  0x10(%edi)
f0100968:	56                   	push   %esi
f0100969:	e8 98 03 00 00       	call   f0100d06 <cprintf>
		cprintf(" %x", *(ebp+5));
f010096e:	83 c4 08             	add    $0x8,%esp
f0100971:	ff 77 14             	pushl  0x14(%edi)
f0100974:	56                   	push   %esi
f0100975:	e8 8c 03 00 00       	call   f0100d06 <cprintf>
		cprintf(" %x\n", *(ebp+6));
f010097a:	83 c4 08             	add    $0x8,%esp
f010097d:	ff 77 18             	pushl  0x18(%edi)
f0100980:	8d 83 d1 fd fe ff    	lea    -0x1022f(%ebx),%eax
f0100986:	50                   	push   %eax
f0100987:	e8 7a 03 00 00       	call   f0100d06 <cprintf>
		ebp = (uint32_t*) *ebp;		
f010098c:	8b 3f                	mov    (%edi),%edi
f010098e:	83 c4 10             	add    $0x10,%esp
	while (ebp) {
f0100991:	85 ff                	test   %edi,%edi
f0100993:	75 a6                	jne    f010093b <mon_backtrace+0x38>
}
f0100995:	b8 00 00 00 00       	mov    $0x0,%eax
f010099a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010099d:	5b                   	pop    %ebx
f010099e:	5e                   	pop    %esi
f010099f:	5f                   	pop    %edi
f01009a0:	5d                   	pop    %ebp
f01009a1:	c3                   	ret    

f01009a2 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009a2:	55                   	push   %ebp
f01009a3:	89 e5                	mov    %esp,%ebp
f01009a5:	57                   	push   %edi
f01009a6:	56                   	push   %esi
f01009a7:	53                   	push   %ebx
f01009a8:	83 ec 68             	sub    $0x68,%esp
f01009ab:	e8 9f f7 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01009b0:	81 c3 58 19 01 00    	add    $0x11958,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009b6:	8d 83 20 ff fe ff    	lea    -0x100e0(%ebx),%eax
f01009bc:	50                   	push   %eax
f01009bd:	e8 44 03 00 00       	call   f0100d06 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009c2:	8d 83 44 ff fe ff    	lea    -0x100bc(%ebx),%eax
f01009c8:	89 04 24             	mov    %eax,(%esp)
f01009cb:	e8 36 03 00 00       	call   f0100d06 <cprintf>
f01009d0:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f01009d3:	8d bb da fd fe ff    	lea    -0x10226(%ebx),%edi
f01009d9:	eb 4a                	jmp    f0100a25 <monitor+0x83>
f01009db:	83 ec 08             	sub    $0x8,%esp
f01009de:	0f be c0             	movsbl %al,%eax
f01009e1:	50                   	push   %eax
f01009e2:	57                   	push   %edi
f01009e3:	e8 30 0f 00 00       	call   f0101918 <strchr>
f01009e8:	83 c4 10             	add    $0x10,%esp
f01009eb:	85 c0                	test   %eax,%eax
f01009ed:	74 08                	je     f01009f7 <monitor+0x55>
			*buf++ = 0;
f01009ef:	c6 06 00             	movb   $0x0,(%esi)
f01009f2:	8d 76 01             	lea    0x1(%esi),%esi
f01009f5:	eb 79                	jmp    f0100a70 <monitor+0xce>
		if (*buf == 0)
f01009f7:	80 3e 00             	cmpb   $0x0,(%esi)
f01009fa:	74 7f                	je     f0100a7b <monitor+0xd9>
		if (argc == MAXARGS-1) {
f01009fc:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f0100a00:	74 0f                	je     f0100a11 <monitor+0x6f>
		argv[argc++] = buf;
f0100a02:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a05:	8d 48 01             	lea    0x1(%eax),%ecx
f0100a08:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100a0b:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f0100a0f:	eb 44                	jmp    f0100a55 <monitor+0xb3>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a11:	83 ec 08             	sub    $0x8,%esp
f0100a14:	6a 10                	push   $0x10
f0100a16:	8d 83 df fd fe ff    	lea    -0x10221(%ebx),%eax
f0100a1c:	50                   	push   %eax
f0100a1d:	e8 e4 02 00 00       	call   f0100d06 <cprintf>
f0100a22:	83 c4 10             	add    $0x10,%esp
	//cprintf("%m%s\n%m%s\n%m%s\n", 0x0100, "blue", 0x0200, "green", 0x0400, "red");

	while (1) {
		buf = readline("K> ");
f0100a25:	8d 83 d6 fd fe ff    	lea    -0x1022a(%ebx),%eax
f0100a2b:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100a2e:	83 ec 0c             	sub    $0xc,%esp
f0100a31:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100a34:	e8 a7 0c 00 00       	call   f01016e0 <readline>
f0100a39:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f0100a3b:	83 c4 10             	add    $0x10,%esp
f0100a3e:	85 c0                	test   %eax,%eax
f0100a40:	74 ec                	je     f0100a2e <monitor+0x8c>
	argv[argc] = 0;
f0100a42:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a49:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100a50:	eb 1e                	jmp    f0100a70 <monitor+0xce>
			buf++;
f0100a52:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a55:	0f b6 06             	movzbl (%esi),%eax
f0100a58:	84 c0                	test   %al,%al
f0100a5a:	74 14                	je     f0100a70 <monitor+0xce>
f0100a5c:	83 ec 08             	sub    $0x8,%esp
f0100a5f:	0f be c0             	movsbl %al,%eax
f0100a62:	50                   	push   %eax
f0100a63:	57                   	push   %edi
f0100a64:	e8 af 0e 00 00       	call   f0101918 <strchr>
f0100a69:	83 c4 10             	add    $0x10,%esp
f0100a6c:	85 c0                	test   %eax,%eax
f0100a6e:	74 e2                	je     f0100a52 <monitor+0xb0>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a70:	0f b6 06             	movzbl (%esi),%eax
f0100a73:	84 c0                	test   %al,%al
f0100a75:	0f 85 60 ff ff ff    	jne    f01009db <monitor+0x39>
	argv[argc] = 0;
f0100a7b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a7e:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a85:	00 
	if (argc == 0)
f0100a86:	85 c0                	test   %eax,%eax
f0100a88:	74 9b                	je     f0100a25 <monitor+0x83>
f0100a8a:	8d b3 18 1d 00 00    	lea    0x1d18(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a90:	c7 45 a0 00 00 00 00 	movl   $0x0,-0x60(%ebp)
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a97:	83 ec 08             	sub    $0x8,%esp
f0100a9a:	ff 36                	pushl  (%esi)
f0100a9c:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a9f:	e8 16 0e 00 00       	call   f01018ba <strcmp>
f0100aa4:	83 c4 10             	add    $0x10,%esp
f0100aa7:	85 c0                	test   %eax,%eax
f0100aa9:	74 29                	je     f0100ad4 <monitor+0x132>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100aab:	83 45 a0 01          	addl   $0x1,-0x60(%ebp)
f0100aaf:	8b 45 a0             	mov    -0x60(%ebp),%eax
f0100ab2:	83 c6 0c             	add    $0xc,%esi
f0100ab5:	83 f8 03             	cmp    $0x3,%eax
f0100ab8:	75 dd                	jne    f0100a97 <monitor+0xf5>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100aba:	83 ec 08             	sub    $0x8,%esp
f0100abd:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ac0:	8d 83 fc fd fe ff    	lea    -0x10204(%ebx),%eax
f0100ac6:	50                   	push   %eax
f0100ac7:	e8 3a 02 00 00       	call   f0100d06 <cprintf>
f0100acc:	83 c4 10             	add    $0x10,%esp
f0100acf:	e9 51 ff ff ff       	jmp    f0100a25 <monitor+0x83>
			return commands[i].func(argc, argv, tf);
f0100ad4:	83 ec 04             	sub    $0x4,%esp
f0100ad7:	8b 45 a0             	mov    -0x60(%ebp),%eax
f0100ada:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100add:	ff 75 08             	pushl  0x8(%ebp)
f0100ae0:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100ae3:	52                   	push   %edx
f0100ae4:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100ae7:	ff 94 83 20 1d 00 00 	call   *0x1d20(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100aee:	83 c4 10             	add    $0x10,%esp
f0100af1:	85 c0                	test   %eax,%eax
f0100af3:	0f 89 2c ff ff ff    	jns    f0100a25 <monitor+0x83>
				break;
	}
}
f0100af9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100afc:	5b                   	pop    %ebx
f0100afd:	5e                   	pop    %esi
f0100afe:	5f                   	pop    %edi
f0100aff:	5d                   	pop    %ebp
f0100b00:	c3                   	ret    

f0100b01 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100b01:	55                   	push   %ebp
f0100b02:	89 e5                	mov    %esp,%ebp
f0100b04:	57                   	push   %edi
f0100b05:	56                   	push   %esi
f0100b06:	53                   	push   %ebx
f0100b07:	83 ec 18             	sub    $0x18,%esp
f0100b0a:	e8 40 f6 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100b0f:	81 c3 f9 17 01 00    	add    $0x117f9,%ebx
f0100b15:	89 c7                	mov    %eax,%edi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b17:	50                   	push   %eax
f0100b18:	e8 62 01 00 00       	call   f0100c7f <mc146818_read>
f0100b1d:	89 c6                	mov    %eax,%esi
f0100b1f:	83 c7 01             	add    $0x1,%edi
f0100b22:	89 3c 24             	mov    %edi,(%esp)
f0100b25:	e8 55 01 00 00       	call   f0100c7f <mc146818_read>
f0100b2a:	c1 e0 08             	shl    $0x8,%eax
f0100b2d:	09 f0                	or     %esi,%eax
}
f0100b2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b32:	5b                   	pop    %ebx
f0100b33:	5e                   	pop    %esi
f0100b34:	5f                   	pop    %edi
f0100b35:	5d                   	pop    %ebp
f0100b36:	c3                   	ret    

f0100b37 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100b37:	55                   	push   %ebp
f0100b38:	89 e5                	mov    %esp,%ebp
f0100b3a:	57                   	push   %edi
f0100b3b:	56                   	push   %esi
f0100b3c:	53                   	push   %ebx
f0100b3d:	83 ec 0c             	sub    $0xc,%esp
f0100b40:	e8 0a f6 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100b45:	81 c3 c3 17 01 00    	add    $0x117c3,%ebx
	basemem = nvram_read(NVRAM_BASELO);
f0100b4b:	b8 15 00 00 00       	mov    $0x15,%eax
f0100b50:	e8 ac ff ff ff       	call   f0100b01 <nvram_read>
f0100b55:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f0100b57:	b8 17 00 00 00       	mov    $0x17,%eax
f0100b5c:	e8 a0 ff ff ff       	call   f0100b01 <nvram_read>
f0100b61:	89 c7                	mov    %eax,%edi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0100b63:	b8 34 00 00 00       	mov    $0x34,%eax
f0100b68:	e8 94 ff ff ff       	call   f0100b01 <nvram_read>
f0100b6d:	c1 e0 06             	shl    $0x6,%eax
	if (ext16mem)
f0100b70:	85 c0                	test   %eax,%eax
f0100b72:	75 0e                	jne    f0100b82 <mem_init+0x4b>
		totalmem = basemem;
f0100b74:	89 f0                	mov    %esi,%eax
	else if (extmem)
f0100b76:	85 ff                	test   %edi,%edi
f0100b78:	74 0d                	je     f0100b87 <mem_init+0x50>
		totalmem = 1 * 1024 + extmem;
f0100b7a:	8d 87 00 04 00 00    	lea    0x400(%edi),%eax
f0100b80:	eb 05                	jmp    f0100b87 <mem_init+0x50>
		totalmem = 16 * 1024 + ext16mem;
f0100b82:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0100b87:	89 c1                	mov    %eax,%ecx
f0100b89:	c1 e9 02             	shr    $0x2,%ecx
f0100b8c:	c7 c2 a8 46 11 f0    	mov    $0xf01146a8,%edx
f0100b92:	89 0a                	mov    %ecx,(%edx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100b94:	89 c2                	mov    %eax,%edx
f0100b96:	29 f2                	sub    %esi,%edx
f0100b98:	52                   	push   %edx
f0100b99:	56                   	push   %esi
f0100b9a:	50                   	push   %eax
f0100b9b:	8d 83 6c ff fe ff    	lea    -0x10094(%ebx),%eax
f0100ba1:	50                   	push   %eax
f0100ba2:	e8 5f 01 00 00       	call   f0100d06 <cprintf>

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	// Remove this line when you're ready to test this function.
	panic("mem_init: This function is not finished\n");
f0100ba7:	83 c4 0c             	add    $0xc,%esp
f0100baa:	8d 83 a8 ff fe ff    	lea    -0x10058(%ebx),%eax
f0100bb0:	50                   	push   %eax
f0100bb1:	68 80 00 00 00       	push   $0x80
f0100bb6:	8d 83 d4 ff fe ff    	lea    -0x1002c(%ebx),%eax
f0100bbc:	50                   	push   %eax
f0100bbd:	e8 d7 f4 ff ff       	call   f0100099 <_panic>

f0100bc2 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100bc2:	55                   	push   %ebp
f0100bc3:	89 e5                	mov    %esp,%ebp
f0100bc5:	57                   	push   %edi
f0100bc6:	56                   	push   %esi
f0100bc7:	53                   	push   %ebx
f0100bc8:	83 ec 04             	sub    $0x4,%esp
f0100bcb:	e8 ab 00 00 00       	call   f0100c7b <__x86.get_pc_thunk.si>
f0100bd0:	81 c6 38 17 01 00    	add    $0x11738,%esi
f0100bd6:	89 75 f0             	mov    %esi,-0x10(%ebp)
f0100bd9:	8b 9e 90 1f 00 00    	mov    0x1f90(%esi),%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100bdf:	ba 00 00 00 00       	mov    $0x0,%edx
f0100be4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100be9:	c7 c7 a8 46 11 f0    	mov    $0xf01146a8,%edi
		pages[i].pp_ref = 0;
f0100bef:	c7 c6 b0 46 11 f0    	mov    $0xf01146b0,%esi
	for (i = 0; i < npages; i++) {
f0100bf5:	eb 1f                	jmp    f0100c16 <page_init+0x54>
f0100bf7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100bfe:	89 d1                	mov    %edx,%ecx
f0100c00:	03 0e                	add    (%esi),%ecx
f0100c02:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100c08:	89 19                	mov    %ebx,(%ecx)
	for (i = 0; i < npages; i++) {
f0100c0a:	83 c0 01             	add    $0x1,%eax
		page_free_list = &pages[i];
f0100c0d:	89 d3                	mov    %edx,%ebx
f0100c0f:	03 1e                	add    (%esi),%ebx
f0100c11:	ba 01 00 00 00       	mov    $0x1,%edx
	for (i = 0; i < npages; i++) {
f0100c16:	39 07                	cmp    %eax,(%edi)
f0100c18:	77 dd                	ja     f0100bf7 <page_init+0x35>
f0100c1a:	84 d2                	test   %dl,%dl
f0100c1c:	75 08                	jne    f0100c26 <page_init+0x64>
	}
}
f0100c1e:	83 c4 04             	add    $0x4,%esp
f0100c21:	5b                   	pop    %ebx
f0100c22:	5e                   	pop    %esi
f0100c23:	5f                   	pop    %edi
f0100c24:	5d                   	pop    %ebp
f0100c25:	c3                   	ret    
f0100c26:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100c29:	89 98 90 1f 00 00    	mov    %ebx,0x1f90(%eax)
f0100c2f:	eb ed                	jmp    f0100c1e <page_init+0x5c>

f0100c31 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100c31:	55                   	push   %ebp
f0100c32:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100c34:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c39:	5d                   	pop    %ebp
f0100c3a:	c3                   	ret    

f0100c3b <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100c3b:	55                   	push   %ebp
f0100c3c:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
}
f0100c3e:	5d                   	pop    %ebp
f0100c3f:	c3                   	ret    

f0100c40 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100c40:	55                   	push   %ebp
f0100c41:	89 e5                	mov    %esp,%ebp
f0100c43:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100c46:	66 83 68 04 01       	subw   $0x1,0x4(%eax)
		page_free(pp);
}
f0100c4b:	5d                   	pop    %ebp
f0100c4c:	c3                   	ret    

f0100c4d <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100c4d:	55                   	push   %ebp
f0100c4e:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100c50:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c55:	5d                   	pop    %ebp
f0100c56:	c3                   	ret    

f0100c57 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100c57:	55                   	push   %ebp
f0100c58:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100c5a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c5f:	5d                   	pop    %ebp
f0100c60:	c3                   	ret    

f0100c61 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100c61:	55                   	push   %ebp
f0100c62:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100c64:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c69:	5d                   	pop    %ebp
f0100c6a:	c3                   	ret    

f0100c6b <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100c6b:	55                   	push   %ebp
f0100c6c:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0100c6e:	5d                   	pop    %ebp
f0100c6f:	c3                   	ret    

f0100c70 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100c70:	55                   	push   %ebp
f0100c71:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100c73:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c76:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100c79:	5d                   	pop    %ebp
f0100c7a:	c3                   	ret    

f0100c7b <__x86.get_pc_thunk.si>:
f0100c7b:	8b 34 24             	mov    (%esp),%esi
f0100c7e:	c3                   	ret    

f0100c7f <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0100c7f:	55                   	push   %ebp
f0100c80:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100c82:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c85:	ba 70 00 00 00       	mov    $0x70,%edx
f0100c8a:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100c8b:	ba 71 00 00 00       	mov    $0x71,%edx
f0100c90:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0100c91:	0f b6 c0             	movzbl %al,%eax
}
f0100c94:	5d                   	pop    %ebp
f0100c95:	c3                   	ret    

f0100c96 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0100c96:	55                   	push   %ebp
f0100c97:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100c99:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c9c:	ba 70 00 00 00       	mov    $0x70,%edx
f0100ca1:	ee                   	out    %al,(%dx)
f0100ca2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ca5:	ba 71 00 00 00       	mov    $0x71,%edx
f0100caa:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0100cab:	5d                   	pop    %ebp
f0100cac:	c3                   	ret    

f0100cad <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100cad:	55                   	push   %ebp
f0100cae:	89 e5                	mov    %esp,%ebp
f0100cb0:	53                   	push   %ebx
f0100cb1:	83 ec 10             	sub    $0x10,%esp
f0100cb4:	e8 96 f4 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100cb9:	81 c3 4f 16 01 00    	add    $0x1164f,%ebx
	cputchar(ch);
f0100cbf:	ff 75 08             	pushl  0x8(%ebp)
f0100cc2:	e8 ff f9 ff ff       	call   f01006c6 <cputchar>
	*cnt++;
}
f0100cc7:	83 c4 10             	add    $0x10,%esp
f0100cca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ccd:	c9                   	leave  
f0100cce:	c3                   	ret    

f0100ccf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100ccf:	55                   	push   %ebp
f0100cd0:	89 e5                	mov    %esp,%ebp
f0100cd2:	53                   	push   %ebx
f0100cd3:	83 ec 14             	sub    $0x14,%esp
f0100cd6:	e8 74 f4 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100cdb:	81 c3 2d 16 01 00    	add    $0x1162d,%ebx
	int cnt = 0;
f0100ce1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100ce8:	ff 75 0c             	pushl  0xc(%ebp)
f0100ceb:	ff 75 08             	pushl  0x8(%ebp)
f0100cee:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100cf1:	50                   	push   %eax
f0100cf2:	8d 83 a5 e9 fe ff    	lea    -0x1165b(%ebx),%eax
f0100cf8:	50                   	push   %eax
f0100cf9:	e8 8d 04 00 00       	call   f010118b <vprintfmt>
	return cnt;
}
f0100cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100d01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100d04:	c9                   	leave  
f0100d05:	c3                   	ret    

f0100d06 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100d06:	55                   	push   %ebp
f0100d07:	89 e5                	mov    %esp,%ebp
f0100d09:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100d0c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100d0f:	50                   	push   %eax
f0100d10:	ff 75 08             	pushl  0x8(%ebp)
f0100d13:	e8 b7 ff ff ff       	call   f0100ccf <vcprintf>
	va_end(ap);

	return cnt;
}
f0100d18:	c9                   	leave  
f0100d19:	c3                   	ret    

f0100d1a <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100d1a:	55                   	push   %ebp
f0100d1b:	89 e5                	mov    %esp,%ebp
f0100d1d:	57                   	push   %edi
f0100d1e:	56                   	push   %esi
f0100d1f:	53                   	push   %ebx
f0100d20:	83 ec 14             	sub    $0x14,%esp
f0100d23:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100d26:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100d29:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100d2c:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100d2f:	8b 32                	mov    (%edx),%esi
f0100d31:	8b 01                	mov    (%ecx),%eax
f0100d33:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100d36:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100d3d:	eb 2f                	jmp    f0100d6e <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100d3f:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100d42:	39 c6                	cmp    %eax,%esi
f0100d44:	7f 49                	jg     f0100d8f <stab_binsearch+0x75>
f0100d46:	0f b6 0a             	movzbl (%edx),%ecx
f0100d49:	83 ea 0c             	sub    $0xc,%edx
f0100d4c:	39 f9                	cmp    %edi,%ecx
f0100d4e:	75 ef                	jne    f0100d3f <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100d50:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d53:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100d56:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100d5a:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100d5d:	73 35                	jae    f0100d94 <stab_binsearch+0x7a>
			*region_left = m;
f0100d5f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100d62:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0100d64:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0100d67:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100d6e:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0100d71:	7f 4e                	jg     f0100dc1 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0100d73:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100d76:	01 f0                	add    %esi,%eax
f0100d78:	89 c3                	mov    %eax,%ebx
f0100d7a:	c1 eb 1f             	shr    $0x1f,%ebx
f0100d7d:	01 c3                	add    %eax,%ebx
f0100d7f:	d1 fb                	sar    %ebx
f0100d81:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100d84:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100d87:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100d8b:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0100d8d:	eb b3                	jmp    f0100d42 <stab_binsearch+0x28>
			l = true_m + 1;
f0100d8f:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0100d92:	eb da                	jmp    f0100d6e <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100d94:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100d97:	76 14                	jbe    f0100dad <stab_binsearch+0x93>
			*region_right = m - 1;
f0100d99:	83 e8 01             	sub    $0x1,%eax
f0100d9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100d9f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100da2:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0100da4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100dab:	eb c1                	jmp    f0100d6e <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100dad:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100db0:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100db2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100db6:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0100db8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100dbf:	eb ad                	jmp    f0100d6e <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100dc1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100dc5:	74 16                	je     f0100ddd <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100dc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100dca:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100dcc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100dcf:	8b 0e                	mov    (%esi),%ecx
f0100dd1:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100dd4:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100dd7:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0100ddb:	eb 12                	jmp    f0100def <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0100ddd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100de0:	8b 00                	mov    (%eax),%eax
f0100de2:	83 e8 01             	sub    $0x1,%eax
f0100de5:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100de8:	89 07                	mov    %eax,(%edi)
f0100dea:	eb 16                	jmp    f0100e02 <stab_binsearch+0xe8>
		     l--)
f0100dec:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100def:	39 c1                	cmp    %eax,%ecx
f0100df1:	7d 0a                	jge    f0100dfd <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0100df3:	0f b6 1a             	movzbl (%edx),%ebx
f0100df6:	83 ea 0c             	sub    $0xc,%edx
f0100df9:	39 fb                	cmp    %edi,%ebx
f0100dfb:	75 ef                	jne    f0100dec <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0100dfd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e00:	89 07                	mov    %eax,(%edi)
	}
}
f0100e02:	83 c4 14             	add    $0x14,%esp
f0100e05:	5b                   	pop    %ebx
f0100e06:	5e                   	pop    %esi
f0100e07:	5f                   	pop    %edi
f0100e08:	5d                   	pop    %ebp
f0100e09:	c3                   	ret    

f0100e0a <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100e0a:	55                   	push   %ebp
f0100e0b:	89 e5                	mov    %esp,%ebp
f0100e0d:	57                   	push   %edi
f0100e0e:	56                   	push   %esi
f0100e0f:	53                   	push   %ebx
f0100e10:	83 ec 3c             	sub    $0x3c,%esp
f0100e13:	e8 37 f3 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100e18:	81 c3 f0 14 01 00    	add    $0x114f0,%ebx
f0100e1e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100e21:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100e24:	8d 83 e0 ff fe ff    	lea    -0x10020(%ebx),%eax
f0100e2a:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100e2c:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100e33:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100e36:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100e3d:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100e40:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100e47:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100e4d:	0f 86 2f 01 00 00    	jbe    f0100f82 <debuginfo_eip+0x178>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100e53:	c7 c0 e5 6b 10 f0    	mov    $0xf0106be5,%eax
f0100e59:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100e5f:	0f 86 00 02 00 00    	jbe    f0101065 <debuginfo_eip+0x25b>
f0100e65:	c7 c0 62 88 10 f0    	mov    $0xf0108862,%eax
f0100e6b:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100e6f:	0f 85 f7 01 00 00    	jne    f010106c <debuginfo_eip+0x262>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100e75:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100e7c:	c7 c0 04 25 10 f0    	mov    $0xf0102504,%eax
f0100e82:	c7 c2 e4 6b 10 f0    	mov    $0xf0106be4,%edx
f0100e88:	29 c2                	sub    %eax,%edx
f0100e8a:	c1 fa 02             	sar    $0x2,%edx
f0100e8d:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100e93:	83 ea 01             	sub    $0x1,%edx
f0100e96:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100e99:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100e9c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100e9f:	83 ec 08             	sub    $0x8,%esp
f0100ea2:	57                   	push   %edi
f0100ea3:	6a 64                	push   $0x64
f0100ea5:	e8 70 fe ff ff       	call   f0100d1a <stab_binsearch>
	if (lfile == 0)
f0100eaa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ead:	83 c4 10             	add    $0x10,%esp
f0100eb0:	85 c0                	test   %eax,%eax
f0100eb2:	0f 84 bb 01 00 00    	je     f0101073 <debuginfo_eip+0x269>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100eb8:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100ebb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ebe:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100ec1:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100ec4:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ec7:	83 ec 08             	sub    $0x8,%esp
f0100eca:	57                   	push   %edi
f0100ecb:	6a 24                	push   $0x24
f0100ecd:	c7 c0 04 25 10 f0    	mov    $0xf0102504,%eax
f0100ed3:	e8 42 fe ff ff       	call   f0100d1a <stab_binsearch>

	if (lfun <= rfun) {
f0100ed8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100edb:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100ede:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0100ee1:	83 c4 10             	add    $0x10,%esp
f0100ee4:	39 c8                	cmp    %ecx,%eax
f0100ee6:	0f 8f ae 00 00 00    	jg     f0100f9a <debuginfo_eip+0x190>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100eec:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100eef:	c7 c1 04 25 10 f0    	mov    $0xf0102504,%ecx
f0100ef5:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0100ef8:	8b 11                	mov    (%ecx),%edx
f0100efa:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0100efd:	c7 c2 62 88 10 f0    	mov    $0xf0108862,%edx
f0100f03:	81 ea e5 6b 10 f0    	sub    $0xf0106be5,%edx
f0100f09:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f0100f0c:	73 0c                	jae    f0100f1a <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100f0e:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100f11:	81 c2 e5 6b 10 f0    	add    $0xf0106be5,%edx
f0100f17:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100f1a:	8b 51 08             	mov    0x8(%ecx),%edx
f0100f1d:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100f20:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0100f22:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100f25:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100f28:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100f2b:	83 ec 08             	sub    $0x8,%esp
f0100f2e:	6a 3a                	push   $0x3a
f0100f30:	ff 76 08             	pushl  0x8(%esi)
f0100f33:	e8 01 0a 00 00       	call   f0101939 <strfind>
f0100f38:	2b 46 08             	sub    0x8(%esi),%eax
f0100f3b:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
  	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100f3e:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100f41:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100f44:	83 c4 08             	add    $0x8,%esp
f0100f47:	57                   	push   %edi
f0100f48:	6a 44                	push   $0x44
f0100f4a:	c7 c7 04 25 10 f0    	mov    $0xf0102504,%edi
f0100f50:	89 f8                	mov    %edi,%eax
f0100f52:	e8 c3 fd ff ff       	call   f0100d1a <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0100f57:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100f5a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100f5d:	c1 e2 02             	shl    $0x2,%edx
f0100f60:	0f b7 4c 3a 06       	movzwl 0x6(%edx,%edi,1),%ecx
f0100f65:	89 4e 04             	mov    %ecx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100f68:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100f6b:	8d 54 17 04          	lea    0x4(%edi,%edx,1),%edx
f0100f6f:	83 c4 10             	add    $0x10,%esp
f0100f72:	c6 45 c0 00          	movb   $0x0,-0x40(%ebp)
f0100f76:	bf 01 00 00 00       	mov    $0x1,%edi
f0100f7b:	89 75 0c             	mov    %esi,0xc(%ebp)
f0100f7e:	89 ce                	mov    %ecx,%esi
f0100f80:	eb 34                	jmp    f0100fb6 <debuginfo_eip+0x1ac>
  	        panic("User address");
f0100f82:	83 ec 04             	sub    $0x4,%esp
f0100f85:	8d 83 ea ff fe ff    	lea    -0x10016(%ebx),%eax
f0100f8b:	50                   	push   %eax
f0100f8c:	6a 7f                	push   $0x7f
f0100f8e:	8d 83 f7 ff fe ff    	lea    -0x10009(%ebx),%eax
f0100f94:	50                   	push   %eax
f0100f95:	e8 ff f0 ff ff       	call   f0100099 <_panic>
		info->eip_fn_addr = addr;
f0100f9a:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100f9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100fa0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100fa3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100fa6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100fa9:	eb 80                	jmp    f0100f2b <debuginfo_eip+0x121>
f0100fab:	83 e8 01             	sub    $0x1,%eax
f0100fae:	83 ea 0c             	sub    $0xc,%edx
f0100fb1:	89 f9                	mov    %edi,%ecx
f0100fb3:	88 4d c0             	mov    %cl,-0x40(%ebp)
f0100fb6:	89 45 bc             	mov    %eax,-0x44(%ebp)
	while (lline >= lfile
f0100fb9:	39 c6                	cmp    %eax,%esi
f0100fbb:	7f 2a                	jg     f0100fe7 <debuginfo_eip+0x1dd>
f0100fbd:	89 55 c4             	mov    %edx,-0x3c(%ebp)
	       && stabs[lline].n_type != N_SOL
f0100fc0:	0f b6 0a             	movzbl (%edx),%ecx
f0100fc3:	80 f9 84             	cmp    $0x84,%cl
f0100fc6:	74 49                	je     f0101011 <debuginfo_eip+0x207>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100fc8:	80 f9 64             	cmp    $0x64,%cl
f0100fcb:	75 de                	jne    f0100fab <debuginfo_eip+0x1a1>
f0100fcd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0100fd0:	83 79 04 00          	cmpl   $0x0,0x4(%ecx)
f0100fd4:	74 d5                	je     f0100fab <debuginfo_eip+0x1a1>
f0100fd6:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100fd9:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0100fdd:	74 3b                	je     f010101a <debuginfo_eip+0x210>
f0100fdf:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0100fe2:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100fe5:	eb 33                	jmp    f010101a <debuginfo_eip+0x210>
f0100fe7:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100fea:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100fed:	8b 7d d8             	mov    -0x28(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100ff0:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100ff5:	39 fa                	cmp    %edi,%edx
f0100ff7:	0f 8d 82 00 00 00    	jge    f010107f <debuginfo_eip+0x275>
		for (lline = lfun + 1;
f0100ffd:	83 c2 01             	add    $0x1,%edx
f0101000:	89 d0                	mov    %edx,%eax
f0101002:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0101005:	c7 c2 04 25 10 f0    	mov    $0xf0102504,%edx
f010100b:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f010100f:	eb 3b                	jmp    f010104c <debuginfo_eip+0x242>
f0101011:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101014:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0101018:	75 26                	jne    f0101040 <debuginfo_eip+0x236>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010101a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010101d:	c7 c0 04 25 10 f0    	mov    $0xf0102504,%eax
f0101023:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0101026:	c7 c0 62 88 10 f0    	mov    $0xf0108862,%eax
f010102c:	81 e8 e5 6b 10 f0    	sub    $0xf0106be5,%eax
f0101032:	39 c2                	cmp    %eax,%edx
f0101034:	73 b4                	jae    f0100fea <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0101036:	81 c2 e5 6b 10 f0    	add    $0xf0106be5,%edx
f010103c:	89 16                	mov    %edx,(%esi)
f010103e:	eb aa                	jmp    f0100fea <debuginfo_eip+0x1e0>
f0101040:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0101043:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101046:	eb d2                	jmp    f010101a <debuginfo_eip+0x210>
			info->eip_fn_narg++;
f0101048:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f010104c:	39 c7                	cmp    %eax,%edi
f010104e:	7e 2a                	jle    f010107a <debuginfo_eip+0x270>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0101050:	0f b6 0a             	movzbl (%edx),%ecx
f0101053:	83 c0 01             	add    $0x1,%eax
f0101056:	83 c2 0c             	add    $0xc,%edx
f0101059:	80 f9 a0             	cmp    $0xa0,%cl
f010105c:	74 ea                	je     f0101048 <debuginfo_eip+0x23e>
	return 0;
f010105e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101063:	eb 1a                	jmp    f010107f <debuginfo_eip+0x275>
		return -1;
f0101065:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010106a:	eb 13                	jmp    f010107f <debuginfo_eip+0x275>
f010106c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101071:	eb 0c                	jmp    f010107f <debuginfo_eip+0x275>
		return -1;
f0101073:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101078:	eb 05                	jmp    f010107f <debuginfo_eip+0x275>
	return 0;
f010107a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010107f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101082:	5b                   	pop    %ebx
f0101083:	5e                   	pop    %esi
f0101084:	5f                   	pop    %edi
f0101085:	5d                   	pop    %ebp
f0101086:	c3                   	ret    

f0101087 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0101087:	55                   	push   %ebp
f0101088:	89 e5                	mov    %esp,%ebp
f010108a:	57                   	push   %edi
f010108b:	56                   	push   %esi
f010108c:	53                   	push   %ebx
f010108d:	83 ec 2c             	sub    $0x2c,%esp
f0101090:	e8 47 06 00 00       	call   f01016dc <__x86.get_pc_thunk.cx>
f0101095:	81 c1 73 12 01 00    	add    $0x11273,%ecx
f010109b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f010109e:	89 c7                	mov    %eax,%edi
f01010a0:	89 d6                	mov    %edx,%esi
f01010a2:	8b 45 08             	mov    0x8(%ebp),%eax
f01010a5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01010a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01010ab:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01010ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01010b1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01010b6:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f01010b9:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f01010bc:	39 d3                	cmp    %edx,%ebx
f01010be:	72 09                	jb     f01010c9 <printnum+0x42>
f01010c0:	39 45 10             	cmp    %eax,0x10(%ebp)
f01010c3:	0f 87 83 00 00 00    	ja     f010114c <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01010c9:	83 ec 0c             	sub    $0xc,%esp
f01010cc:	ff 75 18             	pushl  0x18(%ebp)
f01010cf:	8b 45 14             	mov    0x14(%ebp),%eax
f01010d2:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01010d5:	53                   	push   %ebx
f01010d6:	ff 75 10             	pushl  0x10(%ebp)
f01010d9:	83 ec 08             	sub    $0x8,%esp
f01010dc:	ff 75 dc             	pushl  -0x24(%ebp)
f01010df:	ff 75 d8             	pushl  -0x28(%ebp)
f01010e2:	ff 75 d4             	pushl  -0x2c(%ebp)
f01010e5:	ff 75 d0             	pushl  -0x30(%ebp)
f01010e8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01010eb:	e8 70 0a 00 00       	call   f0101b60 <__udivdi3>
f01010f0:	83 c4 18             	add    $0x18,%esp
f01010f3:	52                   	push   %edx
f01010f4:	50                   	push   %eax
f01010f5:	89 f2                	mov    %esi,%edx
f01010f7:	89 f8                	mov    %edi,%eax
f01010f9:	e8 89 ff ff ff       	call   f0101087 <printnum>
f01010fe:	83 c4 20             	add    $0x20,%esp
f0101101:	eb 13                	jmp    f0101116 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0101103:	83 ec 08             	sub    $0x8,%esp
f0101106:	56                   	push   %esi
f0101107:	ff 75 18             	pushl  0x18(%ebp)
f010110a:	ff d7                	call   *%edi
f010110c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f010110f:	83 eb 01             	sub    $0x1,%ebx
f0101112:	85 db                	test   %ebx,%ebx
f0101114:	7f ed                	jg     f0101103 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101116:	83 ec 08             	sub    $0x8,%esp
f0101119:	56                   	push   %esi
f010111a:	83 ec 04             	sub    $0x4,%esp
f010111d:	ff 75 dc             	pushl  -0x24(%ebp)
f0101120:	ff 75 d8             	pushl  -0x28(%ebp)
f0101123:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101126:	ff 75 d0             	pushl  -0x30(%ebp)
f0101129:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010112c:	89 f3                	mov    %esi,%ebx
f010112e:	e8 4d 0b 00 00       	call   f0101c80 <__umoddi3>
f0101133:	83 c4 14             	add    $0x14,%esp
f0101136:	0f be 84 06 05 00 ff 	movsbl -0xfffb(%esi,%eax,1),%eax
f010113d:	ff 
f010113e:	50                   	push   %eax
f010113f:	ff d7                	call   *%edi
}
f0101141:	83 c4 10             	add    $0x10,%esp
f0101144:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101147:	5b                   	pop    %ebx
f0101148:	5e                   	pop    %esi
f0101149:	5f                   	pop    %edi
f010114a:	5d                   	pop    %ebp
f010114b:	c3                   	ret    
f010114c:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010114f:	eb be                	jmp    f010110f <printnum+0x88>

f0101151 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0101151:	55                   	push   %ebp
f0101152:	89 e5                	mov    %esp,%ebp
f0101154:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0101157:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010115b:	8b 10                	mov    (%eax),%edx
f010115d:	3b 50 04             	cmp    0x4(%eax),%edx
f0101160:	73 0a                	jae    f010116c <sprintputch+0x1b>
		*b->buf++ = ch;
f0101162:	8d 4a 01             	lea    0x1(%edx),%ecx
f0101165:	89 08                	mov    %ecx,(%eax)
f0101167:	8b 45 08             	mov    0x8(%ebp),%eax
f010116a:	88 02                	mov    %al,(%edx)
}
f010116c:	5d                   	pop    %ebp
f010116d:	c3                   	ret    

f010116e <printfmt>:
{
f010116e:	55                   	push   %ebp
f010116f:	89 e5                	mov    %esp,%ebp
f0101171:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0101174:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0101177:	50                   	push   %eax
f0101178:	ff 75 10             	pushl  0x10(%ebp)
f010117b:	ff 75 0c             	pushl  0xc(%ebp)
f010117e:	ff 75 08             	pushl  0x8(%ebp)
f0101181:	e8 05 00 00 00       	call   f010118b <vprintfmt>
}
f0101186:	83 c4 10             	add    $0x10,%esp
f0101189:	c9                   	leave  
f010118a:	c3                   	ret    

f010118b <vprintfmt>:
{
f010118b:	55                   	push   %ebp
f010118c:	89 e5                	mov    %esp,%ebp
f010118e:	57                   	push   %edi
f010118f:	56                   	push   %esi
f0101190:	53                   	push   %ebx
f0101191:	83 ec 2c             	sub    $0x2c,%esp
f0101194:	e8 b6 ef ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0101199:	81 c3 6f 11 01 00    	add    $0x1116f,%ebx
f010119f:	8b 75 0c             	mov    0xc(%ebp),%esi
f01011a2:	8b 7d 10             	mov    0x10(%ebp),%edi
f01011a5:	e9 08 04 00 00       	jmp    f01015b2 <.L36+0x48>
		padc = ' ';
f01011aa:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f01011ae:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f01011b5:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f01011bc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01011c3:	b9 00 00 00 00       	mov    $0x0,%ecx
f01011c8:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01011cb:	8d 47 01             	lea    0x1(%edi),%eax
f01011ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01011d1:	0f b6 17             	movzbl (%edi),%edx
f01011d4:	8d 42 dd             	lea    -0x23(%edx),%eax
f01011d7:	3c 55                	cmp    $0x55,%al
f01011d9:	0f 87 5b 04 00 00    	ja     f010163a <.L22>
f01011df:	0f b6 c0             	movzbl %al,%eax
f01011e2:	89 d9                	mov    %ebx,%ecx
f01011e4:	03 8c 83 94 00 ff ff 	add    -0xff6c(%ebx,%eax,4),%ecx
f01011eb:	ff e1                	jmp    *%ecx

f01011ed <.L73>:
f01011ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f01011f0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f01011f4:	eb d5                	jmp    f01011cb <vprintfmt+0x40>

f01011f6 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f01011f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f01011f9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01011fd:	eb cc                	jmp    f01011cb <vprintfmt+0x40>

f01011ff <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f01011ff:	0f b6 d2             	movzbl %dl,%edx
f0101202:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0101205:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f010120a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010120d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0101211:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0101214:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0101217:	83 f9 09             	cmp    $0x9,%ecx
f010121a:	77 55                	ja     f0101271 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f010121c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f010121f:	eb e9                	jmp    f010120a <.L29+0xb>

f0101221 <.L26>:
			precision = va_arg(ap, int);
f0101221:	8b 45 14             	mov    0x14(%ebp),%eax
f0101224:	8b 00                	mov    (%eax),%eax
f0101226:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101229:	8b 45 14             	mov    0x14(%ebp),%eax
f010122c:	8d 40 04             	lea    0x4(%eax),%eax
f010122f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101232:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0101235:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101239:	79 90                	jns    f01011cb <vprintfmt+0x40>
				width = precision, precision = -1;
f010123b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010123e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101241:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0101248:	eb 81                	jmp    f01011cb <vprintfmt+0x40>

f010124a <.L27>:
f010124a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010124d:	85 c0                	test   %eax,%eax
f010124f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101254:	0f 49 d0             	cmovns %eax,%edx
f0101257:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010125a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010125d:	e9 69 ff ff ff       	jmp    f01011cb <vprintfmt+0x40>

f0101262 <.L23>:
f0101262:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0101265:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010126c:	e9 5a ff ff ff       	jmp    f01011cb <vprintfmt+0x40>
f0101271:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101274:	eb bf                	jmp    f0101235 <.L26+0x14>

f0101276 <.L33>:
			lflag++;
f0101276:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010127a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f010127d:	e9 49 ff ff ff       	jmp    f01011cb <vprintfmt+0x40>

f0101282 <.L30>:
			putch(va_arg(ap, int), putdat);
f0101282:	8b 45 14             	mov    0x14(%ebp),%eax
f0101285:	8d 78 04             	lea    0x4(%eax),%edi
f0101288:	83 ec 08             	sub    $0x8,%esp
f010128b:	56                   	push   %esi
f010128c:	ff 30                	pushl  (%eax)
f010128e:	ff 55 08             	call   *0x8(%ebp)
			break;
f0101291:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0101294:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0101297:	e9 13 03 00 00       	jmp    f01015af <.L36+0x45>

f010129c <.L34>:
f010129c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f010129f:	83 f9 01             	cmp    $0x1,%ecx
f01012a2:	7e 19                	jle    f01012bd <.L34+0x21>
		return va_arg(*ap, long long);
f01012a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01012a7:	8b 00                	mov    (%eax),%eax
f01012a9:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01012ac:	8d 49 08             	lea    0x8(%ecx),%ecx
f01012af:	89 4d 14             	mov    %ecx,0x14(%ebp)
			color_flag = num;
f01012b2:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)
			break;
f01012b8:	e9 f2 02 00 00       	jmp    f01015af <.L36+0x45>
	else if (lflag)
f01012bd:	85 c9                	test   %ecx,%ecx
f01012bf:	75 10                	jne    f01012d1 <.L34+0x35>
		return va_arg(*ap, int);
f01012c1:	8b 45 14             	mov    0x14(%ebp),%eax
f01012c4:	8b 00                	mov    (%eax),%eax
f01012c6:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01012c9:	8d 49 04             	lea    0x4(%ecx),%ecx
f01012cc:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01012cf:	eb e1                	jmp    f01012b2 <.L34+0x16>
		return va_arg(*ap, long);
f01012d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01012d4:	8b 00                	mov    (%eax),%eax
f01012d6:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01012d9:	8d 49 04             	lea    0x4(%ecx),%ecx
f01012dc:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01012df:	eb d1                	jmp    f01012b2 <.L34+0x16>

f01012e1 <.L32>:
			err = va_arg(ap, int);
f01012e1:	8b 45 14             	mov    0x14(%ebp),%eax
f01012e4:	8d 78 04             	lea    0x4(%eax),%edi
f01012e7:	8b 00                	mov    (%eax),%eax
f01012e9:	99                   	cltd   
f01012ea:	31 d0                	xor    %edx,%eax
f01012ec:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01012ee:	83 f8 06             	cmp    $0x6,%eax
f01012f1:	7f 27                	jg     f010131a <.L32+0x39>
f01012f3:	8b 94 83 3c 1d 00 00 	mov    0x1d3c(%ebx,%eax,4),%edx
f01012fa:	85 d2                	test   %edx,%edx
f01012fc:	74 1c                	je     f010131a <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f01012fe:	52                   	push   %edx
f01012ff:	8d 83 26 00 ff ff    	lea    -0xffda(%ebx),%eax
f0101305:	50                   	push   %eax
f0101306:	56                   	push   %esi
f0101307:	ff 75 08             	pushl  0x8(%ebp)
f010130a:	e8 5f fe ff ff       	call   f010116e <printfmt>
f010130f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101312:	89 7d 14             	mov    %edi,0x14(%ebp)
f0101315:	e9 95 02 00 00       	jmp    f01015af <.L36+0x45>
				printfmt(putch, putdat, "error %d", err);
f010131a:	50                   	push   %eax
f010131b:	8d 83 1d 00 ff ff    	lea    -0xffe3(%ebx),%eax
f0101321:	50                   	push   %eax
f0101322:	56                   	push   %esi
f0101323:	ff 75 08             	pushl  0x8(%ebp)
f0101326:	e8 43 fe ff ff       	call   f010116e <printfmt>
f010132b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010132e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0101331:	e9 79 02 00 00       	jmp    f01015af <.L36+0x45>

f0101336 <.L37>:
			if ((p = va_arg(ap, char *)) == NULL)
f0101336:	8b 45 14             	mov    0x14(%ebp),%eax
f0101339:	83 c0 04             	add    $0x4,%eax
f010133c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010133f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101342:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0101344:	85 ff                	test   %edi,%edi
f0101346:	8d 83 16 00 ff ff    	lea    -0xffea(%ebx),%eax
f010134c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010134f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101353:	0f 8e b5 00 00 00    	jle    f010140e <.L37+0xd8>
f0101359:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010135d:	75 08                	jne    f0101367 <.L37+0x31>
f010135f:	89 75 0c             	mov    %esi,0xc(%ebp)
f0101362:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101365:	eb 6d                	jmp    f01013d4 <.L37+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101367:	83 ec 08             	sub    $0x8,%esp
f010136a:	ff 75 cc             	pushl  -0x34(%ebp)
f010136d:	57                   	push   %edi
f010136e:	e8 82 04 00 00       	call   f01017f5 <strnlen>
f0101373:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101376:	29 c2                	sub    %eax,%edx
f0101378:	89 55 c8             	mov    %edx,-0x38(%ebp)
f010137b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010137e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0101382:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101385:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101388:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f010138a:	eb 10                	jmp    f010139c <.L37+0x66>
					putch(padc, putdat);
f010138c:	83 ec 08             	sub    $0x8,%esp
f010138f:	56                   	push   %esi
f0101390:	ff 75 e0             	pushl  -0x20(%ebp)
f0101393:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0101396:	83 ef 01             	sub    $0x1,%edi
f0101399:	83 c4 10             	add    $0x10,%esp
f010139c:	85 ff                	test   %edi,%edi
f010139e:	7f ec                	jg     f010138c <.L37+0x56>
f01013a0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01013a3:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01013a6:	85 d2                	test   %edx,%edx
f01013a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01013ad:	0f 49 c2             	cmovns %edx,%eax
f01013b0:	29 c2                	sub    %eax,%edx
f01013b2:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01013b5:	89 75 0c             	mov    %esi,0xc(%ebp)
f01013b8:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01013bb:	eb 17                	jmp    f01013d4 <.L37+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f01013bd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01013c1:	75 30                	jne    f01013f3 <.L37+0xbd>
					putch(ch, putdat);
f01013c3:	83 ec 08             	sub    $0x8,%esp
f01013c6:	ff 75 0c             	pushl  0xc(%ebp)
f01013c9:	50                   	push   %eax
f01013ca:	ff 55 08             	call   *0x8(%ebp)
f01013cd:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01013d0:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f01013d4:	83 c7 01             	add    $0x1,%edi
f01013d7:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f01013db:	0f be c2             	movsbl %dl,%eax
f01013de:	85 c0                	test   %eax,%eax
f01013e0:	74 52                	je     f0101434 <.L37+0xfe>
f01013e2:	85 f6                	test   %esi,%esi
f01013e4:	78 d7                	js     f01013bd <.L37+0x87>
f01013e6:	83 ee 01             	sub    $0x1,%esi
f01013e9:	79 d2                	jns    f01013bd <.L37+0x87>
f01013eb:	8b 75 0c             	mov    0xc(%ebp),%esi
f01013ee:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01013f1:	eb 32                	jmp    f0101425 <.L37+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f01013f3:	0f be d2             	movsbl %dl,%edx
f01013f6:	83 ea 20             	sub    $0x20,%edx
f01013f9:	83 fa 5e             	cmp    $0x5e,%edx
f01013fc:	76 c5                	jbe    f01013c3 <.L37+0x8d>
					putch('?', putdat);
f01013fe:	83 ec 08             	sub    $0x8,%esp
f0101401:	ff 75 0c             	pushl  0xc(%ebp)
f0101404:	6a 3f                	push   $0x3f
f0101406:	ff 55 08             	call   *0x8(%ebp)
f0101409:	83 c4 10             	add    $0x10,%esp
f010140c:	eb c2                	jmp    f01013d0 <.L37+0x9a>
f010140e:	89 75 0c             	mov    %esi,0xc(%ebp)
f0101411:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101414:	eb be                	jmp    f01013d4 <.L37+0x9e>
				putch(' ', putdat);
f0101416:	83 ec 08             	sub    $0x8,%esp
f0101419:	56                   	push   %esi
f010141a:	6a 20                	push   $0x20
f010141c:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f010141f:	83 ef 01             	sub    $0x1,%edi
f0101422:	83 c4 10             	add    $0x10,%esp
f0101425:	85 ff                	test   %edi,%edi
f0101427:	7f ed                	jg     f0101416 <.L37+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f0101429:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010142c:	89 45 14             	mov    %eax,0x14(%ebp)
f010142f:	e9 7b 01 00 00       	jmp    f01015af <.L36+0x45>
f0101434:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101437:	8b 75 0c             	mov    0xc(%ebp),%esi
f010143a:	eb e9                	jmp    f0101425 <.L37+0xef>

f010143c <.L31>:
f010143c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f010143f:	83 f9 01             	cmp    $0x1,%ecx
f0101442:	7e 40                	jle    f0101484 <.L31+0x48>
		return va_arg(*ap, long long);
f0101444:	8b 45 14             	mov    0x14(%ebp),%eax
f0101447:	8b 50 04             	mov    0x4(%eax),%edx
f010144a:	8b 00                	mov    (%eax),%eax
f010144c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010144f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101452:	8b 45 14             	mov    0x14(%ebp),%eax
f0101455:	8d 40 08             	lea    0x8(%eax),%eax
f0101458:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f010145b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010145f:	79 55                	jns    f01014b6 <.L31+0x7a>
				putch('-', putdat);
f0101461:	83 ec 08             	sub    $0x8,%esp
f0101464:	56                   	push   %esi
f0101465:	6a 2d                	push   $0x2d
f0101467:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010146a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010146d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101470:	f7 da                	neg    %edx
f0101472:	83 d1 00             	adc    $0x0,%ecx
f0101475:	f7 d9                	neg    %ecx
f0101477:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010147a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010147f:	e9 10 01 00 00       	jmp    f0101594 <.L36+0x2a>
	else if (lflag)
f0101484:	85 c9                	test   %ecx,%ecx
f0101486:	75 17                	jne    f010149f <.L31+0x63>
		return va_arg(*ap, int);
f0101488:	8b 45 14             	mov    0x14(%ebp),%eax
f010148b:	8b 00                	mov    (%eax),%eax
f010148d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101490:	99                   	cltd   
f0101491:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101494:	8b 45 14             	mov    0x14(%ebp),%eax
f0101497:	8d 40 04             	lea    0x4(%eax),%eax
f010149a:	89 45 14             	mov    %eax,0x14(%ebp)
f010149d:	eb bc                	jmp    f010145b <.L31+0x1f>
		return va_arg(*ap, long);
f010149f:	8b 45 14             	mov    0x14(%ebp),%eax
f01014a2:	8b 00                	mov    (%eax),%eax
f01014a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01014a7:	99                   	cltd   
f01014a8:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01014ab:	8b 45 14             	mov    0x14(%ebp),%eax
f01014ae:	8d 40 04             	lea    0x4(%eax),%eax
f01014b1:	89 45 14             	mov    %eax,0x14(%ebp)
f01014b4:	eb a5                	jmp    f010145b <.L31+0x1f>
			num = getint(&ap, lflag);
f01014b6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01014b9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01014bc:	b8 0a 00 00 00       	mov    $0xa,%eax
f01014c1:	e9 ce 00 00 00       	jmp    f0101594 <.L36+0x2a>

f01014c6 <.L38>:
f01014c6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01014c9:	83 f9 01             	cmp    $0x1,%ecx
f01014cc:	7e 18                	jle    f01014e6 <.L38+0x20>
		return va_arg(*ap, unsigned long long);
f01014ce:	8b 45 14             	mov    0x14(%ebp),%eax
f01014d1:	8b 10                	mov    (%eax),%edx
f01014d3:	8b 48 04             	mov    0x4(%eax),%ecx
f01014d6:	8d 40 08             	lea    0x8(%eax),%eax
f01014d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01014dc:	b8 0a 00 00 00       	mov    $0xa,%eax
f01014e1:	e9 ae 00 00 00       	jmp    f0101594 <.L36+0x2a>
	else if (lflag)
f01014e6:	85 c9                	test   %ecx,%ecx
f01014e8:	75 1a                	jne    f0101504 <.L38+0x3e>
		return va_arg(*ap, unsigned int);
f01014ea:	8b 45 14             	mov    0x14(%ebp),%eax
f01014ed:	8b 10                	mov    (%eax),%edx
f01014ef:	b9 00 00 00 00       	mov    $0x0,%ecx
f01014f4:	8d 40 04             	lea    0x4(%eax),%eax
f01014f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01014fa:	b8 0a 00 00 00       	mov    $0xa,%eax
f01014ff:	e9 90 00 00 00       	jmp    f0101594 <.L36+0x2a>
		return va_arg(*ap, unsigned long);
f0101504:	8b 45 14             	mov    0x14(%ebp),%eax
f0101507:	8b 10                	mov    (%eax),%edx
f0101509:	b9 00 00 00 00       	mov    $0x0,%ecx
f010150e:	8d 40 04             	lea    0x4(%eax),%eax
f0101511:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101514:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101519:	eb 79                	jmp    f0101594 <.L36+0x2a>

f010151b <.L35>:
f010151b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f010151e:	83 f9 01             	cmp    $0x1,%ecx
f0101521:	7e 15                	jle    f0101538 <.L35+0x1d>
		return va_arg(*ap, unsigned long long);
f0101523:	8b 45 14             	mov    0x14(%ebp),%eax
f0101526:	8b 10                	mov    (%eax),%edx
f0101528:	8b 48 04             	mov    0x4(%eax),%ecx
f010152b:	8d 40 08             	lea    0x8(%eax),%eax
f010152e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101531:	b8 08 00 00 00       	mov    $0x8,%eax
f0101536:	eb 5c                	jmp    f0101594 <.L36+0x2a>
	else if (lflag)
f0101538:	85 c9                	test   %ecx,%ecx
f010153a:	75 17                	jne    f0101553 <.L35+0x38>
		return va_arg(*ap, unsigned int);
f010153c:	8b 45 14             	mov    0x14(%ebp),%eax
f010153f:	8b 10                	mov    (%eax),%edx
f0101541:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101546:	8d 40 04             	lea    0x4(%eax),%eax
f0101549:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010154c:	b8 08 00 00 00       	mov    $0x8,%eax
f0101551:	eb 41                	jmp    f0101594 <.L36+0x2a>
		return va_arg(*ap, unsigned long);
f0101553:	8b 45 14             	mov    0x14(%ebp),%eax
f0101556:	8b 10                	mov    (%eax),%edx
f0101558:	b9 00 00 00 00       	mov    $0x0,%ecx
f010155d:	8d 40 04             	lea    0x4(%eax),%eax
f0101560:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101563:	b8 08 00 00 00       	mov    $0x8,%eax
f0101568:	eb 2a                	jmp    f0101594 <.L36+0x2a>

f010156a <.L36>:
			putch('0', putdat);
f010156a:	83 ec 08             	sub    $0x8,%esp
f010156d:	56                   	push   %esi
f010156e:	6a 30                	push   $0x30
f0101570:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101573:	83 c4 08             	add    $0x8,%esp
f0101576:	56                   	push   %esi
f0101577:	6a 78                	push   $0x78
f0101579:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f010157c:	8b 45 14             	mov    0x14(%ebp),%eax
f010157f:	8b 10                	mov    (%eax),%edx
f0101581:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0101586:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0101589:	8d 40 04             	lea    0x4(%eax),%eax
f010158c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010158f:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0101594:	83 ec 0c             	sub    $0xc,%esp
f0101597:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010159b:	57                   	push   %edi
f010159c:	ff 75 e0             	pushl  -0x20(%ebp)
f010159f:	50                   	push   %eax
f01015a0:	51                   	push   %ecx
f01015a1:	52                   	push   %edx
f01015a2:	89 f2                	mov    %esi,%edx
f01015a4:	8b 45 08             	mov    0x8(%ebp),%eax
f01015a7:	e8 db fa ff ff       	call   f0101087 <printnum>
			break;
f01015ac:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f01015af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01015b2:	83 c7 01             	add    $0x1,%edi
f01015b5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01015b9:	83 f8 25             	cmp    $0x25,%eax
f01015bc:	0f 84 e8 fb ff ff    	je     f01011aa <vprintfmt+0x1f>
			if (ch == '\0')
f01015c2:	85 c0                	test   %eax,%eax
f01015c4:	0f 84 91 00 00 00    	je     f010165b <.L22+0x21>
			putch(ch, putdat);
f01015ca:	83 ec 08             	sub    $0x8,%esp
f01015cd:	56                   	push   %esi
f01015ce:	50                   	push   %eax
f01015cf:	ff 55 08             	call   *0x8(%ebp)
f01015d2:	83 c4 10             	add    $0x10,%esp
f01015d5:	eb db                	jmp    f01015b2 <.L36+0x48>

f01015d7 <.L39>:
f01015d7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01015da:	83 f9 01             	cmp    $0x1,%ecx
f01015dd:	7e 15                	jle    f01015f4 <.L39+0x1d>
		return va_arg(*ap, unsigned long long);
f01015df:	8b 45 14             	mov    0x14(%ebp),%eax
f01015e2:	8b 10                	mov    (%eax),%edx
f01015e4:	8b 48 04             	mov    0x4(%eax),%ecx
f01015e7:	8d 40 08             	lea    0x8(%eax),%eax
f01015ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01015ed:	b8 10 00 00 00       	mov    $0x10,%eax
f01015f2:	eb a0                	jmp    f0101594 <.L36+0x2a>
	else if (lflag)
f01015f4:	85 c9                	test   %ecx,%ecx
f01015f6:	75 17                	jne    f010160f <.L39+0x38>
		return va_arg(*ap, unsigned int);
f01015f8:	8b 45 14             	mov    0x14(%ebp),%eax
f01015fb:	8b 10                	mov    (%eax),%edx
f01015fd:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101602:	8d 40 04             	lea    0x4(%eax),%eax
f0101605:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101608:	b8 10 00 00 00       	mov    $0x10,%eax
f010160d:	eb 85                	jmp    f0101594 <.L36+0x2a>
		return va_arg(*ap, unsigned long);
f010160f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101612:	8b 10                	mov    (%eax),%edx
f0101614:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101619:	8d 40 04             	lea    0x4(%eax),%eax
f010161c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010161f:	b8 10 00 00 00       	mov    $0x10,%eax
f0101624:	e9 6b ff ff ff       	jmp    f0101594 <.L36+0x2a>

f0101629 <.L25>:
			putch(ch, putdat);
f0101629:	83 ec 08             	sub    $0x8,%esp
f010162c:	56                   	push   %esi
f010162d:	6a 25                	push   $0x25
f010162f:	ff 55 08             	call   *0x8(%ebp)
			break;
f0101632:	83 c4 10             	add    $0x10,%esp
f0101635:	e9 75 ff ff ff       	jmp    f01015af <.L36+0x45>

f010163a <.L22>:
			putch('%', putdat);
f010163a:	83 ec 08             	sub    $0x8,%esp
f010163d:	56                   	push   %esi
f010163e:	6a 25                	push   $0x25
f0101640:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101643:	83 c4 10             	add    $0x10,%esp
f0101646:	89 f8                	mov    %edi,%eax
f0101648:	eb 03                	jmp    f010164d <.L22+0x13>
f010164a:	83 e8 01             	sub    $0x1,%eax
f010164d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0101651:	75 f7                	jne    f010164a <.L22+0x10>
f0101653:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101656:	e9 54 ff ff ff       	jmp    f01015af <.L36+0x45>
}
f010165b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010165e:	5b                   	pop    %ebx
f010165f:	5e                   	pop    %esi
f0101660:	5f                   	pop    %edi
f0101661:	5d                   	pop    %ebp
f0101662:	c3                   	ret    

f0101663 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101663:	55                   	push   %ebp
f0101664:	89 e5                	mov    %esp,%ebp
f0101666:	53                   	push   %ebx
f0101667:	83 ec 14             	sub    $0x14,%esp
f010166a:	e8 e0 ea ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f010166f:	81 c3 99 0c 01 00    	add    $0x10c99,%ebx
f0101675:	8b 45 08             	mov    0x8(%ebp),%eax
f0101678:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010167b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010167e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101682:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101685:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010168c:	85 c0                	test   %eax,%eax
f010168e:	74 2b                	je     f01016bb <vsnprintf+0x58>
f0101690:	85 d2                	test   %edx,%edx
f0101692:	7e 27                	jle    f01016bb <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101694:	ff 75 14             	pushl  0x14(%ebp)
f0101697:	ff 75 10             	pushl  0x10(%ebp)
f010169a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010169d:	50                   	push   %eax
f010169e:	8d 83 49 ee fe ff    	lea    -0x111b7(%ebx),%eax
f01016a4:	50                   	push   %eax
f01016a5:	e8 e1 fa ff ff       	call   f010118b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01016aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01016ad:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01016b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01016b3:	83 c4 10             	add    $0x10,%esp
}
f01016b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01016b9:	c9                   	leave  
f01016ba:	c3                   	ret    
		return -E_INVAL;
f01016bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01016c0:	eb f4                	jmp    f01016b6 <vsnprintf+0x53>

f01016c2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01016c2:	55                   	push   %ebp
f01016c3:	89 e5                	mov    %esp,%ebp
f01016c5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01016c8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01016cb:	50                   	push   %eax
f01016cc:	ff 75 10             	pushl  0x10(%ebp)
f01016cf:	ff 75 0c             	pushl  0xc(%ebp)
f01016d2:	ff 75 08             	pushl  0x8(%ebp)
f01016d5:	e8 89 ff ff ff       	call   f0101663 <vsnprintf>
	va_end(ap);

	return rc;
}
f01016da:	c9                   	leave  
f01016db:	c3                   	ret    

f01016dc <__x86.get_pc_thunk.cx>:
f01016dc:	8b 0c 24             	mov    (%esp),%ecx
f01016df:	c3                   	ret    

f01016e0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01016e0:	55                   	push   %ebp
f01016e1:	89 e5                	mov    %esp,%ebp
f01016e3:	57                   	push   %edi
f01016e4:	56                   	push   %esi
f01016e5:	53                   	push   %ebx
f01016e6:	83 ec 1c             	sub    $0x1c,%esp
f01016e9:	e8 61 ea ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01016ee:	81 c3 1a 0c 01 00    	add    $0x10c1a,%ebx
f01016f4:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01016f7:	85 c0                	test   %eax,%eax
f01016f9:	74 13                	je     f010170e <readline+0x2e>
		cprintf("%s", prompt);
f01016fb:	83 ec 08             	sub    $0x8,%esp
f01016fe:	50                   	push   %eax
f01016ff:	8d 83 26 00 ff ff    	lea    -0xffda(%ebx),%eax
f0101705:	50                   	push   %eax
f0101706:	e8 fb f5 ff ff       	call   f0100d06 <cprintf>
f010170b:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010170e:	83 ec 0c             	sub    $0xc,%esp
f0101711:	6a 00                	push   $0x0
f0101713:	e8 cf ef ff ff       	call   f01006e7 <iscons>
f0101718:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010171b:	83 c4 10             	add    $0x10,%esp
	i = 0;
f010171e:	bf 00 00 00 00       	mov    $0x0,%edi
f0101723:	eb 46                	jmp    f010176b <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0101725:	83 ec 08             	sub    $0x8,%esp
f0101728:	50                   	push   %eax
f0101729:	8d 83 ec 01 ff ff    	lea    -0xfe14(%ebx),%eax
f010172f:	50                   	push   %eax
f0101730:	e8 d1 f5 ff ff       	call   f0100d06 <cprintf>
			return NULL;
f0101735:	83 c4 10             	add    $0x10,%esp
f0101738:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010173d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101740:	5b                   	pop    %ebx
f0101741:	5e                   	pop    %esi
f0101742:	5f                   	pop    %edi
f0101743:	5d                   	pop    %ebp
f0101744:	c3                   	ret    
			if (echoing)
f0101745:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101749:	75 05                	jne    f0101750 <readline+0x70>
			i--;
f010174b:	83 ef 01             	sub    $0x1,%edi
f010174e:	eb 1b                	jmp    f010176b <readline+0x8b>
				cputchar('\b');
f0101750:	83 ec 0c             	sub    $0xc,%esp
f0101753:	6a 08                	push   $0x8
f0101755:	e8 6c ef ff ff       	call   f01006c6 <cputchar>
f010175a:	83 c4 10             	add    $0x10,%esp
f010175d:	eb ec                	jmp    f010174b <readline+0x6b>
			buf[i++] = c;
f010175f:	89 f0                	mov    %esi,%eax
f0101761:	88 84 3b 98 1f 00 00 	mov    %al,0x1f98(%ebx,%edi,1)
f0101768:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f010176b:	e8 66 ef ff ff       	call   f01006d6 <getchar>
f0101770:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0101772:	85 c0                	test   %eax,%eax
f0101774:	78 af                	js     f0101725 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101776:	83 f8 08             	cmp    $0x8,%eax
f0101779:	0f 94 c2             	sete   %dl
f010177c:	83 f8 7f             	cmp    $0x7f,%eax
f010177f:	0f 94 c0             	sete   %al
f0101782:	08 c2                	or     %al,%dl
f0101784:	74 04                	je     f010178a <readline+0xaa>
f0101786:	85 ff                	test   %edi,%edi
f0101788:	7f bb                	jg     f0101745 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010178a:	83 fe 1f             	cmp    $0x1f,%esi
f010178d:	7e 1c                	jle    f01017ab <readline+0xcb>
f010178f:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0101795:	7f 14                	jg     f01017ab <readline+0xcb>
			if (echoing)
f0101797:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010179b:	74 c2                	je     f010175f <readline+0x7f>
				cputchar(c);
f010179d:	83 ec 0c             	sub    $0xc,%esp
f01017a0:	56                   	push   %esi
f01017a1:	e8 20 ef ff ff       	call   f01006c6 <cputchar>
f01017a6:	83 c4 10             	add    $0x10,%esp
f01017a9:	eb b4                	jmp    f010175f <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f01017ab:	83 fe 0a             	cmp    $0xa,%esi
f01017ae:	74 05                	je     f01017b5 <readline+0xd5>
f01017b0:	83 fe 0d             	cmp    $0xd,%esi
f01017b3:	75 b6                	jne    f010176b <readline+0x8b>
			if (echoing)
f01017b5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01017b9:	75 13                	jne    f01017ce <readline+0xee>
			buf[i] = 0;
f01017bb:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f01017c2:	00 
			return buf;
f01017c3:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f01017c9:	e9 6f ff ff ff       	jmp    f010173d <readline+0x5d>
				cputchar('\n');
f01017ce:	83 ec 0c             	sub    $0xc,%esp
f01017d1:	6a 0a                	push   $0xa
f01017d3:	e8 ee ee ff ff       	call   f01006c6 <cputchar>
f01017d8:	83 c4 10             	add    $0x10,%esp
f01017db:	eb de                	jmp    f01017bb <readline+0xdb>

f01017dd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01017dd:	55                   	push   %ebp
f01017de:	89 e5                	mov    %esp,%ebp
f01017e0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01017e3:	b8 00 00 00 00       	mov    $0x0,%eax
f01017e8:	eb 03                	jmp    f01017ed <strlen+0x10>
		n++;
f01017ea:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f01017ed:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01017f1:	75 f7                	jne    f01017ea <strlen+0xd>
	return n;
}
f01017f3:	5d                   	pop    %ebp
f01017f4:	c3                   	ret    

f01017f5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01017f5:	55                   	push   %ebp
f01017f6:	89 e5                	mov    %esp,%ebp
f01017f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01017fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01017fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0101803:	eb 03                	jmp    f0101808 <strnlen+0x13>
		n++;
f0101805:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101808:	39 d0                	cmp    %edx,%eax
f010180a:	74 06                	je     f0101812 <strnlen+0x1d>
f010180c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101810:	75 f3                	jne    f0101805 <strnlen+0x10>
	return n;
}
f0101812:	5d                   	pop    %ebp
f0101813:	c3                   	ret    

f0101814 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101814:	55                   	push   %ebp
f0101815:	89 e5                	mov    %esp,%ebp
f0101817:	53                   	push   %ebx
f0101818:	8b 45 08             	mov    0x8(%ebp),%eax
f010181b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010181e:	89 c2                	mov    %eax,%edx
f0101820:	83 c1 01             	add    $0x1,%ecx
f0101823:	83 c2 01             	add    $0x1,%edx
f0101826:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010182a:	88 5a ff             	mov    %bl,-0x1(%edx)
f010182d:	84 db                	test   %bl,%bl
f010182f:	75 ef                	jne    f0101820 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101831:	5b                   	pop    %ebx
f0101832:	5d                   	pop    %ebp
f0101833:	c3                   	ret    

f0101834 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101834:	55                   	push   %ebp
f0101835:	89 e5                	mov    %esp,%ebp
f0101837:	53                   	push   %ebx
f0101838:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010183b:	53                   	push   %ebx
f010183c:	e8 9c ff ff ff       	call   f01017dd <strlen>
f0101841:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0101844:	ff 75 0c             	pushl  0xc(%ebp)
f0101847:	01 d8                	add    %ebx,%eax
f0101849:	50                   	push   %eax
f010184a:	e8 c5 ff ff ff       	call   f0101814 <strcpy>
	return dst;
}
f010184f:	89 d8                	mov    %ebx,%eax
f0101851:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101854:	c9                   	leave  
f0101855:	c3                   	ret    

f0101856 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101856:	55                   	push   %ebp
f0101857:	89 e5                	mov    %esp,%ebp
f0101859:	56                   	push   %esi
f010185a:	53                   	push   %ebx
f010185b:	8b 75 08             	mov    0x8(%ebp),%esi
f010185e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101861:	89 f3                	mov    %esi,%ebx
f0101863:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101866:	89 f2                	mov    %esi,%edx
f0101868:	eb 0f                	jmp    f0101879 <strncpy+0x23>
		*dst++ = *src;
f010186a:	83 c2 01             	add    $0x1,%edx
f010186d:	0f b6 01             	movzbl (%ecx),%eax
f0101870:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101873:	80 39 01             	cmpb   $0x1,(%ecx)
f0101876:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0101879:	39 da                	cmp    %ebx,%edx
f010187b:	75 ed                	jne    f010186a <strncpy+0x14>
	}
	return ret;
}
f010187d:	89 f0                	mov    %esi,%eax
f010187f:	5b                   	pop    %ebx
f0101880:	5e                   	pop    %esi
f0101881:	5d                   	pop    %ebp
f0101882:	c3                   	ret    

f0101883 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101883:	55                   	push   %ebp
f0101884:	89 e5                	mov    %esp,%ebp
f0101886:	56                   	push   %esi
f0101887:	53                   	push   %ebx
f0101888:	8b 75 08             	mov    0x8(%ebp),%esi
f010188b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010188e:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0101891:	89 f0                	mov    %esi,%eax
f0101893:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101897:	85 c9                	test   %ecx,%ecx
f0101899:	75 0b                	jne    f01018a6 <strlcpy+0x23>
f010189b:	eb 17                	jmp    f01018b4 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010189d:	83 c2 01             	add    $0x1,%edx
f01018a0:	83 c0 01             	add    $0x1,%eax
f01018a3:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f01018a6:	39 d8                	cmp    %ebx,%eax
f01018a8:	74 07                	je     f01018b1 <strlcpy+0x2e>
f01018aa:	0f b6 0a             	movzbl (%edx),%ecx
f01018ad:	84 c9                	test   %cl,%cl
f01018af:	75 ec                	jne    f010189d <strlcpy+0x1a>
		*dst = '\0';
f01018b1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01018b4:	29 f0                	sub    %esi,%eax
}
f01018b6:	5b                   	pop    %ebx
f01018b7:	5e                   	pop    %esi
f01018b8:	5d                   	pop    %ebp
f01018b9:	c3                   	ret    

f01018ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01018ba:	55                   	push   %ebp
f01018bb:	89 e5                	mov    %esp,%ebp
f01018bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01018c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01018c3:	eb 06                	jmp    f01018cb <strcmp+0x11>
		p++, q++;
f01018c5:	83 c1 01             	add    $0x1,%ecx
f01018c8:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01018cb:	0f b6 01             	movzbl (%ecx),%eax
f01018ce:	84 c0                	test   %al,%al
f01018d0:	74 04                	je     f01018d6 <strcmp+0x1c>
f01018d2:	3a 02                	cmp    (%edx),%al
f01018d4:	74 ef                	je     f01018c5 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01018d6:	0f b6 c0             	movzbl %al,%eax
f01018d9:	0f b6 12             	movzbl (%edx),%edx
f01018dc:	29 d0                	sub    %edx,%eax
}
f01018de:	5d                   	pop    %ebp
f01018df:	c3                   	ret    

f01018e0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01018e0:	55                   	push   %ebp
f01018e1:	89 e5                	mov    %esp,%ebp
f01018e3:	53                   	push   %ebx
f01018e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01018e7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01018ea:	89 c3                	mov    %eax,%ebx
f01018ec:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01018ef:	eb 06                	jmp    f01018f7 <strncmp+0x17>
		n--, p++, q++;
f01018f1:	83 c0 01             	add    $0x1,%eax
f01018f4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01018f7:	39 d8                	cmp    %ebx,%eax
f01018f9:	74 16                	je     f0101911 <strncmp+0x31>
f01018fb:	0f b6 08             	movzbl (%eax),%ecx
f01018fe:	84 c9                	test   %cl,%cl
f0101900:	74 04                	je     f0101906 <strncmp+0x26>
f0101902:	3a 0a                	cmp    (%edx),%cl
f0101904:	74 eb                	je     f01018f1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101906:	0f b6 00             	movzbl (%eax),%eax
f0101909:	0f b6 12             	movzbl (%edx),%edx
f010190c:	29 d0                	sub    %edx,%eax
}
f010190e:	5b                   	pop    %ebx
f010190f:	5d                   	pop    %ebp
f0101910:	c3                   	ret    
		return 0;
f0101911:	b8 00 00 00 00       	mov    $0x0,%eax
f0101916:	eb f6                	jmp    f010190e <strncmp+0x2e>

f0101918 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101918:	55                   	push   %ebp
f0101919:	89 e5                	mov    %esp,%ebp
f010191b:	8b 45 08             	mov    0x8(%ebp),%eax
f010191e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101922:	0f b6 10             	movzbl (%eax),%edx
f0101925:	84 d2                	test   %dl,%dl
f0101927:	74 09                	je     f0101932 <strchr+0x1a>
		if (*s == c)
f0101929:	38 ca                	cmp    %cl,%dl
f010192b:	74 0a                	je     f0101937 <strchr+0x1f>
	for (; *s; s++)
f010192d:	83 c0 01             	add    $0x1,%eax
f0101930:	eb f0                	jmp    f0101922 <strchr+0xa>
			return (char *) s;
	return 0;
f0101932:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101937:	5d                   	pop    %ebp
f0101938:	c3                   	ret    

f0101939 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101939:	55                   	push   %ebp
f010193a:	89 e5                	mov    %esp,%ebp
f010193c:	8b 45 08             	mov    0x8(%ebp),%eax
f010193f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101943:	eb 03                	jmp    f0101948 <strfind+0xf>
f0101945:	83 c0 01             	add    $0x1,%eax
f0101948:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010194b:	38 ca                	cmp    %cl,%dl
f010194d:	74 04                	je     f0101953 <strfind+0x1a>
f010194f:	84 d2                	test   %dl,%dl
f0101951:	75 f2                	jne    f0101945 <strfind+0xc>
			break;
	return (char *) s;
}
f0101953:	5d                   	pop    %ebp
f0101954:	c3                   	ret    

f0101955 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101955:	55                   	push   %ebp
f0101956:	89 e5                	mov    %esp,%ebp
f0101958:	57                   	push   %edi
f0101959:	56                   	push   %esi
f010195a:	53                   	push   %ebx
f010195b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010195e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101961:	85 c9                	test   %ecx,%ecx
f0101963:	74 13                	je     f0101978 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101965:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010196b:	75 05                	jne    f0101972 <memset+0x1d>
f010196d:	f6 c1 03             	test   $0x3,%cl
f0101970:	74 0d                	je     f010197f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101972:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101975:	fc                   	cld    
f0101976:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101978:	89 f8                	mov    %edi,%eax
f010197a:	5b                   	pop    %ebx
f010197b:	5e                   	pop    %esi
f010197c:	5f                   	pop    %edi
f010197d:	5d                   	pop    %ebp
f010197e:	c3                   	ret    
		c &= 0xFF;
f010197f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101983:	89 d3                	mov    %edx,%ebx
f0101985:	c1 e3 08             	shl    $0x8,%ebx
f0101988:	89 d0                	mov    %edx,%eax
f010198a:	c1 e0 18             	shl    $0x18,%eax
f010198d:	89 d6                	mov    %edx,%esi
f010198f:	c1 e6 10             	shl    $0x10,%esi
f0101992:	09 f0                	or     %esi,%eax
f0101994:	09 c2                	or     %eax,%edx
f0101996:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0101998:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010199b:	89 d0                	mov    %edx,%eax
f010199d:	fc                   	cld    
f010199e:	f3 ab                	rep stos %eax,%es:(%edi)
f01019a0:	eb d6                	jmp    f0101978 <memset+0x23>

f01019a2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01019a2:	55                   	push   %ebp
f01019a3:	89 e5                	mov    %esp,%ebp
f01019a5:	57                   	push   %edi
f01019a6:	56                   	push   %esi
f01019a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01019aa:	8b 75 0c             	mov    0xc(%ebp),%esi
f01019ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01019b0:	39 c6                	cmp    %eax,%esi
f01019b2:	73 35                	jae    f01019e9 <memmove+0x47>
f01019b4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01019b7:	39 c2                	cmp    %eax,%edx
f01019b9:	76 2e                	jbe    f01019e9 <memmove+0x47>
		s += n;
		d += n;
f01019bb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01019be:	89 d6                	mov    %edx,%esi
f01019c0:	09 fe                	or     %edi,%esi
f01019c2:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01019c8:	74 0c                	je     f01019d6 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01019ca:	83 ef 01             	sub    $0x1,%edi
f01019cd:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01019d0:	fd                   	std    
f01019d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01019d3:	fc                   	cld    
f01019d4:	eb 21                	jmp    f01019f7 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01019d6:	f6 c1 03             	test   $0x3,%cl
f01019d9:	75 ef                	jne    f01019ca <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01019db:	83 ef 04             	sub    $0x4,%edi
f01019de:	8d 72 fc             	lea    -0x4(%edx),%esi
f01019e1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01019e4:	fd                   	std    
f01019e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01019e7:	eb ea                	jmp    f01019d3 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01019e9:	89 f2                	mov    %esi,%edx
f01019eb:	09 c2                	or     %eax,%edx
f01019ed:	f6 c2 03             	test   $0x3,%dl
f01019f0:	74 09                	je     f01019fb <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01019f2:	89 c7                	mov    %eax,%edi
f01019f4:	fc                   	cld    
f01019f5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01019f7:	5e                   	pop    %esi
f01019f8:	5f                   	pop    %edi
f01019f9:	5d                   	pop    %ebp
f01019fa:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01019fb:	f6 c1 03             	test   $0x3,%cl
f01019fe:	75 f2                	jne    f01019f2 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101a00:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0101a03:	89 c7                	mov    %eax,%edi
f0101a05:	fc                   	cld    
f0101a06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101a08:	eb ed                	jmp    f01019f7 <memmove+0x55>

f0101a0a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101a0a:	55                   	push   %ebp
f0101a0b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101a0d:	ff 75 10             	pushl  0x10(%ebp)
f0101a10:	ff 75 0c             	pushl  0xc(%ebp)
f0101a13:	ff 75 08             	pushl  0x8(%ebp)
f0101a16:	e8 87 ff ff ff       	call   f01019a2 <memmove>
}
f0101a1b:	c9                   	leave  
f0101a1c:	c3                   	ret    

f0101a1d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101a1d:	55                   	push   %ebp
f0101a1e:	89 e5                	mov    %esp,%ebp
f0101a20:	56                   	push   %esi
f0101a21:	53                   	push   %ebx
f0101a22:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a25:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101a28:	89 c6                	mov    %eax,%esi
f0101a2a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101a2d:	39 f0                	cmp    %esi,%eax
f0101a2f:	74 1c                	je     f0101a4d <memcmp+0x30>
		if (*s1 != *s2)
f0101a31:	0f b6 08             	movzbl (%eax),%ecx
f0101a34:	0f b6 1a             	movzbl (%edx),%ebx
f0101a37:	38 d9                	cmp    %bl,%cl
f0101a39:	75 08                	jne    f0101a43 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0101a3b:	83 c0 01             	add    $0x1,%eax
f0101a3e:	83 c2 01             	add    $0x1,%edx
f0101a41:	eb ea                	jmp    f0101a2d <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0101a43:	0f b6 c1             	movzbl %cl,%eax
f0101a46:	0f b6 db             	movzbl %bl,%ebx
f0101a49:	29 d8                	sub    %ebx,%eax
f0101a4b:	eb 05                	jmp    f0101a52 <memcmp+0x35>
	}

	return 0;
f0101a4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101a52:	5b                   	pop    %ebx
f0101a53:	5e                   	pop    %esi
f0101a54:	5d                   	pop    %ebp
f0101a55:	c3                   	ret    

f0101a56 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101a56:	55                   	push   %ebp
f0101a57:	89 e5                	mov    %esp,%ebp
f0101a59:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101a5f:	89 c2                	mov    %eax,%edx
f0101a61:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101a64:	39 d0                	cmp    %edx,%eax
f0101a66:	73 09                	jae    f0101a71 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101a68:	38 08                	cmp    %cl,(%eax)
f0101a6a:	74 05                	je     f0101a71 <memfind+0x1b>
	for (; s < ends; s++)
f0101a6c:	83 c0 01             	add    $0x1,%eax
f0101a6f:	eb f3                	jmp    f0101a64 <memfind+0xe>
			break;
	return (void *) s;
}
f0101a71:	5d                   	pop    %ebp
f0101a72:	c3                   	ret    

f0101a73 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101a73:	55                   	push   %ebp
f0101a74:	89 e5                	mov    %esp,%ebp
f0101a76:	57                   	push   %edi
f0101a77:	56                   	push   %esi
f0101a78:	53                   	push   %ebx
f0101a79:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101a7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101a7f:	eb 03                	jmp    f0101a84 <strtol+0x11>
		s++;
f0101a81:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0101a84:	0f b6 01             	movzbl (%ecx),%eax
f0101a87:	3c 20                	cmp    $0x20,%al
f0101a89:	74 f6                	je     f0101a81 <strtol+0xe>
f0101a8b:	3c 09                	cmp    $0x9,%al
f0101a8d:	74 f2                	je     f0101a81 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0101a8f:	3c 2b                	cmp    $0x2b,%al
f0101a91:	74 2e                	je     f0101ac1 <strtol+0x4e>
	int neg = 0;
f0101a93:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101a98:	3c 2d                	cmp    $0x2d,%al
f0101a9a:	74 2f                	je     f0101acb <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101a9c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101aa2:	75 05                	jne    f0101aa9 <strtol+0x36>
f0101aa4:	80 39 30             	cmpb   $0x30,(%ecx)
f0101aa7:	74 2c                	je     f0101ad5 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101aa9:	85 db                	test   %ebx,%ebx
f0101aab:	75 0a                	jne    f0101ab7 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101aad:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0101ab2:	80 39 30             	cmpb   $0x30,(%ecx)
f0101ab5:	74 28                	je     f0101adf <strtol+0x6c>
		base = 10;
f0101ab7:	b8 00 00 00 00       	mov    $0x0,%eax
f0101abc:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101abf:	eb 50                	jmp    f0101b11 <strtol+0x9e>
		s++;
f0101ac1:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0101ac4:	bf 00 00 00 00       	mov    $0x0,%edi
f0101ac9:	eb d1                	jmp    f0101a9c <strtol+0x29>
		s++, neg = 1;
f0101acb:	83 c1 01             	add    $0x1,%ecx
f0101ace:	bf 01 00 00 00       	mov    $0x1,%edi
f0101ad3:	eb c7                	jmp    f0101a9c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101ad5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101ad9:	74 0e                	je     f0101ae9 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0101adb:	85 db                	test   %ebx,%ebx
f0101add:	75 d8                	jne    f0101ab7 <strtol+0x44>
		s++, base = 8;
f0101adf:	83 c1 01             	add    $0x1,%ecx
f0101ae2:	bb 08 00 00 00       	mov    $0x8,%ebx
f0101ae7:	eb ce                	jmp    f0101ab7 <strtol+0x44>
		s += 2, base = 16;
f0101ae9:	83 c1 02             	add    $0x2,%ecx
f0101aec:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101af1:	eb c4                	jmp    f0101ab7 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0101af3:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101af6:	89 f3                	mov    %esi,%ebx
f0101af8:	80 fb 19             	cmp    $0x19,%bl
f0101afb:	77 29                	ja     f0101b26 <strtol+0xb3>
			dig = *s - 'a' + 10;
f0101afd:	0f be d2             	movsbl %dl,%edx
f0101b00:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101b03:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101b06:	7d 30                	jge    f0101b38 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0101b08:	83 c1 01             	add    $0x1,%ecx
f0101b0b:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101b0f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0101b11:	0f b6 11             	movzbl (%ecx),%edx
f0101b14:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101b17:	89 f3                	mov    %esi,%ebx
f0101b19:	80 fb 09             	cmp    $0x9,%bl
f0101b1c:	77 d5                	ja     f0101af3 <strtol+0x80>
			dig = *s - '0';
f0101b1e:	0f be d2             	movsbl %dl,%edx
f0101b21:	83 ea 30             	sub    $0x30,%edx
f0101b24:	eb dd                	jmp    f0101b03 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0101b26:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101b29:	89 f3                	mov    %esi,%ebx
f0101b2b:	80 fb 19             	cmp    $0x19,%bl
f0101b2e:	77 08                	ja     f0101b38 <strtol+0xc5>
			dig = *s - 'A' + 10;
f0101b30:	0f be d2             	movsbl %dl,%edx
f0101b33:	83 ea 37             	sub    $0x37,%edx
f0101b36:	eb cb                	jmp    f0101b03 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0101b38:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101b3c:	74 05                	je     f0101b43 <strtol+0xd0>
		*endptr = (char *) s;
f0101b3e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101b41:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0101b43:	89 c2                	mov    %eax,%edx
f0101b45:	f7 da                	neg    %edx
f0101b47:	85 ff                	test   %edi,%edi
f0101b49:	0f 45 c2             	cmovne %edx,%eax
}
f0101b4c:	5b                   	pop    %ebx
f0101b4d:	5e                   	pop    %esi
f0101b4e:	5f                   	pop    %edi
f0101b4f:	5d                   	pop    %ebp
f0101b50:	c3                   	ret    
f0101b51:	66 90                	xchg   %ax,%ax
f0101b53:	66 90                	xchg   %ax,%ax
f0101b55:	66 90                	xchg   %ax,%ax
f0101b57:	66 90                	xchg   %ax,%ax
f0101b59:	66 90                	xchg   %ax,%ax
f0101b5b:	66 90                	xchg   %ax,%ax
f0101b5d:	66 90                	xchg   %ax,%ax
f0101b5f:	90                   	nop

f0101b60 <__udivdi3>:
f0101b60:	55                   	push   %ebp
f0101b61:	57                   	push   %edi
f0101b62:	56                   	push   %esi
f0101b63:	53                   	push   %ebx
f0101b64:	83 ec 1c             	sub    $0x1c,%esp
f0101b67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0101b6b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0101b6f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101b73:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101b77:	85 d2                	test   %edx,%edx
f0101b79:	75 35                	jne    f0101bb0 <__udivdi3+0x50>
f0101b7b:	39 f3                	cmp    %esi,%ebx
f0101b7d:	0f 87 bd 00 00 00    	ja     f0101c40 <__udivdi3+0xe0>
f0101b83:	85 db                	test   %ebx,%ebx
f0101b85:	89 d9                	mov    %ebx,%ecx
f0101b87:	75 0b                	jne    f0101b94 <__udivdi3+0x34>
f0101b89:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b8e:	31 d2                	xor    %edx,%edx
f0101b90:	f7 f3                	div    %ebx
f0101b92:	89 c1                	mov    %eax,%ecx
f0101b94:	31 d2                	xor    %edx,%edx
f0101b96:	89 f0                	mov    %esi,%eax
f0101b98:	f7 f1                	div    %ecx
f0101b9a:	89 c6                	mov    %eax,%esi
f0101b9c:	89 e8                	mov    %ebp,%eax
f0101b9e:	89 f7                	mov    %esi,%edi
f0101ba0:	f7 f1                	div    %ecx
f0101ba2:	89 fa                	mov    %edi,%edx
f0101ba4:	83 c4 1c             	add    $0x1c,%esp
f0101ba7:	5b                   	pop    %ebx
f0101ba8:	5e                   	pop    %esi
f0101ba9:	5f                   	pop    %edi
f0101baa:	5d                   	pop    %ebp
f0101bab:	c3                   	ret    
f0101bac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101bb0:	39 f2                	cmp    %esi,%edx
f0101bb2:	77 7c                	ja     f0101c30 <__udivdi3+0xd0>
f0101bb4:	0f bd fa             	bsr    %edx,%edi
f0101bb7:	83 f7 1f             	xor    $0x1f,%edi
f0101bba:	0f 84 98 00 00 00    	je     f0101c58 <__udivdi3+0xf8>
f0101bc0:	89 f9                	mov    %edi,%ecx
f0101bc2:	b8 20 00 00 00       	mov    $0x20,%eax
f0101bc7:	29 f8                	sub    %edi,%eax
f0101bc9:	d3 e2                	shl    %cl,%edx
f0101bcb:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101bcf:	89 c1                	mov    %eax,%ecx
f0101bd1:	89 da                	mov    %ebx,%edx
f0101bd3:	d3 ea                	shr    %cl,%edx
f0101bd5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101bd9:	09 d1                	or     %edx,%ecx
f0101bdb:	89 f2                	mov    %esi,%edx
f0101bdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101be1:	89 f9                	mov    %edi,%ecx
f0101be3:	d3 e3                	shl    %cl,%ebx
f0101be5:	89 c1                	mov    %eax,%ecx
f0101be7:	d3 ea                	shr    %cl,%edx
f0101be9:	89 f9                	mov    %edi,%ecx
f0101beb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101bef:	d3 e6                	shl    %cl,%esi
f0101bf1:	89 eb                	mov    %ebp,%ebx
f0101bf3:	89 c1                	mov    %eax,%ecx
f0101bf5:	d3 eb                	shr    %cl,%ebx
f0101bf7:	09 de                	or     %ebx,%esi
f0101bf9:	89 f0                	mov    %esi,%eax
f0101bfb:	f7 74 24 08          	divl   0x8(%esp)
f0101bff:	89 d6                	mov    %edx,%esi
f0101c01:	89 c3                	mov    %eax,%ebx
f0101c03:	f7 64 24 0c          	mull   0xc(%esp)
f0101c07:	39 d6                	cmp    %edx,%esi
f0101c09:	72 0c                	jb     f0101c17 <__udivdi3+0xb7>
f0101c0b:	89 f9                	mov    %edi,%ecx
f0101c0d:	d3 e5                	shl    %cl,%ebp
f0101c0f:	39 c5                	cmp    %eax,%ebp
f0101c11:	73 5d                	jae    f0101c70 <__udivdi3+0x110>
f0101c13:	39 d6                	cmp    %edx,%esi
f0101c15:	75 59                	jne    f0101c70 <__udivdi3+0x110>
f0101c17:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101c1a:	31 ff                	xor    %edi,%edi
f0101c1c:	89 fa                	mov    %edi,%edx
f0101c1e:	83 c4 1c             	add    $0x1c,%esp
f0101c21:	5b                   	pop    %ebx
f0101c22:	5e                   	pop    %esi
f0101c23:	5f                   	pop    %edi
f0101c24:	5d                   	pop    %ebp
f0101c25:	c3                   	ret    
f0101c26:	8d 76 00             	lea    0x0(%esi),%esi
f0101c29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0101c30:	31 ff                	xor    %edi,%edi
f0101c32:	31 c0                	xor    %eax,%eax
f0101c34:	89 fa                	mov    %edi,%edx
f0101c36:	83 c4 1c             	add    $0x1c,%esp
f0101c39:	5b                   	pop    %ebx
f0101c3a:	5e                   	pop    %esi
f0101c3b:	5f                   	pop    %edi
f0101c3c:	5d                   	pop    %ebp
f0101c3d:	c3                   	ret    
f0101c3e:	66 90                	xchg   %ax,%ax
f0101c40:	31 ff                	xor    %edi,%edi
f0101c42:	89 e8                	mov    %ebp,%eax
f0101c44:	89 f2                	mov    %esi,%edx
f0101c46:	f7 f3                	div    %ebx
f0101c48:	89 fa                	mov    %edi,%edx
f0101c4a:	83 c4 1c             	add    $0x1c,%esp
f0101c4d:	5b                   	pop    %ebx
f0101c4e:	5e                   	pop    %esi
f0101c4f:	5f                   	pop    %edi
f0101c50:	5d                   	pop    %ebp
f0101c51:	c3                   	ret    
f0101c52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101c58:	39 f2                	cmp    %esi,%edx
f0101c5a:	72 06                	jb     f0101c62 <__udivdi3+0x102>
f0101c5c:	31 c0                	xor    %eax,%eax
f0101c5e:	39 eb                	cmp    %ebp,%ebx
f0101c60:	77 d2                	ja     f0101c34 <__udivdi3+0xd4>
f0101c62:	b8 01 00 00 00       	mov    $0x1,%eax
f0101c67:	eb cb                	jmp    f0101c34 <__udivdi3+0xd4>
f0101c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101c70:	89 d8                	mov    %ebx,%eax
f0101c72:	31 ff                	xor    %edi,%edi
f0101c74:	eb be                	jmp    f0101c34 <__udivdi3+0xd4>
f0101c76:	66 90                	xchg   %ax,%ax
f0101c78:	66 90                	xchg   %ax,%ax
f0101c7a:	66 90                	xchg   %ax,%ax
f0101c7c:	66 90                	xchg   %ax,%ax
f0101c7e:	66 90                	xchg   %ax,%ax

f0101c80 <__umoddi3>:
f0101c80:	55                   	push   %ebp
f0101c81:	57                   	push   %edi
f0101c82:	56                   	push   %esi
f0101c83:	53                   	push   %ebx
f0101c84:	83 ec 1c             	sub    $0x1c,%esp
f0101c87:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0101c8b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101c8f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101c93:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101c97:	85 ed                	test   %ebp,%ebp
f0101c99:	89 f0                	mov    %esi,%eax
f0101c9b:	89 da                	mov    %ebx,%edx
f0101c9d:	75 19                	jne    f0101cb8 <__umoddi3+0x38>
f0101c9f:	39 df                	cmp    %ebx,%edi
f0101ca1:	0f 86 b1 00 00 00    	jbe    f0101d58 <__umoddi3+0xd8>
f0101ca7:	f7 f7                	div    %edi
f0101ca9:	89 d0                	mov    %edx,%eax
f0101cab:	31 d2                	xor    %edx,%edx
f0101cad:	83 c4 1c             	add    $0x1c,%esp
f0101cb0:	5b                   	pop    %ebx
f0101cb1:	5e                   	pop    %esi
f0101cb2:	5f                   	pop    %edi
f0101cb3:	5d                   	pop    %ebp
f0101cb4:	c3                   	ret    
f0101cb5:	8d 76 00             	lea    0x0(%esi),%esi
f0101cb8:	39 dd                	cmp    %ebx,%ebp
f0101cba:	77 f1                	ja     f0101cad <__umoddi3+0x2d>
f0101cbc:	0f bd cd             	bsr    %ebp,%ecx
f0101cbf:	83 f1 1f             	xor    $0x1f,%ecx
f0101cc2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101cc6:	0f 84 b4 00 00 00    	je     f0101d80 <__umoddi3+0x100>
f0101ccc:	b8 20 00 00 00       	mov    $0x20,%eax
f0101cd1:	89 c2                	mov    %eax,%edx
f0101cd3:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101cd7:	29 c2                	sub    %eax,%edx
f0101cd9:	89 c1                	mov    %eax,%ecx
f0101cdb:	89 f8                	mov    %edi,%eax
f0101cdd:	d3 e5                	shl    %cl,%ebp
f0101cdf:	89 d1                	mov    %edx,%ecx
f0101ce1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101ce5:	d3 e8                	shr    %cl,%eax
f0101ce7:	09 c5                	or     %eax,%ebp
f0101ce9:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101ced:	89 c1                	mov    %eax,%ecx
f0101cef:	d3 e7                	shl    %cl,%edi
f0101cf1:	89 d1                	mov    %edx,%ecx
f0101cf3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101cf7:	89 df                	mov    %ebx,%edi
f0101cf9:	d3 ef                	shr    %cl,%edi
f0101cfb:	89 c1                	mov    %eax,%ecx
f0101cfd:	89 f0                	mov    %esi,%eax
f0101cff:	d3 e3                	shl    %cl,%ebx
f0101d01:	89 d1                	mov    %edx,%ecx
f0101d03:	89 fa                	mov    %edi,%edx
f0101d05:	d3 e8                	shr    %cl,%eax
f0101d07:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101d0c:	09 d8                	or     %ebx,%eax
f0101d0e:	f7 f5                	div    %ebp
f0101d10:	d3 e6                	shl    %cl,%esi
f0101d12:	89 d1                	mov    %edx,%ecx
f0101d14:	f7 64 24 08          	mull   0x8(%esp)
f0101d18:	39 d1                	cmp    %edx,%ecx
f0101d1a:	89 c3                	mov    %eax,%ebx
f0101d1c:	89 d7                	mov    %edx,%edi
f0101d1e:	72 06                	jb     f0101d26 <__umoddi3+0xa6>
f0101d20:	75 0e                	jne    f0101d30 <__umoddi3+0xb0>
f0101d22:	39 c6                	cmp    %eax,%esi
f0101d24:	73 0a                	jae    f0101d30 <__umoddi3+0xb0>
f0101d26:	2b 44 24 08          	sub    0x8(%esp),%eax
f0101d2a:	19 ea                	sbb    %ebp,%edx
f0101d2c:	89 d7                	mov    %edx,%edi
f0101d2e:	89 c3                	mov    %eax,%ebx
f0101d30:	89 ca                	mov    %ecx,%edx
f0101d32:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101d37:	29 de                	sub    %ebx,%esi
f0101d39:	19 fa                	sbb    %edi,%edx
f0101d3b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0101d3f:	89 d0                	mov    %edx,%eax
f0101d41:	d3 e0                	shl    %cl,%eax
f0101d43:	89 d9                	mov    %ebx,%ecx
f0101d45:	d3 ee                	shr    %cl,%esi
f0101d47:	d3 ea                	shr    %cl,%edx
f0101d49:	09 f0                	or     %esi,%eax
f0101d4b:	83 c4 1c             	add    $0x1c,%esp
f0101d4e:	5b                   	pop    %ebx
f0101d4f:	5e                   	pop    %esi
f0101d50:	5f                   	pop    %edi
f0101d51:	5d                   	pop    %ebp
f0101d52:	c3                   	ret    
f0101d53:	90                   	nop
f0101d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101d58:	85 ff                	test   %edi,%edi
f0101d5a:	89 f9                	mov    %edi,%ecx
f0101d5c:	75 0b                	jne    f0101d69 <__umoddi3+0xe9>
f0101d5e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101d63:	31 d2                	xor    %edx,%edx
f0101d65:	f7 f7                	div    %edi
f0101d67:	89 c1                	mov    %eax,%ecx
f0101d69:	89 d8                	mov    %ebx,%eax
f0101d6b:	31 d2                	xor    %edx,%edx
f0101d6d:	f7 f1                	div    %ecx
f0101d6f:	89 f0                	mov    %esi,%eax
f0101d71:	f7 f1                	div    %ecx
f0101d73:	e9 31 ff ff ff       	jmp    f0101ca9 <__umoddi3+0x29>
f0101d78:	90                   	nop
f0101d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101d80:	39 dd                	cmp    %ebx,%ebp
f0101d82:	72 08                	jb     f0101d8c <__umoddi3+0x10c>
f0101d84:	39 f7                	cmp    %esi,%edi
f0101d86:	0f 87 21 ff ff ff    	ja     f0101cad <__umoddi3+0x2d>
f0101d8c:	89 da                	mov    %ebx,%edx
f0101d8e:	89 f0                	mov    %esi,%eax
f0101d90:	29 f8                	sub    %edi,%eax
f0101d92:	19 ea                	sbb    %ebp,%edx
f0101d94:	e9 14 ff ff ff       	jmp    f0101cad <__umoddi3+0x2d>

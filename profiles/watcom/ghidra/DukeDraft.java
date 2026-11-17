// Analysis aid only. Decompiled output is not recovered source or match evidence.
import ghidra.app.script.GhidraScript;
import ghidra.app.decompiler.*;
import ghidra.program.model.listing.*;
import ghidra.program.model.data.*;
import ghidra.program.model.symbol.SourceType;
import java.nio.file.*;
import java.io.*;

public class DukeDraft extends GhidraScript {
    private Function seed(long off, String name, boolean shortArg) throws Exception {
        var at=toAddr(0x10000L+off);
        disassemble(at);
        Function f=getFunctionAt(at);
        if(f==null) f=createFunction(at,name);
        f.setName(name,SourceType.USER_DEFINED);
        f.setReturnType(VoidDataType.dataType,SourceType.USER_DEFINED);
        f.setCustomVariableStorage(true);
        f.setStackPurgeSize(0);
        if(shortArg) {
            Parameter p=new ParameterImpl("snum",ShortDataType.dataType,
                new VariableStorage(currentProgram,currentProgram.getRegister("AX")),currentProgram);
            f.replaceParameters(Function.FunctionUpdateType.CUSTOM_STORAGE,true,SourceType.USER_DEFINED,p);
        }
        return f;
    }
    public void run() throws Exception {
        // Import object1.bin at 0x10000 with BinaryLoader, then map the two
        // remaining objects separately, preserving the unmapped LE gaps.
        Path input=Paths.get(getScriptArgs()[0]);
        int n=0;
        for(String line:Files.readAllLines(input.resolve("objects.tsv"))) {
            String[] fields=line.split("\\t");
            long base=Long.parseLong(fields[1],16);
            long size=Long.parseLong(fields[2]);
            int flags=Integer.parseInt(fields[3]);
            ghidra.program.model.mem.MemoryBlock block;
            if(n++==0) {
                block=currentProgram.getMemory().getBlock(toAddr(base));
                if(block==null || block.getSize()!=size) throw new IOException("wrong imported CODE extent");
            } else {
                try(InputStream in=Files.newInputStream(input.resolve(fields[0]))) {
                    block=currentProgram.getMemory().createInitializedBlock(
                        "LE_object"+n,toAddr(base),in,size,monitor,false);
                }
            }
            block.setRead((flags&1)!=0);
            block.setWrite((flags&2)!=0);
            block.setExecute((flags&4)!=0);
        }
        Function pal=seed(204096,"setpal_watcom",false);
        Parameter p=new ParameterImpl("player",new PointerDataType(ByteDataType.dataType),
            new VariableStorage(currentProgram,currentProgram.getRegister("EAX")),currentProgram);
        pal.replaceParameters(Function.FunctionUpdateType.CUSTOM_STORAGE,true,SourceType.USER_DEFINED,p);
        Function stats=seed(241632,"resetplayerstats",true);
        seed(242448,"resetweapons",true);
        seed(242624,"resetinventory",true);
        createLabel(toAddr(0xc0000L+376112),"ps",true);
        createLabel(toAddr(0xc0000L+579668),"ud",true);
        DecompInterface d=new DecompInterface();
        d.openProgram(currentProgram);
        var result=d.decompileFunction(stats,60,monitor);
        if(!result.decompileCompleted()) throw new RuntimeException(result.getErrorMessage());
        Files.writeString(Paths.get(getScriptArgs()[1],"resetplayerstats.c"),result.getDecompiledFunction().getC());
        d.dispose();
    }
}

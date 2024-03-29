//
// Copyright (c) 2016, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   02 Sep 16  Matthew Giannini  Creation
//

using compiler
using compiler::Compiler as FanCompiler

class NodeRunner
{

//////////////////////////////////////////////////////////////////////////
// Main
//////////////////////////////////////////////////////////////////////////

  Int main(Str[] args := Env.cur.args)
  {
    // check for nodejs
    if (!checkForNode) return 1

    try
    {
      parseArgs(args)
      initDirs
      if (hasArg("test")) doTest
      else if (hasArg("run")) doRun
      else if (isInit) doJsBootStrap
      else throw ArgErr("Invalid options")

      // cleanup
      if (!hasArg("keep") && !isInit) nodeDir.delete
    }
    catch (ArgErr e)
    {
      Env.cur.err.printLine("${e.msg}\n")
      help
      return 2
    }
    return 0
  }

  private Bool checkForNode()
  {
    cmd := ["which", "-s", "node"]
    if ("win32" == Env.cur.os) cmd = ["where", "node"]
    if (Process(cmd).run.join != 0)
    {
      Env.cur.err.printLine("Node not found")
      Env.cur.err.printLine("Please ensure Node.js is installed and available in your PATH")
      return false
    }
    return true
  }

  private Void help()
  {
    echo("NodeRunner")
    echo("Usage:")
    echo("  NodeRunner [options] -test <pod>[::<test>[.<method>]]")
    echo("  NodeRunner [options] -run <script>")
    echo("Options:")
    echo("  -keep      Keep intermediate test scripts")
  }

  private Bool isInit() { hasArg("init") }

  private Void initDirs()
  {
    this.nodeDir = Env.cur.tempDir + `nodeRunner/`
    if (hasArg("dir"))
      nodeDir = arg("dir").toUri.plusSlash.toFile
    else if (isInit)
      nodeDir = Env.cur.homeDir.plus(`lib/js/`)
    nodeDir = nodeDir.normalize
  }

//////////////////////////////////////////////////////////////////////////
// Args
//////////////////////////////////////////////////////////////////////////

  private Bool hasArg(Str n) { argsMap.containsKey(n) }

  private Str? arg(Str n) { argsMap[n] }

  private Void parseArgs(Str[] envArgs)
  {
    this.argsMap = Str:Str[:]

    // parse command lines arg "-key [val]"
    envArgs.each |s, i|
    {
      if (!s.startsWith("-") || s.size < 2) return
      name := s[1..-1]
      val  := "true"
      if (i+1 < envArgs.size && !envArgs[i+1].startsWith("-"))
        val = envArgs[i+1]
      this.argsMap[name] = val
    }
  }

//////////////////////////////////////////////////////////////////////////
// Test
//////////////////////////////////////////////////////////////////////////

  private Void doTest()
  {
    pod    := arg("test") ?: throw ArgErr("No test specified")
    type   := "*"
    method := "*"

    // check for type
    if (pod.contains("::"))
    {
      i := pod.index("::")
      type = pod[i+2..-1]
      pod  = pod[0..i-1]
    }

    // check for method
    if (type.contains("."))
    {
      i := type.index(".")
      method = type[i+1..-1]
      type   = type[0..i-1]
    }

    p := Pod.find(pod)
    sortDepends(p)
    writeNodeModules
    testRunner(p, type, method)
  }

  private Void testRunner(Pod pod, Str type, Str method)
  {
    template := this.typeof.pod.file(`/res/testRunnerTemplate.js`).readAllStr
    template = template.replace("//{{require}}", requireStatements)
    template = template.replace("//{{tests}}", testList(pod, type, method))
    template = template.replace("//{{envDirs}}", envDirs)

    // write test runner
    f := nodeDir + `testRunner.js`
    f.out.writeChars(template).flush.close

    // invoke node to run tests
    t1 := Duration.now
    Process(["node", "$f.normalize.osPath"]).run.join
    t2 := Duration.now

    echo("")
    echo("Time: ${(t2-t1).toMillis}ms")
    echo("")
  }

  private Str testList(Pod pod, Str type, Str method)
  {
    buf := StrBuf()
    buf.add("var tests = [\n")

    types := type == "*" ? pod.types : [pod.type(type)]
    types.findAll { it.fits(Test#) && it.hasFacet(Js#) }.each |t|
    {
      buf.add("  {'type': fan.${pod.name}.${t.name},\n")
         .add("   'qname': '${t.qname}',\n")
         .add("   'methods': [")
      methods(t, method).each { buf.add("'${it.name}',") } ; buf.add("]\n")
      buf.add("  },\n")
    }

    return buf.add("];\n").toStr
  }

  private Str envDirs()
  {
    buf := StrBuf()
    buf.add("    fan.sys.Env.cur().m_homeDir = fan.sys.File.os(${Env.cur.homeDir.pathStr.toCode});\n")
    buf.add("    fan.sys.Env.cur().m_workDir = fan.sys.File.os(${Env.cur.workDir.pathStr.toCode});\n")
    buf.add("    fan.sys.Env.cur().m_tempDir = fan.sys.File.os(${Env.cur.tempDir.pathStr.toCode});\n")
    return buf.toStr()
  }

  private Method[] methods(Type type, Str methodName)
  {
    return type.methods.findAll |Method m->Bool|
    {
      if (m.isAbstract) return false
      if (m.name.startsWith("test"))
      {
        if (methodName == "*") return true
        return methodName == m.name
      }
      return false
    }
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  private Void doRun()
  {
    file := arg("run").toUri.toFile
    if (!file.exists) { echo("$file not found"); return }
    this.js = compile(file.in.readAllStr)
    writeNodeModules
    template := this.typeof.pod.file(`/res/scriptRunnerTemplate.js`).readAllStr
    template = template.replace("//{{require}}", requireStatements)
    template = template.replace("{{tempPod}}", tempPod)
    template = template.replace("//{{envDirs}}", envDirs)

    // write test runner
    f := nodeDir + `scriptRunner.js`
    f.out.writeChars(template).flush.close

    // invoke node to run sript
    Process(["node", "$f.normalize.osPath"]).run.join
  }

  Str compile(Str text)
  {
    this.tempPod = "temp${DateTime.now.ticks}"
    input := CompilerInput()
    input.podName   = tempPod
    input.summary   = ""
    input.version   = Version("0")
    input.log.level = LogLevel.silent
    input.isScript  = true
    input.srcStr    = text
    input.srcStrLoc = Loc("")
    input.mode      = CompilerInputMode.str
    input.output    = CompilerOutputMode.transientPod

    // compile the source
    compiler := FanCompiler(input)
    CompilerOutput? co := null
    try co = compiler.compile; catch {}
    if (co == null)
    {
      buf := StrBuf()
      compiler.errs.each |err| { buf.add("$err.line:$err.col:$err.msg\n") }
      echo(buf)
      Env.cur.exit(-1)
    }

    this.dependencies = compiler.depends.map { Pod.find(it.name) }
    return compiler.js
  }

//////////////////////////////////////////////////////////////////////////
// Js
//////////////////////////////////////////////////////////////////////////

  private Void doJsBootStrap()
  {
    this.dependencies = [Pod.find("sys")]
    writeNodeModules
    writeTzJs

    f := moduleDir.plus(`fan.js`)
    f.out.writeChars(
      """let fan = require('sys.js');
         require('mime.js');
         require('units.js');
         require('tz.js');
         module.exports = fan;
         """).flush.close

    echo("JS init written to: ${nodeDir}")
  }

//////////////////////////////////////////////////////////////////////////
// Dependency Graphing
//////////////////////////////////////////////////////////////////////////

  private Void sortDepends(Pod p)
  {
    graph   := buildGraph(p)
    ordered := Pod[,]
    visited := Pod[,]
    path    := Pod[,]
    graph.keys.each |pod|
    {
      path.push(pod)
      while (!path.isEmpty)
      {
        cur := path.pop
        if (visited.contains(cur)) continue

        todo := graph[cur]

        if (todo.isEmpty)
        {
          ordered.add(cur)
          visited.add(cur)
        }
        else
        {
          path.push(cur)
          next := todo.pop
          if (path.contains(next)) throw Err("Circular dependency between ${cur} and ${next} : ${path}")
          path.push(next)
        }
      }
    }
    this.dependencies = ordered.findAll { isJsPod(it) }
  }

  private [Pod:Pod[]] buildGraph(Pod p, Pod:Pod[] graph := [:])
  {
    graph[p] = p.depends.map { Pod.find(it.name) }
    p.depends.each |d| { buildGraph(Pod.find(d.name), graph) }
    return graph
  }

  private Bool isJsPod(Pod pod)
  {
    return pod.file(`/${pod.name}.js`, false) != null
  }

//////////////////////////////////////////////////////////////////////////
// Node
//////////////////////////////////////////////////////////////////////////

  private File moduleDir() { nodeDir.plus(`node_modules/`) }

  ** Copy all pod js files into <nodeDir>/node_modules
  ** Also copies in mime.js, units.js, and indexed-props.js
  private Void writeNodeModules()
  {
    // write js from pod dependencies
    writeDependencies

    // (optional) temp pood
    if (tempPod != null)
      (moduleDir + `${tempPod}.js`).out.writeChars(js).flush.close

    writeMimeJs
    writeUnitsJs

    // indexed-props
    if (!isInit)
    {
      out := (moduleDir + `indexed-props.js`).out
      JsIndexedProps().write(out, dependencies)
      out.flush.close
    }
  }

  private Void writeDependencies()
  {
    copyOpts  := ["overwrite": true]

    dependencies.each |pod|
    {
      script := "${pod.name}.js"
      file   := pod.file(`/$script`, false)
      if (file != null)
        file.copyTo(moduleDir + `$script`, copyOpts)
    }
  }

  private Void writeMimeJs()
  {
    // mime.js
    out := (moduleDir + `mime.js`).out
    JsExtToMime().write(out)
    out.flush.close
  }

  private Void writeUnitsJs()
  {
    // units.js
    out := (moduleDir + `units.js`).out
    JsUnitDatabase().write(out)
    out.flush.close
  }

  private Void writeTzJs()
  {
    // tz.js
    TzTool(["-silent", "-gen", "-outDir", moduleDir.toStr]).run
  }

  private Str requireStatements()
  {
    buf := StrBuf()
    dependencies.each |pod|
    {
      if ("sys" == pod.name)
      {
        buf.add("var fan = require('${pod.name}.js');\n")
        buf.add("require('mime.js');\n")
        buf.add("require('units.js');\n")
        buf.add("require('indexed-props.js');\n")
      }
      else buf.add("require('${pod.name}.js');\n")
    }

    if (tempPod != null)
      buf.add("require('${tempPod}.js');\n")

    return buf.toStr
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private [Str:Str]? argsMap      // parseArgs
  private File? nodeDir           // initDirs
  private Pod[]? dependencies     // sortDepends, compile
  private Str? tempPod            // compile
  private Str? js                 // compile
}

if (sim_call_type==sim.syscb_init) then 
    -- Make sure we have version 2.4.13 or above (the particles are not supported otherwise)
    v=sim.getInt32Parameter(sim.intparam_program_version)
    if (v<20413) then
        sim.displayDialog('Warning','The propeller model is only fully supported from V-REP version 2.4.13 and above.&&nThis simulation will not run as expected!',sim.dlgstyle_ok,false,'',nil,{0.8,0,0,0,0,0})
    end

    -- Detatch the manipulation sphere:
    targetObj=sim.getObjectHandle('Quadricopter_target')
    sim.setObjectParent(targetObj,-1,true)

    -- This control algo was quickly written and is dirty and not optimal. It just serves as a SIMPLE example

    d=sim.getObjectHandle('Quadricopter_base')
    quad=sim.getObjectHandle('Quadricopter')

    particlesAreVisible=sim.getScriptSimulationParameter(sim.handle_self,'particlesAreVisible')
    sim.setScriptSimulationParameter(sim.handle_tree,'particlesAreVisible',tostring(particlesAreVisible))
    simulateParticles=sim.getScriptSimulationParameter(sim.handle_self,'simulateParticles')
    sim.setScriptSimulationParameter(sim.handle_tree,'simulateParticles',tostring(simulateParticles))

    propellerScripts={-1,-1,-1,-1}
    for i=1,4,1 do
        propellerScripts[i]=sim.getScriptHandle('Quadricopter_propeller_respondable'..i)
        sim.setScriptSimulationParameter(propellerScripts[i],'particleVelocity',0)
    end


    fakeShadow=sim.getScriptSimulationParameter(sim.handle_self,'fakeShadow')
    if (fakeShadow) then
        shadowCont=sim.addDrawingObject(sim.drawing_discpoints+sim.drawing_cyclic+sim.drawing_25percenttransparency+sim.drawing_50percenttransparency+sim.drawing_itemsizes,0.2,0,-1,1)
        shadowContTarget=sim.addDrawingObject(sim.drawing_discpoints+sim.drawing_cyclic+sim.drawing_25percenttransparency+sim.drawing_50percenttransparency+sim.drawing_itemsizes,0.2,0,-1,1)
    end

    str=sim.packFloatTable({0,0,0,0})
    sim.setStringSignal("rotorTargetVelocities", str)
    forcefunctions = true
    forcefunc = 1--2

end 

if (sim_call_type==sim.syscb_cleanup) then 
    sim.removeDrawingObject(shadowCont)
end 

if (sim_call_type==sim.syscb_actuation) then 
    s=sim.getObjectSizeFactor(d)
    
    pos=sim.getObjectPosition(d,-1)
    
    if (fakeShadow) then
        itemData={pos[1],pos[2],0.002,0,0,1,0.2*s}
        sim.addDrawingObjectItem(shadowCont,itemData)

        -- Draw shadow for target
        targetPos=sim.getObjectPosition(targetObj,-1)
        itemData={targetPos[1],targetPos[2],0.002,0,0,1,0.1*s}
        sim.addDrawingObjectItem(shadowContTarget,itemData)
    end

    -- Send the desired motor velocities to the 4 rotors:
    data=sim.getStringSignal("rotorTargetVelocities")

    power = 0
    if (data ~= nil) then
        vector=sim.unpackFloatTable(data)
        if (vector[1] ~= nil) then
            power = vector[1]
        end
    end

    -- which external forcing functions to use
    -- 0 will use no forcing functions
    forcefunc=sim.getIntegerSignal("ForceFunction")
    

    if (data ~= nil) then
        vector=sim.unpackFloatTable(data)
        if (vector[1] ~= nil) then
            for i=1,4,1 do
                sim.setScriptSimulationParameter(propellerScripts[i],'particleVelocity',vector[i] + power)
            end
        end
    end

    -- Retrive signals from vrep_gui.py
    --mass=sim.getIntegerSignal("mass")
    --print(mass)
    --sim.setShapeMassAndInertia(sim.handle_self, mass)

end 

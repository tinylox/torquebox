package org.torquebox.core.runtime;

import org.jboss.msc.service.Service;
import org.jboss.msc.service.StartContext;
import org.jboss.msc.service.StartException;
import org.jboss.msc.service.StopContext;

public class RubyRuntimeFactoryService implements Service<RubyRuntimeFactory>{
    

    public RubyRuntimeFactoryService(RubyRuntimeFactoryImpl factory) {
        this.factory = factory;
    }

    @Override
    public RubyRuntimeFactory getValue() throws IllegalStateException, IllegalArgumentException {
        return this.factory;
    }

    @Override
    public void start(StartContext context) throws StartException {
        this.factory.create();
    }

    @Override
    public void stop(StopContext context) {
        this.factory.destroy();
        
    }
    
    private RubyRuntimeFactoryImpl factory;


}

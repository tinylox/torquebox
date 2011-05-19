package org.torquebox.core.as.services;

import org.jboss.msc.inject.Injector;
import org.jboss.msc.service.Service;
import org.jboss.msc.service.StartContext;
import org.jboss.msc.service.StartException;
import org.jboss.msc.service.StopContext;
import org.jboss.msc.value.InjectedValue;
import org.torquebox.core.runtime.DefaultRubyRuntimePool;
import org.torquebox.core.runtime.RubyRuntimeFactory;
import org.torquebox.core.runtime.RubyRuntimePool;

public class DefaultRubyRuntimePoolService implements Service<RubyRuntimePool>{

    public DefaultRubyRuntimePoolService(DefaultRubyRuntimePool pool) {
        this.pool = pool;
    }
    
    @Override
    public RubyRuntimePool getValue() throws IllegalStateException, IllegalArgumentException {
        return pool;
    }

    @Override
    public void start(StartContext context) throws StartException {
        this.pool.setInstanceFactory( this.runtimeFactoryInjector.getValue() );
    }

    @Override
    public void stop(StopContext context) {
        this.pool.setInstanceFactory( null );
    }
    
    public Injector<RubyRuntimeFactory> getRubyRuntimeFactoryInjector() {
        return this.runtimeFactoryInjector;
    }
    
    private InjectedValue<RubyRuntimeFactory> runtimeFactoryInjector = new InjectedValue<RubyRuntimeFactory>();
    private DefaultRubyRuntimePool pool;


}
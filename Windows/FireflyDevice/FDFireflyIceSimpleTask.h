//
//  FDFireflyIceSimpleTask.h
//  FireflyDevice
//
//  Created by Denis Bohm on 10/17/13.
//  Copyright (c) 2013-2014 Firefly Design LLC / Denis Bohm. All rights reserved.
//

#ifndef FDFIREFLYICESIMPLETASK_H
#define FDFIREFLYICESIMPLETASK_H

#include "FDFireflyIceTaskSteps.h"

#include <functional>
#include <memory>

namespace fireflydesign {

	class FDFireflyIceSimpleTask : public FDFireflyIceTaskSteps {
	public:
		FDFireflyIceSimpleTask(std::shared_ptr<FDFireflyIce> fireflyIce, std::shared_ptr<FDFireflyIceChannel> channel, std::function<void(void)> block);

	public:
		virtual void executorTaskStarted(FDExecutor *executor);

	private:
		void complete();

		std::function<void(void)> _block;
	};

}

#endif
